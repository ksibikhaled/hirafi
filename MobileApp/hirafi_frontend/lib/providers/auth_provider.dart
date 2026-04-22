import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  final ApiService _apiService = ApiService();

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      if (response.data['success']) {
        final data = response.data['data'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', data['accessToken']);
        await prefs.setString('refresh_token', data['refreshToken']);
        
        _user = User.fromJson(data);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.data['message'];
      }
    } catch (e) {
      _error = "An error occurred during login";
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.dio.post(
        ApiConstants.register,
        data: data,
      );

      if (response.data['success']) {
        final resData = response.data['data'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', resData['accessToken']);
        await prefs.setString('refresh_token', resData['refreshToken']);
        
        _user = User.fromJson(resData);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.data['message'];
      }
    } catch (e) {
      _error = "An error occurred during registration";
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _user = null;
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    _isLoading = true;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('access_token')) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final response = await _apiService.dio.get(ApiConstants.userProfile);
      if (response.data['success']) {
        _user = User.fromJson(response.data['data']);
      }
    } catch (e) {
      _user = null;
    }
    
    _isLoading = false;
    notifyListeners();
  }
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = _user?.role == 'WORKER' ? ApiConstants.workerProfile : ApiConstants.userProfile;
      final response = await _apiService.dio.put(url, data: data);
      
      if (response.data['success']) {
        _user = User.fromJson(response.data['data']);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = "Failed to update profile";
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}
