import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/notification_provider.dart';
import 'home_screen.dart';
import 'marketplace_screen.dart';
import 'cart_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String title;
  final double price;
  final String unit;
  final String imageUrl;

  const ProductDetailsScreen({
    super.key,
    this.title = 'Carabao Mango (Export Quality)',
    this.price = 180.0,
    this.unit = 'kg',
    this.imageUrl =
        'https://images.unsplash.com/photo-1553279768-865429fa0078?w=800',
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  static const Color primaryGreen = Color(0xFF176B3A);
  static const Color darkGreen = Color(0xFF105B31);
  static const Color pageBackground = Color(0xFFF7F9F7);
  static const Color cardBg = Color(0xFFF0FDF4);
  static const Color ink = Color(0xFF17211B);
  static const Color mutedText = Color(0xFF6D776F);
  static const Color highlightOrange = Color(0xFFD97706);

  int _quantity = 1;
  bool _isFavorite = false;
  int _activeImageIndex = 0;
  int _selectedTabIndex = 0; // 0: Description, 1: Reviews, 2: Seller Info

  final PageController _pageController = PageController();

  final List<String> _productImages = [
    'https://images.unsplash.com/photo-1553279768-865429fa0078?w=800',
    'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=800',
    'https://images.unsplash.com/photo-1591073113125-e46713c829ed?w=800',
  ];

  final List<Map<String, dynamic>> _recommendations = [
    {
      'title': 'Organic Banana (Lakatan)',
      'price': 120.0,
      'seller': 'Davao Organic Farms',
      'rating': 4.8,
      'reviews': 267,
      'bg': const Color(0xFFFFF9C4),
      'image':
          'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=300',
    },
    {
      'title': 'Sweet Pineapple',
      'price': 110.0,
      'seller': 'AgriMart Demo Farm',
      'rating': 4.9,
      'reviews': 104,
      'sold': '176 sold',
      'bg': const Color(0xFFFFF3E0),
      'image':
          'https://images.unsplash.com/photo-1550258987-190a2d41a8ba?w=300',
    },
    {
      'title': 'Ripe Solo Papaya',
      'price': 95.0,
      'seller': 'AgriMart Demo Farm',
      'rating': 4.8,
      'reviews': 81,
      'bg': const Color(0xFFFFE0B2),
      'image':
          'https://images.unsplash.com/photo-1517260739337-6799d239ce83?w=300',
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
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double totalPrice = widget.price * _quantity;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: pageBackground,
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageHeader(),
                    _buildProductTitleAndPrice(),
                    _buildSellerCard(),
                    _buildDeliveryCard(),
                    _buildComparePricesCard(),
                    _buildWholesaleCard(),
                    _buildTabSection(),
                    _buildFreshnessInfoCard(),
                    _buildProductMetadataGrid(),
                    _buildRecommendationsSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildBottomBuyBar(totalPrice),
          ],
        ),
      ),
    );
  }

  // ==============================================
  // 1. IMAGE CAROUSEL & TOP ACTIONS
  // ==============================================

  Widget _buildImageHeader() {
    return Stack(
      children: [
        // Image Slider
        SizedBox(
          height: 320,
          width: double.infinity,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (idx) => setState(() => _activeImageIndex = idx),
            itemCount: _productImages.length,
            itemBuilder: (context, index) {
              return Image.network(
                _productImages[index],
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: const Color(0xFFE8F0E7),
                  child: const Icon(Icons.eco, size: 80, color: primaryGreen),
                ),
              );
            },
          ),
        ),

        // Dark Top Header Overlay Bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(
              12,
              MediaQuery.of(context).padding.top + 8,
              12,
              12,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  primaryGreen.withValues(alpha: 0.9),
                  primaryGreen.withValues(alpha: 0.0),
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _circularIconButton(
                  Icons.arrow_back,
                  onTap: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      _goToPage(const HomeScreen());
                    }
                  },
                ),
                Row(
                  children: [
                    Consumer<NotificationProvider>(
                      builder: (context, provider, _) => _circularIconButton(
                        Icons.shopping_cart_outlined,
                        badge: provider.unreadCount,
                        onTap: () => _goToPage(const CartScreen()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _circularIconButton(
                      Icons.share_outlined,
                      onTap: () => _showMessage('Share link copied!'),
                    ),
                    const SizedBox(width: 8),
                    _circularIconButton(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      iconColor: _isFavorite ? Colors.red : ink,
                      onTap: () {
                        setState(() => _isFavorite = !_isFavorite);
                        _showMessage(
                          _isFavorite
                              ? 'Added to wishlist'
                              : 'Removed from wishlist',
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Badges Overlay (Top Left of Image)
        Positioned(
          top: MediaQuery.of(context).padding.top + 56,
          left: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBadge('Premium', const Color(0xFF105B31)),
              const SizedBox(height: 6),
              _buildBadge('Featured', const Color(0xFF105B31)),
            ],
          ),
        ),

        // Indicator Dots (Bottom Center of Image)
        Positioned(
          bottom: 12,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _productImages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 6,
                width: _activeImageIndex == index ? 20 : 6,
                decoration: BoxDecoration(
                  color: _activeImageIndex == index
                      ? primaryGreen
                      : Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _circularIconButton(
    IconData icon, {
    required VoidCallback onTap,
    Color iconColor = ink,
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
              padding: const EdgeInsets.all(8.0),
              child: Icon(icon, size: 18, color: iconColor),
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
  // 2. PRODUCT TITLE & PRICE SECTION
  // ==============================================

  Widget _buildProductTitleAndPrice() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: ink,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₱${widget.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: primaryGreen,
                    ),
                  ),
                  Text(
                    'per ${widget.unit}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: mutedText,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.star, color: Color(0xFFFFB800), size: 16),
              const SizedBox(width: 4),
              const Text(
                '4.8',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: ink,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                '(234 reviews)',
                style: TextStyle(fontSize: 12, color: mutedText),
              ),
              const SizedBox(width: 12),
              Container(width: 1, height: 12, color: const Color(0xFFE0E0E0)),
              const SizedBox(width: 12),
              const Text(
                '120 in stock',
                style: TextStyle(
                  fontSize: 12,
                  color: primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==============================================
  // 3. SELLER INFO CARD
  // ==============================================

  Widget _buildSellerCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFEFEF)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.eco, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Guimaras Harvest Co.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: const [
                    Icon(Icons.location_on_outlined,
                        size: 13, color: mutedText),
                    SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        'Guimaras, Western Visayas',
                        style: TextStyle(fontSize: 11, color: mutedText),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF9F1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: const [
                Icon(Icons.verified, size: 12, color: primaryGreen),
                SizedBox(width: 4),
                Text(
                  'Verified',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================
  // 4. DELIVERY INFO CARD
  // ==============================================

  Widget _buildDeliveryCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF9F1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              color: primaryGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Standard Delivery',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: ink,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '₱60 – ₱150 • Est. 3–5 days',
                  style: TextStyle(fontSize: 11, color: mutedText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================
  // 5. COMPARE PRICES CARD
  // ==============================================

  Widget _buildComparePricesCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        onTap: () => _showMessage('Comparing prices from other sellers...'),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.scale_outlined,
                  color: primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Compare prices from other sellers',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: ink,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Price per unit, delivery, stock, distance and rating',
                      style: TextStyle(fontSize: 10, color: mutedText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: mutedText, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================================
  // 6. WHOLESALE PRICING CARD
  // ==============================================

  Widget _buildWholesaleCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storefront_outlined,
                  color: primaryGreen, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Wholesale pricing',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: ink,
                  ),
                ),
              ),
              const Text(
                '₱155/kg',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Minimum 20 kg. Retail price remains ₱180/kg below the minimum.',
            style: TextStyle(fontSize: 10, color: mutedText),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _tierChip('20+ • ₱155'),
              const SizedBox(width: 8),
              _tierChip('40+ • ₱147.25'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tierChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          color: mutedText,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ==============================================
  // 7. DESCRIPTION / REVIEWS / SELLER TABS
  // ==============================================

  Widget _buildTabSection() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _tabHeaderItem(0, 'Description'),
              _tabHeaderItem(1, 'Reviews'),
              _tabHeaderItem(2, 'Seller Info'),
            ],
          ),
          const Divider(height: 1, color: Color(0xFFEFEFEF)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _selectedTabIndex == 0
                ? const Text(
                    'World-famous Guimaras carabao mangoes, sweetest in the Philippines. Export-quality, no fiber, incredibly sweet aroma.',
                    style: TextStyle(fontSize: 12, color: ink, height: 1.5),
                  )
                : _selectedTabIndex == 1
                    ? _buildReviewsTab()
                    : _buildSellerInfoTab(),
          ),
        ],
      ),
    );
  }

  Widget _tabHeaderItem(int index, String label) {
    bool isSelected = _selectedTabIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
    );
  }

  // ==============================================
  // REVIEWS TAB CONTENT
  // ==============================================

  Widget _buildReviewsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rating Summary Box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Column(
                children: [
                  const Text(
                    '4.8',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: ink,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.star, size: 14, color: Color(0xFFFFB800)),
                      Icon(Icons.star, size: 14, color: Color(0xFFFFB800)),
                      Icon(Icons.star, size: 14, color: Color(0xFFFFB800)),
                      Icon(Icons.star, size: 14, color: Color(0xFFFFB800)),
                      Icon(Icons.star, size: 14, color: Color(0xFFE0E0E0)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '234 reviews',
                    style: TextStyle(fontSize: 11, color: mutedText),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    _buildRatingBar(5, 0.70),
                    const SizedBox(height: 4),
                    _buildRatingBar(4, 0.20),
                    const SizedBox(height: 4),
                    _buildRatingBar(3, 0.08),
                    const SizedBox(height: 4),
                    _buildRatingBar(2, 0.02),
                    const SizedBox(height: 4),
                    _buildRatingBar(1, 0.02),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Review 1
        _buildReviewItem(
          initials: 'A',
          name: 'Ana C.',
          rating: 5,
          timeAgo: '2 days ago',
          comment: 'Very fresh! Delivered on time. Will order again.',
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(height: 1, color: Color(0xFFF0F0F0)),
        ),

        // Review 2
        _buildReviewItem(
          initials: 'M',
          name: 'Marco R.',
          rating: 4,
          timeAgo: '1 week ago',
          comment: 'Good quality produce. Packaging could be better.',
        ),
      ],
    );
  }

  Widget _buildRatingBar(int starCount, double value) {
    return Row(
      children: [
        Text(
          '$starCount',
          style: const TextStyle(
            fontSize: 11,
            color: mutedText,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewItem({
    required String initials,
    required String name,
    required int rating,
    required String timeAgo,
    required String comment,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: const Color(0xFF16A34A),
          child: Text(
            initials,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: ink,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        Icons.star,
                        size: 12,
                        color: index < rating
                            ? const Color(0xFFFFB800)
                            : const Color(0xFFE0E0E0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    timeAgo,
                    style: const TextStyle(fontSize: 11, color: mutedText),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                comment,
                style: const TextStyle(
                  fontSize: 12,
                  color: ink,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==============================================
  // SELLER INFO TAB CONTENT
  // ==============================================

  Widget _buildSellerInfoTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAF8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: primaryGreen,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.agriculture,
                  color: Color(0xFFFFC107),
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Laguna Free Range Farm',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: const [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: mutedText,
                        ),
                        SizedBox(width: 2),
                        Text(
                          'Laguna, Region IV-A',
                          style: TextStyle(fontSize: 12, color: mutedText),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: const [
                        Icon(
                          Icons.star,
                          size: 14,
                          color: Color(0xFFFFB800),
                        ),
                        SizedBox(width: 2),
                        Text(
                          '4.8',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: ink,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '(892 sales)',
                          style: TextStyle(fontSize: 12, color: mutedText),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _showMessage('Opening Laguna Free Range Farm...'),
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryGreen,
              side: const BorderSide(color: primaryGreen, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Visit Store',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==============================================
  // 8. FRESHNESS & PRODUCT INFORMATION CARD
  // ==============================================

  Widget _buildFreshnessInfoCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCFCE7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.eco_outlined, color: primaryGreen, size: 18),
              SizedBox(width: 8),
              Text(
                'Freshness & Product Information',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _infoRow('Harvest date', 'May 26, 2025'),
          _infoRow('Origin', 'Guimaras, Western Visayas'),
          _infoRow('Grade', 'Seller-listed export grade (demo)'),
          _infoRow(
            'Storage',
            'Store at room temperature until ripe, then refrigerate.',
          ),
          _infoRow('Best before', 'Best used within 7 days of delivery'),
          const SizedBox(height: 10),
          const Text(
            'Seller-provided demo fields. Freshness claims require substantiated listing and storage date.',
            style: TextStyle(fontSize: 9, color: Color(0xFF8A9A8E)),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
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
                fontWeight: FontWeight.w600,
                color: ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================
  // 9. PRODUCT METADATA GRID (Category, Unit, Stock, Type)
  // ==============================================

  Widget _buildProductMetadataGrid() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _metaCard('CATEGORY', 'Fruits')),
              const SizedBox(width: 10),
              Expanded(child: _metaCard('UNIT', widget.unit)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _metaCard('STOCK', '120 units')),
              const SizedBox(width: 10),
              Expanded(child: _metaCard('TYPE', 'Conventional')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metaCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: Color(0xFF9AA59D),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: ink,
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================
  // 10. YOU MAY ALSO LIKE SECTION
  // ==============================================

  Widget _buildRecommendationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'You May Also Like',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: ink,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Category-based demo recommendations',
                    style: TextStyle(fontSize: 10, color: mutedText),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _goToPage(const MarketplaceScreen()),
                child: Row(
                  children: const [
                    Text(
                      'See All',
                      style: TextStyle(
                        fontSize: 11,
                        color: primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.chevron_right, size: 16, color: primaryGreen),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 230,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _recommendations.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = _recommendations[index];
              return _recommendationCard(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _recommendationCard(Map<String, dynamic> item) {
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
          // Image Box
          Stack(
            children: [
              Container(
                height: 110,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: item['bg'],
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    item['image'],
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(Icons.eco,
                        size: 40, color: primaryGreen),
                  ),
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite_border,
                      size: 14, color: mutedText),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '₱${(item['price'] as double).toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: primaryGreen,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item['seller'],
                  style: const TextStyle(fontSize: 9, color: mutedText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFFFB800), size: 10),
                    const SizedBox(width: 2),
                    Text(
                      '${item['rating']} (${item['reviews']})',
                      style:
                          const TextStyle(fontSize: 8, color: mutedText),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'DEMO DATA',
                    style: TextStyle(
                      fontSize: 7,
                      fontWeight: FontWeight.bold,
                      color: highlightOrange,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================
  // 11. STICKY QUANTITY & PURCHASE ACTION BAR
  // ==============================================

  Widget _buildBottomBuyBar(double totalPrice) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEFEFEF))),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Quantity:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: ink,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (_quantity > 1) {
                                  setState(() => _quantity--);
                                }
                              },
                              icon: const Icon(Icons.remove, size: 16),
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            Text(
                              '$_quantity',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () => setState(() => _quantity++),
                              icon: const Icon(Icons.add,
                                  size: 16, color: primaryGreen),
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '₱${totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: primaryGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showMessage(
                          'Added $_quantity ${widget.unit} to cart!'),
                      icon: const Icon(Icons.shopping_cart_outlined, size: 16),
                      label: const Text('Add to Cart'),
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          _showMessage('Proceeding to checkout...'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
            ],
          ),
        ),
      ),
    );
  }
}