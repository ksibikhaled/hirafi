import 'package:flutter/foundation.dart';

class ApiConstants {
  // On Android emulator, the host machine is 10.0.2.2 (not localhost)
  // On web/desktop, localhost works fine
  static String get baseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return "http://10.0.2.2:8080/api";
    }
    return "http://localhost:8080/api";
  }
  
  // Auth
  static const String login = "/auth/login";
  static const String register = "/auth/register";
  static const String refreshToken = "/auth/refresh-token";
  
  // Users
  static const String userProfile = "/users/profile";
  static const String userFollowing = "/users/following";
  static const String userFeed = "/users/feed";
  static const String followWorker = "/users/follow";
  static const String userPosts = "/users/posts"; // For like/comment
  
  // Workers
  static const String workers = "/workers";
  static const String workerPosts = "/workers/{id}/posts";
  static const String workerPortfolio = "/workers/{id}/portfolio";
  static const String workerStats = "/workers/{id}/stats";
  static const String workerProfile = "/workers/profile";
  static const String workerMyPosts = "/workers/my-posts";
  static const String workerCreatePost = "/workers/posts";
  
  // Requests
  static const String requests = "/requests";
  static const String userRequests = "/requests/user";
  static const String workerRequests = "/requests/worker";
  
  // Admin
  static const String adminStats = "/admin/stats";
  static const String adminPendingWorkers = "/admin/workers/pending";
  static const String adminWorkers = "/admin/workers";
  static const String adminUsers = "/admin/users";
  static const String adminPosts = "/admin/posts";
  
  // Comments
  static const String postComments = "/users/posts"; // GET /{postId}/comments
  
  // Reviews
  static const String workerReviews = "/reviews/worker";
  
  // Wallet
  static const String walletBalance = "/wallet/balance";
  static const String walletHistory = "/wallet/history";
  static const String walletDeposit = "/wallet/deposit";
  static const String walletWithdraw = "/wallet/withdraw";
}
