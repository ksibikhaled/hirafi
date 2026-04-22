package com.hirafi.backend.dto;

import lombok.*;

import lombok.*;

@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class AdminStatsDTO {
    private long totalUsers;
    private long totalWorkers;
    private long pendingWorkers;
    private long approvedWorkers;
    private long totalPosts;
    private long totalRequests;
    private long totalReviews;
    private double totalBalance;
}
