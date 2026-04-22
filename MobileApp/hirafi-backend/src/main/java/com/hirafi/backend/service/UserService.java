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
public class UserService {

    private final UserRepository userRepository;
    private final UserProfileRepository userProfileRepository;
    private final FollowerRepository followerRepository;
    private final WorkerRepository workerRepository;
    private final PostRepository postRepository;
    private final NotificationRepository notificationRepository;
    private final CommentRepository commentRepository;
    private final ReactionRepository reactionRepository;
    private final ReviewRepository reviewRepository;
    private final PortfolioRepository portfolioRepository;

    public UserProfileDTO getProfile(User user) {
        UserProfileDTO dto = UserProfileDTO.builder()
                .id(user.getId())
                .email(user.getEmail())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .profileImageUrl(user.getProfileImageUrl())
                .role(user.getRole().name())
                .build();

        if (user.getRole() == Role.USER) {
            userProfileRepository.findByUserId(user.getId()).ifPresent(profile -> {
                dto.setCity(profile.getCity());
                dto.setCountry(profile.getCountry());
                dto.setPhone(profile.getPhone());
            });
        }
        return dto;
    }

    @Transactional
    public UserProfileDTO updateProfile(User user, UserProfileDTO request) {
        user.setFirstName(request.getFirstName() != null ? request.getFirstName() : user.getFirstName());
        user.setLastName(request.getLastName() != null ? request.getLastName() : user.getLastName());
        userRepository.save(user);

        if (user.getRole() == Role.USER) {
            UserProfile profile = userProfileRepository.findByUserId(user.getId())
                    .orElse(UserProfile.builder().user(user).build());
            profile.setCity(request.getCity() != null ? request.getCity() : profile.getCity());
            profile.setCountry(request.getCountry() != null ? request.getCountry() : profile.getCountry());
            profile.setPhone(request.getPhone() != null ? request.getPhone() : profile.getPhone());
            userProfileRepository.save(profile);
        }
        return getProfile(user);
    }

    @Transactional
    public void followWorker(User user, Long workerId) {
        Worker worker = workerRepository.findById(workerId)
                .orElseThrow(() -> new RuntimeException("Worker not found"));

        if (followerRepository.existsByUserIdAndWorkerId(user.getId(), workerId)) {
            throw new RuntimeException("Already following this worker");
        }

        Follower follower = Follower.builder()
                .user(user)
                .worker(worker)
                .build();
        followerRepository.save(follower);

        // Create notification for worker
        Notification notification = Notification.builder()
                .user(worker.getUser())
                .title("New Follower")
                .message(user.getFirstName() + " " + user.getLastName() + " started following you")
                .type("NEW_FOLLOWER")
                .referenceId(user.getId())
                .build();
        notificationRepository.save(notification);
    }

    @Transactional
    public void unfollowWorker(User user, Long workerId) {
        if (!followerRepository.existsByUserIdAndWorkerId(user.getId(), workerId)) {
            throw new RuntimeException("Not following this worker");
        }
        followerRepository.deleteByUserIdAndWorkerId(user.getId(), workerId);
    }

    public Page<NotificationDTO> getNotifications(User user, Pageable pageable) {
        return notificationRepository.findByUserIdOrderByCreatedAtDesc(user.getId(), pageable)
                .map(this::mapNotificationToDTO);
    }

    @Transactional
    public void markNotificationAsRead(Long notificationId) {
        notificationRepository.findById(notificationId).ifPresent(n -> {
            n.setRead(true);
            notificationRepository.save(n);
        });
    }

    private NotificationDTO mapNotificationToDTO(Notification notification) {
        return NotificationDTO.builder()
                .id(notification.getId())
                .title(notification.getTitle())
                .message(notification.getMessage())
                .type(notification.getType())
                .referenceId(notification.getReferenceId())
                .read(notification.isRead())
                .createdAt(notification.getCreatedAt())
                .build();
    }

    public Page<WorkerDTO> getFollowingWorkers(User user, Pageable pageable) {
        Page<Follower> followers = followerRepository.findByUserId(user.getId(), pageable);
        return followers.map(f -> mapWorkerToDTO(f.getWorker(), user.getId()));
    }

