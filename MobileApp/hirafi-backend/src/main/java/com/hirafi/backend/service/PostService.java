package com.hirafi.backend.service;

import com.hirafi.backend.entity.Post;
import com.hirafi.backend.entity.PostImage;
import com.hirafi.backend.entity.Worker;
import com.hirafi.backend.repository.PostRepository;
import com.hirafi.backend.repository.WorkerRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class PostService {

    private final PostRepository postRepository;
    private final WorkerRepository workerRepository;
    private final FileStorageService fileStorageService;

    public Page<Post> getFeed(Long userId, Pageable pageable) {
        return postRepository.findAllByOrderByCreatedAtDesc(pageable);
    }

    public Page<Post> getWorkerPosts(Long workerId, Pageable pageable) {
        return postRepository.findByWorkerIdOrderByCreatedAtDesc(workerId, pageable);
    }

    @Transactional
    public Post createPost(Long workerId, String content, List<MultipartFile> images) {
        Worker worker = workerRepository.findById(workerId)
                .orElseThrow(() -> new RuntimeException("Worker not found"));

        Post post = new Post();
        post.setWorker(worker);
        post.setContent(content);
        post.setCreatedAt(LocalDateTime.now());
        post.setImages(new ArrayList<>());
        post = postRepository.save(post);

        if (images != null) {
            int order = 0;
            for (MultipartFile image : images) {
                if (!image.isEmpty()) {
                    String imageUrl = fileStorageService.storeFile(image, "posts");
                    PostImage postImage = PostImage.builder()
                            .post(post)
                            .imageUrl(imageUrl)
                            .sortOrder(order++)
                            .build();
                    post.getImages().add(postImage);
                }
            }
            post = postRepository.save(post);
        }

        return post;
    }
}
