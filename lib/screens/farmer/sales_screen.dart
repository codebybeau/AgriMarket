
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const Color agriGreen = Color(0xFF2E7D32);
const Color agriDarkGreen = Color(0xFF1B5E20);
const Color agriBackground = Color(0xFFE8F0E6);
const Color agriCard = Color(0xFFF1F6EF);
const Color agriText = Color(0xFF1B3D2A);
const Color agriDescription = Color(0xFF526357);

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final supabase = Supabase.instance.client;

  bool _isLoading = true;
  String? _errorMessage;

  List<Map<String, dynamic>> _sales = [];

  double _totalSales = 0;
  int _completedOrders = 0;
  int _itemsSold = 0;

  @override
  void initState() {
    super.initState();
    _fetchSales();
  }

  // CONVERT DATA TO MAP LIST
  List<Map<String, dynamic>> _toMapList(dynamic value) {
    if (value == null) return [];

    if (value is Map) {
      return [Map<String, dynamic>.from(value)];
    }

    if (value is Iterable) {
      return value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    return [];
  }

  // FETCH FARMER SALES
  Future<void> _fetchSales() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('Please log in to view your sales.');
      }

      // GET PRODUCTS BELONGING TO CURRENT FARMER
      final productResponse = await supabase
          .from('products')
          .select('id, name, price')
          .eq('seller_id', user.id);

      final products = List<Map<String, dynamic>>.from(
        productResponse,
      );

      if (products.isEmpty) {
        if (!mounted) return;

        setState(() {
          _sales = [];
          _totalSales = 0;
          _completedOrders = 0;
          _itemsSold = 0;
          _isLoading = false;
        });
        return;
      }

      final productMap = {
        for (final product in products)
          product['id']: product,
      };

      final productIds = products
          .map((product) => product['id'])
          .toList();

      // GET ORDER ITEMS CONTAINING FARMER PRODUCTS
      final itemResponse = await supabase
          .from('order_items')
          .select(
            'id, order_id, product_id, quantity, unit_price, total_price',
          )
          .inFilter('product_id', productIds);

      final allItems = List<Map<String, dynamic>>.from(
        itemResponse,
      );

      if (allItems.isEmpty) {
        if (!mounted) return;

        setState(() {
          _sales = [];
          _totalSales = 0;
          _completedOrders = 0;
          _itemsSold = 0;
          _isLoading = false;
        });
        return;
      }

      final orderIds = allItems
          .map((item) => item['order_id'])
          .where((id) => id != null)
          .toSet()
          .toList();

      // GET ONLY COMPLETED ORDERS
      final orderResponse = await supabase
          .from('orders')
          .select(
            'id, order_reference, buyer_id, created_at, status, '
            'delivery_method, payment_method',
          )
          .inFilter('id', orderIds)
          .eq('status', 'completed')
          .order('created_at', ascending: false);

      final orders = List<Map<String, dynamic>>.from(
        orderResponse,
      );

      final completedOrderIds = orders
          .map((order) => order['id'])
          .toSet();

      // GET BUYER INFORMATION
      final buyerIds = orders
          .map((order) => order['buyer_id'])
          .where((id) => id != null)
          .toSet()
          .toList();

      Map<String, String> buyerNames = {};

      if (buyerIds.isNotEmpty) {
        final buyerResponse = await supabase
            .from('profiles')
            .select('id, full_name')
            .inFilter('id', buyerIds);

        for (final buyer in buyerResponse) {
          buyerNames[buyer['id'].toString()] =
              buyer['full_name']?.toString() ?? 'Customer';
        }
      }

      // CALCULATE FARMER SALES
      final sales = <Map<String, dynamic>>[];

      double totalSales = 0;
      int itemsSold = 0;

      for (final order in orders) {
        final orderItems = allItems.where(
          (item) =>
              item['order_id'] == order['id'] &&
              completedOrderIds.contains(item['order_id']),
        ).toList();

        final farmerItems = <Map<String, dynamic>>[];

        double orderTotal = 0;
        int orderQuantity = 0;

        for (final item in orderItems) {
          final product = productMap[item['product_id']];

          if (product == null) continue;

          final quantity =
              (item['quantity'] as num?)?.toInt() ?? 0;

          final itemTotal =
              (item['total_price'] as num?)?.toDouble() ?? 0;

          orderTotal += itemTotal;
          orderQuantity += quantity;

          farmerItems.add({
            ...item,
            'product_name': product['name'] ?? 'Product',
          });
        }

        if (farmerItems.isEmpty) continue;

        final buyerId = order['buyer_id']?.toString();

        sales.add({
          ...order,
          'buyer_name': buyerNames[buyerId] ?? 'Customer',
          'items': farmerItems,
          'farmer_total': orderTotal,
          'farmer_quantity': orderQuantity,
        });

        totalSales += orderTotal;
        itemsSold += orderQuantity;
      }

      if (!mounted) return;

      setState(() {
        _sales = sales;
        _totalSales = totalSales;
        _completedOrders = sales.length;
        _itemsSold = itemsSold;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching sales: $e');

      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // FORMAT PRICE
  String _formatPrice(double price) {
    return '₱${price.toStringAsFixed(2)}';
  }

  // FORMAT DATE
  String _formatDate(dynamic value) {
    if (value == null) return 'Date unavailable';

    final date = DateTime.tryParse(value.toString());

    if (date == null) return 'Date unavailable';

    final localDate = date.toLocal();

    return '${localDate.day.toString().padLeft(2, '0')}/'
        '${localDate.month.toString().padLeft(2, '0')}/'
        '${localDate.year}';
  }

  // STATISTICS CARD
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: agriCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: agriGreen.withValues(alpha: 0.10),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: agriGreen.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                icon,
                color: agriGreen,
                size: 20,
              ),
            ),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: agriDarkGreen,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 10,
                color: agriDescription,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // SALE CARD
  Widget _buildSaleCard(Map<String, dynamic> sale) {
    final items = _toMapList(sale['items']);

    return Card(
      color: agriCard,
      elevation: 1.5,
      shadowColor: agriDarkGreen.withValues(alpha: 0.10),
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: agriGreen.withValues(alpha: 0.10),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ORDER REFERENCE AND STATUS
            Row(
              children: [
                Expanded(
                  child: Text(
                    sale['order_reference']?.toString() ?? 'Order',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: agriText,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: agriGreen.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: agriGreen,
                        size: 12,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Completed',
                        style: TextStyle(
                          color: agriGreen,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // BUYER
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  color: agriGreen,
                  size: 17,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Buyer: ${sale['buyer_name']}',
                    style: const TextStyle(
                      color: agriDescription,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // DATE
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: agriGreen,
                  size: 15,
                ),
                const SizedBox(width: 7),
                Text(
                  'Date: ${_formatDate(sale['created_at'])}',
                  style: const TextStyle(
                    color: agriDescription,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const Divider(
              height: 24,
              color: Color(0xFFD5E3D3),
            ),

            // PRODUCTS SOLD
            const Text(
              'Products Sold',
              style: TextStyle(
                color: agriDarkGreen,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 12),

            ...items.map((item) {
              final quantity =
                  (item['quantity'] as num?)?.toInt() ?? 0;

              final total =
                  (item['total_price'] as num?)?.toDouble() ?? 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: agriGreen.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.inventory_2_outlined,
                        color: agriGreen,
                        size: 17,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        '${item['product_name']} × $quantity',
                        style: const TextStyle(
                          fontSize: 12,
                          color: agriText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      _formatPrice(total),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: agriText,
                      ),
                    ),
                  ],
                ),
              );
            }),

            const Divider(
              height: 20,
              color: Color(0xFFD5E3D3),
            ),

            // FARMER EARNINGS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Earnings',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: agriDarkGreen,
                    fontSize: 13,
                  ),
                ),
                Text(
                  _formatPrice(
                    (sale['farmer_total'] as num?)?.toDouble() ?? 0,
                  ),
                  style: const TextStyle(
                    color: agriGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // EMPTY STATE
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: agriCard,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 50,
            color: agriGreen.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 13),
          const Text(
            'No completed sales yet',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: agriDarkGreen,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your completed orders will appear here.',
            style: TextStyle(
              color: agriDescription,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ERROR STATE
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: 45,
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to load sales',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: agriText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: agriDescription,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _fetchSales,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: agriGreen,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MAIN CONTENT
  Widget _buildContent() {
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

    return RefreshIndicator(
      color: agriGreen,
      onRefresh: _fetchSales,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
        children: [
          const Text(
            'Sales Overview',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: agriDarkGreen,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Track your earnings and completed orders.',
            style: TextStyle(
              fontSize: 13,
              color: agriDescription,
            ),
          ),

          const SizedBox(height: 16),

          // SALES STATISTICS
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatCard(
                title: 'Total Sales',
                value: _formatPrice(_totalSales),
                icon: Icons.payments_outlined,
              ),
              const SizedBox(width: 8),
              _buildStatCard(
                title: 'Completed Orders',
                value: _completedOrders.toString(),
                icon: Icons.receipt_long_outlined,
              ),
              const SizedBox(width: 8),
              _buildStatCard(
                title: 'Items Sold',
                value: _itemsSold.toString(),
                icon: Icons.inventory_2_outlined,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // SALES HISTORY
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Sales History',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: agriDarkGreen,
                  ),
                ),
              ),
              Text(
                '${_sales.length} ${_sales.length == 1 ? 'Sale' : 'Sales'}',
                style: const TextStyle(
                  color: agriGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          if (_sales.isEmpty)
            _buildEmptyState()
          else
            ..._sales.map(_buildSaleCard),
        ],
      ),
    );
  }

  // MAIN SCREEN
  @override
  Widget build(BuildContext context) {
    return Container(
      color: agriBackground,
      child: Column(
        children: [
          // HEADER
          Container(
            width: double.infinity,
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
                  Icons.bar_chart_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'My Sales',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _fetchSales,
                  tooltip: 'Refresh sales',
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }
}
