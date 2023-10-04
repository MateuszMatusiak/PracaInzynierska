package com.zam.rks.Service;

import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import com.zam.rks.Dto.Mapper.NotificationDtoMapper;
import com.zam.rks.Dto.NotificationDto;
import com.zam.rks.Repository.NotificationRepository;
import com.zam.rks.Utils.UtilService;
import com.zam.rks.model.Group;
import com.zam.rks.model.NotificationModel;
import com.zam.rks.model.User;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Scope;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.List;

@Service
@Scope
@AllArgsConstructor
public class NotificationService {
	private final FirebaseMessaging firebaseMessaging;
	private final NotificationRepository notificationRepository;
	private final UtilService utilService;
	private static final Logger logger = LoggerFactory.getLogger(NotificationService.class);

	@Async
	public void sendNotificationToGroup(Group group, String title, String body) {
		List<User> users = group.getUsersList();
		for (User user : users) {
			sendNotificationToUser(user, title, body);
		}
	}

	@Async
	public void sendNotificationToUsers(List<User> users, String title, String body) {
		for (User user : users) {
			sendNotificationToUser(user, title, body);
		}
	}

	public void sendNotificationToUser(User user, String title, String body) {
		NotificationModel notification = new NotificationModel(title, body, user);
		notificationRepository.save(notification);
		String img = getImageLink();
		List<String> tokens = user.getDeviceTokens();
		for (String token : tokens) {
			try {
				sendNotification(token, title, body, img);
			} catch (FirebaseMessagingException e) {
				logger.warn("User: " + user.getId() + " has invalid device token: " + token);
			} catch (Exception e) {
				logger.warn("User: " + user.getId() + " couldn't get notification");
			}
		}
		logger.info("User: " + user.getId() + " received notification: " + notification.getId());
	}

	public void sendMessageNotificationToUser(User user, String title, String body) {
		List<String> tokens = user.getDeviceTokens();
		String img = getImageLink();
		for (String token : tokens) {
			try {
				sendNotification(token, title, body, img);
			} catch (FirebaseMessagingException e) {
				logger.warn("User: " + user.getId() + " has invalid device token: " + token);
			}
		}
	}

	public List<NotificationDto> getNotifications() {
		User user = utilService.getUser();
		List<NotificationModel> notifications = notificationRepository.findAllByUserOrderByCreatedAt(user);
		return NotificationDtoMapper.map(notifications);
	}

	private void sendNotification(String token, String title, String body, String imgLink) throws FirebaseMessagingException {
		if(token.isEmpty())
			return;

		Message notificationMessage = Message.builder()
				.putData("title", title)
				.putData("body", body)
				.setToken(token)
				.setNotification(Notification.builder().setBody(body).setTitle(title).setImage(imgLink).build())
				.build();

		firebaseMessaging.send(notificationMessage);
	}

	private String getImageLink() {
		RestTemplate restTemplate = new RestTemplate();
		String ipAddress = restTemplate.getForObject("https://api.ipify.org", String.class);
		return "http://" + ipAddress + ":4567/logo";
	}

	public void setSeenNotification(List<Integer> ids) {
		User user = utilService.getUser();
		List<NotificationModel> notifications = notificationRepository.findAllByIdInAndUser(ids, user);
		for (NotificationModel notification : notifications) {
			notification.setSeen(true);
		}
		notificationRepository.saveAll(notifications);
	}
}
