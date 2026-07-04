package com.study.service;
import com.study.entity.Event;
import com.study.entity.EventDetailsDTO;
import java.util.List;

public interface EventService {
    // 获取首页活动列表（查视图）
    List<EventDetailsDTO> getAvailableEvents();
    
    // 结算过期活动订单
    Integer completeEventTickets(Integer eventId);
    boolean addEvent(Event event);

    boolean removeEvent(Integer eventId);

	EventDetailsDTO getEventDetailById(Integer eventId);
}