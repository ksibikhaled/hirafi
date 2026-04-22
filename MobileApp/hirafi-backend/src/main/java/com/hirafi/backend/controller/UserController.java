package com.hirafi.backend.controller;

import com.hirafi.backend.dto.*;
import com.hirafi.backend.entity.User;
import com.hirafi.backend.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping("/profile")
    public ResponseEntity<ApiResponse<UserProfileDTO>> getProfile(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(ApiResponse.success(userService.getProfile(user)));
    }

    @PutMapping("/profile")
    public ResponseEntity<ApiResponse<UserProfileDTO>> updateProfile(
            @AuthenticationPrincipal User user,
            @RequestBody UserProfileDTO request) {
        return ResponseEntity.ok(ApiResponse.success(userService.updateProfile(user, request)));
    }

    @PostMapping("/follow/{workerId}")
    public ResponseEntity<ApiResponse<String>> followWorker(
            @AuthenticationPrincipal User user,
            @PathVariable Long workerId) {
        userService.followWorker(user, workerId);
        return ResponseEntity.ok(ApiResponse.success("Worker followed successfully", null));
    }

    @DeleteMapping("/unfollow/{workerId}")
    public ResponseEntity<ApiResponse<String>> unfollowWorker(
            @AuthenticationPrincipal User user,
            @PathVariable Long workerId) {
        userService.unfollowWorker(user, workerId);
        return ResponseEntity.ok(ApiResponse.success("Worker unfollowed successfully", null));
    }

    @GetMapping("/following")
    public ResponseEntity<ApiResponse<Page<WorkerDTO>>> getFollowing(
            @AuthenticationPrincipal User user,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(ApiResponse.success(
                userService.getFollowingWorkers(user, PageRequest.of(page, size))));
    }

    @GetMapping("/feed")
    public ResponseEntity<ApiResponse<Page<PostDTO>>> getFeed(
            @AuthenticationPrincipal User user,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(ApiResponse.success(
                userService.getFeed(user, PageRequest.of(page, size))));
    }

    @PostMapping("/posts/{postId}/like")
    public ResponseEntity<ApiResponse<String>> toggleReaction(
            @AuthenticationPrincipal User user,
            @PathVariable Long postId,
            @RequestParam(required = false) String type) {
        userService.toggleReaction(user, postId, type);
        return ResponseEntity.ok(ApiResponse.success("Success"));
    }

    @PostMapping("/posts/{postId}/comment")
    public ResponseEntity<ApiResponse<String>> addComment(
            @AuthenticationPrincipal User user,
            @PathVariable Long postId,
            @RequestBody CommentRequest request) {
        userService.addComment(user, postId, request);
        return ResponseEntity.ok(ApiResponse.success("Comment added"));
    }

    @GetMapping("/posts/{postId}/comments")
    public ResponseEntity<ApiResponse<Page<CommentDTO>>> getComments(
            @PathVariable Long postId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(ApiResponse.success(
                userService.getComments(postId, PageRequest.of(page, size))));
    }

    @GetMapping("/notifications")
    public ResponseEntity<ApiResponse<Page<NotificationDTO>>> getNotifications(
            @AuthenticationPrincipal User user,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(ApiResponse.success(
                userService.getNotifications(user, PageRequest.of(page, size))));
    }

    @PutMapping("/notifications/{id}/read")
    public ResponseEntity<ApiResponse<Void>> markAsRead(@PathVariable Long id) {
        userService.markNotificationAsRead(id);
        return ResponseEntity.ok(ApiResponse.success(null));
    }
}
