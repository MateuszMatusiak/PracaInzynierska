package com.zam.rks.model.Body;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class NotificationRequest {
	private String title;
	private String body;
	private String token;
}