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

  Future<void> _loadSavedAddress() async {
    try {
      final addressProvider = context.read<AddressProvider>();

      await addressProvider.loadAddress();

      if (!mounted) return;

      setState(() {
        _selectedAddress = addressProvider.hasAddress
            ? Map<String, dynamic>.from(addressProvider.addressMap)
            : {};

        _isLoadingAddress = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingAddress = false;
      });

      _showMessage('Unable to load your saved address. Please try again.');
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

  void _openSavedAddresses() async {
    final selected = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SavedAddressesScreen(selectedAddress: _selectedAddress),
      ),
    );

    if (!mounted) return;

    if (selected != null) {
      setState(() {
        _selectedAddress = {
          ...selected,
          'name': selected['name'] ?? selected['full_name'] ?? '',
          'phone': selected['phone'] ?? selected['mobile_number'] ?? '',
          'address': selected['address'] ?? selected['address_line'] ?? '',
          'note': selected['note'] ?? selected['delivery_notes'] ?? '',
        };
      });
      _showMessage('Delivery address updated');
    }
  }

  void _continueToDelivery() {
    if (_selectedAddress.isEmpty) {
      _showMessage('Please add a delivery address in Settings first.');
      return;
    }

    final name =
        (_selectedAddress['name'] ?? _selectedAddress['full_name'] ?? '')
            .toString()
            .trim();

    final phone =
        (_selectedAddress['phone'] ?? _selectedAddress['mobile_number'] ?? '')
            .toString()
            .trim();

    final address =
        (_selectedAddress['address'] ?? _selectedAddress['address_line'] ?? '')
            .toString()
            .trim();

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
        builder: (context) => CheckoutDeliveryScreen(
          checkoutItems: widget.checkoutItems,
          selectedAddress: addressForCheckout,
          deliveryNote: _notesController.text,
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

              // ================= CONTENT =================
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

                            // Default Address Card
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF22C55E),
                                  width: 1.2,
                                ),
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    color: const Color(0xFF16A34A),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        const Text(
                                          'Default Address',
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
                                              decoration:
                                                  TextDecoration.underline,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _selectedAddress['name'] ??
                                                    _selectedAddress['full_name'] ??
                                                    '',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: ink,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                _selectedAddress['phone'] ??
                                                    _selectedAddress['mobile_number'] ??
                                                    '',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: mutedText,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                _selectedAddress['address'] ??
                                                    _selectedAddress['address_line'] ??
                                                    '',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: ink,
                                                  height: 1.3,
                                                ),
                                              ),
                                              if ((_selectedAddress['note'] ??
                                                      _selectedAddress['delivery_notes'] ??
                                                      '')
                                                  .toString()
                                                  .isNotEmpty) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  _selectedAddress['note'] ??
                                                      _selectedAddress['delivery_notes'],
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
                            ),

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
