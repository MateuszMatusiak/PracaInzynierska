package com.zam.rks.model;

import lombok.Getter;
import lombok.Setter;
import org.springframework.lang.Nullable;

import javax.persistence.*;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@Getter
@Setter
@Entity
@Table(name = "m_post")
public class Post {
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private int id;

	private String content;
	private Timestamp date;
	@OneToOne(cascade = CascadeType.ALL)
	@JoinColumn(name = "user_id", referencedColumnName = "id")
	private User user;

	@OneToMany(cascade = CascadeType.ALL)
	@JoinColumn(name = "post_id", referencedColumnName = "id")
	private List<Comment> comments = new ArrayList<>();

	@OneToOne(cascade = CascadeType.ALL)
	@JoinColumn(name = "group_id", referencedColumnName = "id")
	@Nullable
	private Group group;

	@OneToOne(cascade = CascadeType.ALL)
	@JoinColumn(name = "event_id", referencedColumnName = "id")
	@Nullable
	private Event event;

	public Post() {
	}

	public Post(String content, User user, Group group, Event event) {
		this.id = -1;
		this.content = content;
		this.user = user;
		this.group = group;
		this.date = new Timestamp(new Date().getTime());
		this.event = event;
	}
}
