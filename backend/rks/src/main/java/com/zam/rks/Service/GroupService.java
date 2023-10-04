package com.zam.rks.Service;

import com.zam.rks.Dto.GroupDto;
import com.zam.rks.Dto.Mapper.GroupDtoMapper;
import com.zam.rks.Dto.Mapper.UserDtoMapper;
import com.zam.rks.Dto.UserDto;
import com.zam.rks.Repository.GroupRepository;
import com.zam.rks.Repository.GroupUsersRepository;
import com.zam.rks.Repository.UserRepository;
import com.zam.rks.Utils.U;
import com.zam.rks.Utils.UtilService;
import com.zam.rks.model.Group;
import com.zam.rks.model.Body.GroupBody;
import com.zam.rks.model.User;
import com.zam.rks.model.UserRole;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Scope;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import javax.transaction.Transactional;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

@AllArgsConstructor
@Service
@Scope
public class GroupService {

	private final GroupRepository groupRepository;
	private final UserRepository userRepository;
	private final UtilService utilService;
	private final GroupUsersRepository groupUsersRepository;
	private final NotificationService notificationService;
	private static final Logger logger = LoggerFactory.getLogger(GroupService.class);

	@Transactional
	public GroupDto createNewGroup(GroupBody groupBody) {
		Optional<Group> test = groupRepository.findByName(groupBody.getName());
		if (test.isPresent()) {
			throw new ResponseStatusException(HttpStatus.CONFLICT, "Group already exists");
		}
		User user = utilService.getUser();

		List<User> users = new ArrayList<>();
		if (groupBody.getUsersIds() != null) {
			users = userRepository.findAllByIdIn(Arrays.stream(groupBody.getUsersIds().toArray(new Integer[0])).mapToInt(i -> i == null ? -1 : i).toArray());
			if (groupBody.getUsersIds().contains(user.getId()))
				users.removeIf(user1 -> user1.getId() == user.getId());
		}

		Group group = new Group(groupBody.getName(), users);
		group.addUser(user, UserRole.ROLE_OWNER);
		notificationService.sendNotificationToUsers(users, group.getName(), "Zostałeś dodany do grupy");
		return GroupDtoMapper.mapToDto(utilService.saveGroup(group));
	}

	@Transactional
	public GroupDto updateGroupNameById(int id, String name) {
		Group group = groupRepository.findById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Group not found"));
		User user = utilService.getUser();
		String oldName = group.getName();
		if (user.getSelectedGroup().getId() != group.getId()) {
			logger.warn("User: " + user.getId() + " tried to update group name from: " + oldName + " to: " + name + " in group: " + id + " but his selected group is different");
			throw new ResponseStatusException(HttpStatus.CONFLICT, "Selected group is not equal to edited group");
		}
		if (!user.isAdmin()) {
			logger.warn("User: " + user.getId() + " tried to update group name from: " + oldName + " to: " + name + " in group: " + id + " but wasn't found in it");
			throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You don't have permissions to do this");
		}

		group.setName(name);
		Group saved = groupRepository.save(group);
		logger.info("User: " + user.getId() + " updated a group name from: " + oldName + " to: " + name + " in group: " + id);
		return GroupDtoMapper.mapToDto(saved);
	}

	@Transactional
	public List<UserDto> getUsersForGroup(int id) {
		User user = utilService.getUser();
		Group group = utilService.getGroup(id);
		List<User> userList = group.getUsersList();

		boolean isUserInGroup = false;
		for (User u : userList) {
			if (u.getId() == user.getId()) {
				isUserInGroup = true;
				break;
			}
		}
		if (!isUserInGroup) {
			logger.warn("User: " + user.getId() + " tried to get an users from group: " + id + " but wasn't found in it");
			throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You don't have permissions to do this");
		}

		return UserDtoMapper.mapUsersToDto(userList);
	}

