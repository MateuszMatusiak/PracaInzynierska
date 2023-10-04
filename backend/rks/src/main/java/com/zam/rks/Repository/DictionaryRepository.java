package com.zam.rks.Repository;

import com.zam.rks.model.Dictionary;
import com.zam.rks.model.Group;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface DictionaryRepository extends JpaRepository<Dictionary, Integer> {

	@Query("SELECT d FROM Dictionary d WHERE  d.entry LIKE %:entry%")
	List<Dictionary> findByEntryLike(@Param("entry") String entry);

	Optional<Dictionary> findByEntryAndGroup(String entry, Group group);

	List<Dictionary> findAllByGroupOrderByEntryAsc(Group group);
}
