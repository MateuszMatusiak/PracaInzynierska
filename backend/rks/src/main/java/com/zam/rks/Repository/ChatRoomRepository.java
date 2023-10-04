package com.zam.rks.Repository;

import com.zam.rks.model.ChatRoom;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface ChatRoomRepository extends JpaRepository<ChatRoom, Integer> {
	//	@EntityGraph(attributePaths = {"users"})
	@Query("SELECT c FROM ChatRoom c LEFT JOIN FETCH c.users u WHERE c.firebaseId = :firebaseId")
	public Optional<ChatRoom> findByFirebaseId(@Param("firebaseId") String firebaseId);
}
