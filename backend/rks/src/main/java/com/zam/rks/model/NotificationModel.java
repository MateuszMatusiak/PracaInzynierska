package com.zam.rks.model;

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
@Table(name = "m_notification")
public class NotificationModel {
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private int id;
	private String title;
	private String body;
	private boolean seen;
	private Timestamp createdAt;
	@OneToOne
	@JoinColumn(name = "user_id", referencedColumnName = "id")
	private User user;

	public NotificationModel(String title, String body, User user) {
		this.title = title;
		this.body = body;
		this.user = user;
		this.seen = false;
		this.createdAt = new Timestamp(ZonedDateTime.now(ZoneId.of("Europe/Warsaw")).toInstant().toEpochMilli());
	}

	@Override
	public String toString() {
		return "NotificationModel{" +
				"title='" + title + '\'' +
				", body='" + body + '\'' +
				", user=" + user +
				'}';
	}
}
