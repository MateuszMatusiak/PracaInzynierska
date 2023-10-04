package com.zam.rks.model;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.lang.NonNull;

import javax.persistence.*;
import java.sql.Timestamp;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "m_chat_room_muted_users")
public class ChatRoomMutedUser {
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private int id;
	@ManyToOne(cascade = CascadeType.ALL, fetch = FetchType.LAZY)
	@JoinColumn(name = "room_id", referencedColumnName = "id")
	@NonNull
	private ChatRoom room;
	@ManyToOne(cascade = CascadeType.ALL, fetch = FetchType.LAZY)
	@JoinColumn(name = "user_id", referencedColumnName = "id")
	@NonNull
	private User user;

	@ManyToOne(cascade = CascadeType.ALL, fetch = FetchType.LAZY)
	@JoinColumn(name = "muted_user_id", referencedColumnName = "id")
	private User mutedUser;
	private Timestamp mutedUntil;

	public ChatRoomMutedUser(@NonNull ChatRoom room, @NonNull User user, User mutedUser, Timestamp mutedUntil) {
		this.id = -1;
		this.room = room;
		this.user = user;
		this.mutedUser = mutedUser;
		this.mutedUntil = mutedUntil;
	}
}
