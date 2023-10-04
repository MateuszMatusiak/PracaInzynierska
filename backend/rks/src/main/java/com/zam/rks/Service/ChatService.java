package com.zam.rks.Service;

import com.zam.rks.Dto.ChatRoomDto;
import com.zam.rks.Dto.Mapper.ChatRoomDtoMapper;
import com.zam.rks.Dto.Mapper.MessageDtoMapper;
import com.zam.rks.Dto.MessageDto;
import com.zam.rks.Repository.ChatRepository;
import com.zam.rks.Repository.ChatRoomMutedUserRepository;
import com.zam.rks.Repository.ChatRoomRepository;
import com.zam.rks.Repository.UserRepository;
import com.zam.rks.Utils.U;
import com.zam.rks.Utils.UtilService;
import com.zam.rks.model.ChatMessage;
import com.zam.rks.model.ChatRoom;
import com.zam.rks.model.ChatRoomMutedUser;
import com.zam.rks.model.Body.ChatRoomBody;
import com.zam.rks.model.Body.MessageBody;
import com.zam.rks.model.Body.MuteBody;
import com.zam.rks.model.User;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Scope;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.sql.Timestamp;
import java.time.ZoneOffset;
import java.time.ZonedDateTime;
import java.util.*;


@AllArgsConstructor
@Service
@Scope
public class ChatService {
	private final ChatRepository chatRepository;
	private final UtilService utilService;
	private final ChatRoomRepository chatRoomRepository;
	private final UserRepository userRepository;
	private final ChatRoomMutedUserRepository chatRoomMutedUserRepository;
	private final NotificationService notificationService;
	private static final Logger logger = LoggerFactory.getLogger(ChatService.class);

	public ResponseEntity<String> sendMessage(MessageBody model) {
		User sender = utilService.getUser();
		Optional<ChatRoom> test = chatRoomRepository.findByFirebaseId(model.getRoomId());
		if (test.isEmpty()) {
			logger.warn("User: " + sender.getId() + " tried to send a message to chat room: " + model.getRoomId() + " which wasn't found");
			throw new RuntimeException("Room not found");
		}
		ChatRoom room = test.get();
		ChatMessage chatMessage = new ChatMessage(model, sender, room);
		ChatMessage saved = chatRepository.save(chatMessage);
		logger.info("User: " + sender.getId() + " send a message: " + saved.getId() + " to chat room: " + model.getRoomId());

		List<ChatRoomMutedUser> mutedUsers = chatRoomMutedUserRepository.findAllByRoom(room);
		HashMap<Integer, List<Integer>> mutedUsersMap = new HashMap<>();
		for (ChatRoomMutedUser mutedUser : mutedUsers) {
			if (mutedUser.getMutedUntil() != null && mutedUser.getMutedUntil().before(new Timestamp(ZonedDateTime.now(ZoneOffset.UTC).toInstant().toEpochMilli()))) {
				chatRoomMutedUserRepository.deleteById(mutedUser.getId());
			} else {
				List<Integer> mutedIds = mutedUsersMap.get(mutedUser.getUser().getId());
				if (mutedIds == null) {
					mutedIds = new ArrayList<>();
					mutedUsersMap.put(mutedUser.getUser().getId(), mutedIds);
				}
				mutedUsersMap.get(mutedUser.getUser().getId()).add(mutedUser.getMutedUser().getId());
			}
		}
		List<User> users = room.getUsers();
		for (User u : users) {
			if (!u.equals(sender)) {
				List<Integer> mutedUsersForReceiver = mutedUsersMap.get(u.getId());
				if (mutedUsersForReceiver == null) {
					notificationService.sendMessageNotificationToUser(u, sender.getFirstName() + " " + sender.getLastName(), model.getMessage());
					logger.info("Notification sent to " + u.getId());
				} else {
					if (!mutedUsersForReceiver.contains(sender.getId())) {
						notificationService.sendMessageNotificationToUser(u, sender.getFirstName() + " " + sender.getLastName(), model.getMessage());
						logger.info("Notification sent to " + u.getId());
					} else {
						logger.info("Notification didn't send from: " + sender.getId() + " to " + u.getId() + " because of mute");
					}
				}
			}
		}
		return new ResponseEntity<>("Message sent", HttpStatus.OK);
	}

