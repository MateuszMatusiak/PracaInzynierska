package com.zam.rks.Dto;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class DictionaryDto {
	private int id;
	private String entry;
	private String description;
	private String creationTime;
}
