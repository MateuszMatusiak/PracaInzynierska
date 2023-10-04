package com.zam.rks.model;

import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;

import javax.persistence.*;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Getter
@Setter
@Entity
@EqualsAndHashCode
@Table(name = "m_group")
public class Group {
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private int id;
	private String name;
	@Transient
	private List<GroupUser> users = new ArrayList<>();

	public Group() {
	}

	public Group(String name, List<User> users) {
		this.name = name;
		for (User u : users) {
			this.users.add(new GroupUser(this, u, UserRole.ROLE_USER));
		}
	}

	public boolean addUser(User user, UserRole role) {
		boolean canBeAdded = true;
		for (GroupUser u : users) {
			if (u.getUser().getId() == user.getId()) {
				canBeAdded = false;
				break;
			}
		}
		if (canBeAdded)
			users.add(new GroupUser(this, user, role));
		return canBeAdded;
	}

	public void updateUserRole(User user, UserRole role) {
		for (GroupUser u : users) {
			if (u.getUser().getId() == user.getId()) {
				u.setRole(role);
				break;
			}
		}
	}

	public List<User> getUsersList() {
		return this.users.stream().map(GroupUser::getUser).collect(Collectors.toList());
	}

	@Override
	public String toString() {
		return "Group{" +
				"id=" + id +
				", name='" + name + '\'' +
				", users=" + users +
				'}';
	}
}
