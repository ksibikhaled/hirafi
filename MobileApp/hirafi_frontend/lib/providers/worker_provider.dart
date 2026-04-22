import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';
import '../models/worker.dart';
import '../models/post.dart';
import '../models/work_request.dart';
import '../models/comment.dart';
import '../models/review.dart';

class WorkerProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Worker> _workers = [];
  List<Post> _feed = [];
  List<WorkRequest> _userRequests = [];
  List<WorkRequest> _workerRequests = [];
  bool _isLoading = false;
  String? _error;

  List<Worker> get workers => _workers;
  List<Post> get feed => _feed;
  List<WorkRequest> get userRequests => _userRequests;
  List<WorkRequest> get workerRequests => _workerRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchFeed() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.dio.get(ApiConstants.userFeed);
      if (response.data['success']) {
        final data = response.data['data'];
        final List results = data is Map ? (data['content'] ?? []) : data;
        _feed = results.map((e) => Post.fromJson(e)).toList();
      }
    } catch (e) {
      _error = "Échec du chargement du fil d'actualité";
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchWorkers({String? profession, String? city, String? search}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.dio.get(
        ApiConstants.workers,
        queryParameters: {
          if (profession != null) 'profession': profession,
          if (city != null) 'city': city,
          if (search != null) 'search': search,
        },
      );
      if (response.data['success']) {
        final data = response.data['data'];
        final List results = data is Map ? (data['content'] ?? []) : data;
        _workers = results.map((e) => Worker.fromJson(e)).toList();
      }
    } catch (e) {
      _error = "Échec de la recherche";
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Worker?> getWorkerById(int workerId) async {
    try {
      final response = await _apiService.dio.get('${ApiConstants.workers}/$workerId');
      if (response.data['success']) {
        return Worker.fromJson(response.data['data']);
      }
    } catch (e) {
      // Error handling
    }
    return null;
  }

  Future<bool> followWorker(int workerId) async {
    try {
      final response = await _apiService.dio.post("${ApiConstants.followWorker}/$workerId");
      if (response.data['success']) {
        return true;
      }
    } catch (e) {
      // Handle error
    }
    return false;
  }

  Future<bool> createWorkRequest(int workerId, String description, String date, String location, {double? amount}) async {
    try {
      final data = <String, dynamic>{
        'workerId': workerId,
        'description': description,
        'preferredDate': date,
        'location': location,
      };
      if (amount != null && amount > 0) {
        data['amount'] = amount;
      }
      final response = await _apiService.dio.post(
        ApiConstants.requests,
        data: data,
      );
      return response.data['success'] ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> fetchUserRequests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.dio.get(ApiConstants.userRequests);
      if (response.data['success']) {
        final data = response.data['data'];
        final List results = data is Map ? (data['content'] ?? []) : data;
        _userRequests = results.map((e) => WorkRequest.fromJson(e)).toList();
      }
    } catch (e) {
      _error = "Échec du chargement des demandes";
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchWorkerRequests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.dio.get(ApiConstants.workerRequests);
      if (response.data['success']) {
        final data = response.data['data'];
        final List results = data is Map ? (data['content'] ?? []) : data;
        _workerRequests = results.map((e) => WorkRequest.fromJson(e)).toList();
      }
    } catch (e) {
      _error = "Échec du chargement des demandes";
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateRequestStatus(int requestId, String status) async {
    try {
      final response = await _apiService.dio.put(
        '${ApiConstants.requests}/$requestId/status',
        data: {'status': status},
      );
      if (response.data['success']) {
        // Update local list
        final idx = _workerRequests.indexWhere((r) => r.id == requestId);
        if (idx != -1) {
          final old = _workerRequests[idx];
          _workerRequests[idx] = WorkRequest(
            id: old.id,
            userId: old.userId,
            userFirstName: old.userFirstName,
            userLastName: old.userLastName,
            workerId: old.workerId,
            workerFirstName: old.workerFirstName,
            workerLastName: old.workerLastName,
            workerProfession: old.workerProfession,
            description: old.description,
            preferredDate: old.preferredDate,
            location: old.location,
            status: status,
            createdAt: old.createdAt,
          );
          notifyListeners();
        }
        return true;
      }
    } catch (e) {
      // Error
    }
    return false;
  }

  Future<bool> cancelRequest(int requestId) async {
    try {
      final response = await _apiService.dio.delete('${ApiConstants.requests}/$requestId');
      if (response.data['success']) {
        _userRequests.removeWhere((r) => r.id == requestId);
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Error
    }
    return false;
  }

  Future<bool> createPost(String content, List<String> images) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.dio.post(
        ApiConstants.workerCreatePost,
        data: {
          'content': content,
          'imageUrls': images,
        },
      );
      
      if (response.data['success']) {
        await fetchFeed();
        return true;
      }
    } catch (e) {
      _error = "Échec de la publication";
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> toggleLike(int postId) async {
    try {
      final response = await _apiService.dio.post("${ApiConstants.userPosts}/$postId/like");
      if (response.data['success']) {
        final index = _feed.indexWhere((p) => p.id == postId);
        if (index != -1) {
          final post = _feed[index];
          _feed[index] = Post(
            id: post.id,
            workerId: post.workerId,
            workerUserId: post.workerUserId,
            workerFirstName: post.workerFirstName,
            workerLastName: post.workerLastName,
            workerProfession: post.workerProfession,
            workerProfileImage: post.workerProfileImage,
            content: post.content,
            imageUrls: post.imageUrls,
            createdAt: post.createdAt,
            isLiked: !post.isLiked,
            reactionCount: post.isLiked ? post.reactionCount - 1 : post.reactionCount + 1,
            commentCount: post.commentCount,
          );
          notifyListeners();
        }
      }
    } catch (e) {
      // Error
    }
  }

  Future<bool> addComment(int postId, String content, {String? imageUrl}) async {
    try {
      final response = await _apiService.dio.post(
        "${ApiConstants.userPosts}/$postId/comment",
        data: {
          'content': content,
          if (imageUrl != null) 'imageUrl': imageUrl,
        },
      );
      if (response.data['success']) {
        // Update comment count locally
        final index = _feed.indexWhere((p) => p.id == postId);
        if (index != -1) {
          final post = _feed[index];
          _feed[index] = Post(
            id: post.id,
            workerId: post.workerId,
            workerUserId: post.workerUserId,
            workerFirstName: post.workerFirstName,
            workerLastName: post.workerLastName,
            workerProfession: post.workerProfession,
            workerProfileImage: post.workerProfileImage,
            content: post.content,
            imageUrls: post.imageUrls,
            createdAt: post.createdAt,
            isLiked: post.isLiked,
            reactionCount: post.reactionCount,
            commentCount: post.commentCount + 1,
          );
          notifyListeners();
        }
        return true;
      }
    } catch (e) {
      // Error
    }
    return false;
  }

  Future<List<Comment>> fetchComments(int postId) async {
    try {
      final response = await _apiService.dio.get("${ApiConstants.userPosts}/$postId/comments");
      if (response.data['success']) {
        final data = response.data['data'];
        final List results = data is Map ? (data['content'] ?? []) : data;
        return results.map((e) => Comment.fromJson(e)).toList();
      }
    } catch (e) {
      // Error
    }
    return [];
  }

  Future<bool> updatePost(int postId, String content) async {
    try {
      final response = await _apiService.dio.put("${ApiConstants.workerCreatePost}/$postId", data: {'content': content});
      if (response.data['success']) {
        await fetchFeed();
        return true;
      }
    } catch (e) {
      // Error
    }
    return false;
  }

  Future<bool> deletePost(int postId) async {
    try {
      final response = await _apiService.dio.delete("${ApiConstants.workerCreatePost}/$postId");
      if (response.data['success']) {
        _feed.removeWhere((p) => p.id == postId);
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Error
    }
    return false;
  }

  // Reviews
  Future<List<Review>> fetchWorkerReviews(int workerId) async {
    try {
      final response = await _apiService.dio.get("${ApiConstants.workerReviews}/$workerId");
      if (response.data['success']) {
        final data = response.data['data'];
        final List results = data is Map ? (data['content'] ?? []) : data;
        return results.map((e) => Review.fromJson(e)).toList();
      }
    } catch (e) {
      // Error
    }
    return [];
  }

  Future<bool> addReview(int workerId, int rating, String comment) async {
    try {
      final response = await _apiService.dio.post(
        "${ApiConstants.workerReviews}/$workerId",
        data: {
          'rating': rating,
          'comment': comment,
        },
      );
      return response.data['success'] ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> toggleFeatured(int workerId) async {
    try {
      final response = await _apiService.dio.post("${ApiConstants.workers}/toggle-featured");
      if (response.data['success']) {
        final updatedWorkerData = response.data['data'];
        final updatedWorker = Worker.fromJson(updatedWorkerData);
        
        // Update in list if exists
        final index = _workers.indexWhere((w) => w.id == workerId);
        if (index != -1) {
          _workers[index] = updatedWorker;
        }
        
        notifyListeners();
      }
    } catch (e) {
      // Error
    }
  }
}
