package com.hirafi.backend.service;

import com.hirafi.backend.dto.ReviewDTO;
import com.hirafi.backend.entity.Review;
import com.hirafi.backend.entity.User;
import com.hirafi.backend.entity.Worker;
import com.hirafi.backend.entity.Notification;
import com.hirafi.backend.repository.ReviewRepository;
import com.hirafi.backend.repository.WorkerRepository;
import com.hirafi.backend.repository.NotificationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

@Service
@RequiredArgsConstructor
public class ReviewService {

    private final ReviewRepository reviewRepository;
    private final WorkerRepository workerRepository;
    private final NotificationRepository notificationRepository;

    @Transactional
    public ReviewDTO addReview(User user, Long workerId, Integer rating, String comment) {
        Worker worker = workerRepository.findById(workerId)
                .orElseThrow(() -> new RuntimeException("Worker not found"));

        if (reviewRepository.findByWorkerIdAndUserId(workerId, user.getId()).isPresent()) {
            throw new RuntimeException("You have already reviewed this worker");
        }

        Review review = Review.builder()
                .user(user)
                .worker(worker)
                .rating(rating)
                .comment(comment)
                .build();
        review = reviewRepository.save(review);

        // Update worker average rating
        Double avg = reviewRepository.calculateAverageRating(workerId);
        worker.setRatingAvg(BigDecimal.valueOf(avg != null ? avg : 0.0));
        workerRepository.save(worker);

        // Notify worker
        Notification notification = Notification.builder()
                .user(worker.getUser())
                .title("Nouvel Avis")
                .message(user.getFirstName() + " vous a laissé une note de " + rating + "/5")
                .type("NEW_REVIEW")
                .referenceId(review.getId())
                .build();
        notificationRepository.save(notification);

        return mapToDTO(review);
    }

    public Page<ReviewDTO> getWorkerReviews(Long workerId, Pageable pageable) {
        return reviewRepository.findByWorkerIdOrderByCreatedAtDesc(workerId, pageable)
                .map(this::mapToDTO);
    }

    private ReviewDTO mapToDTO(Review review) {
        return ReviewDTO.builder()
                .id(review.getId())
                .userId(review.getUser().getId())
                .userFirstName(review.getUser().getFirstName())
                .userLastName(review.getUser().getLastName())
                .userProfileImage(review.getUser().getProfileImageUrl())
                .workerId(review.getWorker().getId())
                .rating(review.getRating())
                .comment(review.getComment())
                .createdAt(review.getCreatedAt())
                .build();
    }
}
