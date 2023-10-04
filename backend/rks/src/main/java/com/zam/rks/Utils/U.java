package com.zam.rks.Utils;

import com.zam.rks.model.User;
import com.zam.rks.model.UserRole;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.server.ResponseStatusException;

import java.util.Calendar;
import java.util.Date;
import java.util.concurrent.Callable;

public class U {
	private U() {
	}

	public static boolean canOperateOnRole(User user, UserRole role) {
		switch (role) {
			case ROLE_ADMIN -> {
				return user.isOwner();
			}
			case ROLE_MODERATOR -> {
				return user.isAdmin();
			}
			case ROLE_USER -> {
				return user.isModerator();
			}
			default -> {
				return false;
			}
		}
	}

	public static ResponseEntity<?> handleReturn(Callable callable) {
		try {
			Object res = callable.call();
			return new ResponseEntity<>(res, HttpStatus.OK);
		} catch (ResponseStatusException ex) {
			return ResponseEntity.status(ex.getStatus()).body(ex.getMessage());
		} catch (Exception e) {
			e.printStackTrace();
			return ResponseEntity.status(500).body("Internal server error");
		}
	}

	public static Date addToDate(Date date, int hours, int minutes) {
		Calendar calendar = Calendar.getInstance();
		calendar.setTime(date);
		calendar.add(Calendar.HOUR_OF_DAY, hours);
		calendar.add(Calendar.MINUTE, minutes);
		return calendar.getTime();
	}
}
