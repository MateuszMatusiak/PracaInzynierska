package com.zam.rks.model;

import com.zam.rks.model.Body.MapBody;
import lombok.Getter;
import lombok.Setter;

import javax.persistence.*;
import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@Entity
@Table(name = "m_map")
public class MapModel {
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private int id;
	private String name;
	private double latitude;
	private double longitude;
	private String type;
	@OneToMany(cascade = CascadeType.ALL)
	@JoinColumn(name = "localization_id", referencedColumnName = "id")
	private List<Event> events;
	@OneToOne(cascade = CascadeType.MERGE)
	@JoinColumn(name = "group_id", referencedColumnName = "id")
	private Group group;

	public MapModel() {
	}

	public MapModel(String name, double latitude, double longitude, String type, Group group) {
		this.name = name;
		this.latitude = latitude;
		this.longitude = longitude;
		this.type = type;
		this.group = group;
	}

	public MapModel(MapBody map, Group group) {
		this.name = map.getName();
		this.latitude = map.getLatitude();
		this.longitude = map.getLongitude();
		this.type = map.getType();
		this.group = group;
		this.events = new ArrayList<>();
	}

	public MapModel(MapModel other) {
		this.id = other.id;
		this.name = other.name;
		this.latitude = other.latitude;
		this.longitude = other.longitude;
		this.type = other.type;
		this.events = other.events;
		this.group = other.group;
	}

	@Override
	public String toString() {
		return "MapModel{" +
				"id=" + id +
				", name='" + name + '\'' +
				", latitude=" + latitude +
				", longitude=" + longitude +
				", type=" + type +
				'}';
	}
}
