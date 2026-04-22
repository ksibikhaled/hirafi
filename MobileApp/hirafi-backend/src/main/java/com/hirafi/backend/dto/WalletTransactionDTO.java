package com.hirafi.backend.dto;

import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class WalletTransactionDTO {
    private Long id;
    private BigDecimal amount;
    private String type;
    private String status;
    private String referenceId;
    private String description;
    private LocalDateTime createdAt;
}
