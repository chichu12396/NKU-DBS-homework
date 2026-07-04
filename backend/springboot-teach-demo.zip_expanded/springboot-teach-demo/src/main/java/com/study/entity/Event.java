package com.study.entity;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class Event {
    private Integer eventId;
    private Integer organizerId;
    private Integer venueId;
    private String title;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private Integer totalCapacity;
    private Integer availTix;
    private String eventType;
}