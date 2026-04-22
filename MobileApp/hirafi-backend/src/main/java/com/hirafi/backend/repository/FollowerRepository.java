package com.hirafi.backend.repository;

import com.hirafi.backend.entity.Follower;
import com.hirafi.backend.entity.User;
import com.hirafi.backend.entity.Worker;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface FollowerRepository extends JpaRepository<Follower, Long> {
    Optional<Follower> findByUserAndWorker(User user, Worker worker);
    boolean existsByUserAndWorker(User user, Worker worker);
    List<Follower> findByUser(User user);
    long countByWorker(Worker worker);
    void deleteByUserAndWorker(User user, Worker worker);

    // Backward compatibility for existing service calls
    Optional<Follower> findByUserIdAndWorkerId(Long userId, Long workerId);
    boolean existsByUserIdAndWorkerId(Long userId, Long workerId);
    long countByWorkerId(Long workerId);
    void deleteByUserIdAndWorkerId(Long userId, Long workerId);
    Page<Follower> findByUserId(Long userId, Pageable pageable);
}
