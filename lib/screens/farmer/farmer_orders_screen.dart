import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'farmer_theme.dart';

typedef JsonMap = Map<String, dynamic>;
typedef JsonList = List<JsonMap>;

class FarmerOrdersScreen extends StatefulWidget {
  const FarmerOrdersScreen({super.key});

  @override
  State<FarmerOrdersScreen> createState() => _FarmerOrdersScreenState();
}

class _FarmerOrdersScreenState extends State<FarmerOrdersScreen> {
  JsonList _orders = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'Pending',
    'Confirmed',
    'Completed',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  String _capitalizeStatus(String raw) {
    final lower = raw.trim().toLowerCase();
    if (lower == 'delivered' || lower == 'completed') return 'Completed';
    if (lower == 'to_ship' || lower == 'confirmed') return 'Confirmed';
    if (lower == 'cancelled') return 'Cancelled';
    return 'Pending';
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);

    final sellerId = Supabase.instance.client.auth.currentUser?.id ?? '';
    if (sellerId.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Lines 53–79: Remove nested 'profiles ( full_name )' inside orders!inner
      // Lines 53–75: Removed 'unit' from products!inner
      final response = await Supabase.instance.client
          .from('order_items')
          .select('''
            id,
            order_id,
            quantity,
            unit_price,
            total_price,
            products!inner (
              name,
              seller_id
            ),
            orders!inner (
              id,
              order_reference,
              status,
              buyer_id
            )
          ''')
          .eq('products.seller_id', sellerId)
          .order('id', ascending: false);

      final rawItems = JsonList.from(response);
      final Map<dynamic, JsonMap> groupedMap = {};

      for (final item in rawItems) {
        final order = item['orders'] as JsonMap? ?? {};
        final product = item['products'] as JsonMap? ?? {};
        final profile = order['profiles'] as JsonMap? ?? {};

        final dynamic dbOrderId = item['order_id'];
        final String productName =
            product['name']?.toString() ?? 'Unnamed Product';
        final String unit = product['unit']?.toString() ?? 'kg';
        final int qty = (item['quantity'] is num)
            ? (item['quantity'] as num).toInt()
            : (int.tryParse(item['quantity']?.toString() ?? '1') ?? 1);

        final double itemTotal = (item['total_price'] is num)
            ? (item['total_price'] as num).toDouble()
            : (double.tryParse(item['total_price']?.toString() ?? '0') ?? 0.0);

        if (!groupedMap.containsKey(dbOrderId)) {
          groupedMap[dbOrderId] = {
            'db_order_id': dbOrderId,
            'id': order['order_reference']?.toString() ?? 'ORD-$dbOrderId',
            'status': _capitalizeStatus(order['status']?.toString() ?? ''),
            'customer': profile['full_name']?.toString() ?? 'Customer',
            'products_list': <String>[],
            'quantities_list': <String>[],
            'raw_total': 0.0,
          };
        }

        (groupedMap[dbOrderId]!['products_list'] as List<String>)
            .add(productName);
        (groupedMap[dbOrderId]!['quantities_list'] as List<String>)
            .add('$qty $unit');
        groupedMap[dbOrderId]!['raw_total'] =
            (groupedMap[dbOrderId]!['raw_total'] as double) + itemTotal;
      }

      final JsonList formattedOrders = groupedMap.values.map((entry) {
        final double total = entry['raw_total'] as double;
        return <String, dynamic>{
          'db_order_id': entry['db_order_id'],
          'id': entry['id'],
          'status': entry['status'],
          'customer': entry['customer'],
          'product': (entry['products_list'] as List<String>).join(', '),
          'quantity': (entry['quantities_list'] as List<String>).join(', '),
          'total': total.toStringAsFixed(2),
        };
      }).toList();

      if (!mounted) return;
      setState(() {
        _orders = formattedOrders;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading orders: $e')),
      );
    }
  }

  Future<void> _updateOrderStatus(dynamic dbOrderId, String newDbStatus) async {
    try {
      await Supabase.instance.client
          .from('orders')
          .update({'status': newDbStatus})
          .eq('id', dbOrderId);

      await _fetchOrders();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order marked as ${_capitalizeStatus(newDbStatus)}'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update order: $e')),
      );
    }
  }

  JsonList get _filteredOrders {
    if (_selectedFilter == 'All') {
      return _orders;
    }
    return _orders
        .where((order) => order['status'] == _selectedFilter)
        .toList();
  }

  int _countOrders(String status) {
    if (status == 'All') {
      return _orders.length;
    }
    return _orders.where((order) => order['status'] == status).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummary(),
            _buildFilters(),
            Expanded(child: _buildOrdersContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              title: 'Total Orders',
              count: _countOrders('All'),
              icon: Icons.receipt_long_outlined,
              color: agriGreen,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildSummaryCard(
              title: 'Pending',
              count: _countOrders('Pending'),
              icon: Icons.access_time,
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildSummaryCard(
              title: 'Completed',
              count: _countOrders('Completed'),
              icon: Icons.check_circle_outline,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9F6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 12),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.map((filter) {
            final bool selected = _selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text('$filter (${_countOrders(filter)})'),
                selected: selected,
                onSelected: (_) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
                selectedColor: agriGreen,
                backgroundColor: Colors.white,
                showCheckmark: false,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : Colors.black87,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(
                  color: selected ? agriGreen : Colors.grey.shade300,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildOrdersContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: agriGreen),
      );
    }

    if (_orders.isEmpty) {
      return RefreshIndicator(
        color: agriGreen,
        onRefresh: _fetchOrders,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: 360,
            child: _buildEmptyState(),
          ),
        ),
      );
    }

    final orders = _filteredOrders;
    if (orders.isEmpty) {
      return _buildNoFilteredOrdersState();
    }

    return RefreshIndicator(
      color: agriGreen,
      onRefresh: _fetchOrders,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildOrderCard(orders[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                color: agriGreen.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 54,
                color: agriGreen,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Orders Yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'You currently have 0 orders. Orders will appear here when customers place orders for your products.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoFilteredOrdersState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_list_off, size: 52, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No Orders Found',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'There are no ${_selectedFilter.toLowerCase()} orders.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(JsonMap order) {
    final String status = order['status']?.toString() ?? 'Pending';
    final Color statusColor = _getStatusColor(status);
    final dynamic dbOrderId = order['db_order_id'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order['id']?.toString() ?? 'Order',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _detailRow('Customer', order['customer']?.toString() ?? '-'),
          _detailRow('Product', order['product']?.toString() ?? '-'),
          _detailRow('Quantity', order['quantity']?.toString() ?? '-'),
          _detailRow('Total', '₱${order['total'] ?? '0.00'}'),
          if (status == 'Pending' || status == 'Confirmed') ...[
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (status == 'Pending') ...[
                  TextButton(
                    onPressed: () => _updateOrderStatus(dbOrderId, 'cancelled'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _updateOrderStatus(dbOrderId, 'confirmed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: agriGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Confirm Order'),
                  ),
                ] else if (status == 'Confirmed')
                  ElevatedButton(
                    onPressed: () => _updateOrderStatus(dbOrderId, 'completed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Mark as Completed'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Confirmed':
        return Colors.blue;
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}