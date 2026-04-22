package com.hirafi.backend.controller;

import com.hirafi.backend.dto.ApiResponse;
import com.hirafi.backend.dto.WalletBalanceDTO;
import com.hirafi.backend.dto.WalletTransactionDTO;
import com.hirafi.backend.entity.User;
import com.hirafi.backend.service.WalletService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.Map;

@RestController
@RequestMapping("/api/wallet")
@RequiredArgsConstructor
public class WalletController {

    private final WalletService walletService;

    @GetMapping("/balance")
    public ResponseEntity<ApiResponse<WalletBalanceDTO>> getBalance(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(ApiResponse.success(walletService.getBalance(user)));
    }

    @GetMapping("/history")
    public ResponseEntity<ApiResponse<Page<WalletTransactionDTO>>> getHistory(
            @AuthenticationPrincipal User user,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(ApiResponse.success(
                walletService.getHistory(user, PageRequest.of(page, size))
        ));
    }

    @PostMapping("/deposit")
    public ResponseEntity<ApiResponse<WalletBalanceDTO>> deposit(
            @AuthenticationPrincipal User user,
            @RequestBody Map<String, Object> request) {
        
        BigDecimal amount = new BigDecimal(request.get("amount").toString());
        String refId = request.containsKey("referenceId") ? request.get("referenceId").toString() : "SIM_" + System.currentTimeMillis();

        return ResponseEntity.ok(ApiResponse.success(walletService.deposit(user, amount, refId)));
    }

    @PostMapping("/withdraw")
    public ResponseEntity<ApiResponse<WalletBalanceDTO>> withdraw(
            @AuthenticationPrincipal User user,
            @RequestBody Map<String, Object> request) {
        
        BigDecimal amount = new BigDecimal(request.get("amount").toString());
        return ResponseEntity.ok(ApiResponse.success(walletService.withdraw(user, amount)));
    }
}
