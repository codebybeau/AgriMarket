import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _cartShops = [
    {
      'shopName': 'Dela Cruz Family Farm',
      'isMall': true,
      'isPreferred': false,
      'selected': false,
      'items': [
        {
          'id': 'p1',
          'name': 'Organic Ampalaya (Bitter Gourd)',
          'variant': '1kg',
          'price': 85.00,
          'quantity': 2,
          'selected': false,
          'image':
              'https://images.unsplash.com/photo-1546094096-0df4bcaaa337?w=600',
          'badge': 'Fresh Harvest',
        },
        {
          'id': 'p2',
          'name': 'Carabao Mango (Export Quality)',
          'variant': '1kg',
          'price': 180.00,
          'quantity': 1,
          'selected': false,
          'image':
              'https://images.unsplash.com/photo-1553279768-865429fa0078?w=600',
          'badge': null,
        },
      ],
    },
    {
      'shopName': 'Nueva Ecija Rice Cooperative',
      'isMall': false,
      'isPreferred': true,
      'selected': false,
      'items': [
        {
          'id': 'p3',
          'name': 'Dinorado Rice (Premium)',
          'variant': '5kg Sack',
          'price': 340.00,
          'quantity': 1,
          'selected': false,
          'image':
              'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=600',
          'badge': null,
        },
      ],
    },
  ];

  List<Map<String, dynamic>> get cartShops => _cartShops;

  /// Total distinct total items quantity in cart (for badges)
  int get totalCartCount {
    int total = 0;
    for (var shop in _cartShops) {
      for (var item in (shop['items'] as List)) {
        total += (item['quantity'] as int);
      }
    }
    return total;
  }

  /// Total price of checked/selected items
  double get totalPrice {
    double total = 0.0;
    for (var shop in _cartShops) {
      for (var item in (shop['items'] as List)) {
        if (item['selected'] == true) {
          total += (item['price'] as double) * (item['quantity'] as int);
        }
      }
    }
    return total;
  }

  /// Count of selected items
  int get selectedCount {
    int count = 0;
    for (var shop in _cartShops) {
      for (var item in (shop['items'] as List)) {
        if (item['selected'] == true) {
          count += (item['quantity'] as int);
        }
      }
    }
    return count;
  }

  /// Returns true if all items in all shops are selected
  bool get isAllSelected {
    if (_cartShops.isEmpty) return false;
    for (var shop in _cartShops) {
      for (var item in (shop['items'] as List)) {
        if (item['selected'] == false) return false;
      }
    }
    return true;
  }

  /// Add item to cart
  void addToCart({
    required String name,
    required double price,
    String? variant,
    String? image,
    String? shopName,
    bool isMall = false,
    bool isPreferred = false,
  }) {
    final targetShopName = shopName ?? 'Dela Cruz Family Farm';
    final defaultImage = image ??
        'https://images.unsplash.com/photo-1546094096-0df4bcaaa337?w=600';
    final defaultVariant = variant ?? '1kg';

    // Check if shop exists
    int shopIndex =
        _cartShops.indexWhere((s) => s['shopName'] == targetShopName);

    if (shopIndex == -1) {
      // Add new shop and product
      _cartShops.add({
        'shopName': targetShopName,
        'isMall': isMall,
        'isPreferred': isPreferred,
        'selected': false,
        'items': [
          {
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'name': name,
            'variant': defaultVariant,
            'price': price,
            'quantity': 1,
            'selected': false,
            'image': defaultImage,
            'badge': null,
          }
        ],
      });
    } else {
      // Check if product exists in shop
      final items = _cartShops[shopIndex]['items'] as List;
      int itemIndex = items.indexWhere(
          (i) => i['name'] == name && i['variant'] == defaultVariant);

      if (itemIndex != -1) {
        items[itemIndex]['quantity'] =
            (items[itemIndex]['quantity'] as int) + 1;
      } else {
        items.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'name': name,
          'variant': defaultVariant,
          'price': price,
          'quantity': 1,
          'selected': false,
          'image': defaultImage,
          'badge': null,
        });
      }
    }

    notifyListeners();
  }

  /// Toggle Select All items
  void toggleSelectAll(bool? val) {
    final newValue = val ?? false;
    for (var shop in _cartShops) {
      shop['selected'] = newValue;
      for (var item in (shop['items'] as List)) {
        item['selected'] = newValue;
      }
    }
    notifyListeners();
  }

  /// Toggle Shop Selection
  void toggleShopSelect(Map<String, dynamic> shop, bool? val) {
    final newValue = val ?? false;
    shop['selected'] = newValue;
    for (var item in (shop['items'] as List)) {
      item['selected'] = newValue;
    }
    notifyListeners();
  }

  /// Toggle Item Selection
  void toggleItemSelect(
    Map<String, dynamic> shop,
    Map<String, dynamic> item,
    bool? val,
  ) {
    item['selected'] = val ?? false;
    shop['selected'] = (shop['items'] as List).every(
      (i) => i['selected'] == true,
    );
    notifyListeners();
  }

  /// Update item quantity
  void updateQuantity(
      Map<String, dynamic> shop, Map<String, dynamic> item, int delta) {
    final newQty = (item['quantity'] as int) + delta;
    if (newQty >= 1) {
      item['quantity'] = newQty;
    } else if (newQty == 0) {
      // Remove item if quantity becomes 0
      (shop['items'] as List).remove(item);
      if ((shop['items'] as List).isEmpty) {
        _cartShops.remove(shop);
      }
    }
    notifyListeners();
  }

  /// Get selected items formatted for CheckoutScreen
  List<Map<String, dynamic>> getSelectedCheckoutItems() {
    final List<Map<String, dynamic>> selectedItems = [];
    for (var shop in _cartShops) {
      for (var item in (shop['items'] as List)) {
        if (item['selected'] == true) {
          selectedItems.add({
            ...item,
            'shopName': shop['shopName'],
          });
        }
      }
    }
    return selectedItems;
  }
}