import 'package:flutter/material.dart';

import 'add_product_screen.dart';
import 'farmer_theme.dart';

class FarmerProductsScreen extends StatelessWidget {
  const FarmerProductsScreen({super.key});

  void _addProduct(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddNewProductScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'My Products',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: agriDarkGreen,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Manage your farm products and listings.',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 24),

        // Opens your existing AddNewProductScreen.
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () => _addProduct(context),
            icon: const Icon(Icons.add),
            label: const Text('Add New Product'),
            style: ElevatedButton.styleFrom(
              backgroundColor: agriGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Empty state until product records are connected.
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: const Column(
            children: [
              Icon(Icons.inventory_2_outlined, size: 64, color: Colors.black26),
              SizedBox(height: 16),
              Text(
                'No products yet',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Tap "Add New Product" to list your farm produce.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
