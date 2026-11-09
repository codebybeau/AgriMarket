import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../providers/notification_provider.dart';
import '../../services/product_catalog_service.dart';

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
  static const Color darkGreen = Color(0xFF105B31);
  static const Color pageBackground = Color(0xFFF7F9F7);
  static const Color ink = Color(0xFF17211B);
  static const Color mutedText = Color(0xFF6D776F);

  static const String defaultFarmBanner =
      'https://images.unsplash.com/photo-1542838132-92c53300491e?w=600';

  final TextEditingController _searchController = TextEditingController();
  final SupabaseClient _supabase = Supabase.instance.client;

  String _searchQuery = '';

  late final PageController _bannerPageController;
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;

  bool _isLoadingProducts = true;
  bool _isLoadingFarmers = true;

  String? _productError;
  String? _farmerError;

  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _farmerStores = [];

  final List<Map<String, dynamic>> _saleBanners = [
    {
      'title': '🌾 Harvest Season Sale',
      'subtitle': 'Discover fresh produce from local farmers',
      'buttonText': 'Shop Now',
      'image':
          'https://images.unsplash.com/photo-1542838132-92c53300491e?w=1200',
    },
    {
      'title': '🌽 Direct From Farmers',
      'subtitle': 'Explore products from local farms',
      'buttonText': 'Explore',
      'image':
          'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=1200',
    },
    {
      'title': '📦 Wholesale & Bulk Deals',
      'subtitle': 'Find products for your bulk orders',
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

  @override
  void initState() {
    super.initState();

    _bannerPageController = PageController();

    _startBannerAutoScroll();

    _loadProducts();
    _loadFarmers();
  }

  // --------------------------------------------------
  // LOAD PRODUCTS
  // --------------------------------------------------

  Future<void> _loadProducts() async {
    if (!mounted) return;

    setState(() {
      _isLoadingProducts = true;
      _productError = null;
    });

    try {
      final result = await ProductCatalogService().fetchActiveProducts();

      final liveProducts = result.map((product) {
        final rawUnit = (product['unit_name'] ?? 'unit').toString().trim();

        final unit = rawUnit.startsWith('/') ? rawUnit.substring(1) : rawUnit;

        final images = product['images'];

        String imageUrl = product['image_url']?.toString() ?? '';

        if (imageUrl.isEmpty && images is List && images.isNotEmpty) {
          imageUrl = images.first.toString();
        }

        final price = product['price'];

        return <String, dynamic>{
          'id': product['id'],
          'seller_id': product['seller_id'],
          'name': product['name']?.toString() ?? 'Unnamed Product',
          'price': price is num ? price.toDouble() : 0.0,
          'unit': unit,
          'stock_quantity': product['stock_quantity'] is num
              ? (product['stock_quantity'] as num).toInt()
              : 0,
          'image_url': imageUrl,
          'description': product['description']?.toString() ?? '',
          'category_name':
              product['category_name']?.toString() ?? 'Uncategorized',
          'farm_name':
              product['farm_name']?.toString() ??
              product['farmer_name']?.toString() ??
              'Local Farmer',
          'farmer_name': product['farmer_name']?.toString() ?? 'Local Farmer',
          'farm_origin':
              product['farm_origin']?.toString() ?? 'Location not provided',
          'farmer_bio': product['farmer_bio']?.toString() ?? '',
          'farmer_contact': product['farmer_contact']?.toString() ?? '',
          'farmer_avatar': product['farmer_avatar']?.toString() ?? '',
          'is_organic': product['is_organic'] == true,
          'delivery_details': product['delivery_details']?.toString() ?? '',
          'isDemo': false,
        };
      }).toList();

      if (!mounted) return;

      setState(() {
        _products = liveProducts;
        _isLoadingProducts = false;
      });
    } catch (error, stackTrace) {
      debugPrint('Home product loading error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _products = [];
        _isLoadingProducts = false;
        _productError = error.toString();
      });
    }
  }

  // --------------------------------------------------
  // LOAD FARMER STORES DIRECTLY FROM SUPABASE
  // --------------------------------------------------

  Future<void> _loadFarmers() async {
    if (!mounted) return;

    setState(() {
      _isLoadingFarmers = true;
      _farmerError = null;
    });

    try {
      final response = await _supabase
          .from('farmer_profiles')
          .select(
            'user_id, full_name, farm_name, farm_origin, avatar_url, banner_url',
          )
          .order('farm_name');

      final farmers = List<Map<String, dynamic>>.from(response);

      final productCounts = <String, int>{};

      // Product counts are optional. A count-query failure
      // should not prevent farmer profiles from appearing.
      try {
        final activeProducts = await _supabase
            .from('products')
            .select('seller_id')
            .eq('status', 'active');

        for (final product in activeProducts) {
          final sellerId = product['seller_id']?.toString() ?? '';

          if (sellerId.isEmpty) continue;

          productCounts[sellerId] = (productCounts[sellerId] ?? 0) + 1;
        }
      } catch (error) {
        debugPrint('Product count loading error: $error');
      }

      final stores = farmers
          .map((farmer) {
            final sellerId = farmer['user_id']?.toString() ?? '';

            final farmName = farmer['farm_name']?.toString().trim() ?? '';
            final farmerName = farmer['full_name']?.toString().trim() ?? '';
            final farmOrigin = farmer['farm_origin']?.toString().trim() ?? '';
            final avatar = farmer['avatar_url']?.toString().trim() ?? '';
            final banner = farmer['banner_url']?.toString().trim() ?? '';

            return <String, dynamic>{
              'seller_id': sellerId,
              'name': farmName.isNotEmpty ? farmName : 'Local Farmer',
              'farmer_name': farmerName.isNotEmpty ? farmerName : 'Farmer',
              'location': farmOrigin.isNotEmpty
                  ? farmOrigin
                  : 'Location not provided',
              'avatar': avatar,
              'banner_url': banner,
              'product_count': productCounts[sellerId] ?? 0,
            };
          })
          .where((store) {
            return (store['seller_id'] as String).isNotEmpty;
          })
          .toList();

      if (!mounted) return;

      setState(() {
        _farmerStores = stores;
        _isLoadingFarmers = false;
      });

      debugPrint('Loaded ${stores.length} farmer stores.');
    } catch (error, stackTrace) {
      debugPrint('Farmer store loading error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _farmerStores = [];
        _isLoadingFarmers = false;
        _farmerError = error.toString();
      });
    }
  }

  // --------------------------------------------------
  // SEARCH AND FARMER GETTERS
  // --------------------------------------------------

  List<Map<String, dynamic>> get _visibleProducts {
    if (_searchQuery.trim().isEmpty) {
      return _products;
    }

    final query = _searchQuery.toLowerCase().trim();

    return _products.where((product) {
      final name = product['name'].toString().toLowerCase();
      final farm = product['farm_name'].toString().toLowerCase();
      final category = product['category_name'].toString().toLowerCase();
      final origin = product['farm_origin'].toString().toLowerCase();

      return name.contains(query) ||
          farm.contains(query) ||
          category.contains(query) ||
          origin.contains(query);
    }).toList();
  }

  List<Map<String, dynamic>> get _farmers => _farmerStores;

  String _productImage(Map<String, dynamic> product) {
    final image = product['image_url']?.toString().trim() ?? '';

    if (image.isNotEmpty) {
      return image;
    }

    return defaultFarmBanner;
  }

  // Gets the farmer's own saved banner URL.
  // Uses the default image only if the farmer has no banner.
  String _getFarmBanner(Map<String, dynamic> farmer) {
    final banner = farmer['banner_url']?.toString().trim() ?? '';

    return banner.isNotEmpty ? banner : defaultFarmBanner;
  }

  // --------------------------------------------------
  // NAVIGATION
  // --------------------------------------------------

  void _goToPage(Widget page) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  void _openFarmDetails({
    required String sellerId,
    required String farmName,
    required String location,
    String? avatarUrl,
    String? bannerUrl,
  }) {
    if (sellerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open this farm. Farmer ID is missing.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FarmDetailsScreen(
          sellerId: sellerId,
          farmName: farmName,
          location: location,
          rating: '0.0',
          reviewCount: '0',
          avatarUrl: avatarUrl ?? '',
          bannerUrl: bannerUrl?.trim().isNotEmpty == true
              ? bannerUrl!.trim()
              : defaultFarmBanner,
        ),
      ),
    ).then((_) {
      if (mounted) {
        _loadFarmers();
      }
    });
  }

  void _openProductDetails(Map<String, dynamic> product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(
          title: product['name']?.toString() ?? 'Product',
          price: (product['price'] as num?)?.toDouble() ?? 0,
          unit: product['unit']?.toString() ?? 'unit',
          imageUrl: _productImage(product),
          productId: (product['id'] as num?)?.toInt(),
          sellerId: product['seller_id']?.toString(),
          stockQuantity: (product['stock_quantity'] as num?)?.toInt() ?? 0,
          description: product['description']?.toString() ?? '',
          category: product['category_name']?.toString() ?? 'Uncategorized',
          farmName: product['farm_name']?.toString() ?? 'Local Farmer',
          farmOrigin:
              product['farm_origin']?.toString() ?? 'Location not provided',
          isOrganic: product['is_organic'] == true,
          deliveryDetails: product['delivery_details']?.toString() ?? '',
        ),
      ),
    );
  }

  void _startBannerAutoScroll() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!_bannerPageController.hasClients) return;

      final nextIndex = (_currentBannerIndex + 1) % _saleBanners.length;

      _bannerPageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerPageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // --------------------------------------------------
  // MAIN SCREEN
  // --------------------------------------------------

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
                SliverToBoxAdapter(child: _buildFreshlyHarvested()),
                SliverToBoxAdapter(child: _buildFeaturedStores()),
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
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return _buildRecommendedCard(_visibleProducts[index]);
                    }, childCount: _visibleProducts.length),
                  ),
                ),
                if (_visibleProducts.isEmpty)
                  SliverToBoxAdapter(child: _buildEmptyProducts()),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNavigation(),
      ),
    );
  }

  // --------------------------------------------------
  // HEADER
  // --------------------------------------------------

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
              const Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Explore Local Farms',
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
                  badge: provider.unreadCount,
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
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
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
                          setState(() {
                            _searchQuery = '';
                          });
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
          color: Colors.white.withValues(alpha: 0.18),
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

  // --------------------------------------------------
  // SALE BANNER
  // --------------------------------------------------

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
                  setState(() {
                    _currentBannerIndex = index;
                  });
                },
                itemCount: _saleBanners.length,
                itemBuilder: (context, index) {
                  final banner = _saleBanners[index];

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        banner['image'] as String,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) {
                          return Container(color: const Color(0xFF2B8A4A));
                        },
                      ),
                      Container(color: primaryGreen.withValues(alpha: 0.22)),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              banner['title'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              banner['subtitle'] as String,
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
                                banner['buttonText'] as String,
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

  // --------------------------------------------------
  // CATEGORIES
  // --------------------------------------------------

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
                      backgroundImage: NetworkImage(
                        category['image'] as String,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category['name'] as String,
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

  // --------------------------------------------------
  // FEATURED FARM STORES
  // --------------------------------------------------

  Widget _buildFeaturedStores() {
    final farmers = _farmers;

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

        if (_isLoadingFarmers)
          _sectionMessage('Loading farmer stores...')
        else if (_farmerError != null)
          _sectionMessage(
            'Unable to load farmer stores.',
            onRetry: _loadFarmers,
          )
        else if (farmers.isEmpty)
          _sectionMessage('No farmer stores available yet.')
        else
          SizedBox(
            height: 165,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: farmers.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final farmer = farmers[index];

                final sellerId = farmer['seller_id']?.toString() ?? '';

                final farmName = farmer['name']?.toString() ?? 'Local Farmer';

                final location =
                    farmer['location']?.toString() ?? 'Location not provided';

                final avatar = farmer['avatar']?.toString().trim() ?? '';

                final banner = _getFarmBanner(farmer);

                return SizedBox(
                  width: 155,
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => _openFarmDetails(
                        sellerId: sellerId,
                        farmName: farmName,
                        location: location,
                        avatarUrl: avatar,
                        bannerUrl: banner,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(
                            banner,
                            height: 65,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                _farmPlaceholder(height: 65),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(9),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: avatar.isNotEmpty
                                      ? Image.network(
                                          avatar,
                                          width: 35,
                                          height: 35,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) =>
                                              _farmAvatarPlaceholder(),
                                        )
                                      : _farmAvatarPlaceholder(),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        farmName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: ink,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        location,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 9,
                                          color: mutedText,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        '${farmer['product_count']} products',
                                        style: const TextStyle(
                                          fontSize: 9,
                                          color: primaryGreen,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
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
              },
            ),
          ),
      ],
    );
  }

  Widget _farmAvatarPlaceholder() {
    return Container(
      width: 35,
      height: 35,
      color: const Color(0xFFE8F0E7),
      child: const Icon(Icons.person, color: primaryGreen, size: 22),
    );
  }

  // --------------------------------------------------
  // FRESHLY HARVESTED
  // --------------------------------------------------

  Widget _buildFreshlyHarvested() {
    final products = _visibleProducts;

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
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Products published by farmers',
                style: TextStyle(fontSize: 9, color: mutedText),
              ),
              if (!_isLoadingProducts)
                Text(
                  '${products.length} products',
                  style: const TextStyle(
                    fontSize: 9,
                    color: primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        if (_isLoadingProducts)
          _sectionMessage('Loading farmer products...')
        else if (products.isEmpty)
          _sectionMessage(
            _productError != null
                ? 'Unable to load products. Please try again.'
                : 'No active farmer products available yet.',
            onRetry: _loadProducts,
          )
        else
          SizedBox(
            height: 200,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return _buildFreshProductCard(products[index]);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildFreshProductCard(Map<String, dynamic> product) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECE8)),
      ),
      child: InkWell(
        onTap: () => _openProductDetails(product),
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
                    _productImage(product),
                    height: 90,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _productPlaceholder(),
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
                        Icon(Icons.eco_outlined, color: Colors.white, size: 10),
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
                    product['name'].toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₱${(product['price'] as num).toStringAsFixed(2)} / ${product['unit']}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: darkGreen,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product['farm_name'].toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 8,
                      color: primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${product['stock_quantity']} ${product['unit']} available',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 8, color: mutedText),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // RECOMMENDED PRODUCTS
  // --------------------------------------------------

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
          const Text(
            'Explore available products from farmers',
            style: TextStyle(fontSize: 9, color: mutedText),
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
        onTap: () => _openProductDetails(product),
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
                    _productImage(product),
                    height: 110,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _productPlaceholder(),
                  ),
                ),
                if (product['is_organic'] == true)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: primaryGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'ORGANIC',
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
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'].toString(),
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
                    '₱${(product['price'] as num).toStringAsFixed(2)} / ${product['unit']}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product['farm_name'].toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 8,
                      color: primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${product['stock_quantity']} ${product['unit']} available',
                    style: const TextStyle(fontSize: 8, color: mutedText),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // EMPTY / LOADING STATES
  // --------------------------------------------------

  Widget _buildEmptyProducts() {
    if (_isLoadingProducts) {
      return const Padding(
        padding: EdgeInsets.all(30),
        child: Center(child: CircularProgressIndicator(color: primaryGreen)),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 24),
      child: Column(
        children: [
          const Icon(Icons.inventory_2_outlined, size: 42, color: Colors.grey),
          const SizedBox(height: 10),
          Text(
            _searchQuery.isNotEmpty
                ? 'No products match your search.'
                : 'No active products available yet.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: mutedText, fontSize: 12),
          ),
          if (_searchQuery.isNotEmpty)
            TextButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
              child: const Text('Clear search'),
            ),
          if (_productError != null)
            TextButton.icon(
              onPressed: _loadProducts,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
        ],
      ),
    );
  }

  Widget _sectionMessage(String message, {VoidCallback? onRetry}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 11, color: mutedText),
            ),
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _farmPlaceholder({double height = 60}) {
    return Container(
      height: height,
      width: double.infinity,
      color: const Color(0xFFE8F0E7),
      child: const Icon(Icons.agriculture, color: primaryGreen, size: 28),
    );
  }

  Widget _productPlaceholder() {
    return Container(
      height: 110,
      width: double.infinity,
      color: const Color(0xFFE8F0E7),
      child: const Icon(Icons.eco, color: primaryGreen, size: 32),
    );
  }

  // --------------------------------------------------
  // BOTTOM NAVIGATION
  // --------------------------------------------------

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
