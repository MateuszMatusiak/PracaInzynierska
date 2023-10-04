package com.zam.rks.controller;

import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import com.zam.rks.Service.NotificationService;
import com.zam.rks.Utils.U;
import com.zam.rks.model.Body.NotificationRequest;
import lombok.AllArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@AllArgsConstructor
@RestController
@RequestMapping("/notifications")
public class NotificationController {
	private FirebaseMessaging firebaseMessaging;
	private final NotificationService notificationService;

	@GetMapping()
	public ResponseEntity<?> getNotifications() {
		return U.handleReturn(notificationService::getNotifications);
	}

	@PutMapping("/seen")
	public String setSeenNotification(@RequestBody List<Integer> ids) {
		return "OK";
	}

	@PutMapping("/send")
	public ResponseEntity<String> sendNotification(@RequestBody NotificationRequest request) throws FirebaseMessagingException {
		Message message = Message.builder()
				.putData("title", request.getTitle())
				.putData("body", request.getBody())
				.setToken(request.getToken())
				.setNotification(Notification.builder().setBody(request.getBody()).setTitle(request.getTitle()).build())
				.build();

		String response = firebaseMessaging.send(message);

		return ResponseEntity.ok(response);
	}
}