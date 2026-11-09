import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/address_provider.dart';
import 'add_address_screen.dart';
import 'edit_address_screen.dart';

class SavedAddressesScreen extends StatefulWidget {
  final Map<String, dynamic>? selectedAddress;

  const SavedAddressesScreen({super.key, this.selectedAddress});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  static const Color primaryGreen = Color(0xFF176B3A);
  static const Color darkGreen = Color(0xFF105B31);
  static const Color pageBackground = Color(0xFFF7F9F7);
  static const Color ink = Color(0xFF17211B);
  static const Color mutedText = Color(0xFF6D776F);

  Map<String, dynamic>? _currentSelected;
  bool _isLoading = true;
  bool _isWorking = false;

  @override
  void initState() {
    super.initState();
    _currentSelected = widget.selectedAddress == null
        ? null
        : Map<String, dynamic>.from(widget.selectedAddress!);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAddresses();
    });
  }

  Map<String, dynamic> _normalizeAddress(Map<String, dynamic> address) {
    return {
      ...address,
      'name': address['name'] ?? address['full_name'] ?? '',
      'phone': address['phone'] ?? address['mobile_number'] ?? '',
      'address': address['address'] ?? address['address_line'] ?? '',
      'note': address['note'] ?? address['delivery_notes'] ?? '',
      'isDefault': address['isDefault'] ?? address['is_default'] == true,
    };
  }

  Future<void> _loadAddresses() async {
    try {
      final provider = context.read<AddressProvider>();
      await provider.loadAddress();

      if (!mounted) return;

      final addresses = provider.addresses;

      setState(() {
        if (_currentSelected != null) {
          final selectedId = _currentSelected!['id'];

          final matchingAddress = addresses.where(
            (address) => address['id'] == selectedId,
          );

          if (matchingAddress.isNotEmpty) {
            _currentSelected = _normalizeAddress(
              Map<String, dynamic>.from(matchingAddress.first),
            );
          }
        }

        // If the previous selection no longer exists, select the default.
        if (_currentSelected == null ||
            !addresses.any(
              (address) => address['id'] == _currentSelected!['id'],
            )) {
          final defaultAddress = provider.defaultAddress;
          _currentSelected = defaultAddress == null
              ? null
              : _normalizeAddress(Map<String, dynamic>.from(defaultAddress));
        }

        _isLoading = false;
      });

      if (provider.errorMessage != null && mounted) {
        _showMessage(provider.errorMessage!);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessage('Could not load saved addresses.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

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

  void _selectAddress(Map<String, dynamic> address) {
    setState(() {
      _currentSelected = _normalizeAddress(address);
    });

    // Return the selected address to the checkout screen.
    Navigator.pop(context, _normalizeAddress(address));
  }

  Future<void> _openAddAddress() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddAddressScreen()),
    );

    if (!mounted) return;

    // Refresh from Supabase after the add screen closes.
    await _loadAddresses();
  }

  Future<void> _openEditAddress(Map<String, dynamic> address) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            EditAddressScreen(address: Map<String, dynamic>.from(address)),
      ),
    );

    if (!mounted) return;

    // Refresh from Supabase after editing.
    await _loadAddresses();
  }

  Future<void> _setAsDefault(Map<String, dynamic> address) async {
    final id = address['id'];

    if (id is! int) {
      _showMessage('This address has an invalid ID.');
      return;
    }

    setState(() => _isWorking = true);

    try {
      final success = await context.read<AddressProvider>().setDefaultAddress(
        id,
      );

      if (!mounted) return;

      if (success) {
        await _loadAddresses();
        _showMessage('Default address updated.');
      } else {
        _showMessage(
          context.read<AddressProvider>().errorMessage ??
              'Could not update the default address.',
        );
      }
    } catch (_) {
      _showMessage('Could not update the default address.');
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  Future<void> _deleteAddress(Map<String, dynamic> address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete address?'),
        content: const Text(
          'Are you sure you want to delete this saved address?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final id = address['id'];

    if (id is! int) {
      _showMessage('This address has an invalid ID.');
      return;
    }

    setState(() => _isWorking = true);

    try {
      final success = await context.read<AddressProvider>().deleteAddress(id);

      if (!mounted) return;

      if (success) {
        if (_currentSelected?['id'] == id) {
          _currentSelected = null;
        }

        await _loadAddresses();
        _showMessage('Address deleted.');
      } else {
        _showMessage(
          context.read<AddressProvider>().errorMessage ??
              'Could not delete the address.',
        );
      }
    } catch (_) {
      _showMessage('Could not delete the address.');
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final addresses = context.watch<AddressProvider>().addresses;

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
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
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
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: primaryGreen),
                      )
                    : addresses.isEmpty
                    ? _buildEmptyState()
                    : AbsorbPointer(
                        absorbing: _isWorking,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tap an address to use it for this order.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: mutedText,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...addresses.map(
                                (address) => _buildAddressCard(
                                  _normalizeAddress(address),
                                ),
                              ),
                            ],
                          ),
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
                  child: ElevatedButton.icon(
                    onPressed: _isWorking ? null : _openAddAddress,
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_off_outlined, size: 54, color: mutedText),
            const SizedBox(height: 12),
            const Text(
              'No saved addresses yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ink,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add a delivery address to make checkout easier.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: mutedText),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _openAddAddress,
              icon: const Icon(Icons.add),
              label: const Text('Add Address'),
              style: ElevatedButton.styleFrom(
                backgroundColor: darkGreen,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> address) {
    final isDefault =
        address['is_default'] == true || address['isDefault'] == true;

    final isSelected = address['id'] == _currentSelected?['id'];

    final name = (address['name'] ?? '').toString();
    final phone = (address['phone'] ?? '').toString();
    final addressLine = (address['address'] ?? '').toString();
    final note = (address['note'] ?? '').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDefault || isSelected
              ? const Color(0xFF22C55E)
              : const Color(0xFFE2E8F0),
          width: isDefault || isSelected ? 1.5 : 1,
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
          if (isDefault)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              color: const Color(0xFF16A34A),
              child: const Row(
                children: [
                  Icon(Icons.check, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Default Address',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          InkWell(
            onTap: () => _selectAddress(address),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
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
                          style: const TextStyle(
                            fontSize: 12,
                            color: mutedText,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          addressLine,
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
                  if (isSelected)
                    const Icon(
                      Icons.radio_button_checked,
                      color: primaryGreen,
                      size: 20,
                    )
                  else
                    const Icon(
                      Icons.radio_button_unchecked,
                      color: mutedText,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _openEditAddress(address),
                  icon: const Icon(Icons.edit_outlined, size: 14),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryGreen,
                    side: const BorderSide(color: Color(0xFF86EFAC)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                if (!isDefault)
                  OutlinedButton(
                    onPressed: () => _setAsDefault(address),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ink,
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Set as Default'),
                  ),
                IconButton(
                  onPressed: () => _deleteAddress(address),
                  tooltip: 'Delete address',
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFFF87171),
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
