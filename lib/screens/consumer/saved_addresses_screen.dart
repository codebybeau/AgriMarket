import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'add_address_screen.dart';

class SavedAddressesScreen extends StatefulWidget {
  final Map<String, dynamic>? selectedAddress;

  const SavedAddressesScreen({
    super.key,
    this.selectedAddress,
  });

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  static const Color primaryGreen = Color(0xFF176B3A);
  static const Color darkGreen = Color(0xFF105B31);
  static const Color pageBackground = Color(0xFFF7F9F7);
  static const Color ink = Color(0xFF17211B);
  static const Color mutedText = Color(0xFF6D776F);

  late List<Map<String, dynamic>> _addresses;
  late Map<String, dynamic> _currentSelected;

  @override
  void initState() {
    super.initState();
    _addresses = [
      {
        'id': '1',
        'name': 'Juan dela Cruz',
        'phone': '09171234567',
        'address':
            '123 Maginhawa St., Teachers Village, Diliman, Quezon City, Metro Manila 1101',
        'note': '"Leave at the gate"',
        'isDefault': true,
      },
      {
        'id': '2',
        'name': 'Juan dela Cruz',
        'phone': '09171234567',
        'address': 'Unit 4B Aguinaldo Highway, Palico, Imus, Cavite 4103',
        'note': '',
        'isDefault': false,
      },
    ];

    _currentSelected = widget.selectedAddress ?? _addresses.first;
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

  void _setAsDefault(Map<String, dynamic> targetAddress) {
    setState(() {
      for (var addr in _addresses) {
        addr['isDefault'] = (addr['id'] == targetAddress['id']);
      }
    });
    _showMessage('Default address updated');
  }

  void _deleteAddress(Map<String, dynamic> targetAddress) {
    setState(() {
      _addresses.removeWhere((addr) => addr['id'] == targetAddress['id']);
    });
    _showMessage('Address removed');
  }

  void _openAddOrEditAddress({Map<String, dynamic>? addressToEdit}) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => AddAddressScreen(addressToEdit: addressToEdit),
      ),
    );

    if (result != null) {
      setState(() {
        if (addressToEdit != null) {
          final idx =
              _addresses.indexWhere((a) => a['id'] == addressToEdit['id']);
          if (idx != -1) {
            _addresses[idx] = result;
          }
        } else {
          _addresses.add(result);
        }
      });
      _showMessage('Address saved successfully');
    }
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
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () =>
                          Navigator.pop(context, _currentSelected),
                      icon: const Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saved Addresses',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Select a delivery address',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ================= BODY =================
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tap an address to use it for this order',
                        style: TextStyle(
                          fontSize: 12,
                          color: mutedText,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._addresses.map((addr) => _buildAddressCard(addr)),
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
                  child: ElevatedButton.icon(
                    onPressed: () => _openAddOrEditAddress(),
                    icon: const Icon(Icons.add, color: Colors.white, size: 20),
                    label: const Text(
                      'Add New Address',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
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

  Widget _buildAddressCard(Map<String, dynamic> addr) {
    final bool isDefault = addr['isDefault'] == true;
    final bool isSelected = addr['id'] == _currentSelected['id'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDefault || isSelected
              ? const Color(0xFF22C55E)
              : const Color(0xFFE2E8F0),
          width: isDefault || isSelected ? 1.5 : 1.0,
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
      child: InkWell(
        onTap: () {
          setState(() {
            _currentSelected = addr;
          });
          Navigator.pop(context, addr);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDefault)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                color: const Color(0xFF16A34A),
                child: const Row(
                  children: [
                    Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Default',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
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
                              addr['name'] ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              addr['phone'] ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: mutedText,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              addr['address'] ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: ink,
                                height: 1.3,
                              ),
                            ),
                            if ((addr['note'] ?? '').toString().isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                addr['note'],
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
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () =>
                            _openAddOrEditAddress(addressToEdit: addr),
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 14,
                          color: primaryGreen,
                        ),
                        label: const Text(
                          'Edit',
                          style: TextStyle(
                            color: primaryGreen,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF86EFAC)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      if (!isDefault) ...[
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () => _setAsDefault(addr),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Set as Default',
                            style: TextStyle(
                              color: ink,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      IconButton(
                        onPressed: () => _deleteAddress(addr),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Color(0xFFF87171),
                          size: 18,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}