import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

import '../../providers/notification_provider.dart';
import 'marketplace_screen.dart';
import 'notification_screen.dart';
import 'messages_screen.dart'; // <-- 1. IMPORT MESSAGES SCREEN
import 'profile_screen.dart';
import 'cart_screen.dart';
import 'categories_screen.dart';

class NoStretchScrollBehavior extends MaterialScrollBehavior {
  const NoStretchScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child; // Removes the overscroll stretch effect
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color primaryGreen = Color(0xFF176B3A);
  static const Color darkGreen = Color(0xFF105B31);
  static const Color pageBackground = Color(0xFFF7F9F7);
  static const Color ink = Color(0xFF17211B);
  static const Color mutedText = Color(0xFF6D776F);

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Vegetables',
      'image':
          'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=300',
    },
    {
      'name': 'Fruits',
      'image':
          'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=300',
    },
    {
      'name': 'Meat & Poultry',
      'image':
          'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=300',
    },
    {
      'name': 'Fish & Seafood',
      'image':
          'https://images.unsplash.com/photo-1510130387422-82bed34b37e9?w=300',
    },
    {
      'name': 'Rice & Grains',
      'image':
          'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=300',
    },
    {
      'name': 'Eggs & Dairy',
      'image':
          'https://images.unsplash.com/photo-1518569656558-1f25e69d93d7?w=300',
    },
    {
      'name': 'Herbs & Spices',
      'image':
          'https://images.unsplash.com/photo-1506806732259-39c2d0268443?w=300',
    },
    {
      'name': 'Root Crops',
      'image':
          'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=300',
    },
  ];

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
      'image':
          'https://images.unsplash.com/photo-1546094096-0df4bcaaa337?w=600',
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
    {
      'name': 'Fresh Eggplant (Talong)',
      'category': 'Vegetables',
      'price': 55.00,
      'originalPrice': 70.00,
      'discount': '-21%',
      'unit': '/kg',
      'rating': '4.7',
      'reviews': '142',
      'location': 'Quezon, Region IV-A',
      'image':
          'https://images.unsplash.com/photo-1659261200838-6e6a3a3d7d84?w=600',
      'badges': [],
      'bottomBadges': ['Fresh harvest'],
    },
    {
      'name': 'Farm Fresh Eggs (30 pcs)',
      'category': 'Eggs & Dairy',
      'price': 220.00,
      'originalPrice': null,
      'discount': null,
      'unit': '/tray',
      'rating': '4.9',
      'reviews': '620',
      'location': 'Batangas, Region IV-A',
      'image':
          'https://images.unsplash.com/photo-1518569656558-1f25e69d93d7?w=600',
      'badges': ['Farm fresh'],
      'bottomBadges': ['Wholesale'],
    },
    {
      'name': 'Fresh Tilapia',
      'category': 'Fish & Seafood',
      'price': 160.00,
      'originalPrice': 180.00,
      'discount': '-11%',
      'unit': '/kg',
      'rating': '4.5',
      'reviews': '98',
      'location': 'Pampanga, Region III',
      'image':
          'https://images.unsplash.com/photo-1510130387422-82bed34b37e9?w=600',
      'badges': [],
      'bottomBadges': ['Fresh harvest'],
    },
    {
      'name': 'Sweet Red Sweet Potato',
      'category': 'Root Crops',
      'price': 45.00,
      'originalPrice': null,
      'discount': null,
      'unit': '/kg',
      'rating': '4.8',
      'reviews': '76',
      'location': 'Tarlac, Region III',
      'image':
          'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=600',
      'badges': ['Organic'],
      'bottomBadges': [],
    },
  ];

  List<Map<String, dynamic>> get _filteredProducts {
    final query = _searchQuery.trim().toLowerCase();
    return _products.where((p) {
      final categoryMatch =
          _selectedCategory == 'All' || p['category'] == _selectedCategory;
      final searchMatch =
          query.isEmpty ||
          p['name'].toString().toLowerCase().contains(query) ||
          p['category'].toString().toLowerCase().contains(query);
      return categoryMatch && searchMatch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _goToPage(Widget page) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
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
          child: ScrollConfiguration(
            behavior: const NoStretchScrollBehavior(),
            child: CustomScrollView(
              physics: const ClampingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverToBoxAdapter(child: _buildSaleBanner()),
                SliverToBoxAdapter(child: _buildSpecialOffers()),
                SliverToBoxAdapter(child: _buildCategories()),
                SliverToBoxAdapter(child: _buildProductSectionTitle()),

                if (_filteredProducts.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text('No products found. Try another search.'),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 22),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            mainAxisExtent: 290,
                          ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _buildProductCard(_filteredProducts[index]),
                        childCount: _filteredProducts.length,
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 14)),
              ],
            ),
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
        MediaQuery.of(context).padding.top + 38,
        16,
        16,
      ),
      decoration: const BoxDecoration(
        color: darkGreen,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
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
                      'Good morning! 👋',
                      style: TextStyle(color: Color(0xFFD7E9DC), fontSize: 16),
                    ),
                    const SizedBox(height: 3),

                    Consumer<AuthProvider>(
                      builder: (context, auth, child) {
                        return Text(
                          auth.fullName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 30,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // 2. CONNECTED MESSAGES SCREEN HERE
              Consumer<NotificationProvider>(
                builder: (context, provider, _) => _headerAction(
                  Icons.chat_bubble_outline_rounded,
                  onTap: () => _goToPage(const MessagesScreen()),
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
          const SizedBox(height: 14),
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search products, farms, supplies...',
                hintStyle: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF98A19B),
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF8D9A91),
                  size: 20,
                ),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        icon: const Icon(Icons.close, size: 17),
                      ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 11),
              ),
            ),
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
          color: Colors.white.withOpacity(.18),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 34,
              height: 34,
              child: Icon(icon, color: Colors.white, size: 19),
            ),
          ),
        ),
        if (badge > 0)
          Positioned(
            right: -3,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(3),
              constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
              decoration: const BoxDecoration(
                color: Color(0xFFFF3D4F),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  badge > 99 ? '99+' : '$badge',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSaleBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          height: 120,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                'https://images.unsplash.com/photo-1542838132-92c53300491e?w=1200',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: const Color(0xFF2B8A4A)),
              ),
              Container(color: primaryGreen.withOpacity(.82)),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🌾 Harvest Season Sale',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Up to 30% off fresh produce',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _goToPage(const MarketplaceScreen()),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: darkGreen,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 7,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: const StadiumBorder(),
                      ),
                      child: const Text(
                        'Shop Now',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 14,
                bottom: 10,
                child: Row(
                  children: [
                    Container(
                      width: 14,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 4),
                    ...List.generate(
                      2,
                      (_) => Container(
                        margin: const EdgeInsets.only(right: 4),
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialOffers() {
    final offers = [
      {
        'tag': 'LIMITED-TIME DEAL',
        'title': 'Fresh from Local Farms!',
        'subtitle': 'Enjoy special deals on fresh produce and agricultural',
        'image': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=600',
      },
      {
        'tag': 'WELCOME OFFER',
        'title': 'Welcome to AgriMart!',
        'subtitle': 'Shop fresh produce and farming supplies directly from',
        'image':
            'https://images.unsplash.com/photo-1542838132-92c53300491e?w=600',
      },
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 9),
          child: Row(
            children: const [
              Icon(Icons.sell_outlined, color: primaryGreen, size: 14),
              SizedBox(width: 6),
              Text(
                'Special Offers',
                style: TextStyle(
                  color: ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 146,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            itemCount: offers.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final offer = offers[i];
              return Container(
                width: (MediaQuery.of(context).size.width - 42) / 2,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE8ECE8)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.04),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 66,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            offer['image']!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(color: const Color(0xFF39844B)),
                          ),
                          Container(color: primaryGreen.withOpacity(.55)),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              margin: const EdgeInsets.all(7),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(.94),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                '🌿 ${offer['tag']}',
                                style: const TextStyle(
                                  fontSize: 7,
                                  fontWeight: FontWeight.bold,
                                  color: darkGreen,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(6, 7, 6, 5),
                      child: Column(
                        children: [
                          Text(
                            offer['title']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: ink,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            offer['subtitle']!,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 8,
                              height: 1.2,
                              color: Color(0xFF778078),
                            ),
                          ),
                          const SizedBox(height: 5),
                          GestureDetector(
                            onTap: () => _goToPage(const MarketplaceScreen()),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: primaryGreen,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Shop Now',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Popular Categories',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: ink,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _goToPage(const CategoriesScreen()),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Row(
                  children: [
                    Text(
                      'See all',
                      style: TextStyle(
                        fontSize: 10,
                        color: primaryGreen,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Icon(Icons.chevron_right, color: primaryGreen, size: 15),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 4,
              mainAxisSpacing: 8,
              mainAxisExtent: 62,
            ),
            itemBuilder: (context, index) {
              final category = _categories[index];
              final selected = _selectedCategory == category['name'];
              return InkWell(
                onTap: () => setState(
                  () => _selectedCategory = selected
                      ? 'All'
                      : category['name'] as String,
                ),
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(13),
                        border: selected
                            ? Border.all(color: primaryGreen, width: 2)
                            : null,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        category['image']!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFE6EFE6),
                          child: const Icon(Icons.eco, color: primaryGreen),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category['name']!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: selected
                            ? primaryGreen
                            : const Color(0xFF4F5A52),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductSectionTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _selectedCategory == 'All'
                  ? 'Recommended For You'
                  : _selectedCategory,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: ink,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _goToPage(const MarketplaceScreen()),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Row(
              children: [
                Text(
                  'See all',
                  style: TextStyle(fontSize: 10, color: primaryGreen),
                ),
                Icon(Icons.chevron_right, size: 15, color: primaryGreen),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================
  // PRODUCT CARD (MATCHING MARKETPLACE SCREEN)
  // ==============================================

  Widget _buildProductCard(Map<String, dynamic> product) {
    final List badges = product['badges'] ?? [];
    final List bottomBadges = product['bottomBadges'] ?? [];

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECE8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
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
                  errorBuilder: (_, __, ___) =>
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
                if (badges.isNotEmpty)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Row(
                      children: badges.map((badge) {
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
                            badge.toString(),
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
                if (bottomBadges.isNotEmpty)
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: bottomBadges.map((badge) {
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
                            badge.toString(),
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
                      '${product['rating'] ?? '4.8'} (${product['reviews'] ?? '100'})',
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
                        product['location'] ?? 'Local seller',
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
                                  text: '${(product['price'] as num).toInt()}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: darkGreen,
                                  ),
                                ),
                                TextSpan(
                                  text: product['unit'] ?? '/kg',
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
                              '₱${(product['originalPrice'] as num).toInt()}',
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
                      color: const Color(0xFF2DB05F),
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
              color: Colors.black.withOpacity(.12),
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
              true,
              () {},
            ),
            _navItem(
              Icons.grid_view_outlined,
              Icons.grid_view_rounded,
              'Categories',
              false,
              () => _goToPage(const CategoriesScreen()),
            ),
            _navItem(
              Icons.storefront_outlined,
              Icons.storefront_rounded,
              'Marketplace',
              false,
              () => _goToPage(const MarketplaceScreen()),
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
                  Icon(
                    selected ? activeIcon : icon,
                    size: 19,
                    color: selected ? primaryGreen : const Color(0xFF9AA39B),
                  ),
                  if (badge > 0)
                    Positioned(
                      right: -7,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        constraints: const BoxConstraints(
                          minWidth: 13,
                          minHeight: 13,
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