	@Transactional
	public List<UserDto> addUser(int groupId, int userId, UserRole role) {
		Group group = utilService.getGroup(groupId);
		User user = utilService.getUser();
		List<User> userSet = group.getUsersList();

		boolean isUserInGroup = false;
		for (User u : userSet) {
			if (u.getId() == user.getId()) {
				user.setRole(u.getRole());
				isUserInGroup = true;
				break;
			}
		}
		if (!isUserInGroup) {
			logger.warn("User: " + user.getId() + " tried to add an user: " + userId + " to group: " + groupId + " but wasn't found in it");
			throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You don't have permissions to do this");
		}

		Optional<User> test = userRepository.findById(userId);
		if (test.isEmpty()) {
			logger.warn("User: " + user.getId() + " tried to add an user: " + userId + " which wasn't found, to group: " + groupId);
			throw new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found");
		}
		User userToAdd = test.get();
		boolean isAdded = group.addUser(userToAdd, role);
		if (!isAdded) {
			logger.warn("User: " + user.getId() + " tried to add an user: " + userId + " which already exists in group: " + groupId);
			throw new ResponseStatusException(HttpStatus.NOT_MODIFIED, "User already exists in this group");
		}
		utilService.saveGroup(group);
		logger.info("User: " + user.getId() + " added an user: " + userId + " to group: " + groupId);
		notificationService.sendNotificationToUser(userToAdd, group.getName(), "Zostałeś dodany do grupy");
		return UserDtoMapper.mapUsersToDto(group.getUsersList());

	}

	@Transactional
	public List<UserDto> deleteUser(int groupId, int userId) {
		Group group = utilService.getGroup(groupId);
		User user = utilService.getUser();
		List<User> userList = group.getUsersList();
		Optional<User> userToDelete = Optional.empty();

		boolean isUserInGroup = false;
		for (User u : userList) {
			if (u.getId() == user.getId()) {
				user.setRole(u.getRole());
				isUserInGroup = true;
			}
			if (u.getId() == userId) {
				userToDelete = Optional.of(u);
			}
		}
		if (!isUserInGroup) {
			logger.warn("User: " + user.getId() + " tried to delete an user: " + userId + " to group: " + groupId + " but deleting user wasn't found in it");
			throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You don't have permissions to do this");
		}

		if (userToDelete.isEmpty()) {
			logger.warn("User: " + user.getId() + " tried to delete an user: " + userId + " from group: " + groupId + " but user to delete wasn't found in it");
			throw new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found in this group");
		}

		UserRole role = userToDelete.get().getRole();

		if (!U.canOperateOnRole(user, role)) {
			logger.warn("User: " + user.getId() + " tried to delete an user: " + userId + " to group: " + groupId + " but don't have permissions to do it");
			throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You don't have permissions to do this");
		}
		groupUsersRepository.deleteByGroupIdAndUserId(groupId, userId);
		group.getUsers().removeIf(groupUser -> groupUser.getUser().getId() == userId);
		logger.info("User: " + user.getId() + " deleted an user: " + userId + " to group: " + groupId);
		return UserDtoMapper.mapUsersToDto(group.getUsersList());
	}

	@Transactional
	public List<UserDto> editUserRole(int groupId, int userId, UserRole role) {
		Group group = utilService.getGroup(groupId);
		User user = utilService.getUser();
		List<User> userSet = group.getUsersList();
		Optional<User> userToUpdate = Optional.empty();

		boolean isUserInGroup = false;
		for (User u : userSet) {
			if (u.getId() == user.getId()) {
				user.setRole(u.getRole());
				isUserInGroup = true;
			}
			if (u.getId() == userId) {
				userToUpdate = Optional.of(u);
			}
		}
		if (!isUserInGroup) {
			logger.warn("User: " + user.getId() + " tried to edit an user role: " + userId + " in group: " + groupId + " but wasn't found in it");
			throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You don't have permissions to do this");
		}

		if (userToUpdate.isEmpty()) {
			logger.warn("User: " + user.getId() + " tried to edit an user role: " + userId + " in group: " + groupId + " but user to edit wasn't found in it");
			throw new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found in this group");
		}
		UserRole oldRole = userToUpdate.get().getRole();
		if (!(U.canOperateOnRole(user, role) && U.canOperateOnRole(user, userToUpdate.get().getRole()))) {
			logger.warn("User: " + user.getId() + " tried to edit an user role: " + userId + " in group: " + groupId + " but don't have permissions to do it");
			throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You don't have permissions to do this");
		}

		groupUsersRepository.updateUserRoleInGroup(groupId, userId, role);
		group.updateUserRole(userToUpdate.get(), role);
		logger.info("User: " + user.getId() + " edited an user role: " + userId + " in group: " + groupId + " from: " + oldRole + " to: " + role);
		return UserDtoMapper.mapUsersToDto(group.getUsersList());
	}
}
