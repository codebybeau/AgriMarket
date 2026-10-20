import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/notification_provider.dart';
import 'cart_screen.dart';
import 'messages_screen.dart';
import 'product_details_screen.dart';

class FarmDetailsScreen extends StatefulWidget {
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

  const FarmDetailsScreen({
    super.key,
    this.farmName = 'Mang Celso Farm',
    this.location = 'Benguet, CAR',
    this.rating = '4.8',
    this.reviewCount = '892',
    this.avatarUrl =
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
    this.bannerUrl =
        'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=600',
    this.isVerified = true,
    this.productsCount = 45,
    this.followersCount = '1.2K',
    this.followingCount = 89,
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

  bool _isFollowing = false;
  int _selectedTabIndex = 0; // 0: Products, 1: About, 2: Reviews

  final List<Map<String, dynamic>> _farmProducts = [
    {
      'title': 'Organic Ampalaya (Bitter Gourd)',
      'price': 85.0,
      'originalPrice': 110.0,
      'unit': 'kg',
      'discount': '-23%',
      'rating': 4.8,
      'reviews': 234,
      'location': 'Benguet, CAR',
      'isOrganic': true,
      'isFreshHarvest': true,
      'isWholesale': true,
      'image':
          'https://images.unsplash.com/photo-1546094096-0df4bcaaa337?w=600',
    },
    {
      'title': 'Malunggay (Moringa) Fresh Leaves',
      'price': 30.0,
      'originalPrice': null,
      'unit': 'bundle',
      'discount': null,
      'rating': 4.7,
      'reviews': 203,
      'location': 'Benguet, CAR',
      'isOrganic': true,
      'isFreshHarvest': false,
      'isWholesale': false,
      'image':
          'https://images.unsplash.com/photo-1515471209610-dae1c92d877f?w=600',
    },
  ];

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
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: pageBackground,
        body: SingleChildScrollView(
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
    );
  }

  // ==============================================
  // 1. BANNER & HEADER OVERLAY
  // ==============================================

  Widget _buildHeaderBanner() {
    return Stack(
      children: [
        // Banner background image
        SizedBox(
          height: 220,
          width: double.infinity,
          child: Image.network(
            widget.bannerUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              color: const Color(0xFF2B8A4A),
              child: const Icon(Icons.landscape, size: 80, color: Colors.white),
            ),
          ),
        ),

        // Dark gradient overlay
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

        // Top Navigation Action Icons
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
                      badge: provider.unreadCount > 0 ? provider.unreadCount : 4,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MessagesScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  _circularIconButton(
                    Icons.share_outlined,
                    onTap: () => _showMessage('Farm link copied!'),
                  ),
                  const SizedBox(width: 8),
                  Consumer<NotificationProvider>(
                    builder: (context, provider, _) => _circularIconButton(
                      Icons.shopping_cart_outlined,
                      badge: provider.unreadCount,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CartScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Farm Identity Info (Avatar + Name + Rating)
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Avatar with border
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
                  child: Image.network(
                    widget.avatarUrl,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 64,
                      height: 64,
                      color: primaryGreen,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Farm details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.farmName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black45,
                                  blurRadius: 4,
                                ),
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
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFB800),
                          size: 14,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${widget.rating} ',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '(${widget.reviewCount})',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                        const Text(
                          '  |  ',
                          style: TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                        const Icon(
                          Icons.location_on_outlined,
                          color: Colors.white70,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            widget.location,
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
              padding: const EdgeInsets.all(8.0),
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
  // 2. FARM STATS ROW
  // ==============================================

  Widget _buildStatsRow() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statItem('${widget.productsCount}', 'Products'),
          _verticalDivider(),
          _statItem(widget.reviewCount, 'Reviews'),
          _verticalDivider(),
          _statItem(widget.followersCount, 'Followers'),
          _verticalDivider(),
          _statItem('${widget.followingCount}', 'Following'),
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
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: mutedText),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(height: 20, width: 1, color: const Color(0xFFEFEFEF));
  }

  // ==============================================
  // 3. FOLLOW & MESSAGE ACTION BUTTONS
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
                setState(() => _isFollowing = !_isFollowing);
                _showMessage(
                  _isFollowing
                      ? 'Following ${widget.farmName}'
                      : 'Unfollowed ${widget.farmName}',
                );
              },
              icon: Icon(
                _isFollowing ? Icons.check : Icons.eco_outlined,
                size: 18,
              ),
              label: Text(
                _isFollowing ? 'Following' : 'Follow Farm',
                style: const TextStyle(fontWeight: FontWeight.bold),
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
                  MaterialPageRoute(
                    builder: (context) => const MessagesScreen(),
                  ),
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
  // 4. TAB SECTION (Products / About / Reviews)
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
              _tabHeaderItem(0, 'Products (${_farmProducts.length})'),
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
    bool isSelected = _selectedTabIndex == index;
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
  // PRODUCTS GRID
  // ==============================================

  Widget _buildProductsGrid() {
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
        final product = _farmProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
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
                title: product['title'],
                price: product['price'],
                unit: product['unit'],
                imageUrl: product['image'],
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack with Badges
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.network(
                    product['image'],
                    height: 110,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: 110,
                      color: const Color(0xFFE8F0E7),
                      child: const Icon(Icons.eco,
                          color: primaryGreen, size: 36),
                    ),
                  ),
                ),
                // Discount Badge (Top Left)
                if (product['discount'] != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3D4F),
                        borderRadius: BorderRadius.circular(6),
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
                // Organic Badge (Top Right)
                if (product['isOrganic'] == true)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
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
                // Sub-badges (Fresh Harvest / Wholesale bottom left)
                Positioned(
                  bottom: 6,
                  left: 6,
                  child: Row(
                    children: [
                      if (product['isFreshHarvest'] == true) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF105B31),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Fresh harvest',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      if (product['isWholesale'] == true)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Wholesale',
                            style: TextStyle(
                              color: darkGreen,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            // Card Body Details
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['title'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: ink,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          color: Color(0xFFFFB800), size: 10),
                      const SizedBox(width: 2),
                      Text(
                        '${product['rating']} (${product['reviews']})',
                        style: const TextStyle(fontSize: 9, color: mutedText),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 9, color: mutedText),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          product['location'],
                          style:
                              const TextStyle(fontSize: 8, color: mutedText),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '₱${(product['price'] as double).toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: primaryGreen,
                                ),
                              ),
                              Text(
                                '/${product['unit']}',
                                style: const TextStyle(
                                    fontSize: 9, color: mutedText),
                              ),
                            ],
                          ),
                          if (product['originalPrice'] != null)
                            Text(
                              '₱${(product['originalPrice'] as double).toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 9,
                                color: mutedText,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                      // + Add Button
                      GestureDetector(
                        onTap: () =>
                            _showMessage('${product['title']} added to cart!'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2DB05F),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '+ Add',
                            style: TextStyle(
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
          ],
        ),
      ),
    );
  }

  // ==============================================
  // ABOUT TAB
  // ==============================================

  Widget _buildAboutTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About the Farm',
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.bold, color: ink),
        ),
        const SizedBox(height: 6),
        const Text(
          'Mang Celso Farm is a family-owned organic vegetable farm situated in the highland valleys of Benguet. We specialize in highland crops grown sustainably without synthetic pesticides or chemicals.',
          style: TextStyle(fontSize: 11, color: mutedText, height: 1.5),
        ),
        const SizedBox(height: 16),
        const Text(
          'Certifications & Standards',
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.bold, color: ink),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _badgeChip('Organic Verified', Icons.verified_user_outlined),
            const SizedBox(width: 8),
            _badgeChip('Good Agricultural Practice', Icons.eco_outlined),
          ],
        ),
      ],
    );
  }

  Widget _badgeChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF9F1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: primaryGreen),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================
  // REVIEWS TAB
  // ==============================================

  Widget _buildReviewsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '4.8',
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w900, color: ink),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(
                    5,
                    (i) => const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFFB800),
                      size: 14,
                    ),
                  ),
                ),
                Text(
                  'Based on ${widget.reviewCount} customer reviews',
                  style: const TextStyle(fontSize: 10, color: mutedText),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        _reviewItem('Rosa M.', 5, '2 days ago', 'Super fresh produce! Delivered right on time from Benguet.'),
        const Divider(height: 16, color: Color(0xFFF0F0F0)),
        _reviewItem('Danilo K.', 5, '1 week ago', 'The ampalaya quality is top notch. Crisp and clean.'),
      ],
    );
  }

  Widget _reviewItem(String name, int stars, String timeAgo, String comment) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: primaryGreen,
          child: Text(
            name[0],
            style: const TextStyle(
                color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.bold, color: ink),
                  ),
                  Text(timeAgo,
                      style: const TextStyle(fontSize: 9, color: mutedText)),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: List.generate(
                  stars,
                  (i) => const Icon(Icons.star_rounded,
                      color: Color(0xFFFFB800), size: 10),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                comment,
                style: const TextStyle(fontSize: 11, color: ink, height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}