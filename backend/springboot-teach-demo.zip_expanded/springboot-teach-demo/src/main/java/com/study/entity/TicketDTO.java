package com.study.entity;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class TicketDTO {
    private Integer ticketId;
    private Integer eventId;
    private String eventTitle;
    private LocalDateTime startTime;
    private String venueName;
    private String status; // 状态：Paid, Unpaid, Completed
}