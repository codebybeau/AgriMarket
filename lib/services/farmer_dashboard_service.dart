import 'package:supabase_flutter/supabase_flutter.dart';

/// Loads farmer-specific products, orders, and sales from the existing schema.
/// Queries are intentionally separated so this does not depend on Postgres
/// relationship names being configured for nested Supabase selects.
class FarmerDataService {
  FarmerDataService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  String get _sellerId {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw Exception('You must be logged in as a farmer.');
    return id;
  }

  String _normalStatus(dynamic value) {
    final status = (value ?? 'Pending').toString().trim().toLowerCase();
    if (status.isEmpty) return 'Pending';
    return status[0].toUpperCase() + status.substring(1);
  }

  double _number(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  /// Returns products owned by the currently authenticated farmer.
  Future<List<Map<String, dynamic>>> fetchSellerProducts() async {
    final rows = await _client
        .from('products')
        .select(
          'id, seller_id, name, price, stock_quantity, unit_id, category_id, description, delivery_details, is_organic, status, created_at',
        )
        .eq('seller_id', _sellerId)
        .order('created_at', ascending: false);

    final products = List<Map<String, dynamic>>.from(rows);
    if (products.isEmpty) return products;

    final ids = products.map((p) => p['id'] as int).toList();
    final imageRows = await _client
        .from('product_images')
        .select('product_id, image_url, display_order')
        .inFilter('product_id', ids)
        .order('display_order');

    final imageByProduct = <int, String>{};
    for (final image in imageRows) {
      final productId = image['product_id'] as int;
      final url = image['image_url']?.toString() ?? '';
      if (url.isNotEmpty) imageByProduct.putIfAbsent(productId, () => url);
    }

    final unitIds = products
        .map((p) => p['unit_id'])
        .whereType<int>()
        .toSet()
        .toList();
    final unitNames = <int, String>{};
    if (unitIds.isNotEmpty) {
      final units = await _client
          .from('units')
          .select('id, name')
          .inFilter('id', unitIds);
      for (final unit in units) {
        unitNames[unit['id'] as int] = unit['name']?.toString() ?? 'unit';
      }
    }

    return products.map((product) {
      final id = product['id'] as int;
      final unitId = product['unit_id'] as int?;
      return {
        ...product,
        'image_url': imageByProduct[id] ?? '',
        'unit_name': unitNames[unitId] ?? 'unit',
      };
    }).toList();
  }

  /// Returns one row per order that contains at least one product belonging
  /// to this farmer. For multi-seller carts, only this farmer's item totals
  /// and products are included in the order card and sales calculation.
  Future<List<Map<String, dynamic>>> fetchSellerOrders() async {
    final products = await _client
        .from('products')
        .select('id, name, seller_id')
        .eq('seller_id', _sellerId);

    if (products.isEmpty) return [];

    final productById = <int, Map<String, dynamic>>{};
    for (final product in products) {
      productById[product['id'] as int] = Map<String, dynamic>.from(product);
    }

    final productIds = productById.keys.toList();
    final itemRows = await _client
        .from('order_items')
        .select('id, order_id, product_id, quantity, unit_price, total_price')
        .inFilter('product_id', productIds);

    if (itemRows.isEmpty) return [];

    final itemsByOrder = <int, List<Map<String, dynamic>>>{};
    final orderIds = <int>{};
    for (final raw in itemRows) {
      final item = Map<String, dynamic>.from(raw);
      final orderId = item['order_id'] as int;
      final productId = item['product_id'] as int;
      item['product_name'] = productById[productId]?['name'] ?? 'Product';
      item['line_total'] = _number(item['total_price']);
      itemsByOrder.putIfAbsent(orderId, () => []).add(item);
      orderIds.add(orderId);
    }

    if (orderIds.isEmpty) return [];

    final orderRows = await _client
        .from('orders')
        .select(
          'id, order_reference, buyer_id, status, created_at, delivery_method, payment_method, delivery_fee, subtotal, total_amount',
        )
        .inFilter('id', orderIds.toList())
        .order('created_at', ascending: false);

    final buyerIds = orderRows
        .map((row) => row['buyer_id']?.toString())
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();
    final buyerNames = <String, String>{};
    if (buyerIds.isNotEmpty) {
      final profiles = await _client
          .from('profiles')
          .select('id, full_name, phone')
          .inFilter('id', buyerIds);
      for (final profile in profiles) {
        final id = profile['id']?.toString();
        if (id != null) {
          buyerNames[id] =
              profile['full_name']?.toString().trim().isNotEmpty == true
              ? profile['full_name'].toString()
              : 'Customer';
        }
      }
    }

    final result = <Map<String, dynamic>>[];
    for (final rawOrder in orderRows) {
      final order = Map<String, dynamic>.from(rawOrder);
      final orderId = order['id'] as int;
      final orderItems = itemsByOrder[orderId] ?? [];
      if (orderItems.isEmpty) continue;

      final sellerTotal = orderItems.fold<double>(
        0,
        (sum, item) => sum + _number(item['total_price']),
      );
      final quantity = orderItems.fold<int>(
        0,
        (sum, item) => sum + ((item['quantity'] as num?)?.toInt() ?? 0),
      );
      final productNames = orderItems
          .map((item) => item['product_name'].toString())
          .toSet()
          .join(', ');
      final buyerId = order['buyer_id']?.toString() ?? '';

      result.add({
        ...order,
        'display_id': order['order_reference']?.toString().isNotEmpty == true
            ? order['order_reference'].toString()
            : 'Order #$orderId',
        'status': _normalStatus(order['status']),
        'customer': buyerNames[buyerId] ?? 'Customer',
        'product': productNames,
        'quantity': quantity,
        'total': sellerTotal,
        'items': orderItems,
      });
    }

    return result;
  }

  Future<Map<String, dynamic>> fetchDashboardSummary() async {
    final productRows = await _client
        .from('products')
        .select('id')
        .eq('seller_id', _sellerId)
        .neq('status', 'deleted');
    final orders = await fetchSellerOrders();

    final pending = orders.where((o) => o['status'] == 'Pending').length;
    final completedOrders = orders
        .where((o) => o['status'] == 'Completed')
        .toList();
    final completedSales = completedOrders.fold<double>(
      0,
      (sum, order) => sum + _number(order['total']),
    );

    return {
      'product_count': productRows.length,
      'pending_orders': pending,
      'completed_orders': completedOrders.length,
      'sales': completedSales,
    };
  }

  Future<Map<String, dynamic>> fetchSalesSummary() async {
    final orders = await fetchSellerOrders();
    final completed = orders.where((o) => o['status'] == 'Completed').toList();
    final pending = orders.where((o) => o['status'] == 'Pending').length;
    final total = completed.fold<double>(
      0,
      (sum, order) => sum + _number(order['total']),
    );
    return {
      'total_sales': total,
      'completed_orders': completed.length,
      'pending_orders': pending,
      'estimated_earnings': total,
      'completed_order_list': completed,
    };
  }
}
