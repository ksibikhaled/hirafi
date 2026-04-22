package com.hirafi.backend.repository;

import com.hirafi.backend.entity.WorkRequest;
import com.hirafi.backend.entity.RequestStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface WorkRequestRepository extends JpaRepository<WorkRequest, Long> {
    Page<WorkRequest> findByUserIdOrderByCreatedAtDesc(Long userId, Pageable pageable);
    Page<WorkRequest> findByWorkerIdOrderByCreatedAtDesc(Long workerId, Pageable pageable);
    long countByWorkerId(Long workerId);
    long countByWorkerIdAndStatus(Long workerId, RequestStatus status);
}
