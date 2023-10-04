package com.zam.rks.Repository;

import com.zam.rks.model.Group;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface GroupRepository extends JpaRepository<Group, Integer> {

	Optional<Group> findByName(String groupName);

	Optional<Group> findById(int id);

}
