import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/address_provider.dart';
import 'add_address_screen.dart';
import 'edit_address_screen.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AddressProvider>().loadAddress();
      }
    });
  }

  Future<void> _openAddAddress() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddAddressScreen()),
    );

    if (mounted) {
      await context.read<AddressProvider>().loadAddress();
    }
  }

  Future<void> _openEditAddress(Map<String, dynamic> address) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditAddressScreen(address: address)),
    );

    if (mounted) {
      await context.read<AddressProvider>().loadAddress();
    }
  }

  Future<void> _deleteAddress(int id) async {
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

    final provider = context.read<AddressProvider>();
    final success = await provider.deleteAddress(id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Address deleted successfully.'
              : provider.errorMessage ?? 'Could not delete address.',
        ),
      ),
    );
  }

  Future<void> _setDefault(int id) async {
    final provider = context.read<AddressProvider>();
    final success = await provider.setDefaultAddress(id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Default address updated.'
              : provider.errorMessage ?? 'Could not update default address.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddressProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F7),
      appBar: AppBar(
        title: const Text('My Addresses'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddAddress,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Address'),
      ),
      body: SafeArea(
        child: provider.isLoading && !provider.hasAddress
            ? const Center(
                child: CircularProgressIndicator(color: Colors.green),
              )
            : provider.errorMessage != null && !provider.hasAddress
            ? _buildError(provider)
            : !provider.hasAddress
            ? _buildEmptyState()
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                children: [
                  const Text(
                    'Your delivery addresses',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Keep multiple addresses and choose '
                    'which one to use by default.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  ...provider.addresses.map((address) {
                    final id = address['id'] as int;
                    final isDefault = address['is_default'] == true;

                    return Card(
                      color: Colors.white,
                      elevation: 1,
                      margin: const EdgeInsets.only(bottom: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isDefault
                              ? Colors.green.shade300
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    address['full_name'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (isDefault)
                                  const Chip(
                                    label: Text('Default'),
                                    visualDensity: VisualDensity.compact,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(address['mobile_number'] ?? ''),
                            const SizedBox(height: 6),
                            Text(address['address_line'] ?? ''),
                            if ((address['delivery_notes'] ?? '')
                                .toString()
                                .trim()
                                .isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Landmark: '
                                '${address['delivery_notes']}',
                              ),
                            ],
                            const Divider(height: 28),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                TextButton.icon(
                                  onPressed: () => _openEditAddress(address),
                                  icon: const Icon(Icons.edit_outlined),
                                  label: const Text('Edit'),
                                ),
                                if (!isDefault)
                                  TextButton(
                                    onPressed: () => _setDefault(id),
                                    child: const Text('Set as default'),
                                  ),
                                TextButton(
                                  onPressed: () => _deleteAddress(id),
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 76,
              color: Colors.green.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No saved addresses',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your home, boarding house, or another '
              'delivery location.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _openAddAddress,
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Address'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(AddressProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              provider.errorMessage ?? 'Unable to load addresses.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => context.read<AddressProvider>().loadAddress(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
