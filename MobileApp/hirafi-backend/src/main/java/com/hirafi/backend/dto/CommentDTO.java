package com.hirafi.backend.dto;

import lombok.*;

import java.time.LocalDateTime;

@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class CommentDTO {
    private Long id;
    private Long userId;
    private String userFirstName;
    private String userLastName;
    private String userProfileImage;
    private String content;
    private String imageUrl;
    private LocalDateTime createdAt;
}
