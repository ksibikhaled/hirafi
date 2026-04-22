package com.hirafi.backend.repository;

import com.hirafi.backend.entity.User;
import com.hirafi.backend.entity.Role;
import com.hirafi.backend.entity.AccountStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);
    Page<User> findByRole(Role role, Pageable pageable);
    long countByRole(Role role);
    long countByRoleAndStatus(Role role, AccountStatus status);
    @org.springframework.data.jpa.repository.Query("SELECT SUM(u.walletBalance) FROM User u")
    java.math.BigDecimal sumWalletBalance();
}
