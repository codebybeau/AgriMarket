import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../providers/notification_provider.dart';
import '../../services/product_catalog_service.dart';
import 'cart_screen.dart';
import 'messages_screen.dart';
import 'product_details_screen.dart';

class FarmDetailsScreen extends StatefulWidget {
  final String? sellerId;

  final String farmName;
  final String location;
  final String rating;
  final String reviewCount;
  final String avatarUrl;
  final String bannerUrl;
  final bool isVerified;
  final int productsCount;
  final String followersCount;
  final int followingCount;
  final String bio;
  final String contactNumber;

  const FarmDetailsScreen({
    super.key,
    this.sellerId,
    this.farmName = 'Farm',
    this.location = 'Location not provided',
    this.rating = 'N/A',
    this.reviewCount = '0',
    this.avatarUrl = '',
    this.bannerUrl = '',
    this.isVerified = false,
    this.productsCount = 0,
    this.followersCount = '0',
    this.followingCount = 0,
    this.bio = '',
    this.contactNumber = '',
  });

  @override
  State<FarmDetailsScreen> createState() => _FarmDetailsScreenState();
}

class _FarmDetailsScreenState extends State<FarmDetailsScreen> {
  static const Color primaryGreen = Color(0xFF176B3A);
  static const Color darkGreen = Color(0xFF105B31);
  static const Color pageBackground = Color(0xFFF7F9F7);
  static const Color ink = Color(0xFF17211B);
  static const Color mutedText = Color(0xFF6D776F);

  static const String defaultFarmBanner =
      'https://images.unsplash.com/photo-1542838132-92c53300491e?w=600';

  final SupabaseClient _supabase = Supabase.instance.client;
  final ProductCatalogService _productService = ProductCatalogService();

  bool _isLoading = true;
  int _selectedTabIndex = 0;

  String? _loadError;

  Map<String, dynamic>? _farmerProfile;
  List<Map<String, dynamic>> _farmProducts = [];

  @override
  void initState() {
    super.initState();
    _loadFarmDetails();
  }

  // ==============================================
  // LOAD FARMER PROFILE AND PRODUCTS
  // ==============================================

