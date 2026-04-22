package com.hirafi.backend.service;

import com.hirafi.backend.dto.*;
import com.hirafi.backend.entity.*;
import com.hirafi.backend.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AdminService {

    private final UserRepository userRepository;
    private final WorkerRepository workerRepository;
    private final PostRepository postRepository;
    private final WorkRequestRepository workRequestRepository;
    private final FollowerRepository followerRepository;
    private final PortfolioRepository portfolioRepository;
    private final NotificationRepository notificationRepository;
    private final ReviewRepository reviewRepository;

    public AdminStatsDTO getStats() {
        return AdminStatsDTO.builder()
                .totalUsers(userRepository.countByRole(Role.USER))
                .totalWorkers(userRepository.countByRole(Role.WORKER))
                .pendingWorkers(workerRepository.countByApprovedFalse())
                .approvedWorkers(workerRepository.countByApprovedTrue())
                .totalPosts(postRepository.count())
                .totalRequests(workRequestRepository.count())
                .totalReviews(reviewRepository.count())
                .totalBalance(userRepository.sumWalletBalance() != null ? userRepository.sumWalletBalance().doubleValue() : 0.0)
                .build();
    }

    // Worker management
    public Page<WorkerDTO> getPendingWorkers(Pageable pageable) {
        return workerRepository.findByApprovedFalse(pageable).map(this::mapWorkerToDTO);
    }

    public Page<WorkerDTO> getAllWorkers(Pageable pageable) {
        return workerRepository.findAll(pageable).map(this::mapWorkerToDTO);
    }

    @Transactional
    public WorkerDTO approveWorker(Long workerId) {
        Worker worker = workerRepository.findById(workerId)
                .orElseThrow(() -> new RuntimeException("Worker not found"));
        worker.setApproved(true);
        workerRepository.save(worker);
        
        User user = userRepository.findById(worker.getUser().getId()).orElseThrow();
        user.setStatus(AccountStatus.ACTIVE);
        userRepository.save(user);

        Notification notification = Notification.builder()
                .user(worker.getUser())
                .title("Account Approved")
                .message("Your worker account has been approved! You can now start posting.")
                .type("ACCOUNT_APPROVED")
                .build();
        notificationRepository.save(notification);

        return mapWorkerToDTO(worker);
    }

    @Transactional
    public WorkerDTO blockWorker(Long workerId) {
        Worker worker = workerRepository.findById(workerId)
                .orElseThrow(() -> new RuntimeException("Worker not found"));
        worker.getUser().setStatus(AccountStatus.BLOCKED);
        userRepository.save(worker.getUser());
        return mapWorkerToDTO(worker);
    }

    @Transactional
    public void deleteWorker(Long workerId) {
        Worker worker = workerRepository.findById(workerId)
                .orElseThrow(() -> new RuntimeException("Worker not found"));
        userRepository.delete(worker.getUser());
    }

    @Transactional
    public WorkerDTO verifyWorker(Long workerId, Boolean status) {
        Worker worker = workerRepository.findById(workerId)
                .orElseThrow(() -> new RuntimeException("Worker not found"));
        worker.setVerified(status);
        workerRepository.save(worker);

        if (status) {
            Notification notification = Notification.builder()
                    .user(worker.getUser())
                    .title("Profil Certifié")
                    .message("Félicitations ! Votre profil a été certifié par notre équipe.")
                    .type("ACCOUNT_VERIFIED")
                    .build();
            notificationRepository.save(notification);
        }

        return mapWorkerToDTO(worker);
    }

    // User management
    public Page<UserProfileDTO> getAllUsers(Pageable pageable) {
        return userRepository.findByRole(Role.USER, pageable).map(this::mapUserToDTO);
    }

    @Transactional
    public void deleteUser(Long userId) {
        userRepository.deleteById(userId);
    }

    // Post management
    public Page<PostDTO> getAllPosts(Pageable pageable) {
        return postRepository.findAll(pageable).map(this::mapPostToDTO);
    }

    @Transactional
    public void deletePost(Long postId) {
        postRepository.deleteById(postId);
    }

    // Mapping
    private WorkerDTO mapWorkerToDTO(Worker worker) {
        return WorkerDTO.builder()
                .id(worker.getId())
                .userId(worker.getUser().getId())
                .firstName(worker.getUser().getFirstName())
                .lastName(worker.getUser().getLastName())
                .email(worker.getUser().getEmail())
                .profileImageUrl(worker.getUser().getProfileImageUrl())
                .profession(worker.getProfession())
                .phone(worker.getPhone())
                .website(worker.getWebsite())
                .bio(worker.getBio())
                .city(worker.getCity())
                .country(worker.getCountry())
                .approved(worker.getApproved())
                .ratingAvg(worker.getRatingAvg() != null ? worker.getRatingAvg().doubleValue() : 0.0)
                .followersCount(followerRepository.countByWorkerId(worker.getId()))
                .postsCount(postRepository.countByWorkerId(worker.getId()))
                .portfolioCount(portfolioRepository.countByWorkerId(worker.getId()))
                .verified(worker.getVerified())
                .reviewsCount(reviewRepository.countByWorkerId(worker.getId()))
                .build();
    }

    private UserProfileDTO mapUserToDTO(User user) {
        UserProfileDTO dto = UserProfileDTO.builder()
                .id(user.getId())
                .email(user.getEmail())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .profileImageUrl(user.getProfileImageUrl())
                .role(user.getRole().name())
                .build();
        return dto;
    }

    private PostDTO mapPostToDTO(Post post) {
        return PostDTO.builder()
                .id(post.getId())
                .workerId(post.getWorker().getId())
                .workerFirstName(post.getWorker().getUser().getFirstName())
                .workerLastName(post.getWorker().getUser().getLastName())
                .workerProfession(post.getWorker().getProfession())
                .workerProfileImage(post.getWorker().getUser().getProfileImageUrl())
                .content(post.getContent())
                .imageUrls(post.getImages().stream().map(PostImage::getImageUrl).toList())
                .createdAt(post.getCreatedAt())
                .updatedAt(post.getUpdatedAt())
                .workerVerified(post.getWorker().getVerified())
                .build();
    }
}
