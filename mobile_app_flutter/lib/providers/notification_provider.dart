import 'package:flutter/material.dart';
import '../models/notification_item.dart';
import '../services/api_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationItem> _notifications = [];
  bool _isLoading = false;

  List<NotificationItem> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get isLoading => _isLoading;

  NotificationProvider() {
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService().getNotifications();
      if (res['success'] == true) {
        final List<dynamic> data = res['data'];
        _notifications = data.map((json) => NotificationItem.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index].isRead = true;
      notifyListeners();
      try {
        await ApiService().markNotificationRead(id);
      } catch (e) {
        debugPrint('Error marking read: $e');
      }
    }
  }

  Future<void> markAllAsRead() async {
    bool hasUnread = false;
    for (var n in _notifications) {
      if (!n.isRead) {
        n.isRead = true;
        hasUnread = true;
      }
    }
    if (hasUnread) {
      notifyListeners();
      try {
        await ApiService().markAllNotificationsRead();
      } catch (e) {
        debugPrint('Error marking all read: $e');
      }
    }
  }

  void addNotification(NotificationItem item) {
    _notifications.insert(0, item);
    notifyListeners();
  }
}
