import 'package:flutter/material.dart';
import '../models/notification_item.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationItem> _notifications = [];

  List<NotificationItem> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationProvider() {
    _loadInitialMockNotifications();
  }

  void _loadInitialMockNotifications() {
    // Generate realistic mock notifications
    _notifications = [
      NotificationItem(
        id: '1',
        title: 'Market Alert: Tomato Prices',
        message: 'Tomato prices have increased by 4% in Mandya APMC market.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        type: 'market',
        isRead: false,
      ),
      NotificationItem(
        id: '2',
        title: 'New Feature: Equipment Rental',
        message: 'You can now rent tractors and other equipment directly from the app!',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        type: 'feature',
        isRead: false,
      ),
      NotificationItem(
        id: '3',
        title: 'Weather Warning',
        message: 'Heavy rainfall expected tomorrow in your district. Please secure your harvested crops.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: 'weather',
        isRead: true,
      ),
      NotificationItem(
        id: '4',
        title: 'Disease Alert: Rice Blast',
        message: 'High humidity increases risk of Rice Blast. Monitor your fields closely.',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        type: 'alert',
        isRead: true,
      ),
    ];
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    bool hasUnread = false;
    for (var n in _notifications) {
      if (!n.isRead) {
        n.isRead = true;
        hasUnread = true;
      }
    }
    if (hasUnread) {
      notifyListeners();
    }
  }

  void addNotification(NotificationItem item) {
    _notifications.insert(0, item);
    notifyListeners();
  }
}
