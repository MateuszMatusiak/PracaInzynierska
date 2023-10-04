package com.zam.rks.Repository;

import com.zam.rks.model.ChatMessage;
import com.zam.rks.model.ChatRoom;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ChatRepository extends JpaRepository<ChatMessage, Integer> {
	public List<ChatMessage> findAllByRoomOrderByTimeDesc(ChatRoom room);
}
