package com.zam.rks.Repository;

import com.zam.rks.model.Event;
import com.zam.rks.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface EventRepository extends JpaRepository<Event, Integer> {


	//	@EntityGraph(attributePaths = {"users", "localization"})
	@Query("SELECT e FROM Event e LEFT JOIN FETCH e.users u LEFT JOIN FETCH e.localization WHERE e.id = ?1")
	Optional<Event> findById(int id);

	@Query("SELECT e FROM Event e WHERE e.id = ?1")
	Optional<Event> findSingleById(int id);

	@Query("SELECT DISTINCT e FROM Event e JOIN e.users u WHERE u = :user")
	List<Event> findAllForUser(User user);

	List<Event> findAllByLocalizationIdOrderByName(int id);
}
