package com.zam.rks.controller;

import com.zam.rks.Service.PostService;
import com.zam.rks.Utils.U;
import com.zam.rks.model.Body.CommentBody;
import com.zam.rks.model.Body.PostBody;
import lombok.AllArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@AllArgsConstructor
@RestController
@RequestMapping("/post")
public class PostController {
	private final PostService postService;

	@GetMapping
	public ResponseEntity<?> getPosts() {
		return U.handleReturn(postService::getPosts);
	}

	@PostMapping
	public ResponseEntity<?> insertPost(@RequestBody PostBody post) {
		return U.handleReturn(() -> postService.insertPost(post));
	}

	@PutMapping("/{id}")
	public ResponseEntity<?> updatePost(@PathVariable int id, @RequestBody PostBody post) {
		return U.handleReturn(() -> postService.updatePost(id, post));
	}

	@GetMapping("/{id}/comments")
	public ResponseEntity<?> getComments(@PathVariable int id) {
		return U.handleReturn(() -> postService.getComments(id));
	}

	@PostMapping("/{id}/comment")
	public ResponseEntity<?> insertComment(@PathVariable int id, @RequestBody CommentBody comment) {
		return U.handleReturn(() -> postService.insertComment(id, comment));
	}

	@PutMapping("/comment/{commentId}")
	public ResponseEntity<?> updateComment(@PathVariable int commentId, @RequestBody CommentBody comment) {
		return U.handleReturn(() -> postService.updateComment(commentId, comment));
	}
}
