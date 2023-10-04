package com.zam.rks.Dto.Mapper;

import com.zam.rks.Dto.NotificationDto;
import com.zam.rks.model.NotificationModel;

import java.util.List;

public class NotificationDtoMapper {
	public static List<NotificationDto> map(List<NotificationModel> models) {
		return models.stream().map(NotificationDtoMapper::mapToDto).toList();
	}

	public static NotificationDto mapToDto(NotificationModel model) {
		return NotificationDto.builder()
				.id(model.getId())
				.title(model.getTitle())
				.body(model.getBody())
				.read(model.isSeen())
				.build();
	}
}
