package com.zam.rks.Service;

import com.zam.rks.Dto.ImageDto;
import com.zam.rks.Repository.EventRepository;
import com.zam.rks.Repository.ImageRepository;
import com.zam.rks.Utils.UtilService;
import com.zam.rks.model.Event;
import com.zam.rks.model.ImageData;
import com.zam.rks.model.User;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Scope;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.util.FileCopyUtils;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import javax.servlet.http.HttpServletResponse;
import javax.transaction.Transactional;
import java.io.*;
import java.net.URLConnection;
import java.nio.file.Files;
import java.nio.file.NoSuchFileException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.*;

import static com.zam.rks.security.configuration.VersionFilter.EXPECTED_VERSION;

@AllArgsConstructor
@Service
@Scope
public class ImageService {
	private final ImageRepository imageRepository;
//	private final String FOLDER_PATH = "C:\\Users\\Mateusz\\Desktop\\zam\\backend\\rks\\target\\classes\\legancka_resources\\images";
	private final String FOLDER_PATH = Objects.requireNonNull(getClass().getClassLoader().getResource(".")).getPath() + "legancka_resources/images";
	private final EventRepository eventRepository;
	private final UtilService utilService;
	private static final Logger logger = LoggerFactory.getLogger(ImageService.class);

	public ResponseEntity<String> uploadProfileImage(MultipartFile file) throws IOException {
		User user = utilService.getUser();
		saveProfileImage(file, user);
		return new ResponseEntity<>(String.valueOf(user.getId()), HttpStatus.OK);
	}

	public ResponseEntity<String> uploadGroupImage(MultipartFile file) throws IOException {
		User user = utilService.getUser();
		saveGroupImage(file, user);
		return new ResponseEntity<>(String.valueOf(user.getSelectedGroup().getId()), HttpStatus.OK);
	}

	public ResponseEntity<String> uploadChatRoomImage(String roomId, MultipartFile file) throws IOException {
		User user = utilService.getUser();
		saveChatRoomImage(roomId, file, user);
		return new ResponseEntity<>(roomId, HttpStatus.OK);
	}

	public ResponseEntity<String> uploadEventImage(int eventId, MultipartFile file) throws IOException {
		User user = utilService.getUser();
		saveEventImage(file, user, eventId);
		return new ResponseEntity<>(String.valueOf(eventId), HttpStatus.OK);
	}

	public byte[] getProfilePhoto(int userId) throws IOException {
		Optional<ImageData> test = imageRepository.findByNameAndUserId(String.valueOf(userId), userId);
		return getImageBytes(test, "/profile_photos/0");
	}

	public byte[] getGroupImage(int groupId) throws IOException {
		Optional<ImageData> test = imageRepository.findByNameAndGroupId(String.valueOf(groupId), groupId);
		return getImageBytes(test, "/group_images/0");
	}

	public byte[] getEventImage(int eventId) throws IOException {
		Optional<ImageData> test = imageRepository.findByNameAndEventId(String.valueOf(eventId), eventId);
		if (test.isEmpty()) {
			throw new ResponseStatusException(HttpStatus.NOT_FOUND, "There is no image for this event");
		}
		ImageData image = test.get();
		try {
			return Files.readAllBytes(Path.of(image.getFilePath()));
		} catch (NoSuchFileException e) {
			throw new ResponseStatusException(HttpStatus.NOT_FOUND, "There is no image for this event");
		}
	}

	public byte[] downloadImage(int id) throws IOException {
		User user = utilService.getUser();
		Optional<ImageData> test = imageRepository.findById(id);
		if (test.isEmpty()) {
			throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Image not found");
		}
		ImageData image = test.get();

		if (image.getGroup().getId() != user.getSelectedGroup().getId()) {
			logger.warn("User: " + user.getId() + " tried to download image: " + id + " but don't have access to it");
			throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You don't have access to this resource");
		}

		return Files.readAllBytes(Path.of(image.getFilePath()));
	}

	@Transactional
	public ResponseEntity<String> uploadImageToGroup(MultipartFile file) throws IOException {
		uploadImage(file, null);
		return ResponseEntity.status(HttpStatus.OK).body("Successfully uploaded");
	}

	@Transactional
	public ResponseEntity<String> uploadImagesToGroup(MultipartFile[] files) throws IOException {
		for (MultipartFile file : files) {
			uploadImage(file, null);
		}
		return ResponseEntity.status(HttpStatus.OK).body("Successfully uploaded");
	}

	@Transactional
	public ResponseEntity<String> uploadImageToEvent(MultipartFile file, int eventId) throws IOException {
		uploadImage(file, eventId);
		return ResponseEntity.status(HttpStatus.OK).body("Successfully uploaded");
	}

