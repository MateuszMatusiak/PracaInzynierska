package com.zam.rks.Dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.annotations.ApiModelProperty;
import lombok.Builder;
import lombok.Getter;

import java.util.List;

@Getter
@Builder
public class ChatRoomDto {
	private int id;
	private String name;
	private String firebaseId;
	@ApiModelProperty(example = "2000-12-01 12:00")
	@JsonFormat(pattern = "yyyy-MM-dd HH:mm")
	private String creationDate;
	private UserDto creator;
	private List<UserDto> users;
	private String imageUrl;
}
