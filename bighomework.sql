-- 触发器控制下的添加操作
DELIMITER //
CREATE TRIGGER trg
BEFORE INSERT ON Ticket
FOR EACH ROW
BEGIN
    DECLARE current_avail INT;
    SELECT AvailTix INTO current_avail 
    FROM Event 
    WHERE EventID = NEW.EventID;
    IF current_avail <= 0 THEN -- 没票了抛出异常
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = '触发器拦截：该活动已售罄！';
    ELSE
        UPDATE Event   -- 有票
        SET AvailTix = AvailTix - 1 
        WHERE EventID = NEW.EventID;
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE proc_buy_ticket(
    IN p_UserID INT,
    IN p_EventID INT,
    OUT p_Status VARCHAR(20)
)
BEGIN
    DECLARE v_AvailTix INT;
    START TRANSACTION;
    SELECT AvailTix INTO v_AvailTix
    FROM Event
    WHERE EventID = p_EventID
    FOR UPDATE;
    IF v_AvailTix > 0 THEN
        INSERT INTO Ticket (OrderTime, OrderStatus, EventID, UserID) 
        VALUES (NOW(), 'Paid', p_EventID, p_UserID);
        COMMIT;
        SET p_Status = 'Success';
    ELSE
        ROLLBACK;
        SET p_Status = 'Sold Out';
    END IF;
END //
DELIMITER ;

-- 修改 Ticket 表，让 OrderID 成为自动递增的主键
ALTER TABLE Ticket MODIFY COLUMN OrderID INT AUTO_INCREMENT;

-- 触发器控制下的添加操作end

-- 含有事务应用的删除操作
DELIMITER //
-- 创建包含状态校验与时间校验的退票存储过程
CREATE PROCEDURE proc_refund_ticket(
    IN p_OrderID INT,
    OUT p_Status VARCHAR(20)
)
BEGIN
    DECLARE v_EventID INT;
    DECLARE v_OrderStatus VARCHAR(20);
    DECLARE v_EndTime DATETIME;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_Status = 'System Error';
    END;
    START TRANSACTION;
    SELECT EventID, OrderStatus INTO v_EventID, v_OrderStatus
    FROM Ticket
    WHERE OrderID = p_OrderID
    FOR UPDATE; 
    IF v_EventID IS NULL THEN -- 订单不存在
        ROLLBACK;
        SET p_Status = 'Order Not Found';
    ELSEIF v_OrderStatus <> 'Paid' THEN  -- 订单状态是不是“已支付”
        ROLLBACK;
        SET p_Status = 'Wrong Status';
    ELSE
        SELECT EndTime INTO v_EndTime -- 查询该活动的结束时间
        FROM Event
        WHERE EventID = v_EventID;
        IF v_EndTime <= NOW() THEN -- 判断活动是否已经结束
            ROLLBACK;
            SET p_Status = 'Event Ended';
        ELSE
            -- 执行退票流程
            DELETE FROM Ticket WHERE OrderID = p_OrderID;
            UPDATE Event SET AvailTix = AvailTix + 1 WHERE EventID = v_EventID;
            COMMIT;
            SET p_Status = 'Refund Success';
        END IF;
    END IF;
END //
DELIMITER ;

-- 存储过程控制下的更新操作
DELIMITER //
CREATE PROCEDURE proc_complete_event_tickets(
    IN p_EventID INT,
    OUT p_AffectedRows INT
)
BEGIN
    DECLARE v_EndTime DATETIME;
    SELECT EndTime INTO v_EndTime 
    FROM Event 
    WHERE EventID = p_EventID;
    -- 判断是否违规
    IF v_EndTime > NOW() THEN
        SIGNAL SQLSTATE '45000'  -- 用户自定义异常的状态码
        SET MESSAGE_TEXT = '该活动尚未结束';
    ELSE
        UPDATE Ticket 
        NATURAL JOIN Event
        SET Ticket.OrderStatus = 'Completed'
        WHERE Event.EventID = p_EventID
          AND Ticket.OrderStatus = 'Paid';
          
        SET p_AffectedRows = ROW_COUNT();
    END IF;
END //
DELIMITER ;
drop view view_event_details;
-- 含有视图的查询操作
CREATE VIEW view_event_details AS
SELECT 
    EventID,         
    Title AS EventTitle, 
    StartTime,
    AvailTix,
    EventType,
    OrgName AS OrganizerName,
    Venuename AS VenueName,
    Location AS VenueLocation
FROM Event 
NATURAL JOIN Organizers  
NATURAL JOIN Venue;    

