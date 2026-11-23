import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'my_purchase_screen.dart';

class OrderPlacedScreen extends StatelessWidget {
  final String orderReference;

  const OrderPlacedScreen({super.key, this.orderReference = 'ORD-2024-285'});

  static const Color darkGreen = Color(0xFF105B31);
  static const Color primaryGreen = Color(0xFF176B3A);
  static const Color pageBackground = Color(0xFFF7F9F7);
  static const Color mutedText = Color(0xFF6D776F);

  // ---------------------------------------------------------
  // TRACK MY ORDER
  // ---------------------------------------------------------

  void _trackMyOrder(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const MyPurchaseScreen(initialTab: 'Pending'),
      ),
      (route) => route.isFirst,
    );
  }

  // ---------------------------------------------------------
  // CONTINUE SHOPPING
  // ---------------------------------------------------------

  void _continueShopping(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  // ---------------------------------------------------------
  // TIMELINE STEP
  // ---------------------------------------------------------

  Widget _buildTimelineStep({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isCompleted,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFFE8F5E9)
                    : const Color(0xFFF1F3F1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 19,
                color: isCompleted ? primaryGreen : mutedText,
              ),
            ),
            if (!isLast)
              Container(width: 2, height: 42, color: const Color(0xFFDCE5DC)),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? const Color(0xFF26352B) : mutedText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: mutedText),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: darkGreen,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: pageBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
            child: Column(
              children: [
                const SizedBox(height: 28),

                // SUCCESS ICON
                Container(
                  width: 104,
                  height: 104,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    size: 76,
                    color: primaryGreen,
                  ),
                ),

                const SizedBox(height: 24),

                // SUCCESS MESSAGE
                const Text(
                  'Order Placed Successfully!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: darkGreen,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Thank you for shopping with AgriMarket. '
                  'Your order has been received.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, height: 1.5, color: mutedText),
                ),

                const SizedBox(height: 28),

                // ORDER REFERENCE
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE5EBE5)),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'ORDER REFERENCE',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1,
                          fontWeight: FontWeight.bold,
                          color: mutedText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        orderReference,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: darkGreen,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Keep this reference for your records.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: mutedText),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ORDER TIMELINE
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE5EBE5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order Status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: darkGreen,
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildTimelineStep(
                        title: 'Order Placed',
                        subtitle: 'Your order has been received.',
                        icon: Icons.receipt_long_outlined,
                        isCompleted: true,
                        isLast: false,
                      ),

                      _buildTimelineStep(
                        title: 'Processing',
                        subtitle: 'The seller will prepare your order.',
                        icon: Icons.inventory_2_outlined,
                        isCompleted: false,
                        isLast: false,
                      ),

                      _buildTimelineStep(
                        title: 'On the Way',
                        subtitle: 'Your order will be delivered.',
                        icon: Icons.local_shipping_outlined,
                        isCompleted: false,
                        isLast: false,
                      ),

                      _buildTimelineStep(
                        title: 'Delivered',
                        subtitle: 'Your order will be marked as delivered.',
                        icon: Icons.check_circle_outline,
                        isCompleted: false,
                        isLast: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ESTIMATED DELIVERY
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.local_shipping_outlined,
                        color: primaryGreen,
                        size: 26,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estimated Delivery',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: darkGreen,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Check My Purchases for order updates.',
                              style: TextStyle(fontSize: 11, color: mutedText),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // TRACK MY ORDER BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => _trackMyOrder(context),
                    icon: const Icon(Icons.local_shipping_outlined, size: 19),
                    label: const Text(
                      'Track My Order',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // CONTINUE SHOPPING BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () => _continueShopping(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: darkGreen,
                      side: const BorderSide(color: darkGreen),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Continue Shopping',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
