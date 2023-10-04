package com.zam.rks.Service;

import com.zam.rks.Dto.CommentDto;
import com.zam.rks.Dto.Mapper.CommentDtoMapper;
import com.zam.rks.Dto.Mapper.PostDtoMapper;
import com.zam.rks.Dto.PostDto;
import com.zam.rks.Repository.CommentRepository;
import com.zam.rks.Repository.EventRepository;
import com.zam.rks.Repository.PostRepository;
import com.zam.rks.Utils.UtilService;
import com.zam.rks.model.*;
import com.zam.rks.model.Body.CommentBody;
import com.zam.rks.model.Body.PostBody;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Scope;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.Optional;

@AllArgsConstructor
@Service
@Scope
public class PostService {

	private final PostRepository postRepository;
	private final CommentRepository commentRepository;
	private final EventRepository eventRepository;
	private final UtilService utilService;
	private final NotificationService notificationService;
	private static final Logger logger = LoggerFactory.getLogger(PostService.class);

	public List<PostDto> getPosts() {
		User user = utilService.getUser();
		List<Post> posts = postRepository.findPostsForUserAndGroup(user, user.getSelectedGroup().getId());
		Calendar calendar = Calendar.getInstance();
		calendar.setTimeInMillis(System.currentTimeMillis());
		calendar.add(Calendar.HOUR_OF_DAY, -24);

		List<Post> result = new ArrayList<>();
		for (Post post : posts) {
			if (post.getEvent() != null) {
				boolean isArchive = post.getEvent().getEndDate() != null ? post.getEvent().getEndDate().before(new Timestamp(calendar.getTimeInMillis())) : post.getEvent().getStartDate().before(new Timestamp(calendar.getTimeInMillis()));
				if (!isArchive) {
					result.add(post);
				}
			} else {
				result.add(post);
			}
		}
		return PostDtoMapper.mapPostsToDto(result);
	}

	public PostDto insertPost(PostBody post) {
		User user = utilService.getUser();
		Event event = null;
		if (post.getEventId() > 0) {
			Optional<Event> e = eventRepository.findById(post.getEventId());
			if (e.isEmpty()) {
				logger.warn("User: " + user.getId() + " tried to add a post to event: " + post.getEventId() + " which wasn't found");
				throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Event not found");
			}
			event = e.get();
		}
		Group group = null;
		if (event == null) {
			group = user.getSelectedGroup();
		}
		Post postToSave = new Post(post.getContent(), user, group, event);
		Post saved = postRepository.save(postToSave);
		logger.info("User: " + user.getId() + " added a post: " + saved.getId() + " to event: " + post.getEventId());
		notificationService.sendNotificationToGroup(user.getSelectedGroup(), user.getSelectedGroup().getName(), user.getFirstName() + " dodał nowy post");
		return PostDtoMapper.mapToDto(saved);
	}

	public PostDto updatePost(int id, PostBody post) {
		User user = utilService.getUser();
		Optional<Post> postToUpdate = postRepository.findById(id);
		if (postToUpdate.isEmpty()) {
			logger.warn("User: " + user.getId() + " tried to update a post: " + id + " which wasn't found");
			throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Post not found");
		}
		String contentBefore = postToUpdate.get().getContent();
		if (postToUpdate.get().getUser().getId() != user.getId()) {
			logger.warn("User: " + user.getId() + " tried to update a post: " + id + " which it doesn't have access to");
			throw new ResponseStatusException(HttpStatus.FORBIDDEN, "User not allowed to update this post");
		}
		postToUpdate.get().setContent(post.getContent());
		Post saved = postRepository.save(postToUpdate.get());
		logger.info("User: " + user.getId() + " updated a post: " + saved.getId() + " from: " + contentBefore + " to: " + saved.getContent());
		return PostDtoMapper.mapToDto(saved);
	}

	public List<CommentDto> getComments(int id) {
		User user = utilService.getUser();
		List<Comment> comments = commentRepository.findAllByPostIdOrderByDateDesc(id);
		return CommentDtoMapper.mapCommentsToDto(comments);
	}

	public CommentDto insertComment(int id, CommentBody comment) {
		User user = utilService.getUser();
		Optional<Post> post = postRepository.findById(id);
		if (post.isEmpty()) {
			logger.warn("User: " + user.getId() + " tried to insert a comment to post: " + id + " which wasn't found");
			throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Post not found");
		}
		Comment commentToSave = new Comment(comment.getContent(), post.get(), user);
		Comment savedComment = commentRepository.save(commentToSave);
		logger.info("User: " + user.getId() + " added a comment: " + savedComment.getId() + " to a post: " + savedComment.getPost().getId());
		return CommentDtoMapper.mapToDto(savedComment);
	}

	public CommentDto updateComment(int commentId, CommentBody comment) {
		User user = utilService.getUser();
		Optional<Comment> commentToUpdate = commentRepository.findById(commentId);
		if (commentToUpdate.isEmpty()) {
			logger.warn("User: " + user.getId() + " tried to update a comment: " + commentId + " which wasn't found");
			throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Comment not found");
		}
		String contentBefore = commentToUpdate.get().getContent();

		if (commentToUpdate.get().getUser().getId() != user.getId()) {
			logger.warn("User: " + user.getId() + " tried to update a comment: " + commentId + " which it doesn't have access to");
			throw new ResponseStatusException(HttpStatus.FORBIDDEN, "User not allowed to update this comment");
		}
		commentToUpdate.get().setContent(comment.getContent());
		Comment savedComment = commentRepository.save(commentRepository.save(commentToUpdate.get()));
		logger.info("User: " + user.getId() + " updated a comment: " + savedComment.getId() + " from: " + contentBefore + " to: " + savedComment.getContent());
		return CommentDtoMapper.mapToDto(savedComment);
	}
}