  Future<void> _loadFarmDetails() async {
    final sellerId = widget.sellerId;

    if (sellerId == null || sellerId.isEmpty) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _loadError = 'Farmer information is unavailable.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final Map<String, dynamic>? profile = await _supabase
          .from('farmer_profiles')
          .select(
            'user_id, full_name, farm_name, farm_origin, bio, '
            'contact_number, avatar_url, banner_url',
          )
          .eq('user_id', sellerId)
          .maybeSingle();

      final List<Map<String, dynamic>> products = await _productService
          .fetchFarmerProducts(sellerId);

      if (!mounted) return;

      setState(() {
        _farmerProfile = profile;
        _farmProducts = products;
        _isLoading = false;
        _loadError = null;
      });
    } catch (error) {
      debugPrint('Farm details loading error: $error');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _loadError = 'Unable to load farm details. Please try again.';
      });
    }
  }

  // ==============================================
  // FARMER PROFILE GETTERS
  // ==============================================

  String get _displayFarmName {
    final value = _farmerProfile?['farm_name'];

    return value?.toString().trim().isNotEmpty == true
        ? value.toString()
        : widget.farmName;
  }

  String get _displayFarmerName {
    final value = _farmerProfile?['full_name'];

    return value?.toString().trim().isNotEmpty == true
        ? value.toString()
        : 'Farmer';
  }

  String get _displayLocation {
    final value = _farmerProfile?['farm_origin'];

    return value?.toString().trim().isNotEmpty == true
        ? value.toString()
        : widget.location;
  }

  String get _displayBio {
    final value = _farmerProfile?['bio'];

    return value?.toString().trim().isNotEmpty == true
        ? value.toString()
        : widget.bio;
  }

  String get _displayAvatar {
    final value = _farmerProfile?['avatar_url'];

    return value?.toString().trim().isNotEmpty == true
        ? value.toString().trim()
        : widget.avatarUrl.trim();
  }

  // DATABASE BANNER FIRST, HOME SCREEN BANNER SECOND,
  // DEFAULT BANNER LAST.
  String get _displayBanner {
    final profileBanner =
        _farmerProfile?['banner_url']?.toString().trim() ?? '';

    if (profileBanner.isNotEmpty) {
      return profileBanner;
    }

    final passedBanner = widget.bannerUrl.trim();

    if (passedBanner.isNotEmpty) {
      return passedBanner;
    }

    return defaultFarmBanner;
  }

  String get _displayContact {
    final value = _farmerProfile?['contact_number'];

    return value?.toString().trim().isNotEmpty == true
        ? value.toString()
        : widget.contactNumber;
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

  // ==============================================
  // MAIN BUILD
  // ==============================================

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: pageBackground,
        body: RefreshIndicator(
          color: primaryGreen,
          onRefresh: _loadFarmDetails,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildHeaderBanner(),
                _buildStatsRow(),
                _buildActionButtons(),
                _buildTabSection(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==============================================
  // HEADER BANNER
  // ==============================================

  Widget _buildHeaderBanner() {
    final banner = _displayBanner;

    return Stack(
      children: [
        // FARM BANNER
        Container(
          height: 220,
          width: double.infinity,
          color: const Color(0xFFE8F0E7),
          child: Image.network(
            banner,
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) {
              return Container(
                color: const Color(0xFFE8F0E7),
                child: const Center(
                  child: Icon(
                    Icons.agriculture_outlined,
                    color: primaryGreen,
                    size: 55,
                  ),
                ),
              );
            },
          ),
        ),

        // DARK GRADIENT
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.4),
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
        ),

        // TOP NAVIGATION BUTTONS
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _circularIconButton(
                Icons.arrow_back,
                onTap: () => Navigator.pop(context),
              ),
              Row(
                children: [
                  Consumer<NotificationProvider>(
                    builder: (context, provider, _) => _circularIconButton(
                      Icons.chat_bubble_outline_rounded,
                      badge: provider.unreadCount,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MessagesScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  _circularIconButton(
                    Icons.share_outlined,
                    onTap: () =>
                        _showMessage('Farm sharing is not available yet.'),
                  ),
                  const SizedBox(width: 8),
                  Consumer<NotificationProvider>(
                    builder: (context, provider, _) => _circularIconButton(
                      Icons.shopping_cart_outlined,
                      badge: 0,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CartScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // FARMER IDENTITY
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: _displayAvatar.isNotEmpty
                      ? Image.network(
                          _displayAvatar,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _avatarFallback(),
                        )
                      : _avatarFallback(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _displayFarmName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(color: Colors.black45, blurRadius: 4),
                              ],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.isVerified) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF2DB05F),
                            size: 18,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _displayFarmerName,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Colors.white70,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            _displayLocation,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
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
      ],
    );
  }

  Widget _avatarFallback() {
    return Container(
      width: 64,
      height: 64,
      color: primaryGreen,
      child: const Icon(Icons.person, color: Colors.white, size: 32),
    );
  }

  Widget _circularIconButton(
    IconData icon, {
    required VoidCallback onTap,
    int badge = 0,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.white,
          shape: const CircleBorder(),
          elevation: 2,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(icon, size: 18, color: ink),
            ),
          ),
        ),
        if (badge > 0)
          Positioned(
            right: -2,
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
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ==============================================
  // FARM STATISTICS
  // ==============================================

  Widget _buildStatsRow() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statItem(_isLoading ? '...' : '${_farmProducts.length}', 'Products'),
          _verticalDivider(),
          _statItem('—', 'Reviews'),
          _verticalDivider(),
          _statItem('—', 'Followers'),
          _verticalDivider(),
          _statItem('—', 'Following'),
        ],
      ),
    );
  }

  Widget _statItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: mutedText)),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(height: 20, width: 1, color: const Color(0xFFEFEFEF));
  }

  // ==============================================
  // FOLLOW AND MESSAGE BUTTONS
  // ==============================================

  Widget _buildActionButtons() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                _showMessage(
                  'Farm following will be available when the follow feature is implemented.',
                );
              },
              icon: const Icon(Icons.eco_outlined, size: 18),
              label: const Text(
                'Follow Farm',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MessagesScreen()),
                );
              },
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
              label: const Text(
                'Message',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryGreen,
                side: const BorderSide(color: primaryGreen, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================
  // TABS
  // ==============================================

  Widget _buildTabSection() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _tabHeaderItem(
                0,
                'Products (${_isLoading ? '...' : _farmProducts.length})',
              ),
              _tabHeaderItem(1, 'About'),
              _tabHeaderItem(2, 'Reviews'),
            ],
          ),
          const Divider(height: 1, color: Color(0xFFEFEFEF)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _selectedTabIndex == 0
                ? _buildProductsGrid()
                : _selectedTabIndex == 1
                ? _buildAboutTab()
                : _buildReviewsTab(),
          ),
        ],
      ),
    );
  }

  Widget _tabHeaderItem(int index, String label) {
    final isSelected = _selectedTabIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? primaryGreen : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? primaryGreen : mutedText,
            ),
          ),
        ),
      ),
    );
  }

  // ==============================================
  // FARM PRODUCTS
  // ==============================================

  Widget _buildProductsGrid() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator(color: primaryGreen)),
      );
    }

    if (_loadError != null) {
      return Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 36, color: mutedText),
            const SizedBox(height: 8),
            Text(
              _loadError!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: mutedText, fontSize: 12),
            ),
            TextButton(
              onPressed: _loadFarmDetails,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_farmProducts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.inventory_2_outlined, size: 40, color: mutedText),
              SizedBox(height: 8),
              Text(
                'No active products yet.',
                style: TextStyle(color: mutedText, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 260,
      ),
      itemCount: _farmProducts.length,
      itemBuilder: (context, index) {
        return _buildProductCard(_farmProducts[index]);
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final int? productId = (product['id'] as num?)?.toInt();

    final double price = (product['price'] as num?)?.toDouble() ?? 0;

    final String title = product['name']?.toString() ?? 'Product';

    final String unit = product['unit_name']?.toString() ?? 'unit';

    final String image = product['image_url']?.toString() ?? '';

    final int stock = (product['stock_quantity'] as num?)?.toInt() ?? 0;

    final String category =
        product['category_name']?.toString() ?? 'Uncategorized';

    final String description = product['description']?.toString() ?? '';

    final String deliveryDetails =
        product['delivery_details']?.toString() ?? '';

    final bool isOrganic = product['is_organic'] == true;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECE8)),
      ),
      child: InkWell(
        onTap: productId == null
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailsScreen(
                      productId: productId,
                      sellerId: widget.sellerId,
                      title: title,
                      price: price,
                      unit: unit,
                      imageUrl: image,
                      stockQuantity: stock,
                      description: description,
                      category: category,
                      farmName: _displayFarmName,
                      farmOrigin: _displayLocation,
                      isOrganic: isOrganic,
                      deliveryDetails: deliveryDetails,
                    ),
                  ),
                );
              },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PRODUCT IMAGE
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: image.isNotEmpty
                      ? Image.network(
                          image,
                          height: 110,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _productImageFallback(),
                        )
                      : _productImageFallback(),
                ),
                if (isOrganic)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: darkGreen,
                        borderRadius: BorderRadius.circular(6),
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
                Positioned(
                  bottom: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: stock > 0 ? darkGreen : Colors.red.shade700,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      stock > 0 ? 'In stock: $stock' : 'Out of stock',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // PRODUCT INFORMATION
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: ink,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.category_outlined,
                        size: 10,
                        color: mutedText,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 9, color: mutedText),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 10,
                        color: mutedText,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          _displayLocation,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 9, color: mutedText),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                '₱${price.toStringAsFixed(2)}',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: primaryGreen,
                                ),
                              ),
                            ),
                            Text(
                              '/$unit',
                              style: const TextStyle(
                                fontSize: 9,
                                color: mutedText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2DB05F),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'View',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
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

  Widget _productImageFallback() {
    return Container(
      height: 110,
      width: double.infinity,
      color: const Color(0xFFE8F0E7),
      child: const Icon(Icons.eco, color: primaryGreen, size: 36),
    );
  }

  // ==============================================
  // ABOUT FARM
  // ==============================================

  Widget _buildAboutTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About the Farm',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: ink,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _displayBio.isNotEmpty
              ? _displayBio
              : 'This farmer has not added a farm description yet.',
          style: const TextStyle(fontSize: 11, color: mutedText, height: 1.5),
        ),
        const SizedBox(height: 18),
        const Text(
          'Farmer Information',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: ink,
          ),
        ),
        const SizedBox(height: 10),
        _farmerInfoRow(Icons.person_outline, 'Farmer', _displayFarmerName),
        _farmerInfoRow(Icons.store_outlined, 'Farm', _displayFarmName),
        _farmerInfoRow(
          Icons.location_on_outlined,
          'Location',
          _displayLocation,
        ),
        _farmerInfoRow(
          Icons.phone_outlined,
          'Contact',
          _displayContact.isNotEmpty ? _displayContact : 'Not provided',
        ),
      ],
    );
  }

  Widget _farmerInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: primaryGreen),
          const SizedBox(width: 10),
          SizedBox(
            width: 75,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: mutedText),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                color: ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================
  // REVIEWS
  // ==============================================

  Widget _buildReviewsTab() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.rate_review_outlined, size: 40, color: mutedText),
            SizedBox(height: 8),
            Text(
              'No reviews yet',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: ink,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Customer reviews will appear here when available.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: mutedText),
            ),
          ],
        ),
      ),
    );
  }
}
