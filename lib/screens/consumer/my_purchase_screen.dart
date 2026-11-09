import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

class MyPurchaseScreen extends StatefulWidget {
  final String initialTab;

  const MyPurchaseScreen({
    super.key,
    this.initialTab = 'Pending',
  });

  @override
  State<MyPurchaseScreen> createState() => _MyPurchaseScreenState();
}

class _MyPurchaseScreenState extends State<MyPurchaseScreen> {
  static const Color darkGreen = Color(0xFF105B31);
  static const Color primaryGreen = Color(0xFF176B3A);
  static const Color pageBackground = Color(0xFFF7F9F7);
  static const Color ink = Color(0xFF17211B);
  static const Color mutedText = Color(0xFF6D776F);

  late String _selectedTab;

  // Tabs ordered with Return/Refund to the right of Cancelled
  final List<String> _tabs = [
    'Pending',
    'To Ship',
    'To Receive',
    'Completed',
    'Cancelled',
    'Return/Refund',
  ];

  // Sample order dataset for all purchase tabs
  final List<Map<String, dynamic>> _allOrders = [
    {
      'orderId': 'ORD-2024-003',
      'date': '2024-11-22',
      'status': 'Pending',
      'statusLabel': 'Pending',
      'statusColor': const Color(0xFFD97706),
      'statusBgColor': const Color(0xFFFEF3C7),
      'statusIcon': Icons.hourglass_empty_rounded,
      'productName': 'Hybrid Tomato Seeds (F1)',
      'shopName': 'AgriSeeds PH',
      'price': 340.00,
      'imageUrl':
          'https://images.unsplash.com/photo-1592841200221-a6898f307baa?w=300',
    },
    {
      'orderId': 'ORD-2024-002',
      'date': '2024-11-20',
      'status': 'To Ship',
      'statusLabel': 'To Ship',
      'statusColor': const Color(0xFF0284C7),
      'statusBgColor': const Color(0xFFE0F2FE),
      'statusIcon': Icons.inventory_2_outlined,
      'productName': 'Organic Fertilizer (5kg)',
      'shopName': 'GreenThumb Farm Supplies',
      'price': 450.00,
      'imageUrl':
          'https://images.unsplash.com/photo-1628352081506-83c43123ed6d?w=300',
    },
    {
      'orderId': 'ORD-2024-001',
      'date': '2024-11-18',
      'status': 'To Receive',
      'statusLabel': 'In Transit',
      'statusColor': const Color(0xFF7C3AED),
      'statusBgColor': const Color(0xFFF3E8FF),
      'statusIcon': Icons.local_shipping_outlined,
      'productName': 'Fresh Carabao Mangoes (1kg)',
      'shopName': 'Guimaras Harvest Co.',
      'price': 180.00,
      'imageUrl':
          'https://images.unsplash.com/photo-1553279768-865429fa0078?w=300',
    },
    {
      'orderId': 'ORD-2024-000',
      'date': '2024-11-15',
      'status': 'Completed',
      'statusLabel': 'Delivered',
      'statusColor': const Color(0xFF16A34A),
      'statusBgColor': const Color(0xFFDCFCE7),
      'statusIcon': Icons.check_circle_outline_rounded,
      'productName': 'Organic Ampalaya (1kg)',
      'shopName': 'Dela Cruz Family Farm',
      'price': 170.00,
      'imageUrl':
          'https://images.unsplash.com/photo-1595856715694-814d34f0d619?w=300',
    },
    {
      'orderId': 'ORD-2024-004',
      'date': '2024-11-10',
      'status': 'Cancelled',
      'statusLabel': 'Cancelled',
      'statusColor': const Color(0xFFDC2626),
      'statusBgColor': const Color(0xFFFEE2E2),
      'statusIcon': Icons.cancel_outlined,
      'productName': 'Drip Irrigation Kit',
      'shopName': 'AgriTech Tools',
      'price': 1250.00,
      'imageUrl':
          'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=300',
    },
    {
      'orderId': 'ORD-2024-005',
      'date': '2024-11-08',
      'status': 'Return/Refund',
      'statusLabel': 'Refund Requested',
      'statusColor': const Color(0xFFEA580C),
      'statusBgColor': const Color(0xFFFFEDD5),
      'statusIcon': Icons.assignment_return_outlined,
      'productName': 'Native Chicken (Whole)',
      'shopName': 'Laguna Poultry & Meats',
      'price': 350.00,
      'imageUrl':
          'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=300',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  void _showMessage(String message) {
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

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _allOrders
        .where((order) => order['status'] == _selectedTab)
        .toList();

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
              child: filteredOrders.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        return _buildOrderCard(filteredOrders[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HEADER WITH BACK BUTTON & SCROLLABLE TABS ---
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
              // Back Button
              IconButton(
                onPressed: _handleBackNavigation,
                icon: const Icon(
                  Icons.chevron_left_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),

              // Title
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

              // Cart Action
              Consumer<CartProvider>(
                builder: (context, cartProvider, _) => Stack(
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
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Horizontal Scrollable Tabs: Pending -> To Ship -> To Receive -> Completed -> Cancelled -> Return/Refund
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
                  onTap: () => setState(() => _selectedTab = tab),
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
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
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

  // --- ORDER ITEM CARD ---
  Widget _buildOrderCard(Map<String, dynamic> order) {
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showMessage('Viewing details for ${order['orderId']}'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order['orderId'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order['date'],
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF8A958E),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: order['statusBgColor'],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            order['statusIcon'],
                            size: 13,
                            color: order['statusColor'],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            order['statusLabel'],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: order['statusColor'],
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
                      child: Image.network(
                        order['imageUrl'],
                        width: 58,
                        height: 58,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 58,
                          height: 58,
                          color: const Color(0xFFE8F0E7),
                          child: const Icon(
                            Icons.eco,
                            color: primaryGreen,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${order['productName']} · ${order['shopName']}',
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
                            '₱${(order['price'] as num).toInt()}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: darkGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFFA0AEC0),
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- EMPTY TAB STATE ---
  Widget _buildEmptyState() {
    return Center(
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
            'You have no purchases under $_selectedTab at the moment.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: mutedText,
            ),
          ),
        ],
      ),
    );
  }
}