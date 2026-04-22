package com.hirafi.backend.controller;

import com.hirafi.backend.dto.*;
import com.hirafi.backend.entity.User;
import com.hirafi.backend.service.WorkRequestService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/requests")
@RequiredArgsConstructor
public class RequestController {

    private final WorkRequestService workRequestService;

    @PostMapping
    public ResponseEntity<ApiResponse<WorkRequestDTO>> createRequest(
            @AuthenticationPrincipal User user,
            @RequestBody WorkRequestDTO request) {
        return ResponseEntity.ok(ApiResponse.success(workRequestService.createRequest(user, request)));
    }

    @GetMapping("/user")
    public ResponseEntity<ApiResponse<Page<WorkRequestDTO>>> getUserRequests(
            @AuthenticationPrincipal User user,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(ApiResponse.success(
                workRequestService.getUserRequests(user.getId(), PageRequest.of(page, size))));
    }

    @GetMapping("/worker")
    public ResponseEntity<ApiResponse<Page<WorkRequestDTO>>> getWorkerRequests(
            @AuthenticationPrincipal User user,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(ApiResponse.success(
                workRequestService.getWorkerRequests(user, PageRequest.of(page, size))));
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<ApiResponse<WorkRequestDTO>> updateStatus(
            @AuthenticationPrincipal User user,
            @PathVariable Long id,
            @RequestBody Map<String, String> request) {
        return ResponseEntity.ok(ApiResponse.success(
                workRequestService.updateRequestStatus(user, id, request.get("status"))));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<String>> cancelRequest(
            @AuthenticationPrincipal User user,
            @PathVariable Long id) {
        workRequestService.cancelRequest(user, id);
        return ResponseEntity.ok(ApiResponse.success("Request cancelled", null));
    }
}
