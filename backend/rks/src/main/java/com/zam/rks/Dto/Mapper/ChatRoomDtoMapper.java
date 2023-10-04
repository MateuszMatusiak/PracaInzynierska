package com.zam.rks.Dto.Mapper;

import com.zam.rks.Dto.ChatRoomDto;
import com.zam.rks.Utils.Date;
import com.zam.rks.model.ChatRoom;

import java.util.List;
import java.util.stream.Collectors;

public class ChatRoomDtoMapper {
	private ChatRoomDtoMapper() {
	}

	public static List<ChatRoomDto> mapChatRoomsToDto(List<ChatRoom> chatRooms) {
		return chatRooms.stream().map(ChatRoomDtoMapper::mapToDto).collect(Collectors.toList());
	}

	public static ChatRoomDto mapToDto(ChatRoom chatRoom) {
		return ChatRoomDto.builder()
				.id(chatRoom.getId())
				.name(chatRoom.getName())
				.firebaseId(chatRoom.getFirebaseId())
				.creationDate(new Date(chatRoom.getCreationDate()).toString())
				.creator(UserDtoMapper.mapToDto(chatRoom.getCreator()))
				.users(UserDtoMapper.mapUsersToDto(chatRoom.getUsers()))
				.imageUrl(chatRoom.getImageUrl())
				.build();
	}
}
