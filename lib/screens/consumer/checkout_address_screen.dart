import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/address_provider.dart';
import 'checkout_delivery_screen.dart';
import 'saved_addresses_screen.dart';

class CheckoutAddressScreen extends StatefulWidget {
  final List<Map<String, dynamic>> checkoutItems;

  const CheckoutAddressScreen({super.key, required this.checkoutItems});

  @override
  State<CheckoutAddressScreen> createState() => _CheckoutAddressScreenState();
}

class _CheckoutAddressScreenState extends State<CheckoutAddressScreen> {
  static const Color primaryGreen = Color(0xFF176B3A);
  static const Color darkGreen = Color(0xFF105B31);
  static const Color pageBackground = Color(0xFFF7F9F7);
  static const Color ink = Color(0xFF17211B);
  static const Color mutedText = Color(0xFF6D776F);

  final TextEditingController _notesController = TextEditingController();

  Map<String, dynamic> _selectedAddress = {};
  bool _isLoadingAddress = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedAddress();
    });
  }

  Map<String, dynamic> _normalizeAddress(Map<String, dynamic> address) {
    return {
      ...address,
      'name': address['name'] ?? address['full_name'] ?? '',
      'phone': address['phone'] ?? address['mobile_number'] ?? '',
      'address': address['address'] ?? address['address_line'] ?? '',
      'note': address['note'] ?? address['delivery_notes'] ?? '',
    };
  }

  Future<void> _loadSavedAddress() async {
    try {
      final provider = context.read<AddressProvider>();
      await provider.loadAddress();

      if (!mounted) return;

      final defaultAddress = provider.defaultAddress;

      setState(() {
        _selectedAddress = defaultAddress == null
            ? {}
            : _normalizeAddress(Map<String, dynamic>.from(defaultAddress));
        _isLoadingAddress = false;
      });

      if (provider.errorMessage != null) {
        _showMessage(provider.errorMessage!);
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoadingAddress = false;
      });

      _showMessage('Unable to load your saved addresses. Please try again.');
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
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

  Future<void> _openSavedAddresses() async {
    final selected = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => SavedAddressesScreen(
          selectedAddress: _selectedAddress.isEmpty ? null : _selectedAddress,
        ),
      ),
    );

    if (!mounted || selected == null) return;

    setState(() {
      _selectedAddress = _normalizeAddress(selected);
    });

    _showMessage('Delivery address updated');
  }

  void _continueToDelivery() {
    if (_selectedAddress.isEmpty) {
      _showMessage('Please add a delivery address first.');
      return;
    }

    final name = (_selectedAddress['name'] ?? '').toString().trim();
    final phone = (_selectedAddress['phone'] ?? '').toString().trim();
    final address = (_selectedAddress['address'] ?? '').toString().trim();

    if (name.isEmpty || phone.isEmpty || address.isEmpty) {
      _showMessage('Please complete your delivery address.');
      return;
    }

    final addressForCheckout = {
      ..._selectedAddress,
      'name': name,
      'phone': phone,
      'address': address,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutDeliveryScreen(
          checkoutItems: widget.checkoutItems,
          selectedAddress: addressForCheckout,
          deliveryNote: _notesController.text.trim(),
        ),
      ),
    );
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
                        children: [
                          _buildStepItem(1, 'Address', currentStep: 1),
                          _buildStepConnector(),
                          _buildStepItem(2, 'Delivery', currentStep: 1),
                          _buildStepConnector(),
                          _buildStepItem(3, 'Payment', currentStep: 1),
                          _buildStepConnector(),
                          _buildStepItem(4, 'Summary', currentStep: 1),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoadingAddress
                    ? const Center(
                        child: CircularProgressIndicator(color: primaryGreen),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  color: primaryGreen,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Delivery Address',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: ink,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_selectedAddress.isEmpty)
                              _buildNoAddressCard()
                            else
                              _buildSelectedAddressCard(),
                            const SizedBox(height: 24),
                            const Text(
                              'DELIVERY NOTES (OPTIONAL)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: mutedText,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: TextField(
                                controller: _notesController,
                                maxLines: 3,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: ink,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'e.g. Leave at the gate, call before delivery',
                                  hintStyle: TextStyle(
                                    color: Color(0xFFA0AEC0),
                                    fontSize: 12,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
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
                    onPressed: _isLoadingAddress ? null : _continueToDelivery,
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

  Widget _buildNoAddressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const Icon(Icons.location_off_outlined, color: mutedText, size: 36),
          const SizedBox(height: 8),
          const Text(
            'No saved delivery address',
            style: TextStyle(color: ink, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Add an address to continue with your order.',
            textAlign: TextAlign.center,
            style: TextStyle(color: mutedText, fontSize: 12),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _openSavedAddresses,
            icon: const Icon(Icons.add_location_alt_outlined),
            label: const Text('Choose or add address'),
            style: OutlinedButton.styleFrom(foregroundColor: primaryGreen),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedAddressCard() {
    final name = (_selectedAddress['name'] ?? '').toString();
    final phone = (_selectedAddress['phone'] ?? '').toString();
    final address = (_selectedAddress['address'] ?? '').toString();
    final note = (_selectedAddress['note'] ?? '').toString();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF22C55E), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: const Color(0xFF16A34A),
            child: Row(
              children: [
                const Icon(Icons.check, color: Colors.white, size: 14),
                const SizedBox(width: 4),
                const Text(
                  'Selected Address',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: _openSavedAddresses,
                  child: const Text(
                    'Change',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0FDF4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_outlined,
                    color: primaryGreen,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        phone,
                        style: const TextStyle(fontSize: 12, color: mutedText),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        address,
                        style: const TextStyle(
                          fontSize: 12,
                          color: ink,
                          height: 1.3,
                        ),
                      ),
                      if (note.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          note,
                          style: const TextStyle(
                            fontSize: 11,
                            color: mutedText,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(
    int stepNumber,
    String title, {
    required int currentStep,
  }) {
    final isDone = stepNumber < currentStep;
    final isActive = stepNumber == currentStep;

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
