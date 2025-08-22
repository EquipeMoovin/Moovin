import 'package:flutter/material.dart' as material;
import '../models/notification.dart';
import '../services/api_service_notification.dart';

class NotificationProvider with material.ChangeNotifier {
  List<Notification> _notifications = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;

  List<Notification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  final ApiService _apiService = ApiService();

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _apiService.fetchNotifications();
      _calculateUnreadCount();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _calculateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      await _apiService.markNotificationAsRead(notificationId);
      _notifications = _notifications.map((n) {
        if (n.id == notificationId) {
          return Notification(
            id: n.id,
            title: n.title,
            message: n.message,
            type: n.type,
            isRead: true,
            createdAt: n.createdAt,
            relatedObjectId: n.relatedObjectId,
            relatedObjectType: n.relatedObjectType,
          );
        }
        return n;
      }).toList();
      _calculateUnreadCount();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> deleteNotification(int notificationId) async {
    try {
      await _apiService.deleteNotification(notificationId);
      _notifications.removeWhere((n) => n.id == notificationId);
      _calculateUnreadCount();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> markAllAsRead() async {
    try {
      await _apiService.markAllAsRead();
      _notifications = _notifications.map((n) {
        return Notification(
          id: n.id,
          title: n.title,
          message: n.message,
          type: n.type,
          isRead: true,
          createdAt: n.createdAt,
          relatedObjectId: n.relatedObjectId,
          relatedObjectType: n.relatedObjectType,
        );
      }).toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}