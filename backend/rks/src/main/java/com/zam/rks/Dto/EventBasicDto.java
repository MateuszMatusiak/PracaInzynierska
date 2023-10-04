package com.zam.rks.Dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.annotations.ApiModelProperty;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class EventBasicDto {
	private int id;
	private String name;
	private String description;
	@ApiModelProperty(example = "2000-12-01 12:00")
	@JsonFormat(pattern = "yyyy-MM-dd HH:mm")
	private String startDate;
	@ApiModelProperty(example = "2000-12-01 12:00")
	@JsonFormat(pattern = "yyyy-MM-dd HH:mm")
	private String endDate;
	private UserDto creator;
}
