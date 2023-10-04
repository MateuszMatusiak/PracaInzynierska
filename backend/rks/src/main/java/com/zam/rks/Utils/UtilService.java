package com.zam.rks.Utils;

import com.zam.rks.Repository.GroupRepository;
import com.zam.rks.Repository.GroupUsersRepository;
import com.zam.rks.Repository.UserRepository;
import com.zam.rks.model.Group;
import com.zam.rks.model.GroupUser;
import com.zam.rks.model.User;
import com.zam.rks.model.UserRole;
import lombok.AllArgsConstructor;
import org.springframework.context.annotation.Scope;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import javax.transaction.Transactional;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@AllArgsConstructor
@Service
@Scope
public class UtilService {
	private final GroupRepository groupRepository;
	private final UserRepository userRepository;
	private final GroupUsersRepository groupUsersRepository;


	@Transactional
	public User getUser() {
		return (User) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
	}

	@Transactional
	public User getUserById(int id) {
		User user = userRepository.findById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));
		setGroupsAndRole(user);
		return user;
	}

	@Transactional
	public Group getGroup(int id) {
		Group group = groupRepository.findById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Group not found"));
		List<GroupUser> groupUsers = groupUsersRepository.findByGroupId(id);
		group.setUsers(groupUsers);
		return group;
	}

	@Transactional
	public Group saveGroup(Group group) {
		Group newGroup = groupRepository.save(group);
		group.setId(newGroup.getId());
		groupUsersRepository.saveAll(group.getUsers());
		return group;
	}

	@Transactional
	public void setGroupsAndRole(User user) {
		List<GroupUser> groupUsers = groupUsersRepository.findByUserId(user.getId());
		List<Group> groups = groupUsers.stream().map(GroupUser::getGroup).collect(Collectors.toList());
		user.setGroups(groups);
		if (user.getSelectedGroup() == null && groups.size() > 0) {
			user.setSelectedGroup(groups.get(0));
		}
		Optional<GroupUser> test = groupUsers.stream()
				.filter(o -> o.getGroup().getId() == user.getSelectedGroup().getId())
				.findFirst();
		if (test.isEmpty()) {
			if (groupUsers.size() > 0) {
				user.setSelectedGroup(groupUsers.get(0).getGroup());
				user.setRole(groupUsers.get(0).getRole());
			} else {
				user.setSelectedGroup(null);
				user.setRole(UserRole.ROLE_USER);
			}
			userRepository.save(user);
		} else {
			GroupUser groupUser = test.get();
			user.setRole(groupUser.getRole());
		}
	}
}
