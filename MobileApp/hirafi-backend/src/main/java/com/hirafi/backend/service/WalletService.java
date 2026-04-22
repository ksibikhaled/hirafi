package com.hirafi.backend.service;

import com.hirafi.backend.dto.WalletBalanceDTO;
import com.hirafi.backend.dto.WalletTransactionDTO;
import com.hirafi.backend.entity.User;
import com.hirafi.backend.entity.WalletTransaction;
import com.hirafi.backend.entity.TransactionType;
import com.hirafi.backend.entity.TransactionStatus;
import com.hirafi.backend.repository.UserRepository;
import com.hirafi.backend.repository.WalletTransactionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

@Slf4j
@Service
@RequiredArgsConstructor
public class WalletService {

    private static final BigDecimal PLATFORM_FEE_RATE = BigDecimal.valueOf(0.10); // 10%
    private static final BigDecimal MIN_WITHDRAWAL = BigDecimal.valueOf(10.0);
    private static final String DEFAULT_CURRENCY = "TND";

    private final UserRepository userRepository;
    private final WalletTransactionRepository transactionRepository;

    public WalletBalanceDTO getBalance(User user) {
        User updatedUser = userRepository.findById(user.getId())
                .orElseThrow(() -> new RuntimeException("User not found"));
        return WalletBalanceDTO.builder()
                .balance(updatedUser.getWalletBalance())
                .currency(DEFAULT_CURRENCY)
                .build();
    }

    public Page<WalletTransactionDTO> getHistory(User user, Pageable pageable) {
        return transactionRepository.findByUserIdOrderByCreatedAtDesc(user.getId(), pageable)
                .map(this::mapToDTO);
    }

    @Transactional
    public WalletBalanceDTO deposit(User user, BigDecimal amount, String refId) {
        if (amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new RuntimeException("Deposit amount must be positive");
        }

        User updatedUser = userRepository.findById(user.getId())
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Increase balance
        updatedUser.setWalletBalance(updatedUser.getWalletBalance().add(amount));
        userRepository.save(updatedUser);

        // Record transaction
        WalletTransaction transaction = WalletTransaction.builder()
                .user(updatedUser)
                .amount(amount)
                .type(TransactionType.DEPOSIT)
                .status(TransactionStatus.COMPLETED)
                .referenceId(refId)
                .description("Dépôt sur le portefeuille")
                .build();
        transactionRepository.save(transaction);

        return WalletBalanceDTO.builder().balance(updatedUser.getWalletBalance()).currency(DEFAULT_CURRENCY).build();
    }

    @Transactional
    public WalletBalanceDTO withdraw(User user, BigDecimal amount) {
        if (amount.compareTo(MIN_WITHDRAWAL) < 0) {
            throw new RuntimeException("Le montant minimum de retrait est " + MIN_WITHDRAWAL + " " + DEFAULT_CURRENCY);
        }

        User updatedUser = userRepository.findById(user.getId())
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (updatedUser.getWalletBalance().compareTo(amount) < 0) {
            throw new RuntimeException("Solde insuffisant pour effectuer ce retrait");
        }

        updatedUser.setWalletBalance(updatedUser.getWalletBalance().subtract(amount));
        userRepository.save(updatedUser);

        WalletTransaction transaction = WalletTransaction.builder()
                .user(updatedUser)
                .amount(amount.negate())
                .type(TransactionType.WITHDRAWAL)
                .status(TransactionStatus.COMPLETED)
                .referenceId("WD_" + System.currentTimeMillis())
                .description("Retrait de fonds vers compte bancaire")
                .build();
        transactionRepository.save(transaction);

        log.info("WITHDRAWAL: {} {} by user #{}", amount, DEFAULT_CURRENCY, user.getId());
        return WalletBalanceDTO.builder().balance(updatedUser.getWalletBalance()).currency(DEFAULT_CURRENCY).build();
    }

    @Transactional
    public void holdEscrow(User user, BigDecimal amount, String workRequestId) {
        User updatedUser = userRepository.findById(user.getId())
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (updatedUser.getWalletBalance().compareTo(amount) < 0) {
            throw new RuntimeException("Solde insuffisant pour bloquer les fonds");
        }

        updatedUser.setWalletBalance(updatedUser.getWalletBalance().subtract(amount));
        userRepository.save(updatedUser);

        WalletTransaction transaction = WalletTransaction.builder()
                .user(updatedUser)
                .amount(amount.negate())
                .type(TransactionType.ESCROW_HOLD)
                .status(TransactionStatus.COMPLETED)
                .referenceId(workRequestId)
                .description("Fonds bloqués en séquestre pour la mission #" + workRequestId)
                .build();
        transactionRepository.save(transaction);
    }

    @Transactional
    public void releaseEscrow(User workerUser, BigDecimal amount, String workRequestId) {
        // Release funds to worker minus platform fee (10%)
        BigDecimal platformFee = amount.multiply(PLATFORM_FEE_RATE);
        BigDecimal payout = amount.subtract(platformFee);

        User updatedWorker = userRepository.findById(workerUser.getId())
                .orElseThrow(() -> new RuntimeException("Worker not found"));

        updatedWorker.setWalletBalance(updatedWorker.getWalletBalance().add(payout));
        userRepository.save(updatedWorker);

        // Record payout to worker
        WalletTransaction payoutTx = WalletTransaction.builder()
                .user(updatedWorker)
                .amount(payout)
                .type(TransactionType.ESCROW_RELEASE)
                .status(TransactionStatus.COMPLETED)
                .referenceId(workRequestId)
                .description("Paiement reçu pour la mission #" + workRequestId)
                .build();
        transactionRepository.save(payoutTx);

        // Record platform fee transaction (against the worker for audit trail)
        WalletTransaction feeTx = WalletTransaction.builder()
                .user(updatedWorker)
                .amount(platformFee.negate())
                .type(TransactionType.PLATFORM_FEE)
                .status(TransactionStatus.COMPLETED)
                .referenceId(workRequestId)
                .description("Commission Hirafi (10%) sur mission #" + workRequestId)
                .build();
        transactionRepository.save(feeTx);

        log.info("ESCROW RELEASED: {} {} to worker #{}, platform fee: {} {}",
                payout, DEFAULT_CURRENCY, workerUser.getId(), platformFee, DEFAULT_CURRENCY);
    }

    @Transactional
    public void refundEscrow(User clientUser, BigDecimal amount, String workRequestId) {
        User updatedUser = userRepository.findById(clientUser.getId())
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Refund the held amount back to the client
        updatedUser.setWalletBalance(updatedUser.getWalletBalance().add(amount));
        userRepository.save(updatedUser);

        WalletTransaction transaction = WalletTransaction.builder()
                .user(updatedUser)
                .amount(amount)
                .type(TransactionType.ESCROW_HOLD)
                .status(TransactionStatus.REFUNDED)
                .referenceId(workRequestId)
                .description("Remboursement séquestre - Mission #" + workRequestId + " annulée")
                .build();
        transactionRepository.save(transaction);

        log.info("ESCROW REFUNDED: {} {} to user #{} for work request {}",
                amount, DEFAULT_CURRENCY, clientUser.getId(), workRequestId);
    }

    private WalletTransactionDTO mapToDTO(WalletTransaction transaction) {
        return WalletTransactionDTO.builder()
                .id(transaction.getId())
                .amount(transaction.getAmount())
                .type(transaction.getType().name())
                .status(transaction.getStatus().name())
                .referenceId(transaction.getReferenceId())
                .description(transaction.getDescription())
                .createdAt(transaction.getCreatedAt())
                .build();
    }
}
