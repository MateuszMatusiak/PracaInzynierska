package com.zam.rks.Dto.Mapper;

import com.zam.rks.Dto.UserDto;
import com.zam.rks.model.User;

import java.util.List;
import java.util.stream.Collectors;

public class UserDtoMapper {

	public static List<UserDto> mapUsersToDto(List<User> users) {
		return users.stream().map(UserDtoMapper::mapToDto).collect(Collectors.toList());
	}

	public static UserDto mapToDto(User user) {
		return UserDto.builder()
				.id(user.getId())
				.email(user.getEmail())
				.firstName(user.getFirstName())
				.lastName(user.getLastName())
				.birthdate(user.getBirthdate())
				.phoneNumber(user.getPhoneNumber())
				.nickname(user.getNickname())
				.role(user.getStringRole())
				.firebaseId(user.getFirebaseId())
				.selectedGroup(user.getSelectedGroup() == null ? null : GroupDtoMapper.mapToDto(user.getSelectedGroup()))
				.build();
	}
}
