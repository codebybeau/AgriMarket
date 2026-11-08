import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartProvider extends ChangeNotifier {
  CartProvider({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client {
    unawaited(loadCart());
  }

  final SupabaseClient _client;

  final List<Map<String, dynamic>> _cartShops = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get cartShops => _cartShops;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  // ---------------------------------------------------------
  // LOAD CART FROM SUPABASE
  // ---------------------------------------------------------

  Future<void> loadCart() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      _cartShops.clear();
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cartResponse = await _client
          .from('cart_items')
          .select('id, user_id, product_id, quantity, created_at')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final cartRows = List<Map<String, dynamic>>.from(
        cartResponse.map((row) => Map<String, dynamic>.from(row)),
      );

      if (cartRows.isEmpty) {
        _cartShops.clear();
        _isLoading = false;
        notifyListeners();
        return;
      }

      final productIds = cartRows
          .map((row) => row['product_id'])
          .where((id) => id != null)
          .toSet()
          .toList();

      final productResponse = await _client
          .from('products')
          .select(
            'id, seller_id, name, price, stock_quantity, unit_id, '
            'category_id, description, delivery_details, is_organic, status',
          )
          .inFilter('id', productIds)
          .eq('status', 'active');

      final products = List<Map<String, dynamic>>.from(
        productResponse.map((row) => Map<String, dynamic>.from(row)),
      );

      final productById = <int, Map<String, dynamic>>{};

      for (final product in products) {
        final id = _toInt(product['id']);

        if (id != null) {
          productById[id] = product;
        }
      }

      final activeProductIds = productById.keys.toList();

      if (activeProductIds.isEmpty) {
        _cartShops.clear();
        _isLoading = false;
        notifyListeners();
        return;
      }

      final imageResponse = await _client
          .from('product_images')
          .select('product_id, image_url, display_order')
          .inFilter('product_id', activeProductIds)
          .order('display_order', ascending: true);

      final imageByProductId = <int, String>{};

      for (final image in imageResponse) {
        final id = _toInt(image['product_id']);
        final url = image['image_url']?.toString();

        if (id != null && url != null && url.isNotEmpty) {
          imageByProductId.putIfAbsent(id, () => url);
        }
      }

      final unitIds = products
          .map((product) => product['unit_id'])
          .where((id) => id != null)
          .toSet()
          .toList();

      final unitNameById = <dynamic, String>{};

      if (unitIds.isNotEmpty) {
        final unitResponse = await _client
            .from('units')
            .select('id, name')
            .inFilter('id', unitIds);

        for (final unit in unitResponse) {
          unitNameById[unit['id']] = unit['name']?.toString() ?? 'unit';
        }
      }

      final sellerIds = products
          .map((product) => product['seller_id'])
          .where((id) => id != null)
          .toSet()
          .toList();

      final farmerById = <String, Map<String, dynamic>>{};

      if (sellerIds.isNotEmpty) {
        final farmerResponse = await _client
            .from('farmer_profiles')
            .select('user_id, full_name, farm_name, farm_origin, avatar_url')
            .inFilter('user_id', sellerIds);

        for (final farmer in farmerResponse) {
          final id = farmer['user_id']?.toString();

          if (id != null) {
            farmerById[id] = Map<String, dynamic>.from(farmer);
          }
        }
      }

      _cartShops.clear();

      final shopBySellerId = <String, Map<String, dynamic>>{};

      for (final row in cartRows) {
        final productId = _toInt(row['product_id']);
        final cartItemId = _toInt(row['id']);

        if (productId == null || cartItemId == null) continue;

        final product = productById[productId];

        // Do not display inactive or deleted products in the cart.
        if (product == null) continue;

        final sellerId = product['seller_id']?.toString();

        if (sellerId == null) continue;

        final farmer = farmerById[sellerId] ?? {};

        final farmName =
            farmer['farm_name']?.toString().trim().isNotEmpty == true
            ? farmer['farm_name'].toString()
            : farmer['full_name']?.toString() ?? 'Farmer';

        final shop = shopBySellerId.putIfAbsent(sellerId, () {
          final newShop = <String, dynamic>{
            'shopName': farmName,
            'sellerId': sellerId,
            'isMall': false,
            'isPreferred': false,
            'selected': false,
            'items': <Map<String, dynamic>>[],
          };

          _cartShops.add(newShop);
          return newShop;
        });

        final unitId = product['unit_id'];
        final stock = _toInt(product['stock_quantity']) ?? 0;

        final item = <String, dynamic>{
          // Actual database identifiers.
          'id': cartItemId.toString(),
          'cartItemId': cartItemId,
          'productId': productId,
          'sellerId': sellerId,

          // Actual product information.
          'name': product['name']?.toString() ?? 'Product',
          'price': _toDouble(product['price']),
          'quantity': _toInt(row['quantity']) ?? 1,
          'stock_quantity': stock,
          'variant': unitNameById[unitId] ?? 'unit',
          'image': imageByProductId[productId] ?? '',
          'badge': product['is_organic'] == true ? 'Organic' : null,
          'selected': false,

          // Additional information.
          'description': product['description'],
          'delivery_details': product['delivery_details'],
          'farmName': farmName,
          'farmOrigin': farmer['farm_origin'],
          'farmerAvatar': farmer['avatar_url'],
        };

        (shop['items'] as List<Map<String, dynamic>>).add(item);
      }

      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  // ---------------------------------------------------------
  // ADD PRODUCT TO CART
  // ---------------------------------------------------------

  Future<bool> addToCart({
    required String name,
    required double price,
    int? productId,
    String? sellerId,
    String? variant,
    String? image,
    String? shopName,
    bool isMall = false,
    bool isPreferred = false,
  }) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      return false;
    }

    // A real product ID and seller ID are required.
    if (productId == null || sellerId == null) {
      debugPrint(
        'Cannot add demo product. A real productId and sellerId are required.',
      );
      return false;
    }

    try {
      // Recheck the product directly in Supabase.
      final productResponse = await _client
          .from('products')
          .select('id, seller_id, name, price, stock_quantity, status')
          .eq('id', productId)
          .eq('seller_id', sellerId)
          .maybeSingle();

      if (productResponse == null ||
          productResponse['status']?.toString().toLowerCase() != 'active') {
        return false;
      }

      final stock = _toInt(productResponse['stock_quantity']) ?? 0;

      if (stock <= 0) {
        return false;
      }

      // Check whether this consumer already has this product.
      final existingResponse = await _client
          .from('cart_items')
          .select('id, quantity')
          .eq('user_id', user.id)
          .eq('product_id', productId)
          .maybeSingle();

      if (existingResponse != null) {
        final cartItemId = _toInt(existingResponse['id']);
        final currentQuantity = _toInt(existingResponse['quantity']) ?? 0;
        final newQuantity = currentQuantity + 1;

        if (newQuantity > stock) {
          return false;
        }

        if (cartItemId == null) return false;

        await _client
            .from('cart_items')
            .update({'quantity': newQuantity})
            .eq('id', cartItemId)
            .eq('user_id', user.id);
      } else {
        await _client.from('cart_items').insert({
          'user_id': user.id,
          'product_id': productId,
          'quantity': 1,
        });
      }

      await loadCart();
      return true;
    } catch (error) {
      debugPrint('Add to cart error: $error');
      return false;
    }
  }

  // ---------------------------------------------------------
  // CART TOTALS
  // ---------------------------------------------------------

  int get totalCartCount {
    int total = 0;

    for (final shop in _cartShops) {
      for (final item in (shop['items'] as List)) {
        total += _toInt(item['quantity']) ?? 0;
      }
    }

    return total;
  }

  double get totalPrice {
    double total = 0;

    for (final shop in _cartShops) {
      for (final item in (shop['items'] as List)) {
        if (item['selected'] == true) {
          total += _toDouble(item['price']) * (_toInt(item['quantity']) ?? 0);
        }
      }
    }

    return total;
  }

  int get selectedCount {
    int count = 0;

    for (final shop in _cartShops) {
      for (final item in (shop['items'] as List)) {
        if (item['selected'] == true) {
          count += _toInt(item['quantity']) ?? 0;
        }
      }
    }

    return count;
  }

  bool get isAllSelected {
    if (_cartShops.isEmpty) return false;

    for (final shop in _cartShops) {
      for (final item in (shop['items'] as List)) {
        if (item['selected'] != true) return false;
      }
    }

    return true;
  }

  // ---------------------------------------------------------
  // SELECTION METHODS
  // ---------------------------------------------------------

  void toggleSelectAll(bool? val) {
    final newValue = val ?? false;

    for (final shop in _cartShops) {
      shop['selected'] = newValue;

      for (final item in (shop['items'] as List)) {
        item['selected'] = newValue;
      }
    }

    notifyListeners();
  }

  void toggleShopSelect(Map<String, dynamic> shop, bool? val) {
    final newValue = val ?? false;

    shop['selected'] = newValue;

    for (final item in (shop['items'] as List)) {
      item['selected'] = newValue;
    }

    notifyListeners();
  }

  void toggleItemSelect(
    Map<String, dynamic> shop,
    Map<String, dynamic> item,
    bool? val,
  ) {
    item['selected'] = val ?? false;

    shop['selected'] = (shop['items'] as List).every(
      (item) => item['selected'] == true,
    );

    notifyListeners();
  }

  // ---------------------------------------------------------
  // UPDATE QUANTITY
  // ---------------------------------------------------------

  Future<bool> updateQuantity(
    Map<String, dynamic> shop,
    Map<String, dynamic> item,
    int delta,
  ) async {
    final itemIndex = (shop['items'] as List).indexOf(item);

    if (itemIndex == -1) return false;

    final currentQuantity = _toInt(item['quantity']) ?? 1;
    final newQuantity = currentQuantity + delta;

    if (newQuantity < 1) {
      return removeItem(shop, item);
    }

    final stock = _toInt(item['stock_quantity']) ?? 0;

    if (newQuantity > stock) {
      return false;
    }

    final cartItemId = _toInt(item['cartItemId']);
    final user = _client.auth.currentUser;

    if (cartItemId == null || user == null) return false;

    try {
      await _client
          .from('cart_items')
          .update({'quantity': newQuantity})
          .eq('id', cartItemId)
          .eq('user_id', user.id);

      item['quantity'] = newQuantity;

      shop['selected'] = (shop['items'] as List).every(
        (cartItem) => cartItem['selected'] == true,
      );

      notifyListeners();
      return true;
    } catch (error) {
      debugPrint('Update cart quantity error: $error');
      return false;
    }
  }

  // ---------------------------------------------------------
  // REMOVE ITEM
  // ---------------------------------------------------------

  Future<bool> removeItem(
    Map<String, dynamic> shop,
    Map<String, dynamic> item,
  ) async {
    final cartItemId = _toInt(item['cartItemId']);
    final user = _client.auth.currentUser;

    if (cartItemId == null || user == null) return false;

    try {
      await _client
          .from('cart_items')
          .delete()
          .eq('id', cartItemId)
          .eq('user_id', user.id);

      (shop['items'] as List).remove(item);

      if ((shop['items'] as List).isEmpty) {
        _cartShops.remove(shop);
      } else {
        shop['selected'] = (shop['items'] as List).every(
          (cartItem) => cartItem['selected'] == true,
        );
      }

      notifyListeners();
      return true;
    } catch (error) {
      debugPrint('Remove cart item error: $error');
      return false;
    }
  }

  // ---------------------------------------------------------
  // CHECKOUT ITEMS
  // ---------------------------------------------------------

  List<Map<String, dynamic>> getSelectedCheckoutItems() {
    final selectedItems = <Map<String, dynamic>>[];

    for (final shop in _cartShops) {
      for (final item in (shop['items'] as List)) {
        if (item['selected'] == true) {
          selectedItems.add({
            ...Map<String, dynamic>.from(item),
            'shopName': shop['shopName'],
            'sellerId': shop['sellerId'],
          });
        }
      }
    }

    return selectedItems;
  }

  // ---------------------------------------------------------
  // HELPER METHODS
  // ---------------------------------------------------------

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
