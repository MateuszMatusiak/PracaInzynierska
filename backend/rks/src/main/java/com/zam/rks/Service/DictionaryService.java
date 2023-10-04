package com.zam.rks.Service;

import com.zam.rks.Dto.DictionaryDto;
import com.zam.rks.Dto.Mapper.DictionaryDtoMapper;
import com.zam.rks.Repository.DictionaryRepository;
import com.zam.rks.Utils.UtilService;
import com.zam.rks.model.Dictionary;
import com.zam.rks.model.Body.UpdateDictionary;
import com.zam.rks.model.User;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Scope;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import javax.transaction.Transactional;
import java.util.List;
import java.util.Optional;

@AllArgsConstructor
@Service
@Scope
public class DictionaryService {

	private final DictionaryRepository dictionaryRepository;
	private final UtilService utilService;
	private static final Logger logger = LoggerFactory.getLogger(DictionaryService.class);

	public List<Dictionary> getDictionary() {
		User user = utilService.getUser();
		return dictionaryRepository.findAllByGroupOrderByEntryAsc(user.getSelectedGroup());
	}

	@Transactional
	public DictionaryDto insertEntry(UpdateDictionary dictionary) {
		User user = utilService.getUser();
		if (user.getSelectedGroup() == null) {
			logger.warn("User: " + user.getId() + " tried to add dictionary entry: " + dictionary.getEntry() + " without group");
			throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "No group selected");
		}
		Optional<Dictionary> test = dictionaryRepository.findByEntryAndGroup(dictionary.getEntry(), user.getSelectedGroup());
		if (test.isPresent()) {
			if (test.get().getDescription().equals(dictionary.getDescription())) {
				logger.warn("User: " + user.getId() + " tried to add dictionary entry: " + dictionary.getEntry() + " which exists");
				throw new ResponseStatusException(HttpStatus.CONFLICT, "Entry exists");
			}
		}
		Dictionary dictionaryToSave = new Dictionary(dictionary.getEntry().trim(), dictionary.getDescription().trim(), user.getSelectedGroup());
		Dictionary saved = dictionaryRepository.save(dictionaryToSave);
		logger.info("User: " + user.getId() + " added dictionary entry: " + saved.getId());
		return DictionaryDtoMapper.mapToDto(saved);
	}

	public DictionaryDto updateEntry(int id, UpdateDictionary data) {
		User user = utilService.getUser();
		if (user.getSelectedGroup() == null) {
			logger.warn("User: " + user.getId() + " tried to edit dictionary entry: " + id + " without group");
			throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "No group selected");
		}
		Optional<Dictionary> test = dictionaryRepository.findById(id);
		if (test.isEmpty()) {
			logger.warn("User: " + user.getId() + " tried to edit dictionary entry: " + id + " which doesn't exists");
			throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Entry not found");
		}
		Dictionary dictionary = test.get();
		Dictionary old = new Dictionary(dictionary);
		if (!dictionary.getGroup().equals(user.getSelectedGroup())) {
			logger.warn("User: " + user.getId() + " tried to edit dictionary entry: " + id + " which doesn't belong to his group");
			throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Entry doesn't belong to your group");
		}
		dictionary.setEntry(data.getEntry().trim());
		dictionary.setDescription(data.getDescription().trim());
		Dictionary saved = dictionaryRepository.save(dictionary);
		logger.info("User: " + user.getId() + " edited dictionary entry from: " + old + " to: " + saved);
		return DictionaryDtoMapper.mapToDto(saved);
	}
}
