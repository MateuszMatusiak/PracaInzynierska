package com.zam.rks.Dto.Mapper;

import com.zam.rks.Dto.MapBasicDto;
import com.zam.rks.Dto.MapDto;
import com.zam.rks.model.MapModel;

import java.util.List;
import java.util.stream.Collectors;

public class MapDtoMapper {

	public static List<MapDto> mapMapModelToDto(List<MapModel> models) {
		return models.stream().map(MapDtoMapper::mapToDto).collect(Collectors.toList());
	}

	public static MapDto mapToDto(MapModel model) {
		if (model == null)
			return null;
		return MapDto.builder()
				.id(model.getId())
				.name(model.getName())
				.latitude(model.getLatitude())
				.longitude(model.getLongitude())
				.type(model.getType() == null ? "" : model.getType().toString())
				.events(EventDtoMapper.mapEventsToBasicDto(model.getEvents()))
				.build();
	}

	public static List<MapBasicDto> mapMapModelToBasicDto(List<MapModel> models) {
		return models.stream().map(MapDtoMapper::mapToBasicDto).collect(Collectors.toList());
	}

	public static MapBasicDto mapToBasicDto(MapModel model) {
		if (model == null)
			return null;
		return MapBasicDto.builder()
				.id(model.getId())
				.name(model.getName())
				.latitude(model.getLatitude())
				.longitude(model.getLongitude())
				.type(model.getType() == null ? "" : model.getType().toString())
				.build();
	}
}