	public List<MessageDto> getMessages(String roomId) {
		User user = utilService.getUser();
		Optional<ChatRoom> test = chatRoomRepository.findByFirebaseId(roomId);
		if (test.isEmpty()) {
			logger.warn("User: " + user.getId() + " tried to get messages from chat room: " + roomId + " which wasn't found");
			throw new RuntimeException("Room not found");
		}
		ChatRoom room = test.get();
		List<ChatMessage> chatMessages = chatRepository.findAllByRoomOrderByTimeDesc(room);
		return MessageDtoMapper.mapMessagesToDto(chatMessages);
	}

	public ChatRoomDto createChatRoom(ChatRoomBody room) {
		User user = utilService.getUser();
		ChatRoom newRoom = new ChatRoom(room, user);
		if (!room.getUsersIds().contains(user.getId())) {
			newRoom.addUser(user);
		}
		Integer[] userIds = room.getUsersIds().toArray(new Integer[0]);
		List<User> users = userRepository.findAllByIdIn(Arrays.stream(userIds).mapToInt(i -> i == null ? -1 : i).toArray());
		newRoom.getUsers().addAll(users);
		ChatRoom saved = chatRoomRepository.save(newRoom);
		logger.info("User: " + user.getId() + " created a chat room: " + saved.getId());
		return ChatRoomDtoMapper.mapToDto(saved);
	}

	public ResponseEntity<String> muteUserForChatroom(MuteBody muteBody) {
		User user = utilService.getUser();
		User mutedUser = null;

		Timestamp muteTo = null;
		int hour = muteBody.getHour() == null ? 0 : muteBody.getHour();
		int minute = muteBody.getMinutes() == null ? 0 : muteBody.getMinutes();
		if (hour != 0 || minute != 0) {
			muteTo = new Timestamp(U.addToDate(new Date(), hour, minute).getTime());
		}

		if (muteBody.getMutedUserId() != null) {
			Optional<User> userTest = userRepository.findById(muteBody.getMutedUserId());
			if (userTest.isEmpty()) {
				logger.warn("User: " + user.getId() + " tried to mute user: " + muteBody.getMutedUserId() + " which wasn't found");
				return new ResponseEntity<>("User not found", HttpStatus.NOT_FOUND);
			}
			mutedUser = userTest.get();
		}

		Optional<ChatRoom> chatRoomTest = chatRoomRepository.findByFirebaseId(muteBody.getChatRoomFirebaseId());
		if (chatRoomTest.isEmpty()) {
			logger.warn("User: " + user.getId() + " tried to mute chat room: " + muteBody.getChatRoomFirebaseId() + " which wasn't found");
			return new ResponseEntity<>("ChatRoom not found", HttpStatus.NOT_FOUND);
		}
		ChatRoom chatRoom = chatRoomTest.get();
		chatRoomMutedUserRepository.save(new ChatRoomMutedUser(chatRoom, user, mutedUser, muteTo));
		logger.info("User: " + user.getId() + " muted user: " + mutedUser.getId() + " in a chat room: " + chatRoom.getFirebaseId() + " to: " + muteTo);
		return new ResponseEntity<>("Muted", HttpStatus.OK);
	}

