package com.zam.rks.Repository;

import com.zam.rks.model.ChatRoom;
import com.zam.rks.model.ChatRoomMutedUser;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;

import javax.transaction.Transactional;
import java.util.List;

public interface ChatRoomMutedUserRepository extends JpaRepository<ChatRoomMutedUser, Integer> {
	List<ChatRoomMutedUser> findAllByRoom(ChatRoom room);

	@Modifying
	@Query("DELETE FROM ChatRoomMutedUser cr WHERE cr.id = ?1")
	void deleteById(int id);

	@Modifying
	@Transactional
	@Query(value = "DELETE FROM m_chat_room_muted_users cr WHERE cr.muted_user_id = :mutedUserId AND cr.room_id = :chatRoomId AND cr.user_id = :userId", nativeQuery = true)
	void deleteByMutedUserAndChatRoomIdForUser(int mutedUserId, int chatRoomId, int userId);

	@Modifying
	@Transactional
	@Query(value = "DELETE FROM m_chat_room_muted_users cr WHERE cr.muted_user_id IS NULL AND cr.room_id = :chatRoomId AND cr.user_id = :userId", nativeQuery = true)
	void deleteByChatRoomIdForUser(int chatRoomId, int userId);
}
