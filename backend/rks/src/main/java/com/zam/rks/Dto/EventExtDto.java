package com.zam.rks.Dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.annotations.ApiModelProperty;
import lombok.Builder;
import lombok.Getter;

import java.io.Serializable;
import java.util.List;

@Getter
@Builder
public class EventExtDto implements Serializable {
	private int id;
	private String name;
	private String description;
	@ApiModelProperty(example = "2000-12-01 12:00")
	@JsonFormat(pattern = "yyyy-MM-dd HH:mm")
	private String startDate;
	@ApiModelProperty(example = "2000-12-01 12:00")
	@JsonFormat(pattern = "yyyy-MM-dd HH:mm")
	private String endDate;
	private MapBasicDto localization;
	private List<UserDto> users;
	private UserDto creator;

}
