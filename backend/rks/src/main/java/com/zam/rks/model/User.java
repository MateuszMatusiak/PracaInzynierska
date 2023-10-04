package com.zam.rks.model;


import com.zam.rks.Utils.StringListConverter;
import com.zam.rks.model.Body.UserBody;
import lombok.Getter;
import lombok.Setter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import javax.persistence.*;
import java.sql.Date;
import java.sql.Timestamp;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.*;

@Getter
@Setter
@Entity
@Table(name = "m_user")
public class User implements UserDetails {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private int id;
	private String email;
	private String password;
	private String firstName;
	private String lastName;
	private Date birthdate;
	private String phoneNumber;
	private String nickname;
	private String firebaseId;
	@Convert(converter = StringListConverter.class)
	@Column(columnDefinition = "TEXT")
	private List<String> deviceTokens = new ArrayList<>();
	@OneToOne(cascade = CascadeType.ALL)
	@JoinColumn(name = "selected_group", referencedColumnName = "id")
	private Group selectedGroup;
	@Transient
	private List<Group> groups = new ArrayList<>();
	@ManyToMany(fetch = FetchType.LAZY)
	@OrderBy("SUBSTRING(startDate, 1, 10) ASC, name ASC, SUBSTRING(startDate, 11) ASC")
	@JoinTable(name = "m_event_users",
			joinColumns = @JoinColumn(name = "user_id"),
			inverseJoinColumns = @JoinColumn(name = "event_id"))
	private List<Event> events = new ArrayList<>();
	@Column(columnDefinition = "TIMESTAMP default CURRENT_TIMESTAMP")
	private Timestamp creationTime;
	private Boolean enabled;
	private Boolean locked;
	@Transient
	private UserRole role;
	@ManyToMany(fetch = FetchType.LAZY)
	@JoinTable(name = "m_chat_room_users",
			joinColumns = @JoinColumn(name = "user_id"),
			inverseJoinColumns = @JoinColumn(name = "room_id"))
	private List<ChatRoom> chatRooms = new ArrayList<>();

	public User(User oldUser, UserBody newUser) {
		this.id = oldUser.id;
		this.email = oldUser.email;
		this.password = oldUser.password;

		this.firstName = newUser.getFirstName() == null || newUser.getFirstName().isEmpty() ? oldUser.firstName : newUser.getFirstName();
		this.lastName = newUser.getLastName() == null || newUser.getLastName().isEmpty() ? oldUser.lastName : newUser.getLastName();
		this.birthdate = newUser.getBirthdate() == null ? oldUser.birthdate : newUser.getBirthdate();
		this.phoneNumber = newUser.getPhoneNumber() == null || newUser.getPhoneNumber().isEmpty() ? oldUser.phoneNumber : newUser.getPhoneNumber();
		this.nickname = newUser.getNickname() == null || newUser.getNickname().isEmpty() ? oldUser.nickname : newUser.getNickname();
		this.firebaseId = newUser.getFirebaseId() == null || newUser.getFirebaseId().isEmpty() ? oldUser.firebaseId : newUser.getFirebaseId();
		this.selectedGroup = oldUser.selectedGroup;

		this.locked = oldUser.locked;
		this.role = oldUser.role;
		this.enabled = oldUser.enabled;
		this.creationTime = oldUser.creationTime;
		this.groups = oldUser.getGroups();
		this.events = oldUser.getEvents();
		this.deviceTokens = oldUser.getDeviceTokens();
	}


	public User(String email, String password) {
		this.email = email;
		this.password = password;
		this.firstName = "";
		this.lastName = "";
		this.birthdate = null;
		this.phoneNumber = "";
		this.nickname = "";
		this.selectedGroup = null;
		this.role = UserRole.ROLE_USER;
		this.enabled = false;
		this.locked = false;
		this.deviceTokens = new ArrayList<>();
		this.creationTime = new Timestamp(ZonedDateTime.now(ZoneId.of("Europe/Warsaw")).toInstant().toEpochMilli());
	}

	public User() {
	}

	@Override
	public Collection<? extends GrantedAuthority> getAuthorities() {
		return Collections.singleton(new SimpleGrantedAuthority(role.name()));
	}

	public String getStringRole() {
		return role != null ? role.toString() : "";
	}

	public boolean isOwner() {
		return role == UserRole.ROLE_OWNER;
	}

	public boolean isAdmin() {
		return role == UserRole.ROLE_OWNER || role == UserRole.ROLE_ADMIN;
	}

	public boolean isModerator() {
		return role == UserRole.ROLE_OWNER || role == UserRole.ROLE_ADMIN || role == UserRole.ROLE_MODERATOR;
	}

	@Override
	public boolean equals(Object o) {
		if (this == o) return true;
		if (o == null || getClass() != o.getClass()) return false;
		User user = (User) o;
		return id == user.id && email.equals(user.email) && firebaseId.equals(user.firebaseId);
	}

	@Override
	public int hashCode() {
		return Objects.hash(id, email, firebaseId);
	}

	@Override
	public String getUsername() {
		return email;
	}

	public boolean isAccountNonExpired() {
		return true;
	}

	public boolean isAccountNonLocked() {
		return !locked;
	}

	public boolean isCredentialsNonExpired() {
		return true;
	}

	public boolean isEnabled() {
		return enabled;
	}

	public boolean hasRequiredData() {
		return !this.getFirstName().trim().isEmpty() &&
				!this.getLastName().trim().isEmpty() &&
				this.getBirthdate() != null &&
				!this.getPhoneNumber().trim().isEmpty();
	}

	@Override
	public String toString() {
		return "User{" +
				"id=" + id +
				", email='" + email + '\'' +
				", firstName='" + firstName + '\'' +
				", lastName='" + lastName + '\'' +
				", birthdate=" + birthdate +
				", phoneNumber='" + phoneNumber + '\'' +
				", nickname='" + nickname + '\'' +
				", firebaseId='" + firebaseId + '\'' +
				'}';
	}
}
