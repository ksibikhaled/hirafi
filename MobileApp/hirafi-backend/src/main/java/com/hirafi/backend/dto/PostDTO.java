package com.hirafi.backend.dto;

import lombok.*;

import java.time.LocalDateTime;
import java.util.List;

@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class PostDTO {
    private Long id;
    private Long workerId;
    private Long workerUserId;
    private String workerFirstName;
    private String workerLastName;
    private String workerProfession;
    private String workerProfileImage;
    private String content;
    private List<String> imageUrls;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private long reactionCount;
    private long commentCount;
    private boolean isLiked;
    private boolean workerVerified;
}
