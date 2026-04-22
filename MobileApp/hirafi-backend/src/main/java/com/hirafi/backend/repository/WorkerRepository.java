package com.hirafi.backend.repository;

import com.hirafi.backend.entity.Worker;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface WorkerRepository extends JpaRepository<Worker, Long> {
    Optional<Worker> findByUserId(Long userId);

    Page<Worker> findByApprovedTrue(Pageable pageable);

    Page<Worker> findByApprovedFalse(Pageable pageable);

    @Query("SELECT w FROM Worker w WHERE w.approved = true " +
           "AND (:profession IS NULL OR LOWER(w.profession) LIKE LOWER(CONCAT('%', :profession, '%'))) " +
           "AND (:city IS NULL OR LOWER(w.city) LIKE LOWER(CONCAT('%', :city, '%'))) " +
           "AND (:country IS NULL OR LOWER(w.country) LIKE LOWER(CONCAT('%', :country, '%'))) " +
           "AND (:search IS NULL OR LOWER(w.user.firstName) LIKE LOWER(CONCAT('%', :search, '%')) " +
           "  OR LOWER(w.user.lastName) LIKE LOWER(CONCAT('%', :search, '%')) " +
           "  OR LOWER(w.profession) LIKE LOWER(CONCAT('%', :search, '%'))) " +
           "ORDER BY w.featured DESC, w.ratingAvg DESC")
    Page<Worker> searchWorkers(@Param("profession") String profession,
                               @Param("city") String city,
                               @Param("country") String country,
                               @Param("search") String search,
                               Pageable pageable);

    @Query("SELECT w FROM Worker w WHERE w.approved = true " +
           "AND w.id NOT IN (SELECT f.worker.id FROM Follower f WHERE f.user.id = :userId) " +
           "ORDER BY SIZE(w.followers) DESC")
    Page<Worker> findSuggestedWorkers(@Param("userId") Long userId, Pageable pageable);

    long countByApprovedTrue();
    long countByApprovedFalse();
}
