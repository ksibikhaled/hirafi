package com.hirafi.backend.repository;

import com.hirafi.backend.entity.Post;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PostRepository extends JpaRepository<Post, Long> {
    Page<Post> findByWorkerIdOrderByCreatedAtDesc(Long workerId, Pageable pageable);

    Page<Post> findAllByOrderByCreatedAtDesc(Pageable pageable);

    long countByWorkerId(Long workerId);
}
