import 'package:flutter/material.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> orderData; // Added to receive data from FarmerOrdersScreen

  const OrderDetailsScreen({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    const Color brandGreen = Color(0xFF006633);

    // Extract dynamic data with fallback defaults
    final String orderId = orderData['id']?.toString() ?? 'ORD-001';
    final String status = orderData['status']?.toString() ?? 'Pending';
    final String customerName = orderData['customer']?.toString() ?? 'Maria Santos';
    final String productName = orderData['product']?.toString() ?? 'Organic Ampalaya';
    final String quantity = orderData['quantity']?.toString() ?? '2 packs';
    final String total = orderData['total']?.toString() ?? '170';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: brandGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Order Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderHeader(orderId, status),
            const SizedBox(height: 16),
            _buildCustomerCard(customerName),
            const SizedBox(height: 16),
            _buildItemsCard(brandGreen, productName, quantity, total),
            const SizedBox(height: 16),
            _buildPaymentSummaryCard(total),
            const SizedBox(height: 80), 
          ],
        ),
      ),
      bottomSheet: _buildActionFooter(context, brandGreen, orderId),
    );
  }

  Widget _buildOrderHeader(String orderId, String status) {
    Color statusColor = status == 'Pending' ? Colors.orange : (status == 'Completed' ? Colors.blue : Colors.green);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                orderId,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Today, 9:30 AM',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(38),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status.toUpperCase(),
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCustomerCard(String customerName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customer & Shipping',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const Divider(height: 20),
          Text(
            customerName,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 6),
          const Text(
            '+63 912 345 6789',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 6),
          const Text(
            '123 Narra Street, Brgy. Poblacion, Kabacan, Cotabato',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard(Color brandGreen, String productName, String quantity, String price) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Items Ordered',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const Divider(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: brandGreen.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.grass, color: brandGreen),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Qty: $quantity',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Text(
                '₱$price',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummaryCard(String subtotal) {
    int subtotalVal = int.tryParse(subtotal) ?? 170;
    int shippingFee = 50;
    int platformFee = 10;
    int totalPayout = subtotalVal + shippingFee - platformFee;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Summary',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const Divider(height: 20),
          _buildSummaryRow('Subtotal', '₱$subtotalVal'),
          const SizedBox(height: 8),
          _buildSummaryRow('Shipping Fee', '₱$shippingFee'),
          const SizedBox(height: 8),
          _buildSummaryRow('Platform Fee', '-₱$platformFee', isDiscount: true),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Payout',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                '₱$totalPayout',
                style: const TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 18, 
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDiscount ? Colors.red : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildActionFooter(BuildContext context, Color brandGreen, String orderId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.grey),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                orderData['status'] = 'Cancelled';
                Navigator.pop(context, 'Cancelled');
              },
              child: const Text('Decline', style: TextStyle(color: Colors.black54)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: brandGreen,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                orderData['status'] = 'Confirmed';
                Navigator.pop(context, 'Confirmed');
              },
              child: const Text(
                'Confirm Order',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
