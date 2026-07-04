package com.study.service.impl;

import com.study.entity.TicketDTO;
import com.study.mapper.TicketMapper;
import com.study.service.TicketService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class TicketServiceImpl implements TicketService {

    @Autowired
    private TicketMapper ticketMapper;

    @Override
    public String buyTicket(Integer userId, Integer eventId) {
        Map<String, Object> params = new HashMap<>();
        params.put("userId", userId);
        params.put("eventId", eventId);
        
        ticketMapper.buyTicket(params);
        
        return (String) params.get("status");
    }

    @Override
    public String refundTicket(Integer orderId) {
        Map<String, Object> params = new HashMap<>();
        params.put("orderId", orderId);
        
        ticketMapper.refundTicket(params);
        
        return (String) params.get("status");
    }

	@Override
	public List<TicketDTO> getMyTickets(Integer userId) {
		// TODO Auto-generated method stub
		return ticketMapper.selectMyTickets(userId);
	}
}