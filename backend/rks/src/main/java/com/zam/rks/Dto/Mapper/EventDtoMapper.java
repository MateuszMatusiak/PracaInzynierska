package com.zam.rks.Dto.Mapper;

import com.zam.rks.Dto.EventBasicDto;
import com.zam.rks.Dto.EventDto;
import com.zam.rks.Dto.EventExtDto;
import com.zam.rks.Utils.Date;
import com.zam.rks.model.Event;

import java.util.List;
import java.util.stream.Collectors;

public class EventDtoMapper {

	private EventDtoMapper() {
	}

	public static List<EventDto> mapEventsToDto(List<Event> events) {
		return events.stream().map(EventDtoMapper::mapToDto).collect(Collectors.toList());
	}

	public static EventDto mapToDto(Event event) {
		if (event == null) {
			return null;
		}
		return EventDto.builder()
				.id(event.getId())
				.name(event.getName())
				.description(event.getDescription())
				.startDate(new Date(event.getStartDate()).toString())
				.endDate(new Date(event.getEndDate()).toString())
				.users(UserDtoMapper.mapUsersToDto(event.getUsers()))
				.creator(UserDtoMapper.mapToDto(event.getCreator()))
				.build();
	}

	public static List<EventExtDto> mapEventsToExtDto(List<Event> events) {
		return events.stream().map(EventDtoMapper::mapToExtDto).collect(Collectors.toList());
	}

	public static EventExtDto mapToExtDto(Event event) {
		return EventExtDto.builder()
				.id(event.getId())
				.name(event.getName())
				.description(event.getDescription())
				.startDate(new Date(event.getStartDate()).toString())
				.endDate(new Date(event.getEndDate()).toString())
				.localization(MapDtoMapper.mapToBasicDto(event.getLocalization()))
				.users(UserDtoMapper.mapUsersToDto(event.getUsers()))
				.creator(UserDtoMapper.mapToDto(event.getCreator()))
				.build();
	}

	public static List<EventBasicDto> mapEventsToBasicDto(List<Event> events) {
		return events.stream().map(EventDtoMapper::mapBasicToDto).collect(Collectors.toList());
	}

	public static EventBasicDto mapBasicToDto(Event event) {
		if (event == null) {
			return null;
		}
		return EventBasicDto.builder()
				.id(event.getId())
				.name(event.getName())
				.description(event.getDescription())
				.startDate(new Date(event.getStartDate()).toString())
				.endDate(new Date(event.getEndDate()).toString())
				.creator(UserDtoMapper.mapToDto(event.getCreator()))
				.build();
	}
}
