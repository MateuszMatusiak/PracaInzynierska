package com.zam.rks.controller;

import com.zam.rks.Service.ImageService;
import com.zam.rks.Utils.U;
import lombok.AllArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@AllArgsConstructor
@RestController
public class ImageController {
	private final ImageService imageService;

	@PostMapping("/image")
	public ResponseEntity<?> uploadImageToGroup(@RequestParam("image") MultipartFile file) throws IOException {
		return imageService.uploadImageToGroup(file);
	}

	@PostMapping("/images")
	public ResponseEntity<?> uploadImagesToGroup(@RequestParam("images") MultipartFile[] files) throws IOException {
		return imageService.uploadImagesToGroup(files);
	}

	@PostMapping("/image/{eventId}")
	public ResponseEntity<?> uploadImageToEvent(@RequestParam("image") MultipartFile file, @PathVariable int eventId) throws IOException {
		return imageService.uploadImageToEvent(file, eventId);
	}

	@PostMapping("/images/{eventId}")
	public ResponseEntity<?> uploadImagesToEvent(@RequestParam("images") MultipartFile[] files, @PathVariable int eventId) throws IOException {
		return imageService.uploadImagesToEvent(files, eventId);
	}

	@GetMapping("/imagesIds")
	public ResponseEntity<?> getImagesIds() {
		return U.handleReturn(imageService::getImagesIds);
	}

	@GetMapping("/imagesIds/{eventId}")
	public ResponseEntity<?> getEventImagesIds(@PathVariable int eventId) {
		return U.handleReturn(() -> imageService.getEventImagesIds(eventId));
	}

	@GetMapping("/images")
	public ResponseEntity<?> getImages(@RequestParam int[] ids) {
		return U.handleReturn(() -> imageService.getImages(ids));
	}

	@PostMapping("/image/profile")
	public ResponseEntity<?> uploadProfileImage(@RequestParam("image") MultipartFile file) {
		return U.handleReturn(() -> imageService.uploadProfileImage(file));
	}

	@PostMapping("/image/group")
	public ResponseEntity<?> uploadGroupImage(@RequestParam("image") MultipartFile file) {
		return U.handleReturn(() -> imageService.uploadGroupImage(file));
	}

	@PostMapping("/image/chatRoom/{roomId}")
	public ResponseEntity<?> uploadChatRoomImage(@PathVariable String roomId, @RequestParam("image") MultipartFile file) {
		return U.handleReturn(() -> imageService.uploadChatRoomImage(roomId, file));
	}

	@PostMapping("/image/event/{eventId}")
	public ResponseEntity<?> uploadEventImage(@PathVariable int eventId, @RequestParam("image") MultipartFile file) {
		return U.handleReturn(() -> imageService.uploadEventImage(eventId, file));
	}

	@GetMapping("/image/event/{eventId}")
	public ResponseEntity<?> getEventImage(@PathVariable int eventId) throws IOException {
		byte[] image = imageService.getEventImage(eventId);
		return ResponseEntity.status(HttpStatus.OK).contentType(MediaType.valueOf("image/png")).body(image);
	}

	@GetMapping("/image/profile/{userId}")
	public ResponseEntity<?> getProfilePhoto(@PathVariable int userId) throws IOException {
		byte[] image = imageService.getProfilePhoto(userId);
		return ResponseEntity.status(HttpStatus.OK).contentType(MediaType.valueOf("image/png")).body(image);
	}

	@GetMapping("/images/{id}")
	public ResponseEntity<?> downloadImage(@PathVariable int id) throws IOException {
		byte[] image = imageService.downloadImage(id);
		return ResponseEntity.status(HttpStatus.OK).contentType(MediaType.valueOf("image/png")).body(image);
	}

	@GetMapping("/logo")
	public ResponseEntity<?> getLogo() throws IOException {
		byte[] image = imageService.getLogo();
		return ResponseEntity.status(HttpStatus.OK).contentType(MediaType.valueOf("image/png")).body(image);
	}

	@GetMapping("/download")
	public String downloadApp(HttpServletResponse response) {
		return imageService.downloadApp(response) ? "OK" : "ERROR";
	}
}
