import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../providers/cart_provider.dart';
import 'orderplaced_screen.dart';

class CheckoutSummaryScreen extends StatefulWidget {
  final List<Map<String, dynamic>> checkoutItems;
  final Map<String, dynamic> selectedAddress;
  final String deliveryNote;
  final String deliveryMethod;
  final double deliveryFee;
  final String paymentMethod;

  const CheckoutSummaryScreen({
    super.key,
    required this.checkoutItems,
    required this.selectedAddress,
    required this.deliveryNote,
    required this.deliveryMethod,
    required this.deliveryFee,
    required this.paymentMethod,
  });

  @override
  State<CheckoutSummaryScreen> createState() => _CheckoutSummaryScreenState();
}

class _CheckoutSummaryScreenState extends State<CheckoutSummaryScreen> {
  static const Color primaryGreen = Color(0xFF176B3A);
  static const Color darkGreen = Color(0xFF105B31);
  static const Color pageBackground = Color(0xFFF7F9F7);
  static const Color ink = Color(0xFF17211B);
  static const Color mutedText = Color(0xFF6D776F);

  bool _isPlacingOrder = false;

  final SupabaseClient _supabase = Supabase.instance.client;

  double get _subtotal {
    double total = 0;

    for (final item in widget.checkoutItems) {
      final price = (item['price'] as num).toDouble();
      final quantity = (item['quantity'] as num).toInt();

      total += price * quantity;
    }

    return total;
  }

  double get _totalAmount => _subtotal + widget.deliveryFee;

  // ---------------------------------------------------------
  // GET PRODUCT ID
  // ---------------------------------------------------------

  int? _getProductId(Map<String, dynamic> item) {
    final value = item['productId'] ?? item['product_id'];

    if (value == null) return null;

    if (value is int) return value;

    return int.tryParse(value.toString());
  }

  // ---------------------------------------------------------
  // GET CART ITEM ID
  // ---------------------------------------------------------

  int? _getCartItemId(Map<String, dynamic> item) {
    final value = item['cartItemId'] ?? item['cart_item_id'] ?? item['id'];

    if (value == null) return null;

    if (value is int) return value;

    return int.tryParse(value.toString());
  }

  // ---------------------------------------------------------
  // GET ADDRESS ID
  // ---------------------------------------------------------

  int? _getAddressId() {
    final value =
        widget.selectedAddress['id'] ?? widget.selectedAddress['address_id'];

    if (value == null) return null;

    if (value is int) return value;

    return int.tryParse(value.toString());
  }

  // ---------------------------------------------------------
  // SHOW MESSAGE
  // ---------------------------------------------------------

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError ? Colors.red.shade700 : darkGreen,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  // ---------------------------------------------------------
  // PLACE ORDER
  // ---------------------------------------------------------

