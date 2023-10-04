package com.zam.rks.Dto.Mapper;

import com.zam.rks.Dto.DictionaryDto;
import com.zam.rks.model.Dictionary;

import java.util.List;
import java.util.stream.Collectors;

public class DictionaryDtoMapper {
	private DictionaryDtoMapper() {
	}

	public static List<DictionaryDto> mapDictionariesToDto(List<Dictionary> dictionaries) {
		return dictionaries.stream().map(DictionaryDtoMapper::mapToDto).collect(Collectors.toList());
	}

	public static DictionaryDto mapToDto(Dictionary dictionary) {
		if (dictionary == null)
			return null;
		return DictionaryDto.builder()
				.id(dictionary.getId())
				.entry(dictionary.getEntry())
				.description(dictionary.getDescription())
				.creationTime(dictionary.getCreationTime().toString())
				.build();
	}
}
