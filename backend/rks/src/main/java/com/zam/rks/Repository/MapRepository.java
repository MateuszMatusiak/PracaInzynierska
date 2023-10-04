package com.zam.rks.Repository;

import com.zam.rks.model.Group;
import com.zam.rks.model.MapModel;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface MapRepository extends JpaRepository<MapModel, Integer> {
	@EntityGraph(attributePaths = {"events"})
	List<MapModel> findAllByGroup(Group group);
}
