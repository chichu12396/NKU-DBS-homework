package com.study.entity;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class Ticket {
    private Integer orderId;
    private Integer eventId;
    private Integer userId;
    private LocalDateTime orderTime;
    private String seatNumber;
    private String orderStatus;
}