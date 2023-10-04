package com.zam.rks.controller;

import com.zam.rks.Service.DictionaryService;
import com.zam.rks.Utils.U;
import com.zam.rks.model.Body.UpdateDictionary;
import lombok.AllArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@AllArgsConstructor
@RestController
@RequestMapping("/dictionary")
public class DictionaryController {

	private final DictionaryService dictionaryService;


	@GetMapping
	public ResponseEntity<?> getDictionary() {
		return U.handleReturn(dictionaryService::getDictionary);
	}

	@PostMapping
	public ResponseEntity<?> insertEntry(@RequestBody UpdateDictionary dictionary) {
		return U.handleReturn(() -> dictionaryService.insertEntry(dictionary));
	}
	
	@PutMapping("/{id}")
	public ResponseEntity<?> updateEntry(@PathVariable int id, @RequestBody UpdateDictionary data) {
		return U.handleReturn(() -> dictionaryService.updateEntry(id, data));
	}
}
