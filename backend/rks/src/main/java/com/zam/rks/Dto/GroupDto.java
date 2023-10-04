package com.zam.rks.Dto;

import lombok.Builder;
import lombok.Getter;

import java.io.Serializable;

@Getter
@Builder
public class GroupDto implements Serializable {
	private int id;
	private String name;

}
