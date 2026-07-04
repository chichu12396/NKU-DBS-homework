package com.study.entity;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class EventDetailsDTO {
    private Integer eventId;
    private String eventTitle;
    private LocalDateTime startTime;
    private Integer availTix;
    private String eventType;
    private String organizerName;
    private String venueName;
    private String venueLocation;
}