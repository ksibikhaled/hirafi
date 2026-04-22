package com.hirafi.backend.service;

import com.hirafi.backend.entity.Follower;
import com.hirafi.backend.entity.User;
import com.hirafi.backend.entity.Worker;
import com.hirafi.backend.repository.FollowerRepository;
import com.hirafi.backend.repository.UserRepository;
import com.hirafi.backend.repository.WorkerRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FollowerService {

    private final FollowerRepository followerRepository;
    private final UserRepository userRepository;
    private final WorkerRepository workerRepository;

    @Transactional
    public void follow(Long userId, Long workerId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        Worker worker = workerRepository.findById(workerId)
                .orElseThrow(() -> new RuntimeException("Worker not found"));

        if (!followerRepository.existsByUserAndWorker(user, worker)) {
            Follower follower = new Follower();
            follower.setUser(user);
            follower.setWorker(worker);
            follower.setCreatedAt(LocalDateTime.now());
            followerRepository.save(follower);
        }
    }

    @Transactional
    public void unfollow(Long userId, Long workerId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        Worker worker = workerRepository.findById(workerId)
                .orElseThrow(() -> new RuntimeException("Worker not found"));

        followerRepository.findByUserAndWorker(user, worker)
                .ifPresent(followerRepository::delete);
    }

    public boolean isFollowing(Long userId, Long workerId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        Worker worker = workerRepository.findById(workerId)
                .orElseThrow(() -> new RuntimeException("Worker not found"));
        return followerRepository.existsByUserAndWorker(user, worker);
    }

    public List<Worker> getFollowedWorkers(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        return followerRepository.findByUser(user).stream()
                .map(Follower::getWorker)
                .collect(Collectors.toList());
    }
}
