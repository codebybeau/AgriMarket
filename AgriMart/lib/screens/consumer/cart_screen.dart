import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/notification_provider.dart';
import 'home_screen.dart';
import 'notification_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static const Color primaryGreen = Color(0xFF176B3A);
  static const Color darkGreen = Color(0xFF105B31);
  static const Color pageBackground = Color(0xFFF7F9F7);
  static const Color ink = Color(0xFF17211B);
  static const Color mutedText = Color(0xFF6D776F);

  // AGRIMART THEMED MOCK CART DATA
  final List<Map<String, dynamic>> _cartShops = [
    {
      'shopName': 'Dela Cruz Family Farm',
      'isMall': true, // Used for verified farm badge
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
    {
      'shopName': 'Laguna Poultry & Meats',
      'isMall': false,
      'isPreferred': true,
      'selected': false,
      'items': [
        {
          'id': 'p4',
          'name': 'Native Chicken (Whole)',
          'variant': '1 piece (~1.2kg)',
          'price': 350.00,
          'quantity': 1,
          'selected': false,
          'image':
              'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=600',
          'badge': null,
        },
      ],
    },
  ];

  bool _useCoins = false;

  void _goToPage(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
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

  // Calculate overall total price of selected items
  double get _totalPrice {
    double total = 0.0;
    for (var shop in _cartShops) {
      for (var item in shop['items']) {
        if (item['selected'] == true) {
          total += (item['price'] as double) * (item['quantity'] as int);
        }
      }
    }
    return total;
  }

  // Calculate total count of selected items
  int get _selectedItemCount {
    int count = 0;
    for (var shop in _cartShops) {
      for (var item in shop['items']) {
        if (item['selected'] == true) {
          count += item['quantity'] as int;
        }
      }
    }
    return count;
  }

  // Check if all items across all shops are selected
  bool get _isAllSelected {
    if (_cartShops.isEmpty) return false;
    for (var shop in _cartShops) {
      for (var item in shop['items']) {
        if (item['selected'] == false) return false;
      }
    }
    return true;
  }

  // Select/Deselect All
  void _toggleSelectAll(bool? val) {
    final newValue = val ?? false;
    setState(() {
      for (var shop in _cartShops) {
        shop['selected'] = newValue;
        for (var item in shop['items']) {
          item['selected'] = newValue;
        }
      }
    });
  }

  // Select/Deselect Shop
  void _toggleShopSelect(Map<String, dynamic> shop, bool? val) {
    final newValue = val ?? false;
    setState(() {
      shop['selected'] = newValue;
      for (var item in shop['items']) {
        item['selected'] = newValue;
      }
    });
  }

  // Toggle Individual Item Selection
  void _toggleItemSelect(
      Map<String, dynamic> shop, Map<String, dynamic> item, bool? val) {
    setState(() {
      item['selected'] = val ?? false;
      shop['selected'] =
          (shop['items'] as List).every((i) => i['selected'] == true);
    });
  }

  // Change Quantity
  void _updateQuantity(Map<String, dynamic> item, int delta) {
    setState(() {
      final newQty = (item['quantity'] as int) + delta;
      if (newQty >= 1) {
        item['quantity'] = newQty;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: darkGreen,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: pageBackground,
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              // ==============================================
              // GREEN TOP HEADER
              // ==============================================
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  8,
                  MediaQuery.of(context).padding.top + 12,
                  16,
                  16,
                ),
                decoration: const BoxDecoration(
                  color: darkGreen,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => _goToPage(context, const HomeScreen()),
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 22),
                    ),
                    const Expanded(
                      child: Text(
                        'Shopping Cart',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showMessage('Edit mode toggled'),
                      child: const Text(
                        'Edit',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                    Consumer<NotificationProvider>(
                      builder: (context, notificationProvider, child) {
                        final count = notificationProvider.unreadCount;
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () => _goToPage(
                                    context, const NotificationScreen()),
                                icon: const Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                            if (count > 0)
                              Positioned(
                                right: -2,
                                top: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  constraints: const BoxConstraints(
                                      minWidth: 15, minHeight: 15),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFF3D4F),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      count > 99 ? '99+' : count.toString(),
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
              ),

              // ==============================================
              // CART SHOP CARDS LIST
              // ==============================================
              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  itemCount: _cartShops.length,
                  itemBuilder: (context, index) {
                    return _buildShopCard(_cartShops[index]);
                  },
                ),
              ),

              // ==============================================
              // VOUCHERS & REWARDS BAR
              // ==============================================
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    // Platform Vouchers Row
                    InkWell(
                      onTap: () => _showMessage('Voucher selection opened'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.confirmation_number_outlined,
                                color: primaryGreen, size: 18),
                            const SizedBox(width: 8),
                            const Text(
                              'Platform Vouchers',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: ink),
                            ),
                            const Spacer(),
                            Text(
                              'Select or enter code',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade600),
                            ),
                            const Icon(Icons.chevron_right,
                                size: 18, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),

                    // AgriCoins Toggle Row
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFB300),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.monetization_on,
                                color: Colors.white, size: 14),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _selectedItemCount == 0
                                ? 'No item selected'
                                : 'AgriCoins Cashback Available',
                            style: TextStyle(
                              fontSize: 12,
                              color: _selectedItemCount == 0
                                  ? Colors.grey
                                  : ink,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.help_outline,
                              size: 13, color: Colors.grey.shade500),
                          const Spacer(),
                          Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              value: _useCoins && _selectedItemCount > 0,
                              activeColor: primaryGreen,
                              onChanged: _selectedItemCount == 0
                                  ? null
                                  : (v) => setState(() => _useCoins = v),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ==============================================
              // BOTTOM CHECKOUT BAR
              // ==============================================
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: SafeArea( // Added SafeArea here so it doesn't overlap with iOS home indicators
                  top: false,
                  child: Row(
                    children: [
                      // Select All Checkbox
                      Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _isAllSelected,
                              activeColor: primaryGreen,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                              onChanged: _toggleSelectAll,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'All',
                            style: TextStyle(fontSize: 13, color: ink),
                          ),
                        ],
                      ),
                      const Spacer(),

                      // Total Amount Text
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Total ',
                                style: TextStyle(fontSize: 12, color: ink),
                              ),
                              Text(
                                '₱${_totalPrice.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),

                      // Checkout Button
                      SizedBox(
                        height: 42,
                        child: ElevatedButton(
                          onPressed: _selectedItemCount == 0
                              ? null
                              : () => _showMessage('Proceeding to Checkout!'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            disabledBackgroundColor: Colors.grey.shade300,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                          ),
                          child: Text(
                            'Check Out (${_selectedItemCount})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================================
  // SHOP CARD WIDGET
  // ==============================================

  Widget _buildShopCard(Map<String, dynamic> shop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8ECE8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // SHOP HEADER ROW
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 12, 6),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: shop['selected'],
                    activeColor: primaryGreen,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                    onChanged: (val) => _toggleShopSelect(shop, val),
                  ),
                ),
                const SizedBox(width: 8),

                // Mall / Preferred Badge
                if (shop['isMall'] == true)
                  Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: primaryGreen,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Verified Farm',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                if (shop['isPreferred'] == true)
                  Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: darkGreen,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Co-op Partner',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold),
                    ),
                  ),

                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          shop['shopName'],
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: ink,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right,
                          size: 16, color: Colors.grey),
                    ],
                  ),
                ),

                TextButton(
                  onPressed: () => _showMessage('Editing shop items'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Edit',
                    style: TextStyle(fontSize: 12, color: mutedText),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),

          // ITEM CARDS IN THIS SHOP
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: (shop['items'] as List).length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: Color(0xFFF5F5F5)),
            itemBuilder: (context, itemIdx) {
              final item = shop['items'][itemIdx];
              return _buildItemRow(shop, item);
            },
          ),

          const Divider(height: 1, color: Color(0xFFF0F0F0)),

          // SHOP VOUCHER ROW
          InkWell(
            onTap: () => _showMessage('Add shop voucher code'),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.confirmation_number_outlined,
                      color: primaryGreen, size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    'Add shop voucher code',
                    style: TextStyle(fontSize: 12, color: mutedText),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right,
                      size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================
  // INDIVIDUAL ITEM ROW
  // ==============================================

  Widget _buildItemRow(Map<String, dynamic> shop, Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item Checkbox
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: item['selected'],
              activeColor: primaryGreen,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              onChanged: (val) => _toggleItemSelect(shop, item, val),
            ),
          ),
          const SizedBox(width: 8),

          // Item Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item['image'],
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 72,
                height: 72,
                color: const Color(0xFFE8F0E7),
                child: const Icon(Icons.eco, color: primaryGreen),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Item Details & Controls
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600, color: ink),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Variant selector dropdown
                if (item['variant'] != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F5F3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item['variant'],
                          style: const TextStyle(
                              fontSize: 10, color: mutedText),
                        ),
                        const Icon(Icons.arrow_drop_down,
                            size: 14, color: mutedText),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),

                // Price & Quantity Control Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₱${(item['price'] as double).toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: primaryGreen,
                      ),
                    ),

                    // Quantity Stepper (- 1 +)
                    Container(
                      height: 26,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => _updateQuantity(item, -1),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text('-',
                                  style: TextStyle(
                                      fontSize: 13, color: mutedText)),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            color: const Color(0xFFF9F9F9),
                            alignment: Alignment.center,
                            child: Text(
                              '${item['quantity']}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: ink),
                            ),
                          ),
                          InkWell(
                            onTap: () => _updateQuantity(item, 1),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text('+',
                                  style: TextStyle(
                                      fontSize: 13, color: mutedText)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}