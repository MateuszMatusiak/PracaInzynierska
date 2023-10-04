package com.zam.rks.Dto;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class MessageDto {
	private int id;
	private String message;
	private String time;
	private UserDto author;

}
