import 'package:flutter/foundation.dart';

import '../models/product.dart';

class LocalOrder {
  final String id;
  final List<LocalOrderItem> items;
  final double total;
  String status;
  final DateTime createdAt;

  LocalOrder({
    required this.id,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
  });
}

class LocalOrderItem {
  final Product product;
  final int quantity;

  LocalOrderItem({required this.product, required this.quantity});
}

class OrderProvider extends ChangeNotifier {
  final List<LocalOrder> _orders = [];

  List<LocalOrder> get orders => List.unmodifiable(_orders);

  void createOrder({
    required List<LocalOrderItem> items,
    required double total,
  }) {
    _orders.insert(
      0,
      LocalOrder(
        id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
        items: List.unmodifiable(items),
        total: total,
        status: 'Pending',
        createdAt: DateTime.now(),
      ),
    );

    notifyListeners();
  }

  void updateStatus(String id, String status) {
    for (final order in _orders) {
      if (order.id == id) {
        order.status = status;
        notifyListeners();
        return;
      }
    }
  }
}
