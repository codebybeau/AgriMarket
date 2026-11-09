import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/product_catalog_service.dart';
import 'add_product_screen.dart';
import 'farmer_theme.dart';

class FarmerProductsScreen extends StatefulWidget {
  const FarmerProductsScreen({super.key});

  @override
  State<FarmerProductsScreen> createState() => _FarmerProductsScreenState();
}

class _FarmerProductsScreenState extends State<FarmerProductsScreen> {
  final ProductCatalogService _productService = ProductCatalogService();

  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Tracks which product is currently being deleted.
  int? _deletingProductId;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Please log in to view your products.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await _productService.fetchSellerProducts(userId);

      if (!mounted) return;

      setState(() {
        // Do not display products that have already been deleted.
        _products = products
            .where(
              (product) =>
                  product['status']?.toString().toLowerCase() != 'deleted',
            )
            .toList();

        _isLoading = false;
      });
    } catch (error, stackTrace) {
      debugPrint('Error loading seller products: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not load your products. Please try again.';
      });
    }
  }

  Future<void> _addProduct(BuildContext context) async {
    final published = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddNewProductScreen()),
    );

    if (published == true) {
      await _loadProducts();
    }
  }

  // Ask for confirmation before deleting.
  Future<void> _confirmDeleteProduct(Map<String, dynamic> product) async {
    final productName = product['name']?.toString() ?? 'this product';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Product?'),
          content: Text(
            'Are you sure you want to delete "$productName"? '
            'This product will no longer appear in your active listings.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteProduct(product);
    }
  }

  // Soft-delete the product in Supabase.
  Future<void> _deleteProduct(Map<String, dynamic> product) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final productId = product['id'];

    if (userId == null) {
      _showMessage('Please log in again.');
      return;
    }

    if (productId == null) {
      _showMessage('Product ID is missing. Cannot delete product.');
      return;
    }

    final parsedId = productId is num
        ? productId.toInt()
        : int.tryParse(productId.toString());

    if (parsedId == null) {
      _showMessage('Invalid product ID.');
      return;
    }

    setState(() {
      _deletingProductId = parsedId;
    });

    try {
      final response = await Supabase.instance.client
          .from('products')
          .update({'status': 'deleted'})
          .eq('id', parsedId)
          .eq('seller_id', userId)
          .select('id');

      if (response.isEmpty) {
        throw Exception(
          'Product was not found or you do not have permission to delete it.',
        );
      }

      if (!mounted) return;

      setState(() {
        _products.removeWhere(
          (item) => item['id'].toString() == parsedId.toString(),
        );

        _deletingProductId = null;
      });

      _showMessage('Product deleted successfully.');
    } catch (error, stackTrace) {
      debugPrint('Error deleting product: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _deletingProductId = null;
      });

      _showMessage('Could not delete product. Please try again.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  String _priceText(dynamic price) {
    final value = price is num ? price.toDouble() : 0.0;

    return '₱${value.toStringAsFixed(value == value.roundToDouble() ? 0 : 2)}';
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
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
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final imageUrl = product['image_url']?.toString();
    final stock = (product['stock_quantity'] as num?)?.toInt() ?? 0;
    final status = product['status']?.toString() ?? 'unknown';
    final isActive = status.toLowerCase() == 'active';

    final unit = product['unit_name']?.toString() ?? 'unit';

    final rawId = product['id'];
    final productId = rawId is num
        ? rawId.toInt()
        : int.tryParse(rawId?.toString() ?? '');

    final isDeleting = productId != null && _deletingProductId == productId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imageUrl == null || imageUrl.isEmpty
                ? Container(
                    width: 82,
                    height: 82,
                    color: const Color(0xFFE8F0E7),
                    child: const Icon(Icons.eco, color: agriGreen, size: 30),
                  )
                : Image.network(
                    imageUrl,
                    width: 82,
                    height: 82,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 82,
                        height: 82,
                        color: const Color(0xFFE8F0E7),
                        child: const Icon(
                          Icons.eco,
                          color: agriGreen,
                          size: 30,
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name']?.toString() ?? 'Unnamed product',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: agriDarkGreen,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${_priceText(product['price'])} / $unit',
                  style: const TextStyle(
                    color: agriGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Stock: $stock $unit',
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
                const SizedBox(height: 7),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFFE8F5E9)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: isActive ? agriGreen : Colors.black54,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Delete button.
          isDeleting
              ? const Padding(
                  padding: EdgeInsets.all(10),
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  tooltip: 'Delete product',
                  onPressed: () {
                    _confirmDeleteProduct(product);
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: ListView(
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

          const SizedBox(height: 24),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.redAccent,
                    size: 36,
                  ),
                  const SizedBox(height: 10),
                  Text(_errorMessage!, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _loadProducts,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try again'),
                  ),
                ],
              ),
            )
          else if (_products.isEmpty)
            _buildEmptyState()
          else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Listings',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: agriDarkGreen,
                  ),
                ),
                Text(
                  '${_products.length} products',
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._products.map(_buildProductCard),
          ],
        ],
      ),
    );
  }
}
