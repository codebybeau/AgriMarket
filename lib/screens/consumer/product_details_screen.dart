import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../providers/cart_provider.dart';
import '../../services/product_catalog_service.dart';
import 'cart_screen.dart';
import 'farm_details_screen.dart';

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

  bool _isLoadingSeller = true;
  bool _isLoadingFarmerProducts = true;

  Map<String, dynamic>? _sellerProfile;
  List<Map<String, dynamic>> _farmerProducts = [];

  final SupabaseClient _supabase = Supabase.instance.client;
  final ProductCatalogService _productService = ProductCatalogService();

  bool get _isPurchasable =>
      widget.productId != null &&
      widget.sellerId != null &&
      widget.sellerId!.isNotEmpty &&
      widget.stockQuantity > 0;

  double get _totalPrice => widget.price * _quantity;

  String get _farmerName {
    final value = _sellerProfile?['full_name']?.toString();

    return value != null && value.trim().isNotEmpty ? value : 'Farmer';
  }

  String get _farmName {
    final value = _sellerProfile?['farm_name']?.toString();

    return value != null && value.trim().isNotEmpty ? value : widget.farmName;
  }

  String get _farmOrigin {
    final value = _sellerProfile?['farm_origin']?.toString();

    return value != null && value.trim().isNotEmpty ? value : widget.farmOrigin;
  }

  String get _farmerBio => _sellerProfile?['bio']?.toString() ?? '';

  String get _farmerContact =>
      _sellerProfile?['contact_number']?.toString() ?? '';

  String get _farmerAvatar => _sellerProfile?['avatar_url']?.toString() ?? '';

  @override
  void initState() {
    super.initState();
    _loadSellerInformation();
  }

  Future<void> _loadSellerInformation() async {
    final sellerId = widget.sellerId;

    if (sellerId == null || sellerId.isEmpty) {
      if (!mounted) return;

      setState(() {
        _isLoadingSeller = false;
        _isLoadingFarmerProducts = false;
      });
      return;
    }

    // Load farmer profile.
    try {
      final profile = await _supabase
          .from('farmer_profiles')
          .select(
            'user_id, full_name, farm_name, farm_origin, '
            'bio, contact_number, avatar_url',
          )
          .eq('user_id', sellerId)
          .maybeSingle();

      if (!mounted) return;

      setState(() {
        _sellerProfile = profile;
        _isLoadingSeller = false;
      });
    } catch (error) {
      debugPrint('Farmer profile loading error: $error');

      if (!mounted) return;

      setState(() {
        _isLoadingSeller = false;
      });
    }

    // Load other active products from the same farmer.
    try {
      final products = await _productService.fetchFarmerProducts(sellerId);

      if (!mounted) return;

      setState(() {
        _farmerProducts = products.where((product) {
          final id = product['id'];

          // Do not show the product currently being viewed.
          return id?.toString() != widget.productId?.toString();
        }).toList();

        _isLoadingFarmerProducts = false;
      });
    } catch (error) {
      debugPrint('Farmer products loading error: $error');

      if (!mounted) return;

      setState(() {
        _isLoadingFarmerProducts = false;
      });
    }
  }

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
                          _buildCustomerReviews(),
                          const SizedBox(height: 24),
                          _buildFarmerProductsSection(),
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

  // --------------------------------------------------
  // PRODUCT IMAGE HEADER
  // --------------------------------------------------

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
                  errorBuilder: (_, _, _) => _imagePlaceholder(),
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

  // --------------------------------------------------
  // PRODUCT BADGES
  // --------------------------------------------------

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

  // --------------------------------------------------
  // PRODUCT NAME, PRICE, AND STOCK
  // --------------------------------------------------

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

  // --------------------------------------------------
  // FARMER INFORMATION
  // --------------------------------------------------

  Widget _buildSellerCard() {
    return _sectionCard(
      title: 'Seller Information',
      child: _isLoadingSeller
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(15),
                child: CircularProgressIndicator(color: Color(0xFF267A3E)),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 62,
                        height: 62,
                        color: const Color(0xFFE5F1E5),
                        child: _farmerAvatar.isNotEmpty
                            ? Image.network(
                                _farmerAvatar,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    _farmerAvatarPlaceholder(),
                              )
                            : _farmerAvatarPlaceholder(),
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _farmerName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _farmName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
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
                                  _farmOrigin,
                                  style: TextStyle(
                                    fontSize: 11,
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
                if (_farmerBio.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  const Text(
                    'About the Farmer',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _farmerBio,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
                if (_farmerContact.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 16,
                        color: Color(0xFF267A3E),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _farmerContact,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed:
                        widget.sellerId == null || widget.sellerId!.isEmpty
                        ? null
                        : _openFarmDetails,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF267A3E),
                      side: const BorderSide(color: Color(0xFF267A3E)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'View Farmer\'s Farm',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 7),
                        Icon(Icons.arrow_forward, size: 17),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _farmerAvatarPlaceholder() {
    return const Center(
      child: Icon(Icons.person, color: Color(0xFF267A3E), size: 34),
    );
  }

  void _openFarmDetails() {
    final sellerId = widget.sellerId;

    if (sellerId == null || sellerId.isEmpty) {
      _showMessage('Farmer information is unavailable.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FarmDetailsScreen(
          sellerId: sellerId,
          farmName: _farmName,
          location: _farmOrigin,
        ),
      ),
    );
  }

  // --------------------------------------------------
  // DELIVERY INFORMATION
  // --------------------------------------------------

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

  // --------------------------------------------------
  // PRODUCT DESCRIPTION
  // --------------------------------------------------

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

  // --------------------------------------------------
  // PRODUCT INFORMATION
  // --------------------------------------------------

  Widget _buildProductInformation() {
    return _sectionCard(
      title: 'Product Information',
      child: Column(
        children: [
          _infoRow('Product Name', widget.title),
          _infoRow('Category', widget.category),
          _infoRow('Price', '₱${widget.price.toStringAsFixed(2)}'),
          _infoRow('Unit', widget.unit),
          _infoRow('Farm Name', _farmName),
          _infoRow('Farm Location', _farmOrigin),
          _infoRow(
            'Production Type',
            widget.isOrganic ? 'Organic' : 'Not specified as organic',
          ),
          _infoRow('Available Stock', '${widget.stockQuantity} ${widget.unit}'),
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

  // --------------------------------------------------
  // QUANTITY SELECTOR
  // --------------------------------------------------

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
                if (_quantity > 1) {
                  _quantity--;
                }
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

  // --------------------------------------------------
  // CUSTOMER REVIEWS
  // --------------------------------------------------

  Widget _buildCustomerReviews() {
    return _sectionCard(
      title: 'Customer Reviews',
      child: Text(
        'Customer reviews are not available yet.',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      ),
    );
  }

  // --------------------------------------------------
  // OTHER PRODUCTS FROM THE SAME FARMER
  // --------------------------------------------------

  Widget _buildFarmerProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'More Products from $_farmName',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (widget.sellerId != null && widget.sellerId!.isNotEmpty)
              TextButton(
                onPressed: _openFarmDetails,
                child: const Text(
                  'View Farm',
                  style: TextStyle(color: Color(0xFF267A3E), fontSize: 12),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        if (_isLoadingFarmerProducts)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: Color(0xFF267A3E)),
            ),
          )
        else if (_farmerProducts.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 35,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 8),
                Text(
                  'No other active products from this farmer.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 225,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _farmerProducts.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final product = _farmerProducts[index];

                return _buildFarmerProductCard(product);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildFarmerProductCard(Map<String, dynamic> product) {
    final productName = product['name']?.toString() ?? 'Product';

    final productImage = product['image_url']?.toString() ?? '';

    final productPrice = (product['price'] as num?)?.toDouble() ?? 0.0;

    final productUnit = product['unit_name']?.toString() ?? 'unit';

    final productStock = (product['stock_quantity'] as num?)?.toInt() ?? 0;

    final productId = (product['id'] as num?)?.toInt();

    final productCategory =
        product['category_name']?.toString() ?? 'Uncategorized';

    final productDescription = product['description']?.toString() ?? '';

    final productDelivery = product['delivery_details']?.toString() ?? '';

    final isOrganic = product['is_organic'] == true;

    return InkWell(
      onTap: productId == null
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailsScreen(
                    productId: productId,
                    sellerId: widget.sellerId,
                    title: productName,
                    price: productPrice,
                    unit: productUnit,
                    imageUrl: productImage,
                    stockQuantity: productStock,
                    description: productDescription,
                    category: productCategory,
                    farmName: _farmName,
                    farmOrigin: _farmOrigin,
                    isOrganic: isOrganic,
                    deliveryDetails: productDelivery,
                  ),
                ),
              );
            },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 155,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 115,
              width: double.infinity,
              color: const Color(0xFFEAF3E9),
              child: productImage.isNotEmpty
                  ? Image.network(
                      productImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _productImagePlaceholder(),
                    )
                  : _productImagePlaceholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '₱${productPrice.toStringAsFixed(2)} / $productUnit',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF267A3E),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$productStock $productUnit available',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _productImagePlaceholder() {
    return const Center(
      child: Icon(Icons.image_outlined, size: 35, color: Colors.grey),
    );
  }

  // --------------------------------------------------
  // BOTTOM BUY BAR
  // --------------------------------------------------

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

  // --------------------------------------------------
  // ADD TO CART
  // --------------------------------------------------

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
          shopName: _farmName,
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
    } catch (error) {
      if (mounted) {
        _showMessage('Could not add product to cart: $error');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  // --------------------------------------------------
  // REUSABLE SECTION CARD
  // --------------------------------------------------

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

  // --------------------------------------------------
  // SNACKBAR MESSAGE
  // --------------------------------------------------

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }
}
