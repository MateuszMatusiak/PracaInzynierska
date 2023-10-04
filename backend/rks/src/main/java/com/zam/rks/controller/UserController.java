package com.zam.rks.controller;

import com.zam.rks.Service.UserService;
import com.zam.rks.Utils.U;
import com.zam.rks.model.Body.UserBody;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/user")
public class UserController {

	private final UserService userService;

	public UserController(UserService userService) {
		this.userService = userService;
	}

	@GetMapping("/groups")
	public ResponseEntity<?> getGroupsForUser() {
		return U.handleReturn(userService::getGroupsForUser);
	}

	@PutMapping
	public ResponseEntity<?> updateUser(@RequestBody UserBody user) {
		return U.handleReturn(() -> userService.updateUser(user));
	}

	@GetMapping
	public ResponseEntity<?> getUser() {
		return U.handleReturn(userService::getUser);
	}

	@PutMapping("/group/{id}")
	public ResponseEntity<?> setGroupById(@PathVariable int id) {
		return U.handleReturn(() -> userService.setGroupById(id));
	}

	@GetMapping("/search")
	public ResponseEntity<?> findUsers(@RequestParam(required = false) String name) {
		return U.handleReturn(() -> userService.findUsers(name));
	}
}
