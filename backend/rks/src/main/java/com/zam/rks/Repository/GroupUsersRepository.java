package com.zam.rks.Repository;

import com.zam.rks.model.GroupUser;
import com.zam.rks.model.UserRole;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface GroupUsersRepository extends JpaRepository<GroupUser, Integer> {
	//	@EntityGraph(attributePaths = {"group"})
	@Query("SELECT gu FROM GroupUser gu LEFT JOIN FETCH gu.group WHERE gu.user.id = ?1")
	List<GroupUser> findByUserId(int id);

	//	@EntityGraph(attributePaths = {"user"})
	@Query("SELECT gu FROM GroupUser gu LEFT JOIN FETCH gu.user WHERE gu.group.id = ?1")
	List<GroupUser> findByGroupId(int id);

	@Modifying
	@Query("DELETE FROM GroupUser gu WHERE gu.group.id = ?1 AND gu.user.id = ?2")
	void deleteByGroupIdAndUserId(int groupId, int userId);

	@Modifying
	@Query("UPDATE GroupUser gu SET gu.role = ?3 WHERE gu.group.id = ?1 AND gu.user.id = ?2")
	void updateUserRoleInGroup(int groupId, int userId, UserRole role);
}
