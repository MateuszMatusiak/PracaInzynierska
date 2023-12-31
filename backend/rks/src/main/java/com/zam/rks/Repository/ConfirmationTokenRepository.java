package com.zam.rks.Repository;

import com.zam.rks.model.ConfirmationToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;

import javax.transaction.Transactional;
import java.time.LocalDateTime;
import java.util.Optional;

public interface ConfirmationTokenRepository extends JpaRepository<ConfirmationToken, Integer> {
	Optional<ConfirmationToken> findByToken(String token);

	@Transactional
	@Modifying
	@Query("UPDATE ConfirmationToken c " +
			"SET c.confirmedAt = ?2 " +
			"WHERE c.token = ?1")
	int updateConfirmedAt(String token,
						  LocalDateTime confirmedAt);
}
