import 'package:flutter/foundation.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });
}

class NotificationProvider extends ChangeNotifier {
  final List<AppNotification> _notifications = [];

  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  int get unreadCount {
    return _notifications.where((notification) {
      return !notification.isRead;
    }).length;
  }

  void addNotification({required String title, required String message}) {
    final notification = AppNotification(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      message: message,
      createdAt: DateTime.now(),
    );

    _notifications.insert(0, notification);

    notifyListeners();
  }

  void markAsRead(String id) {
    final notification = _notifications.firstWhere(
      (notification) => notification.id == id,
    );

    notification.isRead = true;

    notifyListeners();
  }

  void markAllAsRead() {
    for (final notification in _notifications) {
      notification.isRead = true;
    }

    notifyListeners();
  }

  void removeNotification(String id) {
    _notifications.removeWhere((notification) => notification.id == id);

    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();

    notifyListeners();
  }
}