  Future<void> _placeOrder() async {
    if (_isPlacingOrder) return;

    final user = _supabase.auth.currentUser;

    if (user == null) {
      _showMessage('Please log in before placing an order.', isError: true);
      return;
    }

    if (widget.checkoutItems.isEmpty) {
      _showMessage('Your checkout has no items.', isError: true);
      return;
    }

    final List<Map<String, dynamic>> orderItems = [];
    final List<int> cartItemIds = [];

    // Validate products before saving the order.
    for (final item in widget.checkoutItems) {
      final productId = _getProductId(item);
      final cartItemId = _getCartItemId(item);

      if (productId == null || cartItemId == null) {
        _showMessage(
          'A product ID or cart item ID is missing. Please return to your cart.',
          isError: true,
        );
        return;
      }

      final price = (item['price'] as num).toDouble();
      final quantity = (item['quantity'] as num).toInt();

      if (quantity <= 0 || price < 0) {
        _showMessage('Invalid product quantity or price.', isError: true);
        return;
      }

      cartItemIds.add(cartItemId);

      orderItems.add({
        'product_id': productId,
        'quantity': quantity,
        'unit_price': price,
        'total_price': price * quantity,
      });
    }

    final addressId = _getAddressId();

    if (addressId == null) {
      _showMessage(
        'The selected address ID is missing. Please select your delivery address again.',
        isError: true,
      );
      return;
    }

    // Get the provider BEFORE any asynchronous operation.
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    setState(() {
      _isPlacingOrder = true;
    });

    try {
      final orderReference = 'AGR-${DateTime.now().millisecondsSinceEpoch}';

      // STEP 1: SAVE ORDER.
      final orderResponse = await _supabase
          .from('orders')
          .insert({
            'order_reference': orderReference,
            'buyer_id': user.id,
            'address_id': addressId,
            'delivery_method': widget.deliveryMethod,
            'delivery_fee': widget.deliveryFee,
            'payment_method': widget.paymentMethod,
            'subtotal': _subtotal,
            'total_amount': _totalAmount,
            'status': 'Pending',
          })
          .select('id')
          .single();

      final int orderId = (orderResponse['id'] as num).toInt();

      // STEP 2: SAVE ORDER ITEMS.
      final itemsToInsert = orderItems.map((item) {
        return {
          'order_id': orderId,
          'product_id': item['product_id'],
          'quantity': item['quantity'],
          'unit_price': item['unit_price'],
          'total_price': item['total_price'],
        };
      }).toList();

      await _supabase.from('order_items').insert(itemsToInsert);

      // STEP 3: REMOVE PURCHASED ITEMS FROM CART.
      bool cartCleared = false;

      try {
        cartCleared = await cartProvider.removePurchasedItems(cartItemIds);
      } catch (error) {
        debugPrint('CART CLEANUP ERROR: $error');
      }

      if (!mounted) return;

      if (cartCleared) {
        _showMessage('Order placed successfully! Cart updated.');
      } else {
        _showMessage(
          'Order placed successfully, but some cart items could not be removed. Please refresh your cart.',
          isError: true,
        );
      }

      // STEP 4: NAVIGATE TO ORDER PLACED SCREEN.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              OrderPlacedScreen(orderReference: orderReference),
        ),
      );
    } catch (error) {
      debugPrint('PLACE ORDER ERROR: $error');

      _showMessage(
        'Unable to place your order. Please try again. $error',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
        });
      }
    }
  }

  // ---------------------------------------------------------
  // BUILD SCREEN
  // ---------------------------------------------------------

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
              // HEADER
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
                          _buildStepItem(1, 'Address', currentStep: 4),
                          _buildStepConnector(),
                          _buildStepItem(2, 'Delivery', currentStep: 4),
                          _buildStepConnector(),
                          _buildStepItem(3, 'Payment', currentStep: 4),
                          _buildStepConnector(),
                          _buildStepItem(4, 'Summary', currentStep: 4),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // CONTENT
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order Summary',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ink,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // SELLER VOUCHER CARD
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Seller voucher & delivery promo',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: ink,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '10% off up to ₱100 + free standard delivery - Min. ₱500',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: mutedText,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Sample expiry: Jun 30, 2026',
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE2E8F0),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Apply',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Add ₱415 more to meet the sample minimum spend.',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFD97706),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // DELIVERY ADDRESS
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  color: primaryGreen,
                                  size: 16,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'DELIVERY ADDRESS',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: mutedText,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${widget.selectedAddress['name']} - '
                              '${widget.selectedAddress['phone']}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.selectedAddress['address']?.toString() ??
                                  '',
                              style: const TextStyle(
                                fontSize: 11,
                                color: mutedText,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ITEMS LIST
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ITEMS (${widget.checkoutItems.length})',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: mutedText,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: widget.checkoutItems.length,
                              itemBuilder: (context, index) {
                                final item = widget.checkoutItems[index];

                                final price = (item['price'] as num).toDouble();

                                final quantity = (item['quantity'] as num)
                                    .toInt();

                                final imageUrl =
                                    item['image']?.toString() ?? '';

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: imageUrl.isNotEmpty
                                            ? Image.network(
                                                imageUrl,
                                                width: 44,
                                                height: 44,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, _, _) =>
                                                    _buildProductPlaceholder(),
                                              )
                                            : _buildProductPlaceholder(),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['name']?.toString() ??
                                                  'Product',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: ink,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              'x$quantity kg',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: mutedText,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '₱${(price * quantity).toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: ink,
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

                      const SizedBox(height: 12),

                      // TOTALS AND PAYMENT
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Subtotal',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: mutedText,
                                  ),
                                ),
                                Text(
                                  '₱${_subtotal.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: ink,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Delivery Fee',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: mutedText,
                                  ),
                                ),
                                Text(
                                  widget.deliveryFee == 0
                                      ? 'FREE'
                                      : '₱${widget.deliveryFee.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: ink,
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Divider(color: Color(0xFFE2E8F0)),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: ink,
                                  ),
                                ),
                                Text(
                                  '₱${_totalAmount.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Payment',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: mutedText,
                                  ),
                                ),
                                Text(
                                  widget.paymentMethod,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: ink,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // PLACE ORDER BUTTON
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
                    onPressed: _isPlacingOrder ? null : _placeOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkGreen,
                      disabledBackgroundColor: Colors.grey,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: _isPlacingOrder
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check, color: Colors.white, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Place Order',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
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

  // ---------------------------------------------------------
  // PRODUCT PLACEHOLDER
  // ---------------------------------------------------------

  Widget _buildProductPlaceholder() {
    return Container(
      width: 44,
      height: 44,
      color: const Color(0xFFE8F0E7),
      child: const Icon(Icons.eco, color: primaryGreen, size: 20),
    );
  }

  // ---------------------------------------------------------
  // CHECKOUT STEP ITEM
  // ---------------------------------------------------------

  Widget _buildStepItem(
    int stepNumber,
    String title, {
    required int currentStep,
  }) {
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

  // ---------------------------------------------------------
  // CHECKOUT STEP CONNECTOR
  // ---------------------------------------------------------

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
