import 'package:flutter/foundation.dart';

import '../models/product.dart';

class CartLine {
  final Product product;
  int quantity;

  CartLine({required this.product, required this.quantity});

  double get subtotal => product.price * quantity;
}

class CartProvider extends ChangeNotifier {
  final List<CartLine> _items = [];

  List<CartLine> get items => List.unmodifiable(_items);

  int get itemCount {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  double get total {
    return _items.fold(0, (sum, item) => sum + item.subtotal);
  }

  void add(Product product) {
    if (product.stock <= 0) return;

    final index = _items.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      if (_items[index].quantity < product.stock) {
        _items[index].quantity++;
      }
    } else {
      _items.add(CartLine(product: product, quantity: 1));
    }

    notifyListeners();
  }

  void increase(Product product) {
    add(product);
  }

  void decrease(Product product) {
    final index = _items.indexWhere((item) => item.product.id == product.id);

    if (index == -1) return;

    if (_items[index].quantity > 1) {
      _items[index].quantity--;
    } else {
      _items.removeAt(index);
    }

    notifyListeners();
  }

  void remove(Product product) {
    _items.removeWhere((item) => item.product.id == product.id);

    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
