package com.study.mapper;
import com.study.entity.Event;
import com.study.entity.EventDetailsDTO;

import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Options;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.mapping.StatementType;
import java.util.List;
import java.util.Map;

@Mapper
public interface EventMapper {

    // 直接把你 SQL 里的查询视图操作搬过来
    // 这个接口可以提供给前端首页，拉取所有还有余票的活动
    @Select("SELECT * FROM view_event_details WHERE AvailTix >= 0")
    List<EventDetailsDTO> getAvailableEventsFromView();
    //根据活动ID查询单个活动的详细视图信息
    @Select("SELECT " +
            "  EventID AS eventId, " +
            "  EventTitle AS eventTitle, " +
            "  StartTime AS startTime, " +
            "  AvailTix AS availTix, " +
            "  EventType AS eventType, " +
            "  OrganizerName AS organizerName, " +
            "  VenueName AS venueName, " +
            "  VenueLocation AS venueLocation " +
            "FROM view_event_details " +
            "WHERE EventID = #{eventId}")
    EventDetailsDTO selectEventDetailById(Integer eventId);
    
    // 调用过期活动结算的存储过程
    @Select("CALL proc_complete_event_tickets(" +
            "#{eventId, mode=IN, jdbcType=INTEGER}, " +
            "#{affectedRows, mode=OUT, jdbcType=INTEGER})")
    @Options(statementType = StatementType.CALLABLE)
    void completeEventTickets(Map<String, Object> params);
    
    @Insert("INSERT INTO Event (EventID, OrganizerId, VenueID, Title, StartTime, EndTime, TotalCapacity, AvailTix, EventType) " +
            "VALUES (#{eventId}, #{organizerId}, #{venueId}, #{title}, #{startTime}, #{endTime}, #{totalCapacity}, #{availTix}, #{eventType})")
    int insertEvent(Event event);

    //下架/删除活动 (删除操作)
    @Delete("DELETE FROM Event WHERE EventID = #{eventId}")
    int deleteEvent(Integer eventId);
}