package com.hirafi.backend.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.*;

@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class RegisterRequest {
    @NotBlank @Email
    private String email;

    @NotBlank @Size(min = 6, max = 100)
    private String password;

    @NotBlank
    private String firstName;

    @NotBlank
    private String lastName;

    @NotBlank
    private String role; // "USER" or "WORKER"

    // User-specific
    private String city;
    private String country;
    private String phone;

    // Worker-specific
    private String profession;
    private String workerPhone;
    private String website;
    private String bio;
    private String workerCity;
    private String workerCountry;
}
