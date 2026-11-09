import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'checkout_payment_screen.dart';

class CheckoutDeliveryScreen extends StatefulWidget {
  final List<Map<String, dynamic>> checkoutItems;
  final Map<String, dynamic> selectedAddress;
  final String deliveryNote;

  const CheckoutDeliveryScreen({
    super.key,
    required this.checkoutItems,
    required this.selectedAddress,
    required this.deliveryNote,
  });

  @override
  State<CheckoutDeliveryScreen> createState() => _CheckoutDeliveryScreenState();
}

class _CheckoutDeliveryScreenState extends State<CheckoutDeliveryScreen> {
  static const Color primaryGreen = Color(0xFF176B3A);
  static const Color darkGreen = Color(0xFF105B31);
  static const Color pageBackground = Color(0xFFF7F9F7);
  static const Color ink = Color(0xFF17211B);
  static const Color mutedText = Color(0xFF6D776F);

  String _selectedDeliveryMethod = 'Standard Delivery';
  double _deliveryFee = 80.00;

  final List<Map<String, dynamic>> _deliveryOptions = [
    {
      'title': 'Standard Delivery',
      'subtitle': '3-5 business days',
      'price': 80.0,
      'icon': Icons.inventory_2_outlined,
    },
    {
      'title': 'Express Delivery',
      'subtitle': '1-2 business days',
      'price': 150.0,
      'icon': Icons.bolt_outlined,
    },
    {
      'title': 'Store Pickup',
      'subtitle': "Pick up at seller's location",
      'price': 0.0,
      'icon': Icons.storefront_outlined,
    },
  ];

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
              // ================= HEADER =================
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  8,
                  MediaQuery.of(context).padding.top + 8,
                  16,
                  20,
                ),
                decoration: const BoxDecoration(
                  color: darkGreen,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const Text(
                          'Checkout',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStepItem(1, 'Address', currentStep: 2),
                          _buildStepConnector(),
                          _buildStepItem(2, 'Delivery', currentStep: 2),
                          _buildStepConnector(),
                          _buildStepItem(3, 'Payment', currentStep: 2),
                          _buildStepConnector(),
                          _buildStepItem(4, 'Summary', currentStep: 2),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ================= CONTENT =================
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.local_shipping_outlined,
                            color: primaryGreen,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Delivery Method',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ink,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _deliveryOptions.length,
                        itemBuilder: (context, index) {
                          final option = _deliveryOptions[index];
                          final bool isSelected =
                              _selectedDeliveryMethod == option['title'];

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDeliveryMethod = option['title'];
                                _deliveryFee = option['price'];
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFF0FDF4)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF22C55E)
                                      : const Color(0xFFE2E8F0),
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      option['icon'],
                                      color: isSelected
                                          ? primaryGreen
                                          : mutedText,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          option['title'],
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: ink,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          option['subtitle'],
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: mutedText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    option['price'] == 0.0
                                        ? 'FREE'
                                        : '₱${(option['price'] as double).toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: option['price'] == 0.0
                                          ? primaryGreen
                                          : ink,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Icon(
                                    isSelected
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked,
                                    color: isSelected
                                        ? primaryGreen
                                        : const Color(0xFFCBD5E1),
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // ================= BOTTOM BUTTON =================
              Container(
                padding: const EdgeInsets.all(16),
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
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutPaymentScreen(
                            checkoutItems: widget.checkoutItems,
                            selectedAddress: widget.selectedAddress,
                            deliveryNote: widget.deliveryNote,
                            deliveryMethod: _selectedDeliveryMethod,
                            deliveryFee: _deliveryFee,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepItem(int stepNumber, String title, {required int currentStep}) {
    final bool isDone = stepNumber < currentStep;
    final bool isActive = stepNumber == currentStep;

    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isActive || isDone
                ? Colors.white
                : Colors.white.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 14, color: darkGreen)
                : Text(
                    '$stepNumber',
                    style: TextStyle(
                      color: isActive ? darkGreen : Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: isActive || isDone
                ? Colors.white
                : Colors.white.withValues(alpha: 0.6),
            fontSize: 9,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector() {
    return Expanded(
      child: Container(
        height: 1,
        color: Colors.white.withValues(alpha: 0.3),
        margin: const EdgeInsets.only(bottom: 14, left: 4, right: 4),
      ),
    );
  }
}