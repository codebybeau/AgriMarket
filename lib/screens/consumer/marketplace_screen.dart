import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/notification_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/product_catalog_service.dart';

import 'home_screen.dart';
import 'categories_screen.dart';
import 'profile_screen.dart';
import 'notification_screen.dart';
import 'messages_screen.dart';
import 'cart_screen.dart';
import 'product_details_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  static const Color primaryGreen = Color(0xFF176B3A);
  static const Color darkGreen = Color(0xFF105B31);
  static const Color pageBackground = Color(0xFFF7F9F7);
  static const Color ink = Color(0xFF17211B);
  static const Color mutedText = Color(0xFF6D776F);

  final TextEditingController _searchController = TextEditingController();
  final ProductCatalogService _catalogService = ProductCatalogService();

  String _selectedCategory = 'All';
  String _searchQuery = '';

  bool _isLoading = true;
  String? _errorMessage;

  List<Map<String, dynamic>> _products = [];

  final List<String> _categories = [
    'All',
    'Vegetables',
    'Fruits',
    'Meat & Poultry',
    'Fish & Seafood',
    'Rice & Grains',
    'Agricultural Supplies',
    'Farming Tools & Equipment',
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final products = await _catalogService.fetchActiveProducts();

      if (!mounted) return;

      setState(() {
        _products = products.where((product) {
          final status = product['status']?.toString().toLowerCase();
          return status == 'active';
        }).toList();

        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredProducts {
    return _products.where((product) {
      final name = product['name']?.toString().toLowerCase() ?? '';
      final category = product['category_name']?.toString().toLowerCase() ?? '';

      final matchesSearch =
          name.contains(_searchQuery.toLowerCase()) ||
          category.contains(_searchQuery.toLowerCase());

      final matchesCategory =
          _selectedCategory == 'All' ||
          category == _selectedCategory.toLowerCase();

      return matchesSearch && matchesCategory;
    }).toList();
  }

  void _goToPage(Widget page) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: darkGreen,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  String _formatPrice(dynamic value) {
    final price = value is num ? value.toDouble() : 0.0;
    return price.toStringAsFixed(price == price.roundToDouble() ? 0 : 2);
  }

  String _getProductImage(Map<String, dynamic> product) {
    return product['image_url']?.toString() ?? '';
  }

  String _getProductLocation(Map<String, dynamic> product) {
    final location = product['farm_origin']?.toString() ?? '';

    if (location.isEmpty || location == 'Location not provided') {
      return 'Location not provided';
    }

    return location;
  }

  void _openProduct(Map<String, dynamic> product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(
          title: product['name']?.toString() ?? 'Product',
          price: (product['price'] as num?)?.toDouble() ?? 0,
          unit: product['unit_name']?.toString() ?? 'unit',
          imageUrl: _getProductImage(product),
          productId: (product['id'] as num?)?.toInt(),
          sellerId: product['seller_id']?.toString(),
          stockQuantity: (product['stock_quantity'] as num?)?.toInt() ?? 0,
          description: product['description']?.toString() ?? '',
          category: product['category_name']?.toString() ?? 'Uncategorized',
          farmName:
              product['farm_name']?.toString() ??
              product['farmer_name']?.toString() ??
              'Local Farmer',
          farmOrigin:
              product['farm_origin']?.toString() ?? 'Location not provided',
          isOrganic: product['is_organic'] == true,
          deliveryDetails: product['delivery_details']?.toString() ?? '',
        ),
      ),
    );
  }

  void _addToCart(Map<String, dynamic> product) {
    final stock = (product['stock_quantity'] as num?)?.toInt() ?? 0;

    if (stock <= 0) {
      _showMessage('This product is currently out of stock.');
      return;
    }

    // Temporary compatibility with the existing CartProvider.
    // The next integration step will add productId, sellerId, and stock
    // to the cart provider so real Supabase cart items can be saved.
    context.read<CartProvider>().addToCart(
      name: product['name']?.toString() ?? 'Product',
      price: (product['price'] as num?)?.toDouble() ?? 0,
      variant: product['unit_name']?.toString() ?? 'unit',
      image: _getProductImage(product),
      shopName: product['farm_name']?.toString() ?? 'Farm',
    );

    _showMessage('${product['name']} added to cart.');
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: darkGreen,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: pageBackground,
        extendBody: true,
        body: SafeArea(
          top: false,
          bottom: false,
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(child: _buildCategories()),
              SliverToBoxAdapter(child: _buildResultsBar()),
              _buildProductGrid(),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavigation(),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 16,
        16,
        16,
      ),
      decoration: const BoxDecoration(
        color: darkGreen,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Marketplace',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_products.length} products',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Consumer<CartProvider>(
                builder: (context, cartProvider, _) => _headerAction(
                  Icons.shopping_cart_outlined,
                  onTap: () => _goToPage(const CartScreen()),
                  badge: cartProvider.totalCartCount,
                ),
              ),
              const SizedBox(width: 8),
              _headerAction(
                Icons.chat_bubble_outline_rounded,
                onTap: () => _goToPage(const MessagesScreen()),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.trim();
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search products...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF98A19B),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Color(0xFF8D9A91),
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () {
                    _showMessage('Additional filters will be available soon.');
                  },
                  icon: const Icon(Icons.tune, color: darkGreen, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerAction(
    IconData icon, {
    required VoidCallback onTap,
    int badge = 0,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.white.withValues(alpha: 0.18),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 36,
              height: 36,
              child: Icon(icon, color: Colors.white, size: 20),
            ),
          ),
        ),
        if (badge > 0)
          Positioned(
            right: -3,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(3),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFFF3D4F),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  badge > 99 ? '99+' : '$badge',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? darkGreen : const Color(0xFFF0F4F1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF4F5A52),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultsBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _isLoading
                ? 'Loading products...'
                : '${_filteredProducts.length} results',
            style: const TextStyle(fontSize: 12, color: mutedText),
          ),
          InkWell(
            onTap: () {
              _showMessage('Sort options will be available soon.');
            },
            child: const Row(
              children: [
                Text('Relevance', style: TextStyle(fontSize: 12, color: ink)),
                SizedBox(width: 2),
                Icon(Icons.keyboard_arrow_down, size: 16, color: ink),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    if (_isLoading) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator(color: primaryGreen)),
      );
    }

    if (_errorMessage != null) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _buildEmptyState(
          icon: Icons.cloud_off_outlined,
          title: 'Unable to load products',
          message: 'Please check your connection and try again.',
          buttonText: 'Retry',
          onPressed: _loadProducts,
        ),
      );
    }

    if (_filteredProducts.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _buildEmptyState(
          icon: Icons.inventory_2_outlined,
          title: _products.isEmpty
              ? 'No products available'
              : 'No matching products',
          message: _products.isEmpty
              ? 'Products published by farmers will appear here.'
              : 'Try another search term or category.',
          buttonText: _products.isEmpty ? 'Refresh' : 'Clear filters',
          onPressed: () {
            if (_products.isEmpty) {
              _loadProducts();
            } else {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
                _selectedCategory = 'All';
              });
            }
          },
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          mainAxisExtent: 290,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          return _buildProductCard(_filteredProducts[index]);
        }, childCount: _filteredProducts.length),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 54, color: const Color(0xFF9AA39B)),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: mutedText),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: darkGreen,
                foregroundColor: Colors.white,
              ),
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final name = product['name']?.toString() ?? 'Product';
    final imageUrl = _getProductImage(product);
    final price = (product['price'] as num?)?.toDouble() ?? 0;
    final unit = product['unit_name']?.toString() ?? 'unit';
    final category = product['category_name']?.toString() ?? 'Uncategorized';
    final farmName = product['farm_name']?.toString() ?? 'Farm';
    final stock = (product['stock_quantity'] as num?)?.toInt() ?? 0;
    final isOrganic = product['is_organic'] == true;
    final isAvailable = stock > 0;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECE8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openProduct(product),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrl.isNotEmpty)
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _imagePlaceholder(),
                    )
                  else
                    _imagePlaceholder(),

                  if (isOrganic)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: darkGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Organic',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  if (!isAvailable)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.45),
                        alignment: Alignment.center,
                        child: const Text(
                          'OUT OF STOCK',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: ink,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.storefront_outlined,
                        color: mutedText,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          farmName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 9, color: mutedText),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: mutedText,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _getProductLocation(product),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 9, color: mutedText),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 9, color: mutedText),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text: '₱',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: darkGreen,
                                    ),
                                  ),
                                  TextSpan(
                                    text: _formatPrice(price),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: darkGreen,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '/$unit',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: mutedText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'Stock: $stock',
                              style: TextStyle(
                                fontSize: 9,
                                color: isAvailable ? mutedText : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Material(
                        color: isAvailable
                            ? const Color(0xFF2DB05F)
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: isAvailable ? () => _addToCart(product) : null,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 7,
                            ),
                            child: Text(
                              isAvailable ? '+ Add' : 'Unavailable',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFE8F0E7),
      child: const Center(
        child: Icon(Icons.eco, color: primaryGreen, size: 36),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          _navItem(
            Icons.home_filled,
            'Home',
            false,
            () => _goToPage(const HomeScreen()),
          ),
          _navItem(
            Icons.grid_view_rounded,
            'Categories',
            false,
            () => _goToPage(const CategoriesScreen()),
          ),
          _navItem(Icons.storefront_outlined, 'Marketplace', true, () {}),
          Consumer<NotificationProvider>(
            builder: (context, provider, _) => _navItem(
              Icons.notifications_none_rounded,
              'Notifications',
              false,
              () => _goToPage(const NotificationScreen()),
              badge: provider.unreadCount,
            ),
          ),
          _navItem(
            Icons.person_outline_rounded,
            'Me',
            false,
            () => _goToPage(const ProfileScreen()),
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    IconData icon,
    String label,
    bool selected,
    VoidCallback onTap, {
    int badge = 0,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE8F5E9) : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: selected ? primaryGreen : const Color(0xFF9AA39B),
                  ),
                  if (badge > 0)
                    Positioned(
                      right: -4,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF3D4F),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          badge > 99 ? '99+' : '$badge',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 7,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                  color: selected ? primaryGreen : const Color(0xFF929B94),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
