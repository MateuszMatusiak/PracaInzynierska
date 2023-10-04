package com.zam.rks.Repository;

import com.zam.rks.model.Group;
import com.zam.rks.model.Post;
import com.zam.rks.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PostRepository extends JpaRepository<Post, Integer> {

	List<Post> findAllByGroupOrderByDateDesc(Group group);
	@Query("SELECT p FROM Post p WHERE p.user = :user OR p.event.id IN (SELECT DISTINCT e FROM Event e JOIN e.users u WHERE u = :user) OR p.group.id = :groupId ORDER BY p.date DESC")
	List<Post> findPostsForUserAndGroup(@Param("user") User user, @Param("groupId") int groupId);

}
