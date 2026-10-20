import 'package:flutter/material.dart';

import 'farmer_theme.dart';

class FarmerSalesScreen extends StatelessWidget {
  const FarmerSalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'My Sales',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: agriDarkGreen,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Monitor your sales and earnings.',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: agriGreen,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOTAL SALES',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 12),
              Text(
                '₱0.00',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Your sales summary will appear here.',
                style: TextStyle(color: Colors.white, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _summaryCard(
          icon: Icons.shopping_bag_outlined,
          title: 'Completed Orders',
          value: '0',
        ),
        _summaryCard(
          icon: Icons.pending_actions_outlined,
          title: 'Pending Orders',
          value: '0',
        ),
        _summaryCard(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Estimated Earnings',
          value: '₱0.00',
        ),
      ],
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Icon(icon, color: agriGreen, size: 28),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
