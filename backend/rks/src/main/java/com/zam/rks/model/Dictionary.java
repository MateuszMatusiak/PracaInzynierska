package com.zam.rks.model;

import lombok.Getter;
import lombok.Setter;

import javax.persistence.*;
import java.sql.Timestamp;
import java.time.ZoneId;
import java.time.ZonedDateTime;

@Getter
@Setter
@Entity
@Table(name = "m_dictionary")
public class Dictionary {
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private int id;
	@Column(columnDefinition = "TEXT")
	private String entry;
	@Column(columnDefinition = "TEXT")
	private String description;

	@OneToOne(cascade = CascadeType.MERGE)
	@JoinColumn(name = "group_id", referencedColumnName = "id")
	private Group group;
	@Column(columnDefinition = "TIMESTAMP default CURRENT_TIMESTAMP")
	private Timestamp creationTime;

	public Dictionary() {
	}

	public Dictionary(String entry, String description, Group group) {
		this.entry = entry;
		this.description = description;
		this.creationTime = new Timestamp(ZonedDateTime.now(ZoneId.of("Europe/Warsaw")).toInstant().toEpochMilli());
		this.group = group;
	}

	public Dictionary(Dictionary dictionary) {
		this.entry = dictionary.getEntry();
		this.description = dictionary.getDescription();
		this.creationTime = dictionary.getCreationTime();
		this.group = dictionary.getGroup();
	}

	@Override
	public String toString() {
		return "Dictionary{" +
				"id=" + id +
				", entry='" + entry + '\'' +
				", description='" + description + '\'' +
				'}';
	}
}
