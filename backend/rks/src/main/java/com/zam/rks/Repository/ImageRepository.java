package com.zam.rks.Repository;

import com.zam.rks.model.Event;
import com.zam.rks.model.Group;
import com.zam.rks.model.ImageData;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ImageRepository extends JpaRepository<ImageData, Integer> {
	Optional<ImageData> findByName(String fileName);

	Optional<ImageData> findByNameAndUserId(String fileName, int userId);

	Optional<ImageData> findByNameAndGroupId(String fileName, int groupId);

	Optional<ImageData> findByNameAndEventId(String fileName, int eventId);

	List<ImageData> findAllByGroupOrderByIdDesc(Group group);

	List<ImageData> findAllByIdInAndGroupOrderByIdDesc(int[] ids, Group group);

	List<ImageData> findAllByEventOrderByIdDesc(Event event);
}
