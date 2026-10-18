import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/notification_provider.dart';
import 'home_screen.dart';
import 'categories_screen.dart';
import 'profile_screen.dart';
import 'notification_screen.dart';
import 'cart_screen.dart';

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
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Vegetables',
    'Fruits',
    'Meat & Poultry',
    'Fish & Seafood',
  ];

  // Mock data matching the UI reference
  final List<Map<String, dynamic>> _products = [
    {
      'name': 'Organic Ampalaya (Bitter Gourd)',
      'category': 'Vegetables',
      'price': 85.00,
      'originalPrice': 110.00,
      'discount': '-23%',
      'unit': '/kg',
      'rating': '4.8',
      'reviews': '234',
      'location': 'Benguet, CAR',
      'image': 'https://images.unsplash.com/photo-1595856715694-814d34f0d619?w=600', // Bell peppers stand-in
      'badges': ['Organic'],
      'bottomBadges': ['Fresh harvest', 'Wholesale'],
    },
    {
      'name': 'Carabao Mango (Export Quality)',
      'category': 'Fruits',
      'price': 180.00,
      'originalPrice': null,
      'discount': null,
      'unit': '/kg',
      'rating': '4.9',
      'reviews': '512',
      'location': 'Guimaras, Western Visayas',
      'image':
          'https://images.unsplash.com/photo-1553279768-865429fa0078?w=600',
      'badges': [],
      'bottomBadges': ['Fresh harvest', 'Wholesale', 'Pre-order'],
    },
    {
      'name': 'Native Chicken (Whole)',
      'category': 'Meat & Poultry',
      'price': 350.00,
      'originalPrice': null,
      'discount': null,
      'unit': '/piece',
      'rating': '4.7',
      'reviews': '189',
      'location': 'Laguna, Region IV-A',
      'image':
          'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=600',
      'badges': [],
      'bottomBadges': [],
    },
    {
      'name': 'Dinorado Rice (Premium)',
      'category': 'Rice & Grains',
      'price': 68.00,
      'originalPrice': null,
      'discount': null,
      'unit': '/kg',
      'rating': '4.6',
      'reviews': '890',
      'location': 'Nueva Ecija, Region III',
      'image':
          'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=600',
      'badges': [],
      'bottomBadges': [],
    },
  ];

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
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: darkGreen,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: pageBackground,
        body: SafeArea(
          top: false,
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(child: _buildCategories()),
              SliverToBoxAdapter(child: _buildResultsBar()),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 22),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    mainAxisExtent: 290, // Taller cards to fit content
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildProductCard(_products[index]),
                    childCount: _products.length,
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavigation(),
      ),
    );
  }

  // ==============================================
  // HEADER
  // ==============================================

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
                  children: const [
                    Text(
                      'Marketplace',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '20 products',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Consumer<NotificationProvider>(
                builder: (context, provider, _) => _headerAction(
                  Icons.chat_bubble_outline_rounded,
                  onTap: () => _goToPage(const NotificationScreen()),
                  badge: provider.unreadCount,
                ),
              ),
              const SizedBox(width: 8),
              _headerAction(
                Icons.shopping_cart_outlined,
                onTap: () => _goToPage(const CartScreen()),
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
                  onPressed: () => _showMessage('Filter clicked'),
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

  // ==============================================
  // CATEGORIES & FILTER BAR
  // ==============================================

  Widget _buildCategories() {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedCategory == _categories[index];
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = _categories[index]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? darkGreen : const Color(0xFFF0F4F1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _categories[index],
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
          const Text(
            '20 results',
            style: TextStyle(fontSize: 12, color: mutedText),
          ),
          InkWell(
            onTap: () => _showMessage('Sort Options'),
            child: Row(
              children: [
                const Text(
                  'Relevance',
                  style: TextStyle(fontSize: 12, color: ink),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.keyboard_arrow_down, size: 16, color: ink),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================
  // PRODUCT CARD
  // ==============================================

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECE8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE & BADGES
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  product['image'],
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      Container(color: const Color(0xFFE8F0E7)),
                ),
                // Discount Badge (Top Left)
                if (product['discount'] != null)
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3D4F),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product['discount'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // Top Right Badges (e.g. Organic)
                if ((product['badges'] as List).isNotEmpty)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Row(
                      children: (product['badges'] as List).map((badge) {
                        return Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: darkGreen,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                // Bottom Badges (e.g. Fresh Harvest, Wholesale)
                if ((product['bottomBadges'] as List).isNotEmpty)
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: (product['bottomBadges'] as List).map((badge) {
                        bool isFresh = badge == 'Fresh harvest';
                        bool isPreorder = badge == 'Pre-order';
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isFresh
                                ? primaryGreen
                                : (isPreorder
                                      ? const Color(0xFFFFF3E0)
                                      : Colors.white),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              color: isFresh
                                  ? Colors.white
                                  : (isPreorder
                                        ? const Color(0xFFE65100)
                                        : darkGreen),
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),

          // DETAILS SECTION
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  product['name'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: ink,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),

                // Rating
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFFB300),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${product['rating']} (${product['reviews']})',
                      style: const TextStyle(fontSize: 10, color: mutedText),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Location
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
                        product['location'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 9, color: mutedText),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Price & Add Button Row
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
                                  text: '${product['price'].toInt()}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: darkGreen,
                                  ),
                                ),
                                TextSpan(
                                  text: product['unit'],
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: mutedText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (product['originalPrice'] != null)
                            Text(
                              '₱${product['originalPrice'].toInt()}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: mutedText,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Add Button Pill
                    Material(
                      color: const Color(
                        0xFF2DB05F,
                      ), // Lighter green action button
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () =>
                            _showMessage('Added ${product['name']} to cart'),
                        borderRadius: BorderRadius.circular(12),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          child: Text(
                            '+ Add',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
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
    );
  }

  // ==============================================
  // BOTTOM NAV
  // ==============================================

  Widget _buildBottomNavigation() {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _navItem(
              Icons.home_outlined,
              Icons.home_rounded,
              'Home',
              false,
              () => _goToPage(const HomeScreen()),
            ),
            _navItem(
              Icons.grid_view_outlined,
              Icons.grid_view_rounded,
              'Categories',
              false,
              () => _goToPage(const CategoriesScreen()),
            ),
            // THIS IS ACTIVE NOW
            _navItem(
              Icons.storefront_outlined,
              Icons.storefront_rounded,
              'Marketplace',
              true,
              () {}, // Already here
            ),
            Consumer<NotificationProvider>(
              builder: (context, provider, _) => _navItem(
                Icons.notifications_none_rounded,
                Icons.notifications_rounded,
                'Notifications',
                false,
                () => _goToPage(const NotificationScreen()),
                badge: provider.unreadCount,
              ),
            ),
            _navItem(
              Icons.person_outline_rounded,
              Icons.person_rounded,
              'Me',
              false,
              () => _goToPage(const ProfileScreen()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(
    IconData icon,
    IconData activeIcon,
    String label,
    bool selected,
    VoidCallback onTap, {
    int badge = 0,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Adding active pill background like in the image for selected items
                  if (selected)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F0E7), // Light green pill
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(activeIcon, size: 19, color: darkGreen),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        icon,
                        size: 19,
                        color: const Color(0xFF9AA39B),
                      ),
                    ),
                  if (badge > 0)
                    Positioned(
                      right: -3,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF3D4F),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            badge > 9 ? '9+' : '$badge',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 7,
                              fontWeight: FontWeight.bold,
                            ),
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
                  fontSize: 8,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  color: selected ? darkGreen : const Color(0xFF929B94),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
