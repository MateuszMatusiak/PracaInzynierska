package com.zam.rks.Dto;

import lombok.Builder;
import lombok.Getter;

import java.io.Serializable;
import java.sql.Date;

@Getter
@Builder
public class UserDto implements Serializable {
	private int id;
	private String email;
	private String firstName;
	private String lastName;
	private Date birthdate;
	private String phoneNumber;
	private String nickname;
	private String role;
	private String firebaseId;
	private GroupDto selectedGroup;
}
