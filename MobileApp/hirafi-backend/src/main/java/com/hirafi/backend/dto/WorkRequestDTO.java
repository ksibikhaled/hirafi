package com.hirafi.backend.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class WorkRequestDTO {
    private Long id;
    private Long userId;
    private String userFirstName;
    private String userLastName;
    private Long workerId;
    private String workerFirstName;
    private String workerLastName;
    private String workerProfession;
    @NotBlank
    private String description;
    private LocalDate preferredDate;
    private String location;
    private String status;
    private java.math.BigDecimal amount;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
