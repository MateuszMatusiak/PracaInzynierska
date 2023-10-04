package com.zam.rks.controller;

import com.zam.rks.Service.ChatService;
import com.zam.rks.Utils.U;
import com.zam.rks.model.Body.ChatRoomBody;
import com.zam.rks.model.Body.MessageBody;
import com.zam.rks.model.Body.MuteBody;
import lombok.AllArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@AllArgsConstructor
@RestController
@RequestMapping("/chat")
public class ChatController {
	private final ChatService chatService;

	@PostMapping
	public ResponseEntity<?> sendMessage(@RequestBody MessageBody message) {
		return U.handleReturn(() -> chatService.sendMessage(message));
	}

	@PutMapping("/mute")
	public ResponseEntity<?> muteUserForChatroom(@RequestBody MuteBody muteBody) {
		return U.handleReturn(() -> chatService.muteUserForChatroom(muteBody));
	}

	@PutMapping("/unmute")
	public ResponseEntity<?> unmuteUserForChatroom(@RequestBody MuteBody muteBody) {
		return U.handleReturn(() -> chatService.unmuteUserForChatroom(muteBody));
	}

	@GetMapping("{roomId}")
	public ResponseEntity<?> getMessages(@PathVariable("roomId") String roomId) {
		return U.handleReturn(() -> chatService.getMessages(roomId));
	}

	@PostMapping("/createChatRoom")
	public ResponseEntity<?> createChatRoom(@RequestBody ChatRoomBody room) {
		return U.handleReturn(() -> chatService.createChatRoom(room));
	}

	@PostMapping("/{roomId}/addUser/{userId}")
	public ResponseEntity<?> addUserToChatRoom(@PathVariable("roomId") String roomId, @PathVariable("userId") int userId) {
		return U.handleReturn(() -> chatService.addUserToChatRoom(roomId, userId));
	}

	@DeleteMapping("/{roomId}/removeUser/{userId}")
	public ResponseEntity<?> removeUserFromChatRoom(@PathVariable("roomId") String roomId, @PathVariable("userId") int userId) {
		return U.handleReturn(() -> chatService.removeUserFromChatRoom(roomId, userId));
	}
}
