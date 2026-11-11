
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'order_details_screen.dart' as details;

const Color agriGreen = Color(0xFF2E7D32);
const Color agriDarkGreen = Color(0xFF1B5E20);
const Color agriBackground = Color(0xFFE8F0E6);
const Color agriCard = Color(0xFFF1F6EF);
const Color agriText = Color(0xFF1B3D2A);
const Color agriDescription = Color(0xFF526357);

class FarmerOrdersScreen extends StatefulWidget {
  const FarmerOrdersScreen({super.key});

  @override
  State<FarmerOrdersScreen> createState() => _FarmerOrdersScreenState();
}

class _FarmerOrdersScreenState extends State<FarmerOrdersScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  // LOAD FARMER ORDERS
  Future<void> _loadOrders() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        throw Exception('Please log in to view your orders.');
      }

      // GET FARMER PRODUCTS
      final productResponse = await _supabase
          .from('products')
          .select('id, name')
          .eq('seller_id', user.id);

      final products = List<Map<String, dynamic>>.from(
        productResponse,
      );

      if (products.isEmpty) {
        if (!mounted) return;

        setState(() {
          _orders = [];
          _isLoading = false;
        });
        return;
      }

      final productNames = <String, String>{};

      for (final product in products) {
        productNames[product['id'].toString()] =
            product['name']?.toString() ?? 'Unnamed Product';
      }

      final productIds = products.map((p) => p['id']).toList();

      // GET ORDER ITEMS
      final itemResponse = await _supabase
          .from('order_items')
          .select(
            'id, order_id, product_id, quantity, unit_price, total_price',
          )
          .inFilter('product_id', productIds);

      final items = List<Map<String, dynamic>>.from(itemResponse);

      if (items.isEmpty) {
        if (!mounted) return;

        setState(() {
          _orders = [];
          _isLoading = false;
        });
        return;
      }

      final orderIds = items
          .map((item) => item['order_id'])
          .where((id) => id != null)
          .toSet()
          .toList();

      if (orderIds.isEmpty) {
        if (!mounted) return;

        setState(() {
          _orders = [];
          _isLoading = false;
        });
        return;
      }

      // GET ORDERS
      final orderResponse = await _supabase
          .from('orders')
          .select(
            'id, order_reference, buyer_id, delivery_method, '
            'delivery_fee, payment_method, subtotal, total_amount, '
            'status, created_at',
          )
          .inFilter('id', orderIds)
          .order('created_at', ascending: false);

      final orderRecords = List<Map<String, dynamic>>.from(
        orderResponse,
      );

      // GET BUYER INFORMATION
      final buyerIds = orderRecords
          .map((order) => order['buyer_id'])
          .where((id) => id != null)
          .toSet()
          .toList();

      final buyerNames = <String, String>{};

      if (buyerIds.isNotEmpty) {
        final profileResponse = await _supabase
            .from('profiles')
            .select('id, full_name')
            .inFilter('id', buyerIds);

        for (final profile in profileResponse) {
          buyerNames[profile['id'].toString()] =
              profile['full_name']?.toString() ?? 'Customer';
        }
      }

      // PREPARE FARMER-SPECIFIC ORDER TOTALS
      final result = <Map<String, dynamic>>[];

      for (final order in orderRecords) {
        final orderItems = items
            .where(
              (item) =>
                  item['order_id'].toString() ==
                  order['id'].toString(),
            )
            .map((item) {
              return {
                ...item,
                'product_name':
                    productNames[item['product_id'].toString()] ??
                        'Product unavailable',
              };
            })
            .toList();

        if (orderItems.isEmpty) continue;

        final farmerTotal = orderItems.fold<double>(
          0,
          (sum, item) => sum + _toDouble(item['total_price']),
        );

        result.add({
          ...order,
          'buyer_name':
              buyerNames[order['buyer_id']?.toString()] ?? 'Customer',
          'items': orderItems,
          'farmer_total': farmerTotal,
        });
      }

      if (!mounted) return;

      setState(() {
        _orders = result;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  // FORMAT HELPERS
  double _toDouble(dynamic value) {
    if (value == null) return 0;
    return double.tryParse(value.toString()) ?? 0;
  }

  String _formatPrice(dynamic value) {
    return '₱${_toDouble(value).toStringAsFixed(2)}';
  }

  String _formatDate(dynamic value) {
    if (value == null) return 'Date unavailable';

    final date = DateTime.tryParse(value.toString());

    if (date == null) return 'Date unavailable';

    final localDate = date.toLocal();

    return '${localDate.day.toString().padLeft(2, '0')}/'
        '${localDate.month.toString().padLeft(2, '0')}/'
        '${localDate.year}';
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'delivered':
        return agriGreen;
      case 'pending':
        return Colors.orange.shade800;
      case 'cancelled':
        return Colors.red.shade700;
      case 'processing':
      case 'shipped':
        return Colors.blue.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  // HEADER
  Widget _buildHeader() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: agriDarkGreen,
        boxShadow: [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            color: Colors.white,
            size: 22,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'My Orders',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: _loadOrders,
            tooltip: 'Refresh orders',
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // EMPTY STATE
  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 110),
        Icon(
          Icons.receipt_long_outlined,
          size: 78,
          color: agriGreen.withValues(alpha: 0.5),
        ),
        const SizedBox(height: 18),
        const Center(
          child: Text(
            'No orders yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: agriDarkGreen,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 38),
          child: Text(
            'Orders containing your products will appear here when customers place an order.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: agriDescription,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  // ORDER CARD
  Widget _buildOrderCard(Map<String, dynamic> order) {
    final items = List<Map<String, dynamic>>.from(
      order['items'],
    );

    final status = order['status']?.toString() ?? 'pending';
    final statusColor = _statusColor(status);

    return Card(
      color: agriCard,
      elevation: 1.5,
      shadowColor: agriDarkGreen.withValues(alpha: 0.12),
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: agriGreen.withValues(alpha: 0.10),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(
          16,
          0,
          16,
          16,
        ),
        leading: CircleAvatar(
          backgroundColor: agriGreen.withValues(alpha: 0.12),
          child: const Icon(
            Icons.receipt_long_outlined,
            color: agriGreen,
          ),
        ),
        title: Text(
          order['order_reference']?.toString() ?? 'Order',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: agriText,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            '${order['buyer_name']} • ${_formatDate(order['created_at'])}',
            style: const TextStyle(
              fontSize: 12,
              color: agriDescription,
            ),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatPrice(order['farmer_total']),
              style: const TextStyle(
                color: agriDarkGreen,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 7,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                status.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        children: [
          const Divider(color: Color(0xFFD5E3D3)),

          // ORDER ITEMS
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 9),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: agriGreen.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      color: agriGreen,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['product_name'].toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: agriText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item['quantity']} × '
                          '${_formatPrice(item['unit_price'])}',
                          style: const TextStyle(
                            color: agriDescription,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatPrice(item['total_price']),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: agriText,
                    ),
                  ),
                ],
              ),
            );
          }),

          const Divider(color: Color(0xFFD5E3D3)),

          // ORDER INFORMATION
          _detailRow(
            'Delivery method',
            order['delivery_method']?.toString() ?? 'N/A',
          ),
          _detailRow(
            'Payment method',
            order['payment_method']?.toString() ?? 'N/A',
          ),

          const SizedBox(height: 5),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: agriGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: _detailRow(
              'Your items total',
              _formatPrice(order['farmer_total']),
              isTotal: true,
            ),
          ),

          const SizedBox(height: 14),

          // ORDER DETAILS BUTTON
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        details.OrderDetailsScreen(
                      order: order,
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.visibility_outlined,
                size: 18,
              ),
              label: const Text('View Order Details'),
              style: OutlinedButton.styleFrom(
                foregroundColor: agriGreen,
                side: const BorderSide(color: agriGreen),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ORDER DETAIL ROW
  Widget _detailRow(
    String label,
    String value, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isTotal ? agriDarkGreen : agriDescription,
                fontWeight:
                    isTotal ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            style: TextStyle(
              color: isTotal ? agriDarkGreen : agriText,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ERROR STATE
  Widget _buildErrorState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 100),
        const Icon(
          Icons.error_outline,
          size: 55,
          color: Colors.redAccent,
        ),
        const SizedBox(height: 14),
        const Center(
          child: Text(
            'Unable to load orders',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: agriText,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: agriDescription,
              fontSize: 13,
            ),
          ),
        ),
        Center(
          child: ElevatedButton.icon(
            onPressed: _loadOrders,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: agriGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // BODY
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: agriGreen,
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_orders.isEmpty) {
      return _buildEmptyState();
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      children: [
        // ORDER COUNT
        Row(
          children: [
            const Expanded(
              child: Text(
                'Order History',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: agriDarkGreen,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: agriCard,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_orders.length} ${_orders.length == 1 ? 'Order' : 'Orders'}',
                style: const TextStyle(
                  color: agriGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 5),

        const Text(
          'View customer orders containing your products.',
          style: TextStyle(
            fontSize: 13,
            color: agriDescription,
          ),
        ),

        const SizedBox(height: 16),

        ..._orders.map(_buildOrderCard),
      ],
    );
  }

  // MAIN SCREEN
  @override
  Widget build(BuildContext context) {
    return Container(
      color: agriBackground,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: RefreshIndicator(
              color: agriGreen,
              onRefresh: _loadOrders,
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }
}
