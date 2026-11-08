import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import 'cart_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String title;
  final double price;
  final String unit;
  final String imageUrl;

  final int? productId;
  final String? sellerId;
  final int stockQuantity;

  final String description;
  final String category;
  final String farmName;
  final String farmOrigin;
  final bool isOrganic;
  final String deliveryDetails;

  const ProductDetailsScreen({
    super.key,
    this.title = 'Product',
    this.price = 0,
    this.unit = 'unit',
    this.imageUrl = '',
    this.productId,
    this.sellerId,
    this.stockQuantity = 0,
    this.description = '',
    this.category = 'Uncategorized',
    this.farmName = 'Local Farmer',
    this.farmOrigin = 'Location not provided',
    this.isOrganic = false,
    this.deliveryDetails = '',
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;
  bool _isFavorite = false;
  bool _isAddingToCart = false;

  bool get _isPurchasable =>
      widget.productId != null &&
      widget.sellerId != null &&
      widget.stockQuantity > 0;

  double get _totalPrice => widget.price * _quantity;

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildImageHeader(cartProvider.totalCartCount),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBadges(),
                          const SizedBox(height: 16),
                          _buildProductTitleAndPrice(),
                          const SizedBox(height: 20),
                          _buildSellerCard(),
                          const SizedBox(height: 16),
                          _buildDeliveryCard(),
                          const SizedBox(height: 16),
                          _buildDescriptionCard(),
                          const SizedBox(height: 16),
                          _buildProductInformation(),
                          const SizedBox(height: 16),
                          _buildQuantitySelector(),
                          const SizedBox(height: 20),
                          _buildDemoReviews(),
                          const SizedBox(height: 24),
                          _buildRecommendationsSection(),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildBottomBuyBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageHeader(int cartCount) {
    return Stack(
      children: [
        Container(
          height: 310,
          width: double.infinity,
          color: const Color(0xFFEAF3E9),
          child: widget.imageUrl.isNotEmpty
              ? Image.network(
                  widget.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _imagePlaceholder(),
                )
              : _imagePlaceholder(),
        ),
        Positioned(
          top: 15,
          left: 15,
          child: _circularIconButton(
            icon: Icons.arrow_back,
            onTap: () => Navigator.pop(context),
          ),
        ),
        Positioned(
          top: 15,
          right: 15,
          child: Row(
            children: [
              _circularIconButton(
                icon: Icons.share_outlined,
                onTap: () => _showMessage('Sharing is not available yet.'),
              ),
              const SizedBox(width: 10),
              Stack(
                children: [
                  _circularIconButton(
                    icon: Icons.shopping_cart_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CartScreen()),
                      );
                    },
                  ),
                  if (cartCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$cartCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 15,
          right: 15,
          child: _circularIconButton(
            icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
            iconColor: _isFavorite ? Colors.red : Colors.black87,
            onTap: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _imagePlaceholder() {
    return const Center(
      child: Icon(Icons.image_outlined, size: 75, color: Colors.grey),
    );
  }

  Widget _circularIconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = Colors.black87,
  }) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 43,
          height: 43,
          child: Icon(icon, color: iconColor, size: 21),
        ),
      ),
    );
  }

  Widget _buildBadges() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildBadge(
          widget.isOrganic ? 'ORGANIC' : 'FARM FRESH',
          const Color(0xFFE5F4E7),
          const Color(0xFF267A3E),
        ),
        _buildBadge(
          widget.category.toUpperCase(),
          Colors.grey.shade200,
          Colors.black54,
        ),
      ],
    );
  }

  Widget _buildBadge(String label, Color background, Color foreground) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProductTitleAndPrice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Color(0xFF202820),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₱${widget.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: Color(0xFF267A3E),
              ),
            ),
            const SizedBox(width: 5),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '/ ${widget.unit}',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 17,
              color: Color(0xFF267A3E),
            ),
            const SizedBox(width: 6),
            Text(
              _isPurchasable
                  ? '${widget.stockQuantity} ${widget.unit} available'
                  : 'Currently unavailable',
              style: TextStyle(
                color: _isPurchasable ? Colors.green.shade700 : Colors.red,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSellerCard() {
    return _sectionCard(
      title: 'Seller Information',
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFE5F1E5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.agriculture,
              color: Color(0xFF267A3E),
              size: 28,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.farmName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.farmOrigin,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard() {
    return _sectionCard(
      title: 'Delivery Information',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.local_shipping_outlined,
            color: Color(0xFF267A3E),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.deliveryDetails.isNotEmpty ? widget.deliveryDetails : 'Please contact the seller for delivery arrangements and fees.',
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return _sectionCard(
      title: 'Product Description',
      child: Text(
        widget.description.isNotEmpty
            ? widget.description
            : 'No product description has been provided by the seller.',
        style: TextStyle(
          color: Colors.grey.shade700,
          fontSize: 13,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildProductInformation() {
    return _sectionCard(
      title: 'Product Information',
      child: Column(
        children: [
          _infoRow('Product', widget.title),
          _infoRow('Category', widget.category),
          _infoRow('Unit', widget.unit),
          _infoRow('Farm', widget.farmName),
          _infoRow('Origin', widget.farmOrigin),
          _infoRow(
            'Production type',
            widget.isOrganic ? 'Organic' : 'Not specified as organic',
          ),
          _infoRow('Available stock', '${widget.stockQuantity} ${widget.unit}'),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return _sectionCard(
      title: 'Quantity',
      child: Row(
        children: [
          const Text('Select quantity', style: TextStyle(fontSize: 13)),
          const Spacer(),
          _quantityButton(
            icon: Icons.remove,
            enabled: _quantity > 1,
            onTap: () {
              setState(() {
                if (_quantity > 1) _quantity--;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              '$_quantity',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          _quantityButton(
            icon: Icons.add,
            enabled: _isPurchasable && _quantity < widget.stockQuantity,
            onTap: () {
              setState(() {
                if (_quantity < widget.stockQuantity) {
                  _quantity++;
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFEAF3E9) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: enabled ? const Color(0xFF267A3E) : Colors.grey,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildDemoReviews() {
    return _sectionCard(
      title: 'Customer Reviews',
      child: Text(
        'Customer reviews are not available yet.',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'You May Also Like',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade100),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: Colors.orange.shade800),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Recommendation examples are demo content. They are not real listings and cannot be purchased.',
                  style: TextStyle(fontSize: 12, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBuyBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text(
                  'Subtotal',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const Spacer(),
                Text(
                  '₱${_totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF267A3E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: !_isPurchasable || _isAddingToCart
                        ? null
                        : () => _addToCart(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF267A3E),
                      side: const BorderSide(color: Color(0xFF267A3E)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isAddingToCart
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Add to Cart',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: !_isPurchasable || _isAddingToCart
                        ? null
                        : () => _addToCart(goToCart: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF267A3E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Buy Now',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            if (!_isPurchasable)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'This is a demo or unavailable product.',
                  style: TextStyle(fontSize: 11, color: Colors.red.shade700),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _addToCart({bool goToCart = false}) async {
    if (!_isPurchasable) {
      _showMessage('This product is not available for purchase.');
      return;
    }

    if (_quantity > widget.stockQuantity) {
      _showMessage('Requested quantity exceeds available stock.');
      return;
    }

    setState(() {
      _isAddingToCart = true;
    });

    try {
      final cartProvider = context.read<CartProvider>();

      for (int i = 0; i < _quantity; i++) {
        await cartProvider.addToCart(
          productId: widget.productId,
          sellerId: widget.sellerId,
          name: widget.title,
          price: widget.price,
          variant: widget.unit,
          image: widget.imageUrl,
          shopName: widget.farmName,
        );
      }

      if (!mounted) return;

      _showMessage('$_quantity ${widget.unit} added to your cart!');

      if (goToCart && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CartScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Could not add product to cart: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }
}
