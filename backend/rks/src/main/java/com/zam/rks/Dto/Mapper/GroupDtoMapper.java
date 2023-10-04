package com.zam.rks.Dto.Mapper;

import com.zam.rks.Dto.GroupDto;
import com.zam.rks.model.Group;

import java.util.List;
import java.util.stream.Collectors;

public class GroupDtoMapper {

	private GroupDtoMapper() {
	}

	public static List<GroupDto> mapGroupsToDto(List<Group> groups) {
		return groups.stream().map(GroupDtoMapper::mapToDto).collect(Collectors.toList());
	}

	public static GroupDto mapToDto(Group group) {
		return GroupDto.builder()
				.id(group.getId())
				.name(group.getName())
				.build();
	}
}
