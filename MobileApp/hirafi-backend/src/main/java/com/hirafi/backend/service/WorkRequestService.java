package com.hirafi.backend.service;

import com.hirafi.backend.dto.WorkRequestDTO;
import com.hirafi.backend.entity.*;
import com.hirafi.backend.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class WorkRequestService {

    private final WorkRequestRepository workRequestRepository;
    private final WorkerRepository workerRepository;
    private final NotificationRepository notificationRepository;
    private final WalletService walletService;

    @Transactional
    public WorkRequestDTO createRequest(User user, WorkRequestDTO request) {
        Worker worker = workerRepository.findById(request.getWorkerId())
                .orElseThrow(() -> new RuntimeException("Worker not found"));

        WorkRequest workRequest = WorkRequest.builder()
                .user(user)
                .worker(worker)
                .description(request.getDescription())
                .preferredDate(request.getPreferredDate())
                .location(request.getLocation())
                .amount(request.getAmount())
                .status(RequestStatus.PENDING)
                .build();
        workRequest = workRequestRepository.save(workRequest);

        // If amount is set, hold escrow from client's wallet
        if (workRequest.getAmount() != null && workRequest.getAmount().compareTo(java.math.BigDecimal.ZERO) > 0) {
            walletService.holdEscrow(user, workRequest.getAmount(), workRequest.getId().toString());
        }

        // Notify worker
        Notification notification = Notification.builder()
                .user(worker.getUser())
                .title("New Service Request")
                .message(user.getFirstName() + " " + user.getLastName() + " sent you a service request")
                .type("NEW_REQUEST")
                .referenceId(workRequest.getId())
                .build();
        notificationRepository.save(notification);

        return mapToDTO(workRequest);
    }

    public Page<WorkRequestDTO> getUserRequests(Long userId, Pageable pageable) {
        return workRequestRepository.findByUserIdOrderByCreatedAtDesc(userId, pageable)
                .map(this::mapToDTO);
    }

    public Page<WorkRequestDTO> getWorkerRequests(User user, Pageable pageable) {
        Worker worker = workerRepository.findByUserId(user.getId())
                .orElseThrow(() -> new RuntimeException("Worker profile not found"));
        return workRequestRepository.findByWorkerIdOrderByCreatedAtDesc(worker.getId(), pageable)
                .map(this::mapToDTO);
    }

    @Transactional
    public WorkRequestDTO updateRequestStatus(User user, Long requestId, String status) {
        WorkRequest workRequest = workRequestRepository.findById(requestId)
                .orElseThrow(() -> new RuntimeException("Request not found"));

        Worker worker = workerRepository.findByUserId(user.getId())
                .orElseThrow(() -> new RuntimeException("Worker profile not found"));

        if (!workRequest.getWorker().getId().equals(worker.getId())) {
            throw new RuntimeException("Unauthorized to update this request");
        }

        RequestStatus newStatus = RequestStatus.valueOf(status.toUpperCase());
        workRequest.setStatus(newStatus);
        workRequest = workRequestRepository.save(workRequest);

        // Notify user
        String message = switch (newStatus) {
            case ACCEPTED -> worker.getUser().getFirstName() + " accepted your service request";
            case REJECTED -> worker.getUser().getFirstName() + " declined your service request";
            case IN_PROGRESS -> worker.getUser().getFirstName() + " started working on your request";
            case COMPLETED -> {
                // If amount is set, release escrow to worker
                if (workRequest.getAmount() != null) {
                    walletService.releaseEscrow(worker.getUser(), workRequest.getAmount(), workRequest.getId().toString());
                }
                yield worker.getUser().getFirstName() + " completed your service request";
            }
            default -> "Your service request status was updated";
        };

        Notification notification = Notification.builder()
                .user(workRequest.getUser())
                .title("Request Update")
                .message(message)
                .type("REQUEST_UPDATE")
                .referenceId(workRequest.getId())
                .build();
        notificationRepository.save(notification);

        return mapToDTO(workRequest);
    }

    @Transactional
    public void cancelRequest(User user, Long requestId) {
        WorkRequest workRequest = workRequestRepository.findById(requestId)
                .orElseThrow(() -> new RuntimeException("Request not found"));

        if (!workRequest.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Unauthorized");
        }

        if (workRequest.getStatus() != RequestStatus.PENDING) {
            throw new RuntimeException("Can only cancel pending requests");
        }

        workRequest.setStatus(RequestStatus.CANCELLED);
        workRequestRepository.save(workRequest);

        // Refund escrow if amount was held
        if (workRequest.getAmount() != null && workRequest.getAmount().compareTo(java.math.BigDecimal.ZERO) > 0) {
            walletService.refundEscrow(user, workRequest.getAmount(), workRequest.getId().toString());
        }
    }

    private WorkRequestDTO mapToDTO(WorkRequest wr) {
        return WorkRequestDTO.builder()
                .id(wr.getId())
                .userId(wr.getUser().getId())
                .userFirstName(wr.getUser().getFirstName())
                .userLastName(wr.getUser().getLastName())
                .workerId(wr.getWorker().getId())
                .workerFirstName(wr.getWorker().getUser().getFirstName())
                .workerLastName(wr.getWorker().getUser().getLastName())
                .workerProfession(wr.getWorker().getProfession())
                .description(wr.getDescription())
                .preferredDate(wr.getPreferredDate())
                .location(wr.getLocation())
                .status(wr.getStatus().name())
                .amount(wr.getAmount())
                .createdAt(wr.getCreatedAt())
                .updatedAt(wr.getUpdatedAt())
                .build();
    }
}
