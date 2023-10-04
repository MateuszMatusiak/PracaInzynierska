package com.zam.rks.controller;

import com.zam.rks.Service.EventService;
import com.zam.rks.Utils.U;
import com.zam.rks.model.Body.EventBody;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
public class EventController {

	private final EventService eventService;

	public EventController(EventService eventService) {
		this.eventService = eventService;
	}

	@PostMapping("/event")
	public ResponseEntity<?> createEvent(@RequestBody EventBody event) {
		return U.handleReturn(() -> eventService.createEvent(event));
	}

	@GetMapping("/events")
	public ResponseEntity<?> getEvents() {
		return U.handleReturn(eventService::getEvents);
	}

	@GetMapping("/events/{id}")
	public ResponseEntity<?> getEventById(@PathVariable int id) {
		return U.handleReturn(() -> eventService.getEventById(id));
	}

	@PutMapping("/event/{id}")
	public ResponseEntity<?> updateEvent(@PathVariable int id, @RequestBody EventBody event) {
		return U.handleReturn(() -> eventService.updateEvent(id, event));
	}

	@PostMapping("/event/{eventId}/user/{userId}")
	public ResponseEntity<?> addUser(@PathVariable int eventId, @PathVariable int userId) {
		return U.handleReturn(() -> eventService.addUser(eventId, userId));
	}

	@DeleteMapping("/event/{eventId}/user/{userId}")
	public ResponseEntity<?> deleteUser(@PathVariable int eventId, @PathVariable int userId) {
		return U.handleReturn(() -> eventService.deleteUser(eventId, userId));
	}
}
