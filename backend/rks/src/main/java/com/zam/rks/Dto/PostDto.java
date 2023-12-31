package com.zam.rks.Dto;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class PostDto {
	private int id;
	private String content;
	private String date;
	private UserDto user;
	private EventBasicDto event;

}
