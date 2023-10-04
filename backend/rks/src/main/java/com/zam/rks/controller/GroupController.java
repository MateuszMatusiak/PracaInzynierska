package com.zam.rks.controller;

import com.zam.rks.Service.GroupService;
import com.zam.rks.Utils.U;
import com.zam.rks.model.Body.GroupBody;
import com.zam.rks.model.Body.RoleBody;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/group")
public class GroupController {

	private final GroupService groupService;

	public GroupController(GroupService groupService) {
		this.groupService = groupService;
	}

	@PostMapping
	public ResponseEntity<?> createNewGroup(@RequestBody GroupBody groupName) {
		return U.handleReturn(() -> groupService.createNewGroup(groupName));
	}

	@PutMapping("/{id}/{name}")
	public ResponseEntity<?> updateGroupNameById(@PathVariable int id, @PathVariable String name) {
		return U.handleReturn(() -> groupService.updateGroupNameById(id, name));
	}

	@GetMapping("/{id}/users")
	public ResponseEntity<?> getUsersForGroup(@PathVariable int id) {
		return U.handleReturn(() -> groupService.getUsersForGroup(id));
	}

	@PostMapping("/{groupId}/user/{userId}")
	public ResponseEntity<?> addUser(@PathVariable int groupId, @PathVariable int userId, @RequestBody RoleBody role) {
		return U.handleReturn(() -> groupService.addUser(groupId, userId, role.getRole()));
	}

	@DeleteMapping("/{groupId}/user/{userId}")
	public ResponseEntity<?> deleteUser(@PathVariable int groupId, @PathVariable int userId) {
		return U.handleReturn(() -> groupService.deleteUser(groupId, userId));
	}

	@PutMapping("/{groupId}/user/{userId}")
	public ResponseEntity<?> editUserRole(@PathVariable int groupId, @PathVariable int userId, @RequestBody RoleBody role) {
		return U.handleReturn(() -> groupService.editUserRole(groupId, userId, role.getRole()));
	}
}