    public Page<PostDTO> getFeed(User user, Pageable pageable) {
        return postRepository.findAllByOrderByCreatedAtDesc(pageable)
                .map(post -> mapPostToDTO(post, user.getId()));
    }

    private WorkerDTO mapWorkerToDTO(Worker worker, Long currentUserId) {
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
                .isFollowed(currentUserId != null && followerRepository.existsByUserIdAndWorkerId(currentUserId, worker.getId()))
                .verified(worker.getVerified())
                .reviewsCount(reviewRepository.countByWorkerId(worker.getId()))
                .build();
    }

    @Transactional
    public void toggleReaction(User user, Long postId, String type) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new RuntimeException("Post not found"));
        
        reactionRepository.findByPostIdAndUserId(postId, user.getId())
                .ifPresentOrElse(
                    reactionRepository::delete,
                    () -> {
                        Reaction reaction = Reaction.builder()
                                .post(post)
                                .user(user)
                                .type(type != null ? type : "LIKE")
                                .build();
                        reactionRepository.save(reaction);

                        // Notify artisan
                        if (!post.getWorker().getUser().getId().equals(user.getId())) {
                            String message = user.getFirstName() + (type.equals("HEART") ? " adore votre publication" : " a aimé votre publication");
                            Notification notification = Notification.builder()
                                    .user(post.getWorker().getUser())
                                    .title("Nouvelle Réaction")
                                    .message(message)
                                    .type("NEW_LIKE")
                                    .referenceId(post.getId())
                                    .build();
                            notificationRepository.save(notification);
                        }
                    }
                );
    }

    @Transactional
    public void addComment(User user, Long postId, CommentRequest request) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new RuntimeException("Post not found"));

        Comment comment = Comment.builder()
                .post(post)
                .user(user)
                .content(request.getContent())
                .imageUrl(request.getImageUrl())
                .build();
        commentRepository.save(comment);

        // Notify artisan
        if (!post.getWorker().getUser().getId().equals(user.getId())) {
            Notification notification = Notification.builder()
                    .user(post.getWorker().getUser())
                    .title("Nouveau Commentaire")
                    .message(user.getFirstName() + " a commenté votre publication")
                    .type("NEW_COMMENT")
                    .referenceId(post.getId())
                    .build();
            notificationRepository.save(notification);
        }
    }

    public Page<CommentDTO> getComments(Long postId, org.springframework.data.domain.Pageable pageable) {
        return commentRepository.findByPostIdOrderByCreatedAtDesc(postId, pageable)
                .map(this::mapCommentToDTO);
    }

    private CommentDTO mapCommentToDTO(Comment comment) {
        return CommentDTO.builder()
                .id(comment.getId())
                .userId(comment.getUser().getId())
                .userFirstName(comment.getUser().getFirstName())
                .userLastName(comment.getUser().getLastName())
                .userProfileImage(comment.getUser().getProfileImageUrl())
                .content(comment.getContent())
                .imageUrl(comment.getImageUrl())
                .createdAt(comment.getCreatedAt())
                .build();
    }


    private PostDTO mapPostToDTO(Post post, Long currentUserId) {
        return PostDTO.builder()
                .id(post.getId())
                .workerId(post.getWorker().getId())
                .workerUserId(post.getWorker().getUser().getId())
                .workerFirstName(post.getWorker().getUser().getFirstName())
                .workerLastName(post.getWorker().getUser().getLastName())
                .workerProfession(post.getWorker().getProfession())
                .workerProfileImage(post.getWorker().getUser().getProfileImageUrl())
                .content(post.getContent())
                .imageUrls(post.getImages().stream().map(PostImage::getImageUrl).toList())
                .createdAt(post.getCreatedAt())
                .updatedAt(post.getUpdatedAt())
                .commentCount(post.getComments().size())
                .reactionCount(post.getReactions().size())
                .isLiked(currentUserId != null && post.getReactions().stream()
                        .anyMatch(r -> r.getUser().getId().equals(currentUserId)))
                .workerVerified(post.getWorker().getVerified())
                .build();
    }
}
