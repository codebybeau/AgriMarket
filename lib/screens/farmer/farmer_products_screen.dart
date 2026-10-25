import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FarmerProductsScreen extends StatelessWidget {
  const FarmerProductsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    if (currentUserId == null) {
      return const Scaffold(
        body: Center(child: Text('User not logged in.')),
      );
    }

    // Listens to products in real-time matching the integer primary key 'id' and current seller_id
    final Stream<List<Map<String, dynamic>>> myProductsStream = Supabase.instance.client
        .from('products')
        .stream(primaryKey: ['id'])
        .eq('seller_id', currentUserId)
        .order('id', ascending: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'My Products',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: myProductsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error loading products: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No products yet',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your product listings will appear here after you add them.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () {
                      // Navigate back or to add product screen
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'Add New Product',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          // Check for low-stock or out-of-stock items for alert box
          final lowStockItems = products.where((p) {
            final stock = (p['stock'] ?? 0) as int;
            return stock <= 5;
          }).toList();

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Low-stock alert banner
              if (lowStockItems.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7E6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFD591)),
                  ),
                  child: Text(
                    'Low-stock alert: ${lowStockItems.map((e) => e['name'] ?? '').join(', ')}',
                    style: const TextStyle(
                      color: Color(0xFFD46B08),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],

              // Product Cards List
              ...products.map((product) {
                final int stock = product['stock'] ?? 0;
                final int sold = product['sold_count'] ?? product['sold'] ?? 0;
                final String unit = product['unit'] ?? 'kg';
                final bool isOutOfStock = stock <= 0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Rounded Product Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: product['image_url'] != null &&
                                (product['image_url'] as String).isNotEmpty
                            ? Image.network(
                                product['image_url'],
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  width: 70,
                                  height: 70,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.broken_image,
                                      color: Colors.grey),
                                ),
                              )
                            : Container(
                                width: 70,
                                height: 70,
                                color: Colors.grey[200],
                                child: const Icon(Icons.image,
                                    color: Colors.grey),
                              ),
                      ),
                      const SizedBox(width: 12),

                      // Product Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['name'] ?? 'Unnamed Product',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '₱${product['price'] ?? 0}/$unit',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Stock Badge & Sales
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isOutOfStock
                                        ? const Color(0xFFFFE8E8)
                                        : const Color(0xFFE6F4EA),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    isOutOfStock
                                        ? 'Out of stock'
                                        : '$stock in stock',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isOutOfStock
                                          ? const Color(0xFFE53935)
                                          : const Color(0xFF1E8E3E),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '$sold sold',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Edit Button
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: Color(0xFF4B5563),
                          ),
                          onPressed: () {
                            // Link to edit product screen if available
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}
