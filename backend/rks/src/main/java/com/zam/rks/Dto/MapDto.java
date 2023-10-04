package com.zam.rks.Dto;

import lombok.Builder;
import lombok.Getter;

import java.io.Serializable;
import java.util.List;

@Getter
@Builder
public class MapDto implements Serializable {
	private int id;
	private String name;
	private double latitude;
	private double longitude;
	private String type;
	List<EventBasicDto> events;
}
