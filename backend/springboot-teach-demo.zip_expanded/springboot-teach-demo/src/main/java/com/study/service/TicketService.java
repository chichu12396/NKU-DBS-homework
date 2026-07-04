package com.study.service;
import com.study.entity.TicketDTO; 
import java.util.List;
public interface TicketService {
    // 购票业务
    String buyTicket(Integer userId, Integer eventId);
    
    // 退票业务
    String refundTicket(Integer orderId);
    List<TicketDTO> getMyTickets(Integer userId);
}