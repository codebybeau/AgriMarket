import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'delivery_add_screen.dart'; // Isama ang import na ito

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> checkoutItems;

  const CheckoutScreen({
    super.key,
    required this.checkoutItems,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const Color primaryGreen = Color(0xFF176B3A);
  static const Color darkGreen = Color(0xFF105B31);
  static const Color pageBackground = Color(0xFFF7F9F7);
  static const Color ink = Color(0xFF17211B);
  static const Color mutedText = Color(0xFF6D776F);

  late List<Map<String, dynamic>> _items;
  final double _deliveryFee = 80.00;
  final double _freeDeliveryThreshold = 1000.00;

  @override
  void initState() {
    super.initState();
    _items = widget.checkoutItems
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  int get _totalItemsCount {
    int count = 0;
    for (var item in _items) {
      count += (item['quantity'] as int);
    }
    return count;
  }

  double get _subtotal {
    double total = 0.0;
    for (var item in _items) {
      total += (item['price'] as double) * (item['quantity'] as int);
    }
    return total;
  }

  double get _currentDeliveryFee {
    return _subtotal >= _freeDeliveryThreshold ? 0.0 : _deliveryFee;
  }

  double get _totalAmount => _subtotal + _currentDeliveryFee;

  void _updateQuantity(int index, int delta) {
    setState(() {
      final newQty = (_items[index]['quantity'] as int) + delta;
      if (newQty >= 1) {
        _items[index]['quantity'] = newQty;
      }
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _placeOrder() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Order placed successfully! Redirecting to Delivery details...'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: darkGreen,
          duration: Duration(seconds: 2),
        ),
      );

    // INAYOS: Lilipat na ito papuntang DeliveryAddScreen kapag klinick ang Place Order
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DeliveryAddScreen(
          checkoutItems: _items,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double remainingForFreeDelivery =
        _freeDeliveryThreshold - _subtotal;

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
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const Text(
                      'Order Summary',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$_totalItemsCount ${_totalItemsCount == 1 ? "item" : "items"}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF5ED),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: primaryGreen.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.local_shipping_outlined,
                              color: primaryGreen,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: ink,
                                  ),
                                  children: remainingForFreeDelivery > 0
                                      ? [
                                          const TextSpan(text: 'Add '),
                                          TextSpan(
                                            text:
                                                '₱${remainingForFreeDelivery.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: primaryGreen,
                                            ),
                                          ),
                                          const TextSpan(
                                            text: ' more for ',
                                          ),
                                          const TextSpan(
                                            text: 'FREE delivery!',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: primaryGreen,
                                            ),
                                          ),
                                        ]
                                      : [
                                          const TextSpan(
                                            text:
                                                ' You have unlocked FREE delivery!',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: primaryGreen,
                                            ),
                                          ),
                                        ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (_items.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            children: const [
                              Icon(
                                Icons.shopping_basket_outlined,
                                size: 48,
                                color: mutedText,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'No items selected for checkout',
                                style: TextStyle(color: mutedText),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFE8ECE8),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      item['image'],
                                      width: 68,
                                      height: 68,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Container(
                                        width: 68,
                                        height: 68,
                                        color: const Color(0xFFE8F0E7),
                                        child: const Icon(
                                          Icons.eco,
                                          color: primaryGreen,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['name'],
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: ink,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        if (item['shopName'] != null)
                                          Text(
                                            item['shopName'],
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: mutedText,
                                            ),
                                          ),
                                        if (item['variant'] != null)
                                          Text(
                                            'per ${item['variant']}',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Color(0xFF88928B),
                                            ),
                                          ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Text(
                                              '₱${(item['price'] as double).toStringAsFixed(0)}',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: primaryGreen,
                                              ),
                                            ),
                                            const Spacer(),
                                            IconButton(
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                              icon: const Icon(
                                                Icons.delete_outline_rounded,
                                                color: Colors.redAccent,
                                                size: 18,
                                              ),
                                              onPressed: () =>
                                                  _removeItem(index),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              height: 26,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: const Color(0xFFE0E0E0),
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Row(
                                                children: [
                                                  InkWell(
                                                    onTap: () => _updateQuantity(
                                                        index, -1),
                                                    child: const Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 8),
                                                      child: Text(
                                                        '-',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color: mutedText,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                    ),
                                                    color: const Color(0xFFF9F9F9),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      '${item['quantity']}',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: ink,
                                                      ),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () => _updateQuantity(
                                                        index, 1),
                                                    child: const Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 8),
                                                      child: Text(
                                                        '+',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color: primaryGreen,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
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
                          },
                        ),
                    ],
                  ),
                ),
              ),

              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Order Summary',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: ink,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Subtotal ($_totalItemsCount ${_totalItemsCount == 1 ? "item" : "items"})',
                            style: const TextStyle(
                              fontSize: 13,
                              color: mutedText,
                            ),
                          ),
                          Text(
                            '₱${_subtotal.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: ink,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Delivery Fee',
                            style: TextStyle(fontSize: 13, color: mutedText),
                          ),
                          Text(
                            _currentDeliveryFee == 0
                                ? 'FREE'
                                : '₱${_currentDeliveryFee.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _currentDeliveryFee == 0
                                  ? primaryGreen
                                  : ink,
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(color: Color(0xFFEEEEEE)),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: ink,
                            ),
                          ),
                          Text(
                            '₱${_totalAmount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: primaryGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _items.isEmpty ? null : _placeOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            disabledBackgroundColor: Colors.grey.shade300,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Place Order',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
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
}