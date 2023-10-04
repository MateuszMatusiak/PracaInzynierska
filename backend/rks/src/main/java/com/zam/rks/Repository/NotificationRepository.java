package com.zam.rks.Repository;

import com.zam.rks.model.NotificationModel;
import com.zam.rks.model.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface NotificationRepository extends JpaRepository<NotificationModel, Integer> {
	List<NotificationModel> findAllByUserOrderByCreatedAt(User user);

	List<NotificationModel> findAllByIdInAndUser(List<Integer> ids, User user);
}
