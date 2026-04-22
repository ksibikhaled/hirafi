import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';
import '../models/worker.dart';
import '../models/user.dart';
import '../models/post.dart';

class AdminProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Worker> _pendingWorkers = [];
  List<Worker> _allWorkers = [];
  List<User> _allUsers = [];
  List<Post> _allPosts = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = false;
  String? _error;

  List<Worker> get pendingWorkers => _pendingWorkers;
  List<Worker> get allWorkers => _allWorkers;
  List<User> get allUsers => _allUsers;
  List<Post> get allPosts => _allPosts;
  Map<String, dynamic> get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchStats() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.dio.get(ApiConstants.adminStats);
      if (response.data['success']) {
        _stats = response.data['data'];
      }
    } catch (e) {
      _error = "Échec du chargement des statistiques";
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchPendingWorkers() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.dio.get(ApiConstants.adminPendingWorkers);
      if (response.data['success']) {
        final List results = response.data['data']['content'] ?? response.data['data'];
        _pendingWorkers = results.map((e) => Worker.fromJson(e)).toList();
      }
    } catch (e) {
      _error = "Échec du chargement des artisans en attente";
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAllWorkers() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.dio.get(ApiConstants.adminWorkers);
      if (response.data['success']) {
        final List results = response.data['data']['content'] ?? response.data['data'];
        _allWorkers = results.map((e) => Worker.fromJson(e)).toList();
      }
    } catch (e) {
      _error = "Échec du chargement des artisans";
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> approveWorker(int workerId) async {
    try {
      final response = await _apiService.dio.put('${ApiConstants.adminWorkers}/$workerId/approve');
      if (response.data['success']) {
        _pendingWorkers.removeWhere((w) => w.id == workerId);
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = "Échec de l'approbation";
    }
    return false;
  }

  Future<bool> blockWorker(int workerId) async {
    try {
      final response = await _apiService.dio.put('${ApiConstants.adminWorkers}/$workerId/block');
      if (response.data['success']) {
        _pendingWorkers.removeWhere((w) => w.id == workerId);
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = "Échec du blocage";
    }
    return false;
  }

  Future<bool> deleteWorker(int workerId) async {
    try {
      final response = await _apiService.dio.delete('${ApiConstants.adminWorkers}/$workerId');
      if (response.data['success']) {
        _allWorkers.removeWhere((w) => w.id == workerId);
        _pendingWorkers.removeWhere((w) => w.id == workerId);
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = "Échec de la suppression";
    }
    return false;
  }

  Future<bool> verifyWorker(int workerId, bool status) async {
    try {
      final response = await _apiService.dio.put(
        '${ApiConstants.adminWorkers}/$workerId/verify',
        queryParameters: {'status': status},
      );
      if (response.data['success']) {
        final idx = _allWorkers.indexWhere((w) => w.id == workerId);
        if (idx != -1) {
          final old = _allWorkers[idx];
          _allWorkers[idx] = Worker(
            id: old.id,
            userId: old.userId,
            firstName: old.firstName,
            lastName: old.lastName,
            email: old.email,
            profileImageUrl: old.profileImageUrl,
            profession: old.profession,
            phone: old.phone,
            website: old.website,
            bio: old.bio,
            city: old.city,
            country: old.country,
            approved: old.approved,
            ratingAvg: old.ratingAvg,
            followersCount: old.followersCount,
            postsCount: old.postsCount,
            portfolioCount: old.portfolioCount,
            isFollowed: old.isFollowed,
            verified: status,
            reviewsCount: old.reviewsCount,
          );
          notifyListeners();
        }
        return true;
      }
    } catch (e) {
      _error = "Échec de la mise à jour de la certification";
    }
    return false;
  }

  Future<void> fetchAllUsers() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.dio.get(ApiConstants.adminUsers);
      if (response.data['success']) {
        final List results = response.data['data']['content'] ?? response.data['data'];
        _allUsers = results.map((e) => User.fromJson(e)).toList();
      }
    } catch (e) {
      _error = "Échec du chargement des utilisateurs";
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> deleteUser(int userId) async {
    try {
      final response = await _apiService.dio.delete('${ApiConstants.adminUsers}/$userId');
      if (response.data['success']) {
        _allUsers.removeWhere((u) => u.id == userId);
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = "Échec de la suppression";
    }
    return false;
  }

  Future<void> fetchAllPosts() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.dio.get(ApiConstants.adminPosts);
      if (response.data['success']) {
        final List results = response.data['data']['content'] ?? response.data['data'];
        _allPosts = results.map((e) => Post.fromJson(e)).toList();
      }
    } catch (e) {
      _error = "Échec du chargement des publications";
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> deletePost(int postId) async {
    try {
      final response = await _apiService.dio.delete('${ApiConstants.adminPosts}/$postId');
      if (response.data['success']) {
        _allPosts.removeWhere((p) => p.id == postId);
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = "Échec de la suppression";
    }
    return false;
  }
}
