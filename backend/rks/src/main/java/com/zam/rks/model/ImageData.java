package com.zam.rks.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;
import org.springframework.lang.Nullable;

import javax.persistence.*;

@Getter
@Setter
@Entity
@AllArgsConstructor
@Table(name = "m_image")
public class ImageData {
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private int id;
	private String name;
	private String type;
	private String filePath;
	@OneToOne(cascade = CascadeType.ALL)
	@JoinColumn(name = "user_id", referencedColumnName = "id")
	@JsonIgnore
	private User user;
	@OneToOne(cascade = CascadeType.ALL)
	@JoinColumn(name = "group_id", referencedColumnName = "id")
	@JsonIgnore
	private Group group;
	@OneToOne(cascade = CascadeType.ALL)
	@JoinColumn(name = "event_id", referencedColumnName = "id")
	@Nullable
	@JsonIgnore
	private Event event;

	public ImageData() {
	}

	@Override
	public String toString() {
		return "ImageData{" +
				"id=" + id +
				", name='" + name + '\'' +
				", type='" + type + '\'' +
				", filePath='" + filePath + '\'' +
				'}';
	}
}
