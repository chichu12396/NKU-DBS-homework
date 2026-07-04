select * from student
-- 触发器验证
-- 定义一个变量来接收返回状态
SET @result_status = '';
-- 调用存储过程，模拟 User 1 购买 Event 1 的票
CALL proc_buy_ticket(1, 1, @result_status);
-- 查看返回结果（看看是 Success 还是 Sold Out）
SELECT @result_status;
-- 去查看 Event 表，看看 AvailTix 是不是自动变成 99 了！
SELECT * FROM Event WHERE EventID = 1;
-- 插入一个没有余票的活动（假设 EventID = 88，AvailTix = 0）
INSERT INTO Event (EventID, OrganizerId, VenueID, Title, StartTime, EndTime, TotalCapacity, AvailTix, EventType) 
VALUES (88, 1, 1, '极其火爆的讲座', '2026-10-01 10:00:00', '2026-10-01 12:00:00', 100, 0, 'Lecture');
-- 试图绕过一切，直接向 Ticket 表强行插入一张 EventID = 88 的票
INSERT INTO Ticket (OrderTime, OrderStatus, EventID, UserID) 
VALUES (NOW(), 'Paid', 88, 1);
-- 删除验证
SELECT * FROM Event WHERE EventID = 1;
SELECT * FROM Ticket;
SET @refund_status = '';
-- 传入要删除的订单号（例如 1），尝试退票
CALL proc_refund_ticket(1, @refund_status);
-- 查看事务执行结果
SELECT @refund_status;

-- 存储过程验证
-- 插入活动 A（已过期，EventID=99）
INSERT INTO Event (EventID, OrganizerId, VenueID, Title, StartTime, EndTime, TotalCapacity, AvailTix, EventType) 
VALUES (99, 1, 1, '已结束的讲座', '2020-01-01 10:00:00', '2020-01-01 12:00:00', 100, 50, 'Lecture');

-- 插入活动 B（未来的活动，还没结束，EventID=100）
-- 注意：EndTime 设到了 2099 年
INSERT INTO Event (EventID, OrganizerId, VenueID, Title, StartTime, EndTime, TotalCapacity, AvailTix, EventType) 
VALUES (100, 1, 1, '未来的跨年演唱会', '2099-12-31 20:00:00', '2099-12-31 23:59:00', 100, 50, 'Performances');

-- 分别给它们造两张票
INSERT INTO Ticket (OrderTime, OrderStatus, EventID, UserID) VALUES (NOW(), 'Paid', 99, 1);
INSERT INTO Ticket (OrderTime, OrderStatus, EventID, UserID) VALUES (NOW(), 'Paid', 100, 1);
-- 展示当前这几张票的状态还是 'Paid'
SELECT OrderID, OrderStatus, EventID FROM Ticket WHERE EventID = 100;
SET @updated_count = 0;
-- 传入我们要结算的活动 ID (99\100)
CALL proc_complete_event_tickets(100, @updated_count);
-- 展示成功更新了多少张票 (应该返回 2)
SELECT @updated_count AS '成功结算的订单数';
-- 再次查询这些票，展示它们的状态已经自动变成了 'Completed'
SELECT OrderID, OrderStatus, EventID FROM Ticket WHERE EventID = 100;

-- 视图查询
select * from event;
select * from ticket;
select * from lecture;
select * from user;
SELECT * FROM view_event_details WHERE AvailTix > 0;