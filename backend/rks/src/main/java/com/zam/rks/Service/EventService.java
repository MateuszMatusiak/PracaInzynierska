package com.zam.rks.Service;

import com.zam.rks.Dto.EventBasicDto;
import com.zam.rks.Dto.EventDto;
import com.zam.rks.Dto.EventExtDto;
import com.zam.rks.Dto.Mapper.EventDtoMapper;
import com.zam.rks.Dto.Mapper.UserDtoMapper;
import com.zam.rks.Dto.UserDto;
import com.zam.rks.Repository.EventRepository;
import com.zam.rks.Repository.MapRepository;
import com.zam.rks.Repository.UserRepository;
import com.zam.rks.Utils.Date;
import com.zam.rks.Utils.UtilService;
import com.zam.rks.model.Event;
import com.zam.rks.model.MapModel;
import com.zam.rks.model.Body.EventBody;
import com.zam.rks.model.User;
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

@Service
@Scope
@AllArgsConstructor
public class EventService {
	private final EventRepository eventRepository;
	private final UserRepository userRepository;
	private final MapRepository mapRepository;
	private final UtilService utilService;
	private final NotificationService notificationService;
	private static final Logger logger = LoggerFactory.getLogger(EventService.class);

	@Transactional
	public EventDto createEvent(EventBody e) {
		User user = utilService.getUser();
		MapModel map = null;
		if (e.getLocalizationId() > 0) {
			Optional<MapModel> test = mapRepository.findById(e.getLocalizationId());
			if (test.isEmpty()) {
				logger.warn("User: " + user.getId() + " tried to add a map point: " + e.getLocalizationId() + " which wasn't found to a new event");
				throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Localization not found");
			}
		}
		Event newEvent = new Event(e, map, user);
		List<Integer> usersToAdd = e.getUsersIds() != null ? e.getUsersIds() : new ArrayList<>();

		if (!usersToAdd.contains(user.getId())) {
			newEvent.addUser(user);
		}
		Integer[] userIds = usersToAdd.toArray(new Integer[0]);

		List<User> users = userRepository.findAllByIdIn(Arrays.stream(userIds).mapToInt(i -> i == null ? -1 : i).toArray());
		newEvent.getUsers().addAll(users);
		Event saved = eventRepository.save(newEvent);
		logger.info("User: " + user.getId() + " added an event: " + saved.getId());
		notificationService.sendNotificationToUsers(users, saved.getName(), "Zostałeś dodany do wydarzenia");
		return EventDtoMapper.mapToDto(saved);
	}

	@Transactional
	public List<EventBasicDto> getEvents() {
		User user = utilService.getUser();
		List<Event> events = eventRepository.findAllForUser(user);
		return EventDtoMapper.mapEventsToBasicDto(events);
	}

	@Transactional
	public EventExtDto getEventById(int id) {
		User user = utilService.getUser();
		Optional<Event> test = eventRepository.findById(id);
		if (test.isEmpty()) {
			logger.warn("User: " + user.getId() + " tried to get an event: " + id + " which wasn't found");
			throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Event not found");
		}
		List<Event> events = user.getEvents();
		boolean found = false;
		for (Event e : events) {
			if (e.getId() == id) {
				found = true;
				break;
			}
		}
		if (!found) {
			logger.warn("User: " + user.getId() + " tried to get an event: " + id + " which it doesn't have access to");
			throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You don't have access to edit this event");
		}
		return EventDtoMapper.mapToExtDto(test.get());
	}

	@Transactional
	public EventDto updateEvent(int id, EventBody eventBody) {
		User user = utilService.getUser();
		Optional<Event> test = eventRepository.findSingleById(id);
		if (test.isEmpty()) {
			logger.warn("User: " + user.getId() + " tried to update an event: " + id + " which wasn't found");
			throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Event not found");
		}
		Event event = test.get();
		Event old = new Event(event);
		if (event.getCreator().getId() != user.getId()) {
			logger.warn("User: " + user.getId() + " tried to update an event: " + id + " which it doesn't have access to");
			throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You don't have permissions to edit this event");
		}
		if (eventBody.getName() != null)
			event.setName(eventBody.getName());
		if (eventBody.getStartDate() != null)
			event.setStartDate(new Date(eventBody.getStartDate()).getTimestamp());
		if (eventBody.getEndDate() != null)
			event.setEndDate(new Date(eventBody.getEndDate()).getTimestamp());
		if (eventBody.getDescription() != null)
			event.setDescription(eventBody.getDescription());
		if (eventBody.getLocalizationId() != null) {
			Optional<MapModel> testM = mapRepository.findById(eventBody.getLocalizationId());
			testM.ifPresent(event::setLocalization);
		}
		Integer[] userIds = eventBody.getUsersIds().toArray(new Integer[0]);
		List<User> users = userRepository.findAllByIdIn(Arrays.stream(userIds).mapToInt(i -> i == null ? -1 : i).toArray());

		event.setUsers(new ArrayList<>(users));
		if (!eventBody.getUsersIds().contains(user.getId())) {
			event.addUser(user);
		}
		Event saved = eventRepository.save(event);
		logger.info("User: " + user.getId() + " updated an event: " + saved.getId() + " from: " + old + " to: " + saved);
		notificationService.sendNotificationToUsers(users, saved.getName(), "Wydarzenie zostało zaktualizowane");
		return EventDtoMapper.mapToDto(saved);
	}

	@Transactional
	public List<UserDto> addUser(int eventId, int userId) {
		User user = utilService.getUser();
		Optional<Event> test = eventRepository.findSingleById(eventId);
		if (test.isEmpty()) {
			logger.warn("User: " + user.getId() + " tried to add user: " + userId + " to an event: " + eventId + " which wasn't found");
			throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Event not found");
		}
		Event event = test.get();
		Event old = new Event(event);
		if (event.getCreator().getId() != user.getId()) {
			logger.warn("User: " + user.getId() + " tried to add user: " + userId + " to an event: " + eventId + " which it doesn't have access to");
			throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You don't have permissions to edit this event");
		}

		Optional<User> testU = userRepository.findById(userId);
		if (testU.isEmpty()) {
			logger.warn("User: " + user.getId() + " tried to add user: " + userId + " which wasn't found to an event: " + eventId);
			throw new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found");
		}
		User userToAdd = testU.get();
		List<User> users = event.getUsers();
		boolean canBeAdded = true;
		for (User u : users) {
			if (u.getId() == userId) {
				canBeAdded = false;
				break;
			}
		}
		if (!canBeAdded) {
			logger.warn("User: " + user.getId() + " tried to add user: " + userId + " which exists to an event: " + eventId);
			throw new ResponseStatusException(HttpStatus.NOT_MODIFIED, "User already exists in this event");
		}

		users.add(userToAdd);
		event.setUsers(users);
		Event saved = eventRepository.save(event);
		logger.info("User: " + user.getId() + " added user to an event: " + saved.getId() + " from: " + old + " to: " + saved);
		notificationService.sendNotificationToUser(userToAdd, saved.getName(), "Zostałeś dodany do wydarzenia");
		return UserDtoMapper.mapUsersToDto(users);
	}

	@Transactional
	public List<UserDto> deleteUser(int eventId, int userId) {
		User user = utilService.getUser();
		Optional<Event> test = eventRepository.findSingleById(eventId);
		if (test.isEmpty()) {
			logger.warn("User: " + user.getId() + " tried to add user: " + userId + " to an event: " + eventId + " which wasn't found");
			throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Event not found");
		}
		Event event = test.get();
		Event old = new Event(event);
		if (event.getCreator().getId() != user.getId()) {
			logger.warn("User: " + user.getId() + " tried to add user: " + userId + " to an event: " + eventId + " which it doesn't have access to");
			throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You don't have permissions to edit this event");
		}

		event.getUsers().removeIf(user1 -> user1.getId() == userId);
		Event saved = eventRepository.save(event);
		logger.info("User: " + user.getId() + " deleted user from an event: " + saved.getId() + " from: " + old + " to: " + saved);
		return UserDtoMapper.mapUsersToDto(event.getUsers());
	}
}
