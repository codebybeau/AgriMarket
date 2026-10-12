import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/notification_provider.dart';
import 'orders_screen.dart';

const Color _agriGreen = Color(0xFF176B3A);

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  String selectedMethod = 'Cash on Delivery';

  final List<_PaymentOption> options = const [
    _PaymentOption(
      'Cash on Delivery',
      'Pay when your order arrives',
      Icons.payments_outlined,
    ),
    _PaymentOption(
      'GCash',
      'Prototype selection only; no real payment is processed',
      Icons.account_balance_wallet_outlined,
    ),
    _PaymentOption(
      'Bank Transfer',
      'Prototype selection only; no real payment is processed',
      Icons.account_balance_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F5),
      appBar: AppBar(
        backgroundColor: _agriGreen,
        foregroundColor: Colors.white,
        title: const Text('Payment Methods'),
      ),
      body: cart.items.isEmpty
          ? const Center(
              child: Text('Your cart is empty. Please select a product first.'),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text(
                        'Choose how you want to pay',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Select one payment method for this order.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ...options.map((option) {
                        final isSelected = selectedMethod == option.title;

                        return Card(
                          color: Colors.white,
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: isSelected
                                  ? _agriGreen
                                  : const Color(0xFFE0E5E0),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              setState(() {
                                selectedMethod = option.title;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Icon(
                                    option.icon,
                                    color: _agriGreen,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          option.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(option.description),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    isSelected
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked,
                                    color: isSelected
                                        ? _agriGreen
                                        : Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Items',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text('${cart.itemCount}'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total to pay',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '₱${cart.total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _agriGreen,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Demo only: GCash and Bank Transfer do not process '
                        'real payments.',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: cart.items.isEmpty
                            ? null
                            : () {
                                final items = cart.items
                                    .map(
                                      (item) => LocalOrderItem(
                                        product: item.product,
                                        quantity: item.quantity,
                                      ),
                                    )
                                    .toList();

                                context.read<OrderProvider>().createOrder(
                                  items: items,
                                  total: cart.total,
                                );

                                context
                                    .read<NotificationProvider>()
                                    .addNotification(
                                      title: 'Order placed',
                                      message:
                                          'Your order was placed using '
                                          '$selectedMethod.',
                                    );

                                cart.clear();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Order placed successfully!'),
                                  ),
                                );

                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const OrdersScreen(),
                                  ),
                                  (route) => route.isFirst,
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _agriGreen,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Confirm Order'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _PaymentOption {
  final String title;
  final String description;
  final IconData icon;

  const _PaymentOption(this.title, this.description, this.icon);
}
