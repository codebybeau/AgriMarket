import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../providers/cart_provider.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

class MyPurchaseScreen extends StatefulWidget {
  final String initialTab;

  const MyPurchaseScreen({super.key, this.initialTab = 'Pending'});

  @override
  State<MyPurchaseScreen> createState() => _MyPurchaseScreenState();
}

class _MyPurchaseScreenState extends State<MyPurchaseScreen> {
  static const Color darkGreen = Color(0xFF105B31);
  static const Color primaryGreen = Color(0xFF176B3A);
  static const Color pageBackground = Color(0xFFF7F9F7);
  static const Color ink = Color(0xFF17211B);
  static const Color mutedText = Color(0xFF6D776F);

  final SupabaseClient _supabase = Supabase.instance.client;

  late String _selectedTab;

  final List<String> _tabs = [
    'Pending',
    'To Ship',
    'To Receive',
    'Completed',
    'Cancelled',
    'Return/Refund',
  ];

  List<Map<String, dynamic>> _allOrders = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _selectedTab = _tabs.contains(widget.initialTab)
        ? widget.initialTab
        : 'Pending';

    _loadOrders();
  }

  // ---------------------------------------------------------
  // SAFE CONVERSION HELPERS
  // ---------------------------------------------------------

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  // ---------------------------------------------------------
  // LOAD ORDERS FROM SUPABASE
  // ---------------------------------------------------------

  Future<void> _loadOrders() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        throw Exception('Please sign in to view your purchases.');
      }

      // Your orders table uses buyer_id, NOT user_id.
      final orderResponse = await _supabase
          .from('orders')
          .select(
            'id, order_reference, buyer_id, delivery_method, '
            'delivery_fee, payment_method, subtotal, total_amount, '
            'status, created_at',
          )
          .eq('buyer_id', user.id)
          .order('created_at', ascending: false);

      final orders = List<Map<String, dynamic>>.from(
        orderResponse.map((row) => Map<String, dynamic>.from(row)),
      );

      if (orders.isEmpty) {
        if (!mounted) return;

        setState(() {
          _allOrders = [];
          _isLoading = false;
        });
        return;
      }

      // Get order IDs. Your orders.id is int8.
      final orderIds = orders
          .map((order) => _toInt(order['id']))
          .whereType<int>()
          .toList();

      if (orderIds.isEmpty) {
        if (!mounted) return;

        setState(() {
          _allOrders = [];
          _isLoading = false;
        });
        return;
      }

      // Load items belonging to these orders.
      final itemResponse = await _supabase
          .from('order_items')
          .select('id, order_id, product_id, quantity, unit_price, total_price')
          .inFilter('order_id', orderIds);

      final orderItems = List<Map<String, dynamic>>.from(
        itemResponse.map((row) => Map<String, dynamic>.from(row)),
      );

      // Collect valid product IDs only.
      final productIds = orderItems
          .map((item) => _toInt(item['product_id']))
          .whereType<int>()
          .toSet()
          .toList();

      final productById = <int, Map<String, dynamic>>{};
      final imageByProductId = <int, String>{};
      final farmerById = <String, Map<String, dynamic>>{};

      // Load product details.
      if (productIds.isNotEmpty) {
        final productResponse = await _supabase
            .from('products')
            .select('id, name, seller_id')
            .inFilter('id', productIds);

        for (final row in productResponse) {
          final product = Map<String, dynamic>.from(row);
          final productId = _toInt(product['id']);

          if (productId != null) {
            productById[productId] = product;
          }
        }

        // Load product images.
        final imageResponse = await _supabase
            .from('product_images')
            .select('product_id, image_url, display_order')
            .inFilter('product_id', productIds)
            .order('display_order', ascending: true);

        for (final row in imageResponse) {
          final productId = _toInt(row['product_id']);
          final imageUrl = row['image_url']?.toString();

          if (productId != null && imageUrl != null && imageUrl.isNotEmpty) {
            imageByProductId.putIfAbsent(productId, () => imageUrl);
          }
        }

        // Collect seller IDs.
        final sellerIds = productById.values
            .map((product) => product['seller_id']?.toString())
            .whereType<String>()
            .where((id) => id.isNotEmpty)
            .toSet()
            .toList();

        // Load farmer/shop names.
        if (sellerIds.isNotEmpty) {
          final farmerResponse = await _supabase
              .from('farmer_profiles')
              .select('user_id, full_name, farm_name')
              .inFilter('user_id', sellerIds);

          for (final row in farmerResponse) {
            final farmer = Map<String, dynamic>.from(row);
            final sellerId = farmer['user_id']?.toString();

            if (sellerId != null) {
              farmerById[sellerId] = farmer;
            }
          }
        }
      }

      // Build the orders used by the existing UI.
      final loadedOrders = <Map<String, dynamic>>[];

      for (final order in orders) {
        final orderId = _toInt(order['id']);

        if (orderId == null) continue;

        final matchingItems = orderItems.where((item) {
          return _toInt(item['order_id']) == orderId;
        }).toList();

        final firstItem = matchingItems.isNotEmpty
            ? matchingItems.first
            : <String, dynamic>{};

        String productName = 'Product';
        String imageUrl = '';
        String shopName = 'Farmer';

        final productId = _toInt(firstItem['product_id']);

        if (productId != null) {
          final product = productById[productId];

          if (product != null) {
            productName = product['name']?.toString() ?? 'Product';

            imageUrl = imageByProductId[productId] ?? '';

            final sellerId = product['seller_id']?.toString();
            final farmer = sellerId == null ? null : farmerById[sellerId];

            if (farmer != null) {
              final farmName = farmer['farm_name']?.toString();
              final fullName = farmer['full_name']?.toString();

              if (farmName != null && farmName.trim().isNotEmpty) {
                shopName = farmName;
              } else if (fullName != null && fullName.trim().isNotEmpty) {
                shopName = fullName;
              }
            }
          }
        }

        final status = _normalizeStatus(
          order['status']?.toString() ?? 'Pending',
        );

        final createdAt = DateTime.tryParse(
          order['created_at']?.toString() ?? '',
        );

        final formattedDate = createdAt == null
            ? 'Date unavailable'
            : '${createdAt.day.toString().padLeft(2, '0')}/'
                  '${createdAt.month.toString().padLeft(2, '0')}/'
                  '${createdAt.year}';

        loadedOrders.add({
          'id': orderId,
          'databaseId': orderId,
          'orderId': order['order_reference']?.toString() ?? 'Order #$orderId',
          'date': formattedDate,
          'status': status,
          'statusLabel': status,
          'statusBgColor': _statusBackground(status),
          'statusColor': _statusColor(status),
          'statusIcon': _statusIcon(status),
          'imageUrl': imageUrl,
          'productName': matchingItems.length > 1
              ? '$productName and ${matchingItems.length - 1} more item(s)'
              : productName,
          'shopName': shopName,
          'price': _toDouble(order['total_amount']),
          'itemCount': matchingItems.length,
        });
      }

      if (!mounted) return;

      setState(() {
        _allOrders = loadedOrders;
        _isLoading = false;
      });
    } catch (error) {
      debugPrint('Load purchases error: $error');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  // ---------------------------------------------------------
  // STATUS HELPERS
  // ---------------------------------------------------------

  String _normalizeStatus(String status) {
    final value = status.trim().toLowerCase();

    switch (value) {
      case 'pending':
      case 'to pay':
        return 'Pending';

      case 'to ship':
      case 'toship':
        return 'To Ship';

      case 'to receive':
      case 'to_receive':
      case 'toreceive':
        return 'To Receive';

      case 'completed':
      case 'complete':
        return 'Completed';

      case 'cancelled':
      case 'canceled':
        return 'Cancelled';

      case 'return/refund':
      case 'return':
      case 'refund':
        return 'Return/Refund';

      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending':
        return const Color(0xFFD97706);
      case 'To Ship':
        return const Color(0xFF2563EB);
      case 'To Receive':
        return const Color(0xFF7C3AED);
      case 'Completed':
        return const Color(0xFF15803D);
      case 'Cancelled':
        return const Color(0xFFDC2626);
      default:
        return mutedText;
    }
  }

  Color _statusBackground(String status) {
    switch (status) {
      case 'Pending':
        return const Color(0xFFFFF7ED);
      case 'To Ship':
        return const Color(0xFFEFF6FF);
      case 'To Receive':
        return const Color(0xFFF5F3FF);
      case 'Completed':
        return const Color(0xFFF0FDF4);
      case 'Cancelled':
        return const Color(0xFFFEF2F2);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Pending':
        return Icons.schedule_rounded;
      case 'To Ship':
        return Icons.inventory_2_outlined;
      case 'To Receive':
        return Icons.local_shipping_outlined;
      case 'Completed':
        return Icons.check_circle_outline;
      case 'Cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  // ---------------------------------------------------------
  // CANCEL ORDER
  // ---------------------------------------------------------

  Future<void> _cancelOrder(Map<String, dynamic> order) async {
    final orderId = _toInt(order['databaseId'] ?? order['id']);

    if (orderId == null) {
      _showMessage('Order ID is missing.');
      return;
    }

    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Order?'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep Order'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel Order'),
          ),
        ],
      ),
    );

    if (shouldCancel != true || !mounted) return;

    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        _showMessage('Please sign in again.');
        return;
      }

      // First, retrieve the actual order from Supabase.
      final existingOrder = await _supabase
          .from('orders')
          .select('id, buyer_id, status')
          .eq('id', orderId)
          .eq('buyer_id', user.id)
          .maybeSingle();

      if (existingOrder == null) {
        _showMessage(
          'Order not found. Check your buyer_id and Supabase access policies.',
        );
        return;
      }

      final actualStatus = existingOrder['status']?.toString() ?? '';

      debugPrint('Order ID: $orderId');
      debugPrint('Database status: $actualStatus');

      // Only allow cancellation while the order is Pending.
      if (_normalizeStatus(actualStatus) != 'Pending') {
        _showMessage(
          'This order cannot be cancelled because its status is $actualStatus.',
        );
        return;
      }

      // Update the order.
      final response = await _supabase
          .from('orders')
          .update({'status': 'Cancelled'})
          .eq('id', orderId)
          .eq('buyer_id', user.id)
          .eq('status', 'Pending')
          .select('id, status');

      if (!mounted) return;

      if (response.isEmpty) {
        _showMessage('Update blocked. Check your Supabase UPDATE RLS policy.');
        return;
      }

      debugPrint('Cancellation result: $response');

      _showMessage('Order cancelled successfully!');

      await _loadOrders();
    } catch (error) {
      debugPrint('Cancel order error: $error');

      if (!mounted) return;

      _showMessage('Cancellation failed: $error');
    }
  }

  // ---------------------------------------------------------
  // SNACKBAR
  // ---------------------------------------------------------

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: darkGreen,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  // ---------------------------------------------------------
  // BACK NAVIGATION
  // ---------------------------------------------------------

  void _handleBackNavigation() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, _, _) => const ProfileScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }

  // ---------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _allOrders.where((order) {
      return order['status'] == _selectedTab;
    }).toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: darkGreen,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: pageBackground,
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                color: primaryGreen,
                onRefresh: _loadOrders,
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: primaryGreen),
                      )
                    : _errorMessage != null
                    ? _buildErrorState()
                    : filteredOrders.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          return _buildOrderCard(filteredOrders[index]);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // HEADER AND TABS
  // ---------------------------------------------------------

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        8,
        MediaQuery.of(context).padding.top + 8,
        16,
        16,
      ),
      decoration: const BoxDecoration(
        color: darkGreen,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: _handleBackNavigation,
                icon: const Icon(
                  Icons.chevron_left_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const Expanded(
                child: Text(
                  'My Purchases',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Consumer<CartProvider>(
                builder: (context, cartProvider, _) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Material(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CartScreen(),
                              ),
                            );
                          },
                          child: const SizedBox(
                            width: 38,
                            height: 38,
                            child: Icon(
                              Icons.shopping_cart_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      if (cartProvider.totalCartCount > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF3D4F),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                cartProvider.totalCartCount > 99
                                    ? '99+'
                                    : '${cartProvider.totalCartCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _tabs.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final tab = _tabs[index];
                final isSelected = _selectedTab == tab;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTab = tab;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        tab,
                        style: TextStyle(
                          color: isSelected ? darkGreen : Colors.white,
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // ORDER CARD
  // ---------------------------------------------------------

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final canCancel = order['status'] == 'Pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECE8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['orderId']?.toString() ?? 'Order',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order['date']?.toString() ?? '',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF8A958E),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: order['statusBgColor'] as Color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        order['statusIcon'] as IconData,
                        size: 13,
                        color: order['statusColor'] as Color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        order['statusLabel']?.toString() ?? '',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: order['statusColor'] as Color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child:
                      order['imageUrl'] != null &&
                          order['imageUrl'].toString().isNotEmpty
                      ? Image.network(
                          order['imageUrl'].toString(),
                          width: 58,
                          height: 58,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _buildProductPlaceholder(),
                        )
                      : _buildProductPlaceholder(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['productName']?.toString() ?? 'Product',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4A5568),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        order['shopName']?.toString() ?? 'Farmer',
                        style: const TextStyle(fontSize: 11, color: mutedText),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFA0AEC0),
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFFE8ECE8), height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order['itemCount']} item(s)',
                  style: const TextStyle(fontSize: 11, color: mutedText),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Order Total',
                      style: TextStyle(fontSize: 10, color: mutedText),
                    ),
                    Text(
                      '₱${_toDouble(order['price']).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // CANCEL ORDER BUTTON
            if (canCancel) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: OutlinedButton.icon(
                  onPressed: () => _cancelOrder(order),
                  icon: const Icon(Icons.cancel_outlined, size: 17),
                  label: const Text(
                    'Cancel Order',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductPlaceholder() {
    return Container(
      width: 58,
      height: 58,
      color: const Color(0xFFE8F0E7),
      child: const Icon(Icons.eco, color: primaryGreen, size: 28),
    );
  }

  // ---------------------------------------------------------
  // EMPTY STATE
  // ---------------------------------------------------------

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.55,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      size: 48,
                      color: primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No $_selectedTab Purchases',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'You have no purchases under $_selectedTab '
                    'at the moment.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: mutedText),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------
  // ERROR STATE
  // ---------------------------------------------------------

  Widget _buildErrorState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.55,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  const Text(
                    'Unable to Load Purchases',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage ?? 'An unexpected error occurred.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, color: mutedText),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadOrders,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkGreen,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
