package com.zam.rks.Repository;

import com.zam.rks.model.User;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import javax.transaction.Transactional;
import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Integer> {

	@EntityGraph(attributePaths = {"events", "selectedGroup"})
	Optional<User> findByEmail(String email);

	List<User> findAllByIdIn(int[] ids);

	List<User> findByNicknameLikeOrFirstNameLikeOrLastNameLikeOrderByNicknameAscFirstNameAscLastNameAsc(String nickname, String firstname, String lastname);

	@Transactional
	@Modifying
	@Query("UPDATE User u " +
			"SET u.enabled = TRUE WHERE u.email = ?1")
	int enableAppUser(String email);
}
