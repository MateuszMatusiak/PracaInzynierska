package com.zam.rks.model.Body;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.sql.Date;

@Getter
@AllArgsConstructor
public class UserBody {
	private String firstName;
	private String lastName;
	private Date birthdate;
	private String nickname;
	private String phoneNumber;
	private String firebaseId;

}
