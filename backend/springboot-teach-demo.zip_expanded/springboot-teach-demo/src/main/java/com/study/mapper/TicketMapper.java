package com.study.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Options;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.mapping.StatementType;

import com.study.entity.TicketDTO;

import java.util.List;
import java.util.Map;

@Mapper
public interface TicketMapper {
	
    // 调用购票存储过程
    // 注意这里的语法：明确指定模式为 IN 或 OUT，并指定对应的 jdbcType
    @Select("CALL proc_buy_ticket(" +
            "#{userId, mode=IN, jdbcType=INTEGER}, " +
            "#{eventId, mode=IN, jdbcType=INTEGER}, " +
            "#{status, mode=OUT, jdbcType=VARCHAR})")
    @Options(statementType = StatementType.CALLABLE)
    void buyTicket(Map<String, Object> params);
    
 // 1. 查询票夹（复用你的视图，对齐 OrderID 和 OrderStatus）
    @Select("SELECT " +
            "  t.OrderID AS ticketId, " +
            "  t.EventID AS eventId, " +
            "  e.EventTitle AS eventTitle, " +
            "  e.StartTime AS startTime, " +
            "  e.VenueName AS venueName, " +
            "  t.OrderStatus AS status " +
            "FROM Ticket t " +
            "LEFT JOIN view_event_details e ON t.EventID = e.EventID " +
            "WHERE t.UserID = #{userId} " +
            "ORDER BY t.OrderID DESC")
    List<TicketDTO> selectMyTickets(Integer userId);
    
    // 调用退票存储过程
    @Select("CALL proc_refund_ticket(" +
            "#{orderId, mode=IN, jdbcType=INTEGER}, " +
            "#{status, mode=OUT, jdbcType=VARCHAR})")
    @Options(statementType = StatementType.CALLABLE)
    void refundTicket(Map<String, Object> params);
}