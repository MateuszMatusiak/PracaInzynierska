package com.zam.rks.Dto;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class NotificationDto {
	private int id;
	private String title;
	private String body;
	private boolean read;
}
