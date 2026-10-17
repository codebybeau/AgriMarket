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

  int get unreadCount =>
      _notifications.where((notification) => !notification.isRead).length;

  void addNotification({required String title, required String message}) {
    _notifications.insert(
      0,
      AppNotification(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title,
        message: message,
        createdAt: DateTime.now(),
      ),
    );

    notifyListeners();
  }

  void markAsRead(String id) {
    for (final notification in _notifications) {
      if (notification.id == id) {
        notification.isRead = true;
        notifyListeners();
        return;
      }
    }
  }

  void markAllAsRead() {
    for (final notification in _notifications) {
      notification.isRead = true;
    }

    notifyListeners();
  }
}
