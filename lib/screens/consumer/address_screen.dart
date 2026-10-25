import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/address_provider.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _landmarkController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final address = context.read<AddressProvider>();

      _nameController.text = address.recipientName;
      _phoneController.text = address.phoneNumber;
      _addressController.text = address.deliveryAddress;
      _landmarkController.text = address.landmark;

      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AddressProvider>().saveAddress(
      name: _nameController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      landmarkText: _landmarkController.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Delivery address saved successfully.')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final hasExistingAddress = context.watch<AddressProvider>().hasAddress;

    return Scaffold(
      appBar: AppBar(
        title: Text(hasExistingAddress ? 'Edit Address' : 'Add Address'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 56,
                color: Colors.green,
              ),
              const SizedBox(height: 12),
              Text(
                hasExistingAddress
                    ? 'Update your delivery details'
                    : 'Enter your delivery details',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              _buildField(
                controller: _nameController,
                label: 'Recipient Name',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),

              _buildField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              _buildField(
                controller: _addressController,
                label: 'Complete Delivery Address',
                icon: Icons.home_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              _buildField(
                controller: _landmarkController,
                label: 'Landmark (Optional)',
                icon: Icons.place_outlined,
                requiredField: false,
              ),
              const SizedBox(height: 28),

              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _saveAddress,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(
                    hasExistingAddress ? 'Update Address' : 'Save Address',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool requiredField = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (requiredField && (value == null || value.trim().isEmpty)) {
          return '$label is required';
        }
        return null;
      },
    );
  }
}
