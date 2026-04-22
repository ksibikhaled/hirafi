package com.hirafi.backend.dto;

import lombok.*;

import java.math.BigDecimal;

@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class WalletBalanceDTO {
    private BigDecimal balance;
    private String currency; // Default "TND" or "EUR"
}
