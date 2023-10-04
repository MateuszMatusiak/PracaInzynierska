package com.zam.rks.model.Body;

import lombok.Getter;

import java.util.List;

@Getter
public class ChatRoomBody {
	private String name;
	private String firebaseId;
	private String imageUrl;
	private List<Integer> usersIds;

}
