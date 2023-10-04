package com.zam.rks.model.Body;

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.annotations.ApiModelProperty;
import lombok.Getter;

import java.util.List;

@Getter
public class EventBody {
	private String name;

	@ApiModelProperty(example = "2000-12-01 12:00")
	@JsonFormat(pattern = "yyyy-MM-dd HH:mm")
	private String startDate;
	@ApiModelProperty(example = "2000-12-01 12:00")
	@JsonFormat(pattern = "yyyy-MM-dd HH:mm")
	private String endDate;
	private String description;
	private Integer localizationId;
	private List<Integer> usersIds;
}
