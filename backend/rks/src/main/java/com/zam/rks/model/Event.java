package com.zam.rks.model;

import com.zam.rks.Utils.Date;
import com.zam.rks.model.Body.EventBody;
import lombok.Getter;
import lombok.Setter;
import org.springframework.lang.NonNull;
import org.springframework.lang.Nullable;

import javax.persistence.*;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@Entity
@Table(name = "m_event")
public class Event {
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private int id;
	private String name;
	private String description;
	@NonNull
	private Timestamp startDate;
	@Nullable
	private Timestamp endDate;
	@NonNull
	@OneToOne(cascade = CascadeType.ALL)
	@JoinColumn(name = "user_id", referencedColumnName = "id")
	private User creator;
	@ManyToOne(cascade = CascadeType.ALL, fetch = FetchType.LAZY)
	@JoinColumn(name = "localization_id", referencedColumnName = "id")
	@Nullable
	private MapModel localization;
	@ManyToMany(fetch = FetchType.LAZY)
	@JoinTable(name = "m_event_users", joinColumns = @JoinColumn(name = "event_id"), inverseJoinColumns = @JoinColumn(name = "user_id"))
	List<User> users = new ArrayList<>();


	public Event(EventBody e, MapModel localization, User creator) {
		this.id = -1;
		this.name = e.getName() == null ? "" : e.getName();
		this.startDate = new Date(e.getStartDate()).getTimestamp();
		this.endDate = e.getEndDate() == null ? null : new Date(e.getEndDate()).getTimestamp();
		this.users = new ArrayList<>();
		this.localization = localization;
		this.description = e.getDescription();
		this.creator = creator;
	}

	public Event(Event other) {
		this.id = other.id;
		this.name = other.name;
		this.description = other.description;
		this.startDate = other.startDate;
		this.endDate = other.endDate;
		this.creator = other.creator;
		this.localization = other.localization;
		this.users.addAll(other.users);
	}

	public Event() {
	}

	public void addUser(User user) {
		this.users.add(user);
	}

	@Override
	public String toString() {
		return "Event{" +
				"id=" + id +
				", name='" + name + '\'' +
				", description='" + description + '\'' +
				", startDate=" + startDate +
				", endDate=" + endDate +
				", localization=" + localization +
				", users=" + users +
				'}';
	}
}
