import 'package:flutter/material.dart';
import '../models/notification.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';

class NotificationProvider with ChangeNotifier {
  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  int _unreadCount = 0;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _unreadCount;

  final ApiService _apiService = ApiService();

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.dio.get('/users/notifications');
      if (response.data['success']) {
        final List<dynamic> data = response.data['data']['content'];
        _notifications = data.map((json) => AppNotification.fromJson(json)).toList();
        _unreadCount = _notifications.where((n) => !n.read).length;
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _apiService.dio.put('/users/notifications/$id/read');
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        final n = _notifications[index];
        _notifications[index] = AppNotification(
          id: n.id,
          title: n.title,
          message: n.message,
          type: n.type,
          referenceId: n.referenceId,
          read: true,
          createdAt: n.createdAt,
        );
        _unreadCount = _notifications.where((n) => !n.read).length;
        notifyListeners();
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  void clearNotifications() {
    _notifications = [];
    _unreadCount = 0;
    notifyListeners();
  }
}
