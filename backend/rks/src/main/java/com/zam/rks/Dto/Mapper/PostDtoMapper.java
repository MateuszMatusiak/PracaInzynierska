package com.zam.rks.Dto.Mapper;

import com.zam.rks.Dto.PostDto;
import com.zam.rks.model.Post;

import java.util.List;
import java.util.stream.Collectors;

public class PostDtoMapper {
	public static List<PostDto> mapPostsToDto(List<Post> models) {
		return models.stream().map(PostDtoMapper::mapToDto).collect(Collectors.toList());
	}

	public static PostDto mapToDto(Post model) {
		return PostDto.builder()
				.id(model.getId())
				.content(model.getContent())
				.date(model.getDate().toString())
				.user(UserDtoMapper.mapToDto(model.getUser()))
				.event(EventDtoMapper.mapBasicToDto(model.getEvent()))
				.build();
	}
}
