package com.zam.rks.model;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.lang.NonNull;

import javax.persistence.*;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "m_group_users")
public class GroupUser {
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private int id;
	@ManyToOne(cascade = CascadeType.ALL, fetch = FetchType.LAZY)
	@JoinColumn(name = "group_id", referencedColumnName = "id")
	private Group group;
	@ManyToOne(cascade = CascadeType.ALL, fetch = FetchType.LAZY)
	@JoinColumn(name = "user_id", referencedColumnName = "id")
	private User user;
	@Enumerated(EnumType.STRING)
	private UserRole role;

	public GroupUser(@NonNull Group group, @NonNull User user, UserRole role) {
		this.id = -1;
		this.group = group;
		this.user = user;
		this.role = role;
	}

	@NonNull
	public User getUser() {
		user.setRole(role);
		return user;
	}

	@Override
	public String toString() {
		return "GroupUser{" +
				"user=" + user.getId() +
				", role=" + role +
				'}';
	}
}
