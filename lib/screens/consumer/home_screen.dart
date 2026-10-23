import 'dart:async';
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
import 'product_details_screen.dart';
import 'farm_details_screen.dart';

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
  static const Color darkGreen = Color(0xFF0D4B27);
  static const Color pageBackground = Color(0xFFF7F9F7);
  static const Color ink = Color(0xFF17211B);
  static const Color mutedText = Color(0xFF6D776F);
  static const Color orangeText = Color(0xFFE67E22);

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Overlay Advertisement State
  bool _showAdOverlay = true;

  // Banner Auto-Scroll Variables
  late final PageController _bannerPageController;
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;

  final List<Map<String, dynamic>> _saleBanners = [
    {
      'title': '🌾 Harvest Season Sale',
      'subtitle': 'Up to 30% off fresh produce',
      'buttonText': 'Shop Now',
      'image':
          'https://images.unsplash.com/photo-1542838132-92c53300491e?w=1200',
    },
    {
      'title': '🌽 Direct From Farmers',
      'subtitle': '100% fresh from local farms',
      'buttonText': 'Explore',
      'image':
          'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=1200',
    },
    {
      'title': '📦 Wholesale & Bulk Deals',
      'subtitle': 'Special rates for bulk orders',
      'buttonText': 'View Deals',
      'image':
          'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=1200',
    },
  ];

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
      'location': 'Benguet, CAR',
      'rating': '4.8',
      'reviews': '892',
      'image':
          'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=600',
      'avatar':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      'verified': true,
    },
    {
      'name': 'Guimaras Harvest',
      'location': 'Guimaras, Visayas',
      'rating': '4.9',
      'reviews': '512',
      'image':
          'https://images.unsplash.com/photo-1550989460-0adf9ea622e2?w=600',
      'avatar':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
      'verified': true,
    },
    {
      'name': 'Nueva Ecija Grains',
      'location': 'Nueva Ecija, Central Luzon',
      'rating': '4.6',
      'reviews': '340',
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
      'location': 'Benguet, CAR',
      'image':
          'https://images.unsplash.com/photo-1546094096-0df4bcaaa337?w=600',
    },
    {
      'name': 'Fresh Pechay Bundle',
      'price': 45.00,
      'unit': '/bundle',
      'harvestDate': 'Harvested May 28, 2025',
      'farm': 'Pangasinan Greens',
      'location': 'Pangasinan',
      'image':
          'https://images.unsplash.com/photo-1515471209610-dae1c92d877f?w=600',
    },
    {
      'name': 'Carabao Mango',
      'price': 180.00,
      'unit': '/kg',
      'harvestDate': 'Harvested May 26, 2025',
      'farm': 'Guimaras Harvest',
      'location': 'Guimaras',
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
      'reviews': '142',
      'products': '18 products',
    },
    {
      'name': 'Kabacan Harvest Hub',
      'location': 'Kabacan',
      'distance': '8.7 km',
      'rating': '4.7',
      'reviews': '98',
      'products': '12 products',
    },
  ];

  final List<Map<String, dynamic>> _recommendedProducts = [
    {
      'name': 'Fresh Eggs (Native/Itlog na Manok)',
      'price': 12.0,
      'farm': 'Pampanga Poultry Farm',
      'rating': '4.9',
      'reviews': '1024',
      'image':
          'https://images.unsplash.com/photo-1598514982205-f36b96d1e8dd?w=600',
    },
    {
      'name': 'Dinorado Rice (Premium)',
      'price': 68.0,
      'farm': 'Nueva Ecija Grains',
      'rating': '4.6',
      'reviews': '890',
      'image':
          'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=600',
    },
    {
      'name': 'Carabao Mango (Export Quality)',
      'price': 180.0,
      'farm': 'Guimaras Harvest Co.',
      'rating': '4.9',
      'reviews': '512',
      'image':
          'https://images.unsplash.com/photo-1553279768-865429fa0078?w=600',
    },
    {
      'name': 'Harvesting Sickle Set',
      'price': 480.0,
      'farm': 'AgroTools PH Demo',
      'rating': '4.9',
      'reviews': '157',
      'sold': '447 sold',
      'image':
          'https://images.unsplash.com/photo-1592982537447-6f296b02a220?w=600',
    },
  ];

  @override
  void initState() {
    super.initState();
    _bannerPageController = PageController();
    _startBannerAutoScroll();
  }

  void _startBannerAutoScroll() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerPageController.hasClients) {
        final nextIndex = (_currentBannerIndex + 1) % _saleBanners.length;
        _bannerPageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerPageController.dispose();
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

  void _openFarmDetails({
    required String farmName,
    required String location,
    String rating = '4.8',
    String reviewCount = '892',
    String? avatarUrl,
    String? bannerUrl,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FarmDetailsScreen(
          farmName: farmName,
          location: location,
          rating: rating,
          reviewCount: reviewCount,
          avatarUrl: avatarUrl ??
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
          bannerUrl: bannerUrl ??
              'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=600',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: pageBackground,
            extendBody: true,
            body: SafeArea(
              top: false,
              bottom: false,
              child: Column(
                children: [
                  // Pinned Sticky Header
                  _buildHeader(),
                  // Scrollable Body Content
                  Expanded(
                    child: ScrollConfiguration(
                      behavior: const NoStretchScrollBehavior(),
                      child: CustomScrollView(
                        physics: const ClampingScrollPhysics(),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        slivers: [
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
                                mainAxisExtent: 250,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => _buildRecommendedCard(
                                    _recommendedProducts[index]),
                                childCount: _recommendedProducts.length,
                              ),
                            ),
                          ),

                          const SliverToBoxAdapter(child: SizedBox(height: 120)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: _buildBottomNavigation(),
          ),

          // --- AGRIMART OVERLAY ADVERTISEMENT (OVERLAYS ENTIRE SCREEN & BOTBAR) ---
          if (_showAdOverlay) _buildAdOverlay(),
        ],
      ),
    );
  }

  // --- AGRIMART POPUP OVERLAY ADVERTISEMENT ---
  Widget _buildAdOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.65),
      padding: const EdgeInsets.symmetric(horizontal: 28),
      alignment: Alignment.center,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main Ad Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Image Header with Gradient Overlay
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child: Stack(
                      children: [
                        Image.network(
                          'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=800',
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            height: 160,
                            color: primaryGreen,
                            child: const Center(
                              child: Icon(Icons.eco,
                                  size: 60, color: Colors.white),
                            ),
                          ),
                        ),
                        Container(
                          height: 160,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                darkGreen.withValues(alpha: 0.85),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          bottom: 12,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: orangeText,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'EXCLUSIVE OFFER',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'AgriMart Mega Fresh Pass',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'GET ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: ink,
                              ),
                            ),
                            Text(
                              '20% OFF',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: primaryGreen,
                              ),
                            ),
                            const Text(
                              ' YOUR FIRST ORDER',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: ink,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Direct farm produce delivered straight to your door. Use promo code on checkout.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: mutedText,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Promo Code Box
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F7F2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: primaryGreen.withValues(alpha: 0.3),
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.confirmation_number_outlined,
                                    color: primaryGreen,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Code: AGRI20',
                                    style: TextStyle(
                                      color: darkGreen,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(
                                    const ClipboardData(text: 'AGRI20'),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Promo code copied!'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'COPY',
                                  style: TextStyle(
                                    color: primaryGreen,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Action Button
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() => _showAdOverlay = false);
                              _goToPage(const MarketplaceScreen());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Claim Voucher & Shop Now',
                              style: TextStyle(
                                fontSize: 13,
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
            ),

            // Top Close Button (X)
            Positioned(
              right: -10,
              top: -10,
              child: GestureDetector(
                onTap: () => setState(() => _showAdOverlay = false),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 18,
                    color: ink,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- GRADIENT FARM HEADER ---
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [darkGreen, primaryGreen, Color(0xFF1E824C)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 12,
        16,
        16,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search,
                    color: Color(0xFF88968C),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      textInputAction: TextInputAction.search,
                      style: const TextStyle(
                        fontSize: 13,
                        color: ink,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Organic Fertilizers & Seeds',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: orangeText,
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      child: const Icon(
                        Icons.close,
                        color: mutedText,
                        size: 18,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Cart Icon with Badge
          _headerIcon(
            icon: Icons.shopping_cart_outlined,
            badgeText: '97',
            onTap: () => _goToPage(const CartScreen()),
          ),

          const SizedBox(width: 8),

          // Chat Icon with Badge
          Consumer<NotificationProvider>(
            builder: (context, provider, _) => _headerIcon(
              icon: Icons.chat_bubble_outline_rounded,
              badgeText: provider.unreadCount > 0
                  ? '${provider.unreadCount}'
                  : '12',
              onTap: () => _goToPage(const MessagesScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerIcon({
    required IconData icon,
    required String badgeText,
    required VoidCallback onTap,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        if (badgeText.isNotEmpty)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFFFF3D4F),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 14,
              ),
              child: Text(
                badgeText,
                textAlign: TextAlign.center,
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
    );
  }

  // --- AUTOMATIC HORIZONTAL SALE BANNER CAROUSEL ---
  Widget _buildSaleBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 120,
          child: Stack(
            children: [
              PageView.builder(
                controller: _bannerPageController,
                onPageChanged: (index) {
                  setState(() => _currentBannerIndex = index);
                },
                itemCount: _saleBanners.length,
                itemBuilder: (context, index) {
                  final banner = _saleBanners[index];
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        banner['image'],
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: const Color(0xFF2B8A4A),
                        ),
                      ),
                      Container(color: primaryGreen.withValues(alpha: 0.22)),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              banner['title'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              banner['subtitle'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () =>
                                  _goToPage(const MarketplaceScreen()),
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
                              child: Text(
                                banner['buttonText'],
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              Positioned(
                right: 16,
                bottom: 12,
                child: Row(
                  children: List.generate(
                    _saleBanners.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(left: 4),
                      width: _currentBannerIndex == index ? 16 : 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: _currentBannerIndex == index
                            ? Colors.white
                            : Colors.white54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
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
                child: const Row(
                  children: [
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
                onTap: () => _goToPage(const CategoriesScreen()),
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
                onTap: () => _goToPage(const MarketplaceScreen()),
                child: const Row(
                  children: [
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
                child: InkWell(
                  onTap: () => _openFarmDetails(
                    farmName: store['name'],
                    location: store['location'],
                    rating: store['rating'],
                    reviewCount: store['reviews'] ?? '892',
                    avatarUrl: store['avatar'],
                    bannerUrl: store['image'],
                  ),
                  borderRadius: BorderRadius.circular(16),
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
                              errorBuilder: (_, _, _) => Container(
                                color: const Color(0xFFE8F0E7),
                                child: const Icon(Icons.store,
                                    color: primaryGreen, size: 24),
                              ),
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
                child: const Row(
                  children: [
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
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sample harvest dates from configured service areas',
                style: TextStyle(fontSize: 9, color: mutedText),
              ),
              Row(
                children: [
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
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailsScreen(
                          title: product['name'],
                          price: (product['price'] as num).toDouble(),
                          unit: (product['unit'] as String).replaceAll('/', ''),
                          imageUrl: product['image'],
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
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
                              errorBuilder: (_, _, _) => Container(
                                color: const Color(0xFFE8F0E7),
                                child: const Icon(Icons.eco,
                                    color: primaryGreen, size: 28),
                              ),
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
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
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
                            GestureDetector(
                              onTap: () => _openFarmDetails(
                                farmName: product['farm'],
                                location: product['location'] ?? 'Philippines',
                              ),
                              child: Text(
                                product['farm'],
                                style: const TextStyle(
                                  fontSize: 8,
                                  color: primaryGreen,
                                  fontWeight: FontWeight.bold,
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
                onTap: () => _goToPage(const MarketplaceScreen()),
                child: const Row(
                  children: [
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
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE8ECE8)),
                ),
                child: InkWell(
                  onTap: () => _openFarmDetails(
                    farmName: farmer['name'],
                    location: farmer['location'],
                    rating: farmer['rating'],
                    reviewCount: farmer['reviews'] ?? '142',
                  ),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
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
                              style: const TextStyle(
                                  fontSize: 9, color: mutedText),
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
                              style: const TextStyle(
                                  fontSize: 9, color: mutedText),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
                child: const Row(
                  children: [
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
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(
                title: product['name'],
                price: (product['price'] as num).toDouble(),
                imageUrl: product['image'],
              ),
            ),
          );
        },
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
                    errorBuilder: (_, _, _) => Container(
                      color: const Color(0xFFE8F0E7),
                      child: const Icon(Icons.eco,
                          color: primaryGreen, size: 32),
                    ),
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
                  GestureDetector(
                    onTap: () => _openFarmDetails(
                      farmName: product['farm'],
                      location: 'Philippines',
                    ),
                    child: Text(
                      product['farm'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 8,
                        color: primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                            style: const TextStyle(
                                fontSize: 8, color: mutedText),
                          ),
                        ],
                      ),
                      if (product['sold'] != null)
                        Text(
                          product['sold'],
                          style:
                              const TextStyle(fontSize: 8, color: mutedText),
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
      ),
    );
  }

  // --- FLOATING BOTTOM NAVIGATION ---
  Widget _buildBottomNavigation() {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      margin: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: bottomInset > 0 ? bottomInset + 8 : 16,
      ),
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
                          '$badge',
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