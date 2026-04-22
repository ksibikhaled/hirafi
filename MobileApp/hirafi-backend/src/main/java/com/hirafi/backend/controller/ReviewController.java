package com.hirafi.backend.controller;

import com.hirafi.backend.dto.ApiResponse;
import com.hirafi.backend.dto.ReviewDTO;
import com.hirafi.backend.entity.User;
import com.hirafi.backend.service.ReviewService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/reviews")
@RequiredArgsConstructor
public class ReviewController {

    private final ReviewService reviewService;

    @PostMapping("/worker/{workerId}")
    public ResponseEntity<ApiResponse<ReviewDTO>> addReview(
            @AuthenticationPrincipal User user,
            @PathVariable Long workerId,
            @RequestBody Map<String, Object> request) {
        Integer rating = (Integer) request.get("rating");
        String comment = (String) request.get("comment");
        return ResponseEntity.ok(ApiResponse.success(
                "Avis ajouté avec succès", 
                reviewService.addReview(user, workerId, rating, comment)));
    }

    @GetMapping("/worker/{workerId}")
    public ResponseEntity<ApiResponse<Page<ReviewDTO>>> getWorkerReviews(
            @PathVariable Long workerId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        return ResponseEntity.ok(ApiResponse.success(
                reviewService.getWorkerReviews(workerId, PageRequest.of(page, size))));
    }
}
