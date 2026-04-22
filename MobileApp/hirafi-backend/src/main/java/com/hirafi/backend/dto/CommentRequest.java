package com.hirafi.backend.dto;

import lombok.Data;

@Data
public class CommentRequest {
    private String content;
    private String imageUrl;
}
