package com.study.entity;

import lombok.Data;

@Data
public class Venue {
    private Integer venueId;
    private String venuename;
    private String location;
    private Integer maxCapacity;
}