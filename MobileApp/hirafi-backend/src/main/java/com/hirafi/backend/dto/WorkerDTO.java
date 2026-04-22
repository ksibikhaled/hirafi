package com.hirafi.backend.dto;

import lombok.*;
import lombok.*;

@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class WorkerDTO {
    private Long id;
    private Long userId;
    private String firstName;
    private String lastName;
    private String email;
    private String profileImageUrl;
    private String profession;
    private String phone;
    private String website;
    private String bio;
    private String city;
    private String country;
    private Boolean approved;
    private Double ratingAvg;
    private Long followersCount;
    private Long postsCount;
    private Long portfolioCount;
    private Boolean isFollowed;
    private Boolean verified;
    private Boolean featured;
    private Long reviewsCount;
}
