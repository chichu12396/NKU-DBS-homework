package com.study.service.impl;
import com.study.entity.Event;
import com.study.entity.EventDetailsDTO;
import com.study.mapper.EventMapper;
import com.study.service.EventService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class EventServiceImpl implements EventService {

    @Autowired
    private EventMapper eventMapper;

    @Override
    public List<EventDetailsDTO> getAvailableEvents() {
        return eventMapper.getAvailableEventsFromView();
    }

    @Override
    public Integer completeEventTickets(Integer eventId) {
        Map<String, Object> params = new HashMap<>();
        params.put("eventId", eventId);
        
        eventMapper.completeEventTickets(params);
        
        // 更新了多少条订单
        return (Integer) params.get("affectedRows");
    }
    
    @Override
    public boolean addEvent(Event event) {
 
        if (event.getAvailTix() == null) {
            event.setAvailTix(event.getTotalCapacity());
        }
        
        int rows = eventMapper.insertEvent(event);
        return rows > 0;
    }

    // 删除活动
    @Override
    public boolean removeEvent(Integer eventId) {
        int rows = eventMapper.deleteEvent(eventId);
        return rows > 0;
    }

	@Override
	public EventDetailsDTO getEventDetailById(Integer eventId) {
		return eventMapper.selectEventDetailById(eventId);
	}
}