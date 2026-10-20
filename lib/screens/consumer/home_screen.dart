import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/notification_provider.dart';
import 'marketplace_screen.dart';
import 'notification_screen.dart';
import 'messages_screen.dart';
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
    return child;
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
  static const Color orangeText = Color(0xFFE67E22);

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
  ];

  final List<Map<String, dynamic>> _featuredStores = [
    {
      'name': 'Mang Celso Farm',
      'location': 'Benguet',
      'rating': '4.8',
      'image':
          'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=600',
      'avatar':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      'verified': true,
    },
    {
      'name': 'Guimaras Harvest',
      'location': 'Guimaras',
      'rating': '4.9',
      'image':
          'https://images.unsplash.com/photo-1550989460-0adf9ea622e2?w=600',
      'avatar':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
      'verified': true,
    },
    {
      'name': 'Nueva Ecija Grains',
      'location': 'Nueva Ecija',
      'rating': '4.6',
      'image':
          'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=600',
      'avatar':
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
      'verified': true,
    },
  ];

  final List<Map<String, dynamic>> _freshProducts = [
    {
      'name': 'Organic Ampalaya',
      'price': 85.00,
      'unit': '/kg',
      'harvestDate': 'Harvested May 27, 2025',
      'farm': 'Mang Celso Farm',
      'image':
          'https://images.unsplash.com/photo-1546094096-0df4bcaaa337?w=600',
    },
    {
      'name': 'Fresh Pechay Bundle',
      'price': 45.00,
      'unit': '/bundle',
      'harvestDate': 'Harvested May 28, 2025',
      'farm': 'Pangasinan Greens',
      'image':
          'https://images.unsplash.com/photo-1515471209610-dae1c92d877f?w=600',
    },
    {
      'name': 'Carabao Mango',
      'price': 180.00,
      'unit': '/kg',
      'harvestDate': 'Harvested May 26, 2025',
      'farm': 'Guimaras Harvest',
      'image':
          'https://images.unsplash.com/photo-1553279768-865429fa0078?w=600',
    },
  ];

  final List<Map<String, dynamic>> _nearbyFarmers = [
    {
      'name': 'Mt. Apo Fresh Farm',
      'location': 'Kidapawan City',
      'distance': '2.4 km',
      'rating': '4.9',
      'products': '18 products',
    },
    {
      'name': 'Kabacan Harvest Hub',
      'location': 'Kabacan',
      'distance': '8.7 km',
      'rating': '4.7',
      'products': '12 products',
    },
  ];

  final List<Map<String, dynamic>> _recommendedProducts = [
    {
      'name': 'Fresh Eggs (Native/Itlog na Manok)',
      'price': 12,
      'farm': 'Pampanga Poultry Farm',
      'rating': '4.9',
      'reviews': '1024',
      'image':
          'https://images.unsplash.com/photo-1598514982205-f36b96d1e8dd?w=600',
    },
    {
      'name': 'Dinorado Rice (Premium)',
      'price': 68,
      'farm': 'Nueva Ecija Grains',
      'rating': '4.6',
      'reviews': '890',
      'image':
          'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=600',
    },
    {
      'name': 'Carabao Mango (Export Quality)',
      'price': 180,
      'farm': 'Guimaras Harvest Co.',
      'rating': '4.9',
      'reviews': '512',
      'image':
          'https://images.unsplash.com/photo-1553279768-865429fa0078?w=600',
    },
    {
      'name': 'Harvesting Sickle Set',
      'price': 480,
      'farm': 'AgroTools PH Demo',
      'rating': '4.9',
      'reviews': '157',
      'sold': '447 sold',
      'image':
          'https://images.unsplash.com/photo-1592982537447-6f296b02a220?w=600',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          child: ScrollConfiguration(
            behavior: const NoStretchScrollBehavior(),
            child: CustomScrollView(
              physics: const ClampingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverToBoxAdapter(child: _buildSaleBanner()),
                SliverToBoxAdapter(child: _buildCategories()),
                SliverToBoxAdapter(child: _buildFeaturedStores()),
                SliverToBoxAdapter(child: _buildFreshlyHarvested()),
                SliverToBoxAdapter(child: _buildNearbyFarmers()),

                // Recommended For You Section
                SliverToBoxAdapter(child: _buildRecommendedHeader()),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          mainAxisExtent:
                              250, // Fixed height matching the new card
                        ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _buildRecommendedCard(_recommendedProducts[index]),
                      childCount: _recommendedProducts.length,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 110)),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNavigation(),
      ),
    );
  }

  // --- HEADER ---
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 24,
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
                child: Row(
                  children: const [
                    Icon(
                      Icons.location_on_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Metro Manila (NCR)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.chevron_right, color: Colors.white70, size: 16),
                  ],
                ),
              ),
              Consumer<NotificationProvider>(
                builder: (context, provider, _) => _headerAction(
                  Icons.chat_bubble_outline_rounded,
                  onTap: () => _goToPage(const MessagesScreen()),
                  badge: provider.unreadCount > 0 ? provider.unreadCount : 4,
                ),
              ),
              const SizedBox(width: 10),
              _headerAction(
                Icons.shopping_cart_outlined,
                onTap: () => _goToPage(const CartScreen()),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 44,
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
                  fontSize: 13,
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
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
          color: Colors.white..withValues(alpha: 0.18),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 38,
              height: 38,
              child: Icon(icon, color: Colors.white, size: 20),
            ),
          ),
        ),
        if (badge > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFFFF3D4F),
                shape: BoxShape.circle,
              ),
              child: Text(
                badge > 99 ? '99+' : '$badge',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // --- SALE BANNER ---
  Widget _buildSaleBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 120,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                'https://images.unsplash.com/photo-1542838132-92c53300491e?w=1200',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    Container(color: const Color(0xFF2B8A4A)),
              ),
              Container(color: primaryGreen..withValues(alpha: 0.18)),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '🌾 Harvest Season Sale',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Up to 30% off fresh produce',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => _goToPage(const MarketplaceScreen()),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: darkGreen,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: const StadiumBorder(),
                      ),
                      child: const Text(
                        'Shop Now',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 16,
                bottom: 12,
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Colors.white54,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Colors.white54,
                        shape: BoxShape.circle,
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

  // --- POPULAR CATEGORIES ---
  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Popular Categories',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: ink,
                ),
              ),
              GestureDetector(
                onTap: () => _goToPage(const CategoriesScreen()),
                child: Row(
                  children: const [
                    Text(
                      'See all',
                      style: TextStyle(
                        fontSize: 11,
                        color: primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(Icons.chevron_right, color: primaryGreen, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _categories.map((category) {
              return GestureDetector(
                onTap: () {},
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xFFE8ECE8),
                      backgroundImage: NetworkImage(category['image']!),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category['name']!,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: ink,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // --- FEATURED FARM STORES ---
  Widget _buildFeaturedStores() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Featured Farm Stores',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: ink,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: const [
                    Text(
                      'See all',
                      style: TextStyle(
                        fontSize: 11,
                        color: primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(Icons.chevron_right, color: primaryGreen, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _featuredStores.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final store = _featuredStores[index];
              return Container(
                width: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE8ECE8)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                          child: Image.network(
                            store['image'],
                            height: 60,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          bottom: -16,
                          left: 12,
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundImage: NetworkImage(
                                    store['avatar'],
                                  ),
                                ),
                              ),
                              if (store['verified'])
                                const Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF2DB05F),
                                    size: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store['name'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Color(0xFFFFB300),
                                size: 12,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                store['rating'],
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: mutedText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                color: mutedText,
                                size: 10,
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  store['location'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: mutedText,
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
            },
          ),
        ),
      ],
    );
  }

  // --- FRESHLY HARVESTED ---
  Widget _buildFreshlyHarvested() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 28, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Freshly Harvested',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: ink,
                ),
              ),
              GestureDetector(
                onTap: () => _goToPage(const MarketplaceScreen()),
                child: Row(
                  children: const [
                    Text(
                      'See all',
                      style: TextStyle(
                        fontSize: 11,
                        color: primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(Icons.chevron_right, color: primaryGreen, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sample harvest dates from configured service areas',
                style: TextStyle(fontSize: 9, color: mutedText),
              ),
              Row(
                children: const [
                  Icon(
                    Icons.notifications_active_outlined,
                    size: 12,
                    color: primaryGreen,
                  ),
                  SizedBox(width: 2),
                  Text(
                    'Alerts',
                    style: TextStyle(
                      fontSize: 9,
                      color: primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _freshProducts.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final product = _freshProducts[index];
              return Container(
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE8ECE8)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                          child: Image.network(
                            product['image'],
                            height: 90,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: primaryGreen,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.eco_outlined,
                                  color: Colors.white,
                                  size: 10,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  'Fresh',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['name'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: '₱',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: darkGreen,
                                  ),
                                ),
                                TextSpan(
                                  text: '${(product['price'] as num).toInt()}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
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
                          const SizedBox(height: 6),
                          Text(
                            product['harvestDate'],
                            style: const TextStyle(
                              fontSize: 8,
                              color: mutedText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            product['farm'],
                            style: const TextStyle(
                              fontSize: 8,
                              color: mutedText,
                              fontWeight: FontWeight.w500,
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

  // --- NEARBY FARMERS ---
  Widget _buildNearbyFarmers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Nearby Farmers',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: ink,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: const [
                    Text(
                      'See all',
                      style: TextStyle(
                        fontSize: 11,
                        color: primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(Icons.chevron_right, color: primaryGreen, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _nearbyFarmers.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final farmer = _nearbyFarmers[index];
              return Container(
                width: 180,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE8ECE8)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.near_me_outlined,
                            color: primaryGreen,
                            size: 14,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F3F1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            farmer['distance'],
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      farmer['name'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: mutedText,
                          size: 10,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          farmer['location'],
                          style: const TextStyle(fontSize: 9, color: mutedText),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${farmer['rating']} ★',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: primaryGreen,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '• ${farmer['products']}',
                          style: const TextStyle(fontSize: 9, color: mutedText),
                        ),
                      ],
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

  // --- RECOMMENDED FOR YOU ---
  Widget _buildRecommendedHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recommended for You',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: ink,
                ),
              ),
              GestureDetector(
                onTap: () => _goToPage(const MarketplaceScreen()),
                child: Row(
                  children: const [
                    Text(
                      'See all',
                      style: TextStyle(
                        fontSize: 11,
                        color: primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(Icons.chevron_right, color: primaryGreen, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Popular demo picks',
                style: TextStyle(fontSize: 9, color: mutedText),
              ),
              Text(
                'Sample data',
                style: TextStyle(
                  fontSize: 9,
                  color: orangeText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedCard(Map<String, dynamic> product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                child: Image.network(
                  product['image'],
                  height: 110,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_border,
                    size: 14,
                    color: mutedText,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: ink,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '₱${product['price']}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: primaryGreen,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  product['farm'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 8, color: mutedText),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFFFB300),
                          size: 10,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${product['rating']} (${product['reviews']})',
                          style: const TextStyle(fontSize: 8, color: mutedText),
                        ),
                      ],
                    ),
                    if (product['sold'] != null)
                      Text(
                        product['sold'],
                        style: const TextStyle(fontSize: 8, color: mutedText),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'DEMO DATA',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: orangeText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- FLOATING BOTTOM NAVIGATION ---
  Widget _buildBottomNavigation() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navItem(Icons.home_filled, 'Home', true, () {}),
          _navItem(
            Icons.grid_view_rounded,
            'Categories',
            false,
            () => _goToPage(const CategoriesScreen()),
          ),
          _navItem(
            Icons.storefront_outlined,
            'Marketplace',
            false,
            () => _goToPage(const MarketplaceScreen()),
          ),
          Consumer<NotificationProvider>(
            builder: (context, provider, _) => _navItem(
              Icons.notifications_none_rounded,
              'Notifications',
              false,
              () => _goToPage(const NotificationScreen()),
              badge: provider.unreadCount > 0 ? provider.unreadCount : 4,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                  size: 22,
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
                        '$badge',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                color: selected ? primaryGreen : const Color(0xFF929B94),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
