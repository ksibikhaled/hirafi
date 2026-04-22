package com.hirafi.backend.controller;

import com.hirafi.backend.dto.ApiResponse;
import com.hirafi.backend.dto.PostDTO;
import com.hirafi.backend.entity.Post;
import com.hirafi.backend.entity.PostImage;
import com.hirafi.backend.entity.User;
import com.hirafi.backend.service.PostService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/posts")
@RequiredArgsConstructor
public class PostController {

    private final PostService postService;

    @GetMapping("/feed")
    public ResponseEntity<ApiResponse<Page<PostDTO>>> getFeed(
            @AuthenticationPrincipal User user,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Page<PostDTO> feed = postService.getFeed(user.getId(), PageRequest.of(page, size))
                .map(this::mapToDTO);
        return ResponseEntity.ok(ApiResponse.success(feed));
    }

    private PostDTO mapToDTO(Post post) {
        return PostDTO.builder()
                .id(post.getId())
                .workerId(post.getWorker().getId())
                .workerFirstName(post.getWorker().getUser().getFirstName())
                .workerLastName(post.getWorker().getUser().getLastName())
                .workerProfession(post.getWorker().getProfession())
                .workerProfileImage(post.getWorker().getUser().getProfileImageUrl())
                .content(post.getContent())
                .imageUrls(post.getImages().stream().map(PostImage::getImageUrl).toList())
                .createdAt(post.getCreatedAt())
                .updatedAt(post.getUpdatedAt())
                .build();
    }
}
