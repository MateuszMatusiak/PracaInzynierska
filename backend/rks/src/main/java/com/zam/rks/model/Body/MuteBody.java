package com.zam.rks.model.Body;

import lombok.Getter;

@Getter
public class MuteBody {
	private Integer mutedUserId;
	private Integer hour;
	private Integer minutes;
	private String chatRoomFirebaseId;

}