	@Transactional
	public ResponseEntity<String> uploadImagesToEvent(MultipartFile[] files, Integer eventId) throws IOException {
		for (MultipartFile file : files) {
			uploadImage(file, eventId);
		}
		return ResponseEntity.status(HttpStatus.OK).body("Successfully uploaded");
	}

	public List<Integer> getImagesIds() {
		User user = utilService.getUser();

		List<ImageData> images = imageRepository.findAllByGroupOrderByIdDesc(user.getSelectedGroup());
		return images.stream().map(ImageData::getId).toList();
	}

	public List<Integer> getEventImagesIds(int eventId) {
		User user = utilService.getUser();
		List<Event> events = user.getEvents();
		Event event = null;
		for (Event e : events) {
			if (e.getId() == eventId) {
				event = e;
				break;
			}
		}
		if (event == null) {
			logger.warn("User: " + user.getId() + " tried to get images for an event: " + eventId + " but don't have permissions to do it");
			throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You don't have access to this resource");
		}

		List<ImageData> images = imageRepository.findAllByEventOrderByIdDesc(event);
		return images.stream().map(ImageData::getId).toList();
	}

	public List<ImageDto> getImages(int[] ids) throws IOException {
		User user = utilService.getUser();

		List<ImageData> images = imageRepository.findAllByIdInAndGroupOrderByIdDesc(ids, user.getSelectedGroup());
		if (images.isEmpty()) {
			throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Images not found");
		}

		List<ImageDto> res = new ArrayList<>();
		for (ImageData img : images) {
			if (user.getSelectedGroup().getId() != img.getGroup().getId()) continue;
			try {
				String encodedImage = Base64.getEncoder().encodeToString(Files.readAllBytes(Path.of(img.getFilePath())));
				res.add(new ImageDto(img.getId(), encodedImage));
			} catch (NoSuchFileException e) {
				//ignore
			}
		}
		return res;
	}

	private void uploadImage(MultipartFile file, Integer eventId) throws IOException {
		Calendar calendar = Calendar.getInstance();
		SimpleDateFormat formatter = new SimpleDateFormat("ddMMyyyyHHmmssSSS");
		String newName = formatter.format(calendar.getTime());

		User user = utilService.getUser();

		Event event = null;
		if (eventId != null) {
			Optional<Event> eTest = eventRepository.findById(eventId);
			if (eTest.isPresent()) {
				event = eTest.get();
			}
		}

		String path = FOLDER_PATH + "/group_content/" + user.getSelectedGroup().getId() + "/" + newName;
		Files.createDirectories(Paths.get(FOLDER_PATH + "/group_content/" + user.getSelectedGroup().getId()));

		file.transferTo(new File(path));
		ImageData saved = imageRepository.save(new ImageData(-1, newName, file.getContentType(), path, user, user.getSelectedGroup(), event));
		logger.info("User: " + user.getId() + " saved a new image: " + saved);
	}

	private void saveProfileImage(MultipartFile file, User user) throws IOException {
		String path = FOLDER_PATH + "/profile_photos/" + user.getId();
		Files.createDirectories(Paths.get(FOLDER_PATH + "/profile_photos"));

		Optional<ImageData> test = imageRepository.findByNameAndUserId(String.valueOf(user.getId()), user.getId());
		if (test.isPresent()) {
			moveOldImage(String.valueOf(user.getId()), "/old_profile_photos/", test.get());
		}

		file.transferTo(new File(path));
		ImageData saved = imageRepository.save(new ImageData(-1, String.valueOf(user.getId()), file.getContentType(), path, user, null, null));
		logger.info("User: " + user.getId() + " saved a new image: " + saved);
	}

	private void saveGroupImage(MultipartFile file, User user) throws IOException {
		if (!user.isModerator()) {
			logger.warn("User: " + user.getId() + " tried to change a group image but don't have permissions to do it");
			throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You don't have access to this resource");
		}
		String path = FOLDER_PATH + "/group_images/" + user.getSelectedGroup().getId();
		Files.createDirectories(Paths.get(FOLDER_PATH + "/group_images"));

		Optional<ImageData> test = imageRepository.findByNameAndGroupId(String.valueOf(user.getSelectedGroup().getId()), user.getSelectedGroup().getId());
		if (test.isPresent()) {
			moveOldImage(String.valueOf(user.getSelectedGroup().getId()), "/old_group_images/", test.get());
		}

		file.transferTo(new File(path));
		ImageData saved = imageRepository.save(new ImageData(-1, String.valueOf(user.getSelectedGroup().getId()), file.getContentType(), path, null, user.getSelectedGroup(), null));
		logger.info("User: " + user.getId() + " saved a new image: " + saved);
	}

