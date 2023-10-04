package com.zam.rks.Dto.Mapper;

import com.zam.rks.Dto.MessageDto;
import com.zam.rks.model.ChatMessage;

import java.util.List;
import java.util.stream.Collectors;

public class MessageDtoMapper {
	public static List<MessageDto> mapMessagesToDto(List<ChatMessage> model) {
		return model.stream().map(MessageDtoMapper::mapToDto).collect(Collectors.toList());
	}

	public static MessageDto mapToDto(ChatMessage model) {
		return MessageDto.builder()
				.id(model.getId())
				.message(model.getMessage())
				.time(model.getTime().toString())
				.author(UserDtoMapper.mapToDto(model.getAuthor()))
				.build();
	}
}
