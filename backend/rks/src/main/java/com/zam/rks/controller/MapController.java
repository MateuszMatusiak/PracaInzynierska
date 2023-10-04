package com.zam.rks.controller;

import com.zam.rks.Service.MapService;
import com.zam.rks.Utils.U;
import com.zam.rks.model.Body.MapBody;
import lombok.AllArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@AllArgsConstructor
@RestController
@RequestMapping("/map")
public class MapController {
	private final MapService mapService;

	@GetMapping("/{id}/events")
	public ResponseEntity<?> getEventsIdsForLocalization(@PathVariable int id) {
		return U.handleReturn(() -> mapService.getEventsIdsForLocalization(id));
	}

	@GetMapping
	public ResponseEntity<?> getMap() {
		return U.handleReturn(mapService::getMap);
	}

	@PostMapping("/point")
	public ResponseEntity<?> insertMapPoint(@RequestBody MapBody mapModel) {
		return U.handleReturn(() -> mapService.insertMapPoint(mapModel));
	}

	@PutMapping("/point/{id}")
	public ResponseEntity<?> updateMapPoint(@PathVariable int id,
											@RequestBody MapBody mapModel) {
		return U.handleReturn(() -> mapService.updateMapPoint(id, mapModel));
	}
}