	private void saveEventImage(MultipartFile file, User user, int eventId) throws IOException {
		Event event = eventRepository.findById(eventId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Event not found"));
		if (!event.getCreator().equals(user)) {
			logger.warn("User: " + user.getId() + " tried to change an event image but don't have permissions to do it");
			throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You don't have access to edit this event");
		}
		String path = FOLDER_PATH + "/event_images/" + eventId;
		Files.createDirectories(Paths.get(FOLDER_PATH + "/event_images"));

		Optional<ImageData> test = imageRepository.findByNameAndEventId(String.valueOf(eventId), eventId);
		if (test.isPresent()) {
			moveOldImage(String.valueOf(eventId), "/old_event_images/", test.get());
		}

		file.transferTo(new File(path));
		ImageData saved = imageRepository.save(new ImageData(-1, String.valueOf(eventId), file.getContentType(), path, user, null, event));
		logger.info("User: " + user.getId() + " saved a new image: " + saved);
	}

	private void saveChatRoomImage(String roomId, MultipartFile file, User user) throws IOException {
		if (user.getChatRooms().stream().noneMatch(c -> c.getFirebaseId().equals(roomId))) {
			logger.warn("User: " + user.getId() + " tried to change a chat room image but don't have permissions to do it");
			throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You don't have access to this chat room");
		}
		String path = FOLDER_PATH + "/chatRoom_images/" + roomId;
		Files.createDirectories(Paths.get(FOLDER_PATH + "/chatRoom_images"));

		Optional<ImageData> test = imageRepository.findByName(roomId);
		if (test.isPresent()) {
			moveOldImage(roomId, "/old_chatRoom_images/", test.get());
		}

		file.transferTo(new File(path));
		ImageData saved = imageRepository.save(new ImageData(-1, roomId, file.getContentType(), path, null, null, null));
		logger.info("User: " + user.getId() + " saved a new image: " + saved);
	}

	private void moveOldImage(String elementId, String folderNameOld, ImageData imageData) throws IOException {
		User user = utilService.getUser();
		Calendar calendar = Calendar.getInstance();
		SimpleDateFormat formatter = new SimpleDateFormat("ddMMyyyyHHmmssSSS");
		String date = formatter.format(calendar.getTime());
		String newName = elementId + "_" + date;
		String pathForOldImages = FOLDER_PATH + folderNameOld + elementId;
		String oldPath = imageData.getFilePath();
		try {
			Files.createDirectories(Paths.get(pathForOldImages));
			Files.move(Path.of(imageData.getFilePath()), Path.of(pathForOldImages + "/" + newName));

			imageData.setName(newName);
			imageData.setFilePath(pathForOldImages + "/" + newName);
			imageRepository.save(imageData);
			logger.info("User: " + user.getId() + " moved an image from: " + oldPath + " to: " + pathForOldImages + "/" + newName);
		} catch (NoSuchFileException e) {
			logger.warn("User: " + user.getId() + " tried to move an image from: " + oldPath + " to: " + pathForOldImages + "/" + newName + " but it wasn't found");
		}
	}

	private byte[] getImageBytes(Optional<ImageData> test, String emptyPath) throws IOException {
		if (test.isEmpty()) {
			String path = FOLDER_PATH + emptyPath;
			return Files.readAllBytes(Path.of(path));
		}
		ImageData image = test.get();
		try {
			return Files.readAllBytes(Path.of(image.getFilePath()));
		} catch (NoSuchFileException e) {
			String path = FOLDER_PATH + emptyPath;
			return Files.readAllBytes(Path.of(path));
		}
	}

	public byte[] getLogo() throws IOException {
		String path = FOLDER_PATH + "/logo.png";
		return Files.readAllBytes(Path.of(path));
	}

	public boolean downloadApp(HttpServletResponse response) {
		String path = Objects.requireNonNull(getClass().getClassLoader().getResource(".")).getPath() + "legancka_resources/app.apk";
		try {
			String name = "legancka-" + EXPECTED_VERSION + ".apk";
			File file = new File(path);
			if (file.exists()) {

				String mimeType = URLConnection.guessContentTypeFromName(file.getName());
				if (mimeType == null) {
					mimeType = "application/octet-stream";
				}

				response.setContentType(mimeType);
				response.setHeader("Content-Disposition", String.format("inline; filename=\"" + name + "\""));
				response.setContentLength((int) file.length());

				InputStream inputStream = new BufferedInputStream(new FileInputStream(file));

				FileCopyUtils.copy(inputStream, response.getOutputStream());
				return true;
			}
		} catch (IOException e) {
			return false;
		}
		return false;
	}
}
