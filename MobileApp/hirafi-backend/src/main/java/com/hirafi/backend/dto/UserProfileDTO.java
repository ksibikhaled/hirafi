package com.hirafi.backend.dto;

import lombok.*;

@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class UserProfileDTO {
    private Long id;
    private String email;
    private String firstName;
    private String lastName;
    private String profileImageUrl;
    private String role;
    private String city;
    private String country;
    private String phone;
}
