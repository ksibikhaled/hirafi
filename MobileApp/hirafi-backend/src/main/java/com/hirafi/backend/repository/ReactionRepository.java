package com.hirafi.backend.repository;

import com.hirafi.backend.entity.Reaction;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ReactionRepository extends JpaRepository<Reaction, Long> {
    Optional<Reaction> findByPostIdAndUserId(Long postId, Long userId);
    long countByPostId(Long postId);
    long countByPostIdAndType(Long postId, String type);
}
