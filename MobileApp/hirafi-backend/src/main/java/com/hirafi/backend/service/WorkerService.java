package com.hirafi.backend.service;

import com.hirafi.backend.dto.*;
import com.hirafi.backend.entity.*;
import com.hirafi.backend.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class WorkerService {

    private final WorkerRepository workerRepository;
    private final PostRepository postRepository;
    private final PostImageRepository postImageRepository;
    private final PortfolioRepository portfolioRepository;
    private final FollowerRepository followerRepository;
    private final WorkRequestRepository workRequestRepository;
    private final FileStorageService fileStorageService;
    private final WalletService walletService;
    private final NotificationRepository notificationRepository;
    private final ReviewRepository reviewRepository;

    public Page<WorkerDTO> searchWorkers(String profession, String city, String country, String search, Long currentUserId, Pageable pageable) {
        return workerRepository.searchWorkers(profession, city, country, search, pageable)
                .map(w -> mapWorkerToDTO(w, currentUserId));
    }

    public Page<WorkerDTO> getSuggestedWorkers(Long userId, Pageable pageable) {
        return workerRepository.findSuggestedWorkers(userId, pageable)
                .map(w -> mapWorkerToDTO(w, userId));
    }

    public WorkerDTO getWorkerById(Long id, Long currentUserId) {
        Worker worker = workerRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Worker not found"));
        return mapWorkerToDTO(worker, currentUserId);
    }

    public WorkerDTO getWorkerByUserId(Long userId) {
        Worker worker = workerRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Worker profile not found"));
        return mapWorkerToDTO(worker, null);
    }

    @Transactional
    public WorkerDTO updateWorkerProfile(User user, WorkerDTO request) {
        Worker worker = workerRepository.findByUserId(user.getId())
                .orElseThrow(() -> new RuntimeException("Worker profile not found"));

        if (request.getFirstName() != null) user.setFirstName(request.getFirstName());
        if (request.getLastName() != null) user.setLastName(request.getLastName());
        if (request.getProfession() != null) worker.setProfession(request.getProfession());
        if (request.getPhone() != null) worker.setPhone(request.getPhone());
        if (request.getWebsite() != null) worker.setWebsite(request.getWebsite());
        if (request.getBio() != null) worker.setBio(request.getBio());
        if (request.getCity() != null) worker.setCity(request.getCity());
        if (request.getCountry() != null) worker.setCountry(request.getCountry());

        workerRepository.save(worker);
        return mapWorkerToDTO(worker, null);
    }

    // Post management
    @Transactional
    public PostDTO createPost(User user, String content, List<MultipartFile> images) {
        Worker worker = workerRepository.findByUserId(user.getId())
                .orElseThrow(() -> new RuntimeException("Worker profile not found"));

        Post post = Post.builder()
                .worker(worker)
                .content(content)
                .images(new ArrayList<>())
                .build();
        post = postRepository.save(post);

        if (images != null) {
            int order = 0;
            for (MultipartFile image : images) {
                String imageUrl = fileStorageService.storeFile(image, "posts");
                PostImage postImage = PostImage.builder()
                        .post(post)
                        .imageUrl(imageUrl)
                        .sortOrder(order++)
                        .build();
                post.getImages().add(postImage);
            }
            post = postRepository.save(post);
        }

        return mapPostToDTO(post, user.getId());
    }

    @Transactional
    public PostDTO createPostJson(User user, PostDTO request) {
        Worker worker = workerRepository.findByUserId(user.getId())
                .orElseThrow(() -> new RuntimeException("Worker profile not found"));

        Post post = Post.builder()
                .worker(worker)
                .content(request.getContent())
                .images(new ArrayList<>())
                .build();
        post = postRepository.save(post);

        if (request.getImageUrls() != null) {
            int order = 0;
            for (String imageUrl : request.getImageUrls()) {
                PostImage postImage = PostImage.builder()
                        .post(post)
                        .imageUrl(imageUrl)
                        .sortOrder(order++)
                        .build();
                post.getImages().add(postImage);
            }
            post = postRepository.save(post);
        }

        return mapPostToDTO(post, user.getId());
    }

    @Transactional
    public PostDTO updatePost(User user, Long postId, String content) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new RuntimeException("Post not found"));

        Worker worker = workerRepository.findByUserId(user.getId())
                .orElseThrow(() -> new RuntimeException("Worker profile not found"));

        if (!post.getWorker().getId().equals(worker.getId())) {
            throw new RuntimeException("Unauthorized to edit this post");
        }

        post.setContent(content);
        post = postRepository.save(post);
        return mapPostToDTO(post);
    }

    @Transactional
    public void deletePost(User user, Long postId) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new RuntimeException("Post not found"));

        Worker worker = workerRepository.findByUserId(user.getId())
                .orElseThrow(() -> new RuntimeException("Worker profile not found"));

        if (!post.getWorker().getId().equals(worker.getId())) {
            throw new RuntimeException("Unauthorized to delete this post");
        }

        post.getImages().forEach(img -> fileStorageService.deleteFile(img.getImageUrl()));
        postRepository.delete(post);
    }

    public Page<PostDTO> getWorkerPosts(Long workerId, Pageable pageable) {
        return postRepository.findByWorkerIdOrderByCreatedAtDesc(workerId, pageable)
                .map(this::mapPostToDTO);
    }

    public Page<PostDTO> getMyPosts(User user, Pageable pageable) {
        Worker worker = workerRepository.findByUserId(user.getId())
                .orElseThrow(() -> new RuntimeException("Worker profile not found"));
        return postRepository.findByWorkerIdOrderByCreatedAtDesc(worker.getId(), pageable)
                .map(this::mapPostToDTO);
    }

    // Portfolio management
    @Transactional
    public PortfolioDTO addPortfolioItem(User user, String title, String description, MultipartFile image) {
        Worker worker = workerRepository.findByUserId(user.getId())
                .orElseThrow(() -> new RuntimeException("Worker profile not found"));

        String imageUrl = null;
        if (image != null && !image.isEmpty()) {
            imageUrl = fileStorageService.storeFile(image, "portfolio");
        }

        Portfolio portfolio = Portfolio.builder()
                .worker(worker)
                .title(title)
                .description(description)
                .imageUrl(imageUrl)
                .build();
        portfolio = portfolioRepository.save(portfolio);

        return mapPortfolioToDTO(portfolio);
    }

    @Transactional
    public void deletePortfolioItem(User user, Long portfolioId) {
        Portfolio portfolio = portfolioRepository.findById(portfolioId)
                .orElseThrow(() -> new RuntimeException("Portfolio item not found"));

        Worker worker = workerRepository.findByUserId(user.getId())
                .orElseThrow(() -> new RuntimeException("Worker profile not found"));

        if (!portfolio.getWorker().getId().equals(worker.getId())) {
            throw new RuntimeException("Unauthorized to delete this portfolio item");
        }

        fileStorageService.deleteFile(portfolio.getImageUrl());
        portfolioRepository.delete(portfolio);
    }

    public Page<PortfolioDTO> getWorkerPortfolio(Long workerId, Pageable pageable) {
        return portfolioRepository.findByWorkerIdOrderByCreatedAtDesc(workerId, pageable)
                .map(this::mapPortfolioToDTO);
    }

    @Transactional
    public WorkerDTO toggleFeatured(User user) {
        Worker worker = workerRepository.findByUserId(user.getId())
                .orElseThrow(() -> new RuntimeException("Worker not found"));
        
        boolean wasFeatured = worker.getFeatured() != null && worker.getFeatured();
        boolean willBeFeatured = !wasFeatured;

        if (willBeFeatured) {
            // Deduct 25 TND for the boost
            walletService.deposit(user, java.math.BigDecimal.valueOf(-25.0), "BOOST_" + System.currentTimeMillis());
        }

        worker.setFeatured(willBeFeatured);
        return mapWorkerToDTO(workerRepository.save(worker), user.getId());
    }

    // Stats
    public WorkerDTO getWorkerStats(Long workerId) {
        Worker worker = workerRepository.findById(workerId)
                .orElseThrow(() -> new RuntimeException("Worker not found"));
        return mapWorkerToDTO(worker, null);
    }

    // Mapping helpers
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
                .featured(worker.getFeatured())
                .reviewsCount(reviewRepository.countByWorkerId(worker.getId()))
                .build();
    }

    private PostDTO mapPostToDTO(Post post) {
        return mapPostToDTO(post, post.getWorker().getUser().getId()); // Self view usually
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

    private PortfolioDTO mapPortfolioToDTO(Portfolio portfolio) {
        return PortfolioDTO.builder()
                .id(portfolio.getId())
                .workerId(portfolio.getWorker().getId())
                .title(portfolio.getTitle())
                .description(portfolio.getDescription())
                .imageUrl(portfolio.getImageUrl())
                .createdAt(portfolio.getCreatedAt())
                .build();
    }
}
