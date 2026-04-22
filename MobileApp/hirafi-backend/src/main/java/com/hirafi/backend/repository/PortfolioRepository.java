package com.hirafi.backend.repository;

import com.hirafi.backend.entity.Portfolio;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PortfolioRepository extends JpaRepository<Portfolio, Long> {
    Page<Portfolio> findByWorkerIdOrderByCreatedAtDesc(Long workerId, Pageable pageable);
    long countByWorkerId(Long workerId);
}
