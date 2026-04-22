package com.hirafi.backend.dto;

import lombok.*;

import java.time.LocalDateTime;

@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class PortfolioDTO {
    private Long id;
    private Long workerId;
    private String title;
    private String description;
    private String imageUrl;
    private LocalDateTime createdAt;
}
