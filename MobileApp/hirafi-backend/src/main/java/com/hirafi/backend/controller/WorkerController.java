package com.hirafi.backend.controller;

import com.hirafi.backend.dto.*;
import com.hirafi.backend.entity.User;
import com.hirafi.backend.service.WorkerService;
import com.hirafi.backend.service.WorkRequestService;
import com.hirafi.backend.service.FollowerService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/api/workers")
@RequiredArgsConstructor
public class WorkerController {

    private final WorkerService workerService;
    private final WorkRequestService workRequestService;
    private final FollowerService followerService;

    @PostMapping("/{id}/follow")
    public ResponseEntity<ApiResponse<String>> follow(
            @AuthenticationPrincipal User user,
            @PathVariable Long id) {
        followerService.follow(user.getId(), id);
        return ResponseEntity.ok(ApiResponse.success("Followed successfully", null));
    }

    @PostMapping("/{id}/unfollow")
    public ResponseEntity<ApiResponse<String>> unfollow(
            @AuthenticationPrincipal User user,
            @PathVariable Long id) {
        followerService.unfollow(user.getId(), id);
        return ResponseEntity.ok(ApiResponse.success("Unfollowed successfully", null));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<Page<WorkerDTO>>> getWorkers(
            @RequestParam(required = false) String profession,
            @RequestParam(required = false) String city,
            @RequestParam(required = false) String country,
            @RequestParam(required = false) String search,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @AuthenticationPrincipal User user) {
        Long userId = user != null ? user.getId() : null;
        return ResponseEntity.ok(ApiResponse.success(
                workerService.searchWorkers(profession, city, country, search, userId, PageRequest.of(page, size))));
    }

    @GetMapping("/suggested")
    public ResponseEntity<ApiResponse<Page<WorkerDTO>>> getSuggested(
            @AuthenticationPrincipal User user,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        return ResponseEntity.ok(ApiResponse.success(
                workerService.getSuggestedWorkers(user.getId(), PageRequest.of(page, size))));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<WorkerDTO>> getWorker(
            @PathVariable Long id,
            @AuthenticationPrincipal User user) {
        Long userId = user != null ? user.getId() : null;
        return ResponseEntity.ok(ApiResponse.success(workerService.getWorkerById(id, userId)));
    }

    @GetMapping("/{id}/posts")
    public ResponseEntity<ApiResponse<Page<PostDTO>>> getWorkerPosts(
            @PathVariable Long id,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(ApiResponse.success(
                workerService.getWorkerPosts(id, PageRequest.of(page, size))));
    }

    @GetMapping("/{id}/portfolio")
    public ResponseEntity<ApiResponse<Page<PortfolioDTO>>> getWorkerPortfolio(
            @PathVariable Long id,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(ApiResponse.success(
                workerService.getWorkerPortfolio(id, PageRequest.of(page, size))));
    }

    @GetMapping("/{id}/stats")
    public ResponseEntity<ApiResponse<WorkerDTO>> getWorkerStats(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.success(workerService.getWorkerStats(id)));
    }

    @GetMapping("/profile")
    public ResponseEntity<ApiResponse<WorkerDTO>> getProfile(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(ApiResponse.success(workerService.getWorkerByUserId(user.getId())));
    }

    @PutMapping("/profile")
    public ResponseEntity<ApiResponse<WorkerDTO>> updateProfile(
            @AuthenticationPrincipal User user,
            @RequestBody WorkerDTO request) {
        return ResponseEntity.ok(ApiResponse.success(workerService.updateWorkerProfile(user, request)));
    }

    @PostMapping(value = "/posts", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<PostDTO>> createPost(
            @AuthenticationPrincipal User user,
            @RequestParam("content") String content,
            @RequestParam(value = "images", required = false) List<MultipartFile> images) {
        return ResponseEntity.ok(ApiResponse.success(workerService.createPost(user, content, images)));
    }

    @PostMapping(value = "/posts", consumes = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<ApiResponse<PostDTO>> createPostJson(
            @AuthenticationPrincipal User user,
            @RequestBody PostDTO request) {
        return ResponseEntity.ok(ApiResponse.success(workerService.createPostJson(user, request)));
    }

    @PutMapping("/posts/{id}")
    public ResponseEntity<ApiResponse<PostDTO>> updatePost(
            @AuthenticationPrincipal User user,
            @PathVariable Long id,
            @RequestBody PostDTO request) {
        return ResponseEntity.ok(ApiResponse.success(workerService.updatePost(user, id, request.getContent())));
    }

    @DeleteMapping("/posts/{id}")
    public ResponseEntity<ApiResponse<String>> deletePost(
            @AuthenticationPrincipal User user,
            @PathVariable Long id) {
        workerService.deletePost(user, id);
        return ResponseEntity.ok(ApiResponse.success("Post deleted", null));
    }

    @PostMapping(value = "/portfolio", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<PortfolioDTO>> addPortfolio(
            @AuthenticationPrincipal User user,
            @RequestParam("title") String title,
            @RequestParam(value = "description", required = false) String description,
            @RequestParam(value = "image", required = false) MultipartFile image) {
        return ResponseEntity.ok(ApiResponse.success(
                workerService.addPortfolioItem(user, title, description, image)));
    }

    @DeleteMapping("/portfolio/{id}")
    public ResponseEntity<ApiResponse<String>> deletePortfolio(
            @AuthenticationPrincipal User user,
            @PathVariable Long id) {
        workerService.deletePortfolioItem(user, id);
        return ResponseEntity.ok(ApiResponse.success("Portfolio item deleted", null));
    }

    @GetMapping("/requests")
    public ResponseEntity<ApiResponse<Page<WorkRequestDTO>>> getReceivedRequests(
            @AuthenticationPrincipal User user,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(ApiResponse.success(
                workRequestService.getWorkerRequests(user, PageRequest.of(page, size))));
    }

    @GetMapping("/my-posts")
    public ResponseEntity<ApiResponse<Page<PostDTO>>> getMyPosts(
            @AuthenticationPrincipal User user,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(ApiResponse.success(
                workerService.getMyPosts(user, PageRequest.of(page, size))));
    }

    @PostMapping("/toggle-featured")
    public ResponseEntity<ApiResponse<WorkerDTO>> toggleFeatured(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(ApiResponse.success(workerService.toggleFeatured(user)));
    }
}
