package com.zam.rks.Service;

import com.zam.rks.Dto.GroupDto;
import com.zam.rks.Dto.Mapper.GroupDtoMapper;
import com.zam.rks.Dto.Mapper.UserDtoMapper;
import com.zam.rks.Dto.UserDto;
import com.zam.rks.Repository.UserRepository;
import com.zam.rks.Utils.UtilService;
import com.zam.rks.model.Group;
import com.zam.rks.model.Body.UserBody;
import com.zam.rks.model.User;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Scope;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import javax.transaction.Transactional;
import java.util.List;

@AllArgsConstructor
@Service
@Scope
public class UserService {
	private final UserRepository userRepository;
	private final UtilService utilService;
	private static final Logger logger = LoggerFactory.getLogger(UserService.class);

	public List<GroupDto> getGroupsForUser() {
		User user = utilService.getUser();
		return GroupDtoMapper.mapGroupsToDto(user.getGroups());
	}

	@Transactional
	public UserDto updateUser(UserBody userBody) {
		User user = utilService.getUser();
		User newUser = new User(user, userBody);
		logger.info("User: " + user.getId() + " updated data from: " + user + " to: " + newUser);
		User u = userRepository.save(newUser);
		return UserDtoMapper.mapToDto(u);
	}

	public UserDto getUser() {
		User user = utilService.getUser();
		return UserDtoMapper.mapToDto(user);
	}

	@Transactional
	public UserDto setGroupById(int id) {
		User user = utilService.getUser();
		Group group = utilService.getGroup(id);
		if (!group.getUsersList().stream().map(User::getId).toList().contains(user.getId())) {
			logger.warn("User: " + user.getId() + " don't have access to selected group: " + group.getId());
			throw new ResponseStatusException(HttpStatus.FORBIDDEN, "User don't have access to group");
		}
		user.setSelectedGroup(group);
		utilService.setGroupsAndRole(user);
		return UserDtoMapper.mapToDto(user);

	}

	public List<UserDto> findUsers(String name) {
		List<User> users;
		if (name == null) {
			users = userRepository.findAll();
		} else {
			String n = name + '%';
			users = userRepository.findByNicknameLikeOrFirstNameLikeOrLastNameLikeOrderByNicknameAscFirstNameAscLastNameAsc(n, n, n);
		}
		return UserDtoMapper.mapUsersToDto(users);
	}
}
