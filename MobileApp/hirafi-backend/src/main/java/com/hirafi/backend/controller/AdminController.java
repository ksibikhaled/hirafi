package com.hirafi.backend.controller;

import com.hirafi.backend.dto.*;
import com.hirafi.backend.service.AdminService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin")
@PreAuthorize("hasRole('ADMIN')")
@RequiredArgsConstructor
public class AdminController {

    private final AdminService adminService;

    @GetMapping("/stats")
    public ResponseEntity<ApiResponse<AdminStatsDTO>> getStats() {
        return ResponseEntity.ok(ApiResponse.success(adminService.getStats()));
    }

    // Worker management
    @GetMapping("/workers/pending")
    public ResponseEntity<ApiResponse<Page<WorkerDTO>>> getPendingWorkers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(ApiResponse.success(adminService.getPendingWorkers(PageRequest.of(page, size))));
    }

    @GetMapping("/workers")
    public ResponseEntity<ApiResponse<Page<WorkerDTO>>> getAllWorkers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(ApiResponse.success(adminService.getAllWorkers(PageRequest.of(page, size))));
    }

    @PutMapping("/workers/{id}/approve")
    public ResponseEntity<ApiResponse<WorkerDTO>> approveWorker(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.success("Worker approved", adminService.approveWorker(id)));
    }

    @PutMapping("/workers/{id}/block")
    public ResponseEntity<ApiResponse<WorkerDTO>> blockWorker(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.success("Worker blocked", adminService.blockWorker(id)));
    }

    @DeleteMapping("/workers/{id}")
    public ResponseEntity<ApiResponse<String>> deleteWorker(@PathVariable Long id) {
        adminService.deleteWorker(id);
        return ResponseEntity.ok(ApiResponse.success("Worker deleted", null));
    }

    @PutMapping("/workers/{id}/verify")
    public ResponseEntity<ApiResponse<WorkerDTO>> verifyWorker(
            @PathVariable Long id,
            @RequestParam Boolean status) {
        return ResponseEntity.ok(ApiResponse.success("Worker verification updated", adminService.verifyWorker(id, status)));
    }

    // User management
    @GetMapping("/users")
    public ResponseEntity<ApiResponse<Page<UserProfileDTO>>> getAllUsers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(ApiResponse.success(adminService.getAllUsers(PageRequest.of(page, size))));
    }

    @DeleteMapping("/users/{id}")
    public ResponseEntity<ApiResponse<String>> deleteUser(@PathVariable Long id) {
        adminService.deleteUser(id);
        return ResponseEntity.ok(ApiResponse.success("User deleted", null));
    }

    // Post management
    @GetMapping("/posts")
    public ResponseEntity<ApiResponse<Page<PostDTO>>> getAllPosts(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(ApiResponse.success(adminService.getAllPosts(PageRequest.of(page, size))));
    }

    @DeleteMapping("/posts/{id}")
    public ResponseEntity<ApiResponse<String>> deletePost(@PathVariable Long id) {
        adminService.deletePost(id);
        return ResponseEntity.ok(ApiResponse.success("Post deleted", null));
    }
}