	public ResponseEntity<String> unmuteUserForChatroom(MuteBody muteBody) {
		User user = utilService.getUser();
		Optional<ChatRoom> chatRoomTest = chatRoomRepository.findByFirebaseId(muteBody.getChatRoomFirebaseId());
		if (chatRoomTest.isEmpty()) {
			logger.warn("User: " + user.getId() + " tried to unmute chat room: " + muteBody.getChatRoomFirebaseId() + " which wasn't found");
			return new ResponseEntity<>("ChatRoom not found", HttpStatus.NOT_FOUND);
		}
		ChatRoom chatRoom = chatRoomTest.get();

		if (muteBody.getMutedUserId() == null) {
			chatRoomMutedUserRepository.deleteByChatRoomIdForUser(chatRoom.getId(), user.getId());
			logger.info("User: " + user.getId() + " unmuted chat room: " + muteBody.getChatRoomFirebaseId());
		} else {
			chatRoomMutedUserRepository.deleteByMutedUserAndChatRoomIdForUser(muteBody.getMutedUserId(), chatRoom.getId(), user.getId());
			logger.info("User: " + user.getId() + " unmuted user: " + muteBody.getMutedUserId() + " in chat room: " + muteBody.getChatRoomFirebaseId());
		}
		return new ResponseEntity<>("Unmuted", HttpStatus.OK);
	}

	public ResponseEntity<ChatRoomDto> addUserToChatRoom(String roomId, int userId) {
		User user = utilService.getUser();
		Optional<ChatRoom> chatRoomTest = chatRoomRepository.findByFirebaseId(roomId);
		if (chatRoomTest.isEmpty()) {
			logger.warn("User: " + user.getId() + " tried to add user: " + userId + " to chat room: " + roomId + " which wasn't found");
			throw new ResponseStatusException(HttpStatus.NOT_FOUND, "ChatRoom not found");
		}
		ChatRoom chatRoom = chatRoomTest.get();
		Optional<User> userTest = userRepository.findById(userId);
		if (userTest.isEmpty()) {
			logger.warn("User: " + user.getId() + " tried to add user: " + userId + " which wasn't found to chat room: " + roomId);
			throw new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found");
		}
		User userToAdd = userTest.get();
		if (chatRoom.getUsers().contains(userToAdd)) {
			logger.warn("User: " + user.getId() + " tried to add user: " + userId + " which is already in chat room: " + roomId);
			throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "User already in chat room");
		}
		chatRoom.getUsers().add(userToAdd);
		ChatRoom saved = chatRoomRepository.save(chatRoom);
		logger.info("User: " + user.getId() + " added user: " + userId + " to chat room: " + roomId);
		return new ResponseEntity<>(ChatRoomDtoMapper.mapToDto(saved), HttpStatus.OK);
	}

	public ResponseEntity<ChatRoomDto> removeUserFromChatRoom(String roomId, int userId) {
		User user = utilService.getUser();
		Optional<ChatRoom> chatRoomTest = chatRoomRepository.findByFirebaseId(roomId);
		if (chatRoomTest.isEmpty()) {
			logger.warn("User: " + user.getId() + " tried to remove user: " + userId + " from chat room: " + roomId + " which wasn't found");
			throw new ResponseStatusException(HttpStatus.NOT_FOUND, "ChatRoom not found");
		}
		ChatRoom chatRoom = chatRoomTest.get();
		Optional<User> userTest = userRepository.findById(userId);
		if (userTest.isEmpty()) {
			logger.warn("User: " + user.getId() + " tried to remove user: " + userId + " which wasn't found from chat room: " + roomId);
			throw new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found");
		}
		User userToRemove = userTest.get();
		if (!chatRoom.getUsers().contains(userToRemove)) {
			logger.warn("User: " + user.getId() + " tried to remove user: " + userId + " which is not in chat room: " + roomId);
			throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "User not in chat room");
		}
		chatRoom.getUsers().remove(userToRemove);
		ChatRoom saved = chatRoomRepository.save(chatRoom);
		logger.info("User: " + user.getId() + " removed user: " + userId + " from chat room: " + roomId);
		return new ResponseEntity<>(ChatRoomDtoMapper.mapToDto(saved), HttpStatus.OK);
	}
}
