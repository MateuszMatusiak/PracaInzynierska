package com.zam.rks.model;

import com.zam.rks.model.Body.MessageBody;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import javax.persistence.*;
import java.sql.Timestamp;
import java.time.ZoneId;
import java.time.ZonedDateTime;

@Getter
@Setter
@Entity
@NoArgsConstructor
@Table(name = "m_room_message")
public class ChatMessage {
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private int id;
	private String message;
	@Column(columnDefinition = "TIMESTAMP default CURRENT_TIMESTAMP")
	private Timestamp time;
	@OneToOne(cascade = CascadeType.ALL)
	@JoinColumn(name = "user_id", referencedColumnName = "id")
	private User author;
	@OneToOne(cascade = CascadeType.ALL)
	@JoinColumn(name = "room_id", referencedColumnName = "id")
	private ChatRoom room;

	public ChatMessage(MessageBody model, User user, ChatRoom room) {
		this.id = -1;
		this.message = model.getMessage();
		this.time = new Timestamp(ZonedDateTime.now(ZoneId.of("Europe/Warsaw")).toInstant().toEpochMilli());
		this.author = user;
		this.room = room;
	}
}

