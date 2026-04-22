package com.hirafi.backend.repository;

import com.hirafi.backend.entity.Review;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ReviewRepository extends JpaRepository<Review, Long> {
    Page<Review> findByWorkerIdOrderByCreatedAtDesc(Long workerId, Pageable pageable);
    
    @Query("SELECT AVG(r.rating) FROM Review r WHERE r.worker.id = :workerId")
    Double calculateAverageRating(Long workerId);

    Optional<Review> findByWorkerIdAndUserId(Long workerId, Long userId);

    long countByWorkerId(Long workerId);
}
