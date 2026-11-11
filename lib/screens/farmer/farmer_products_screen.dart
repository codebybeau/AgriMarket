
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'add_product_screen.dart';
import 'edit_product_screen.dart';

class FarmerProductsScreen extends StatefulWidget {
  const FarmerProductsScreen({super.key});

  @override
  State<FarmerProductsScreen> createState() =>
      _FarmerProductsScreenState();
}

class _FarmerProductsScreenState extends State<FarmerProductsScreen> {
  final supabase = Supabase.instance.client;

  // AgriMart theme
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color backgroundColor = Color(0xFFE8F0E6);
  static const Color cardColor = Color(0xFFF1F6EF);
  static const Color textColor = Color(0xFF1B3D2A);
  static const Color descriptionColor = Color(0xFF526357);

  List<Map<String, dynamic>> products = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  // FETCH FARMER PRODUCTS
  Future<void> _fetchProducts() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('Please log in to view your products.');
      }

      final response = await supabase
          .from('products')
          .select('''
            id,
            name,
            price,
            stock_quantity,
            description,
            status,
            is_organic,
            created_at,
            product_images (
              image_url,
              display_order
            )
          ''')
          .eq('seller_id', userId)
          .order('created_at', ascending: false);

      if (!mounted) return;

      setState(() {
        products = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  // OPEN ADD PRODUCT SCREEN
  Future<void> _openAddProduct() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddNewProductScreen(),
      ),
    );

    if (mounted) {
      await _fetchProducts();
    }
  }

  // OPEN EDIT PRODUCT SCREEN
  Future<void> _openEditProduct(
    Map<String, dynamic> product,
  ) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(
          product: product,
        ),
      ),
    );

    if (mounted && result == true) {
      await _fetchProducts();
    }
  }

  // GET PRODUCT IMAGE
  String? _getProductImage(Map<String, dynamic> product) {
    final images = product['product_images'] as List<dynamic>? ?? [];

    if (images.isEmpty) return null;

    final sortedImages = images
        .map((image) => Map<String, dynamic>.from(image as Map))
        .toList();

    sortedImages.sort(
      (a, b) => (a['display_order'] ?? 0)
          .compareTo(b['display_order'] ?? 0),
    );

    return sortedImages.first['image_url']?.toString();
  }

  // MAIN SCREEN
  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Stack(
        children: [
          Column(
            children: [
              // HEADER
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: const BoxDecoration(
                  color: darkGreen,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'My Products',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _fetchProducts,
                      tooltip: 'Refresh products',
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // CONTENT
              Expanded(
                child: _buildBody(),
              ),
            ],
          ),

          // ADD PRODUCT BUTTON
          Positioned(
            right: 18,
            bottom: 18,
            child: FloatingActionButton.extended(
              onPressed: _openAddProduct,
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.add),
              label: const Text(
                'Add Product',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // BUILD BODY
  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: primaryGreen,
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 12),
              const Text(
                'Unable to load products',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: descriptionColor,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: _fetchProducts,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (products.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchProducts,
        color: primaryGreen,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 100),
            Icon(
              Icons.inventory_2_outlined,
              size: 78,
              color: primaryGreen.withValues(alpha: 0.55),
            ),
            const SizedBox(height: 18),
            const Center(
              child: Text(
                'No products yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: darkGreen,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 38),
              child: Text(
                'Your product listings will appear here after you add them.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: descriptionColor,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Tap Add Product to get started.',
                style: TextStyle(
                  color: primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchProducts,
      color: primaryGreen,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 100),
        children: [
          // PRODUCT COUNT
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Your Listings',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: darkGreen,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${products.length} ${products.length == 1 ? 'Product' : 'Products'}',
                  style: const TextStyle(
                    color: primaryGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          const Text(
            'Manage your products and keep your listings updated.',
            style: TextStyle(
              fontSize: 13,
              color: descriptionColor,
            ),
          ),

          const SizedBox(height: 16),

          ...products.map(_buildProductCard),
        ],
      ),
    );
  }

  // PRODUCT CARD
  Widget _buildProductCard(Map<String, dynamic> product) {
    final imageUrl = _getProductImage(product);
    final name = product['name']?.toString() ?? 'Unnamed Product';
    final price = (product['price'] as num?)?.toDouble() ?? 0.0;
    final stock = product['stock_quantity'] ?? 0;
    final status = product['status']?.toString() ?? 'Unknown';
    final isOrganic = product['is_organic'] == true;

    final isActive = status.toLowerCase() == 'active';

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: cardColor,
      elevation: 1.5,
      shadowColor: darkGreen.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: primaryGreen.withValues(alpha: 0.10),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PRODUCT IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 105,
                height: 112,
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _imagePlaceholder();
                        },
                      )
                    : _imagePlaceholder(),
              ),
            ),

            const SizedBox(width: 13),

            // PRODUCT INFORMATION
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    '₱${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: primaryGreen,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Row(
                    children: [
                      const Icon(
                        Icons.inventory_outlined,
                        size: 15,
                        color: descriptionColor,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Stock: $stock',
                        style: const TextStyle(
                          fontSize: 12,
                          color: descriptionColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 9),

                  // PRODUCT LABELS
                  Wrap(
                    spacing: 6,
                    runSpacing: 5,
                    children: [
                      _buildLabel(
                        status.toUpperCase(),
                        isActive ? primaryGreen : Colors.orange.shade800,
                      ),
                      if (isOrganic)
                        _buildLabel('ORGANIC', Colors.teal.shade700),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // EDIT BUTTON
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: () => _openEditProduct(product),
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 16,
                      ),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryGreen,
                        side: const BorderSide(
                          color: primaryGreen,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 7,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // IMAGE PLACEHOLDER
  Widget _imagePlaceholder() {
    return Container(
      color: backgroundColor,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: primaryGreen,
        size: 36,
      ),
    );
  }

  // STATUS LABEL
  Widget _buildLabel(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
