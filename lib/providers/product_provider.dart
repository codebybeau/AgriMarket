import 'package:flutter/foundation.dart';

import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  final List<Product> _products = [
    Product(
      id: 'p1',
      name: 'Fresh Tomatoes',
      category: 'Vegetables',
      price: 80,
      unit: 'kg',
      farmer: "Juan's Farm",
      location: 'Magpet, Cotabato',
      description: 'Fresh locally grown tomatoes.',
      emoji: '🍅',
      stock: 20,
    ),
    Product(
      id: 'p2',
      name: 'Carabao Mangoes',
      category: 'Fruits',
      price: 120,
      unit: 'kg',
      farmer: 'Green Valley Farm',
      location: 'Kabacan, Cotabato',
      description: 'Sweet ripe mangoes from a local farm.',
      emoji: '🥭',
      stock: 15,
    ),
    Product(
      id: 'p3',
      name: 'Free-range Eggs',
      category: 'Eggs & Dairy',
      price: 12,
      unit: 'piece',
      farmer: 'Sunrise Farm',
      location: 'Matalam, Cotabato',
      description: 'Fresh free-range eggs.',
      emoji: '🥚',
      stock: 60,
    ),
    Product(
      id: 'p4',
      name: 'Premium Rice',
      category: 'Rice & Grains',
      price: 55,
      unit: 'kg',
      farmer: "Farmer's Choice",
      location: 'Kidapawan, Cotabato',
      description: 'Locally harvested quality rice.',
      emoji: '🌾',
      stock: 50,
    ),
    Product(
      id: 'p5',
      name: 'Fresh Lettuce',
      category: 'Vegetables',
      price: 95,
      unit: 'kg',
      farmer: 'Highland Greens',
      location: 'Makilala, Cotabato',
      description: 'Crisp fresh lettuce.',
      emoji: '🥬',
      stock: 18,
    ),
    Product(
      id: 'p6',
      name: 'Root Crops',
      category: 'Root Crops',
      price: 70,
      unit: 'kg',
      farmer: 'Mountain Harvest',
      location: 'Magpet, Cotabato',
      description: 'Fresh locally harvested root crops.',
      emoji: '🥔',
      stock: 25,
    ),
  ];

  List<Product> get products => List.unmodifiable(_products);

  List<Product> search(String query, {String? category}) {
    final q = query.trim().toLowerCase();

    return _products.where((product) {
      final matchesQuery =
          q.isEmpty ||
          product.name.toLowerCase().contains(q) ||
          product.category.toLowerCase().contains(q) ||
          product.farmer.toLowerCase().contains(q);

      final matchesCategory =
          category == null || category == 'All' || product.category == category;

      return matchesQuery && matchesCategory;
    }).toList();
  }

  Product? byId(String id) {
    for (final product in _products) {
      if (product.id == id) {
        return product;
      }
    }

    return null;
  }

  void addProduct(Product product) {
    _products.insert(0, product);
    notifyListeners();
  }

  void updateProduct(Product updated) {
    final index = _products.indexWhere((product) => product.id == updated.id);

    if (index == -1) return;

    _products[index] = updated;
    notifyListeners();
  }

  void deleteProduct(String id) {
    _products.removeWhere((product) => product.id == id);
    notifyListeners();
  }
}
