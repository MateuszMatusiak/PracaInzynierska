package com.zam.rks.Service;

import com.zam.rks.Dto.EventBasicDto;
import com.zam.rks.Dto.MapDto;
import com.zam.rks.Dto.Mapper.EventDtoMapper;
import com.zam.rks.Dto.Mapper.MapDtoMapper;
import com.zam.rks.Repository.EventRepository;
import com.zam.rks.Repository.MapRepository;
import com.zam.rks.Utils.UtilService;
import com.zam.rks.model.Event;
import com.zam.rks.model.Group;
import com.zam.rks.model.MapModel;
import com.zam.rks.model.Body.MapBody;
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
public class MapService {
	private final MapRepository mapRepository;
	private final EventRepository eventRepository;
	private final UtilService utilService;
	private static final Logger logger = LoggerFactory.getLogger(MapService.class);

	public List<EventBasicDto> getEventsIdsForLocalization(int id) {
		List<Event> events = eventRepository.findAllByLocalizationIdOrderByName(id);
		return EventDtoMapper.mapEventsToBasicDto(events);
	}

	@Transactional
	public List<MapDto> getMap() {
		User user = utilService.getUser();
		List<MapModel> models = mapRepository.findAllByGroup(user.getSelectedGroup());
		return MapDtoMapper.mapMapModelToDto(models);
	}

	@Transactional
	public MapDto insertMapPoint(MapBody mapModel) {
		User user = utilService.getUser();
		Group group = user.getSelectedGroup();
		MapModel newPoint = new MapModel(mapModel, group);
		MapModel saved = mapRepository.save(newPoint);
		logger.info("User: " + user.getId() + " added a map point: " + saved);
		return MapDtoMapper.mapToDto(saved);
	}

	@Transactional
	public MapDto updateMapPoint(int id, MapBody mapModel) {
		User user = utilService.getUser();
		Optional<MapModel> test = mapRepository.findById(id);
		if (test.isEmpty()) {
			logger.warn("User: " + user.getId() + " tried to update a map point: " + id + " which wasn't found");
			throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Point not found");
		}
		MapModel point = test.get();
		MapModel old = new MapModel(point);
		point.setName(mapModel.getName());
		point.setLatitude(mapModel.getLatitude());
		point.setLongitude(mapModel.getLongitude());
		point.setType(mapModel.getType());
		MapModel saved = mapRepository.save(point);
		logger.info("User: " + user.getId() + " updated a map point from: " + old + " to: " + saved);
		return MapDtoMapper.mapToDto(saved);
	}
}
