package com.hirafi.backend.dto;

import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class ReviewDTO {
    private Long id;
    private Long userId;
    private String userFirstName;
    private String userLastName;
    private String userProfileImage;
    private Long workerId;
    private Integer rating;
    private String comment;
    private LocalDateTime createdAt;
}
