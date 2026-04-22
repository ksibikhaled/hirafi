package com.hirafi.backend.dto;

import lombok.*;

@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class AuthResponse {
    private String accessToken;
    private String refreshToken;
    private String role;
    private Long userId;
    private String firstName;
    private String lastName;
    private String email;
    private String status;
}
