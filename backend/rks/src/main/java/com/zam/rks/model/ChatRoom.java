package com.zam.rks.model;

import com.zam.rks.model.Body.ChatRoomBody;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import javax.persistence.*;
import java.sql.Timestamp;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@Entity
@NoArgsConstructor
@Table(name = "m_chat_room")
public class ChatRoom {
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private int id;
	private String name;
	private String firebaseId;
	private Timestamp creationDate;
	@ManyToMany(fetch = FetchType.LAZY)
	@JoinTable(name = "m_chat_room_users",
			joinColumns = @JoinColumn(name = "room_id"),
			inverseJoinColumns = @JoinColumn(name = "user_id"))
	private List<User> users = new ArrayList<>();
	@OneToOne(cascade = CascadeType.ALL)
	@JoinColumn(name = "user_id", referencedColumnName = "id")
	private User creator;

	private String imageUrl;

	public ChatRoom(ChatRoomBody room, User creator) {
		this.id = -1;
		this.name = room.getName();
		this.firebaseId = room.getFirebaseId();
		this.creationDate = new Timestamp(ZonedDateTime.now(ZoneId.of("Europe/Warsaw")).toInstant().toEpochMilli());
		this.imageUrl = room.getImageUrl() == null ? "" : room.getImageUrl();
		this.creator = creator;
		this.users = new ArrayList<>();
	}

	public void addUser(User user) {
		this.users.add(user);
	}
}
