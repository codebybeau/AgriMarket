import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/notification_provider.dart';
import 'home_screen.dart';
import 'marketplace_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';
import 'cart_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  static const Color primaryGreen = Color(0xFF176B3A);
  static const Color darkGreen = Color(0xFF105B31);
  static const Color pageBackground = Color(0xFFF7F9F7);
  static const Color ink = Color(0xFF17211B);

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';

  final List<String> _filterChips = [
    'All',
    'Food',
    'Agricultural Supplies',
    'Farming Tools',
    'Irrigation',
  ];

  final List<Map<String, dynamic>> _categorySections = [
    {
      'title': 'Food & Fresh Produce',
      'group': 'Food',
      'items': [
        {
          'name': 'Vegetables',
          'image': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=300',
        },
        {
          'name': 'Fruits',
          'image': 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=300',
        },
        {
          'name': 'Meat & Poultry',
          'image': 'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=300',
        },
        {
          'name': 'Fish & Seafood',
          'image': 'https://images.unsplash.com/photo-1510130387422-82bed34b37e9?w=300',
        },
        {
          'name': 'Rice & Grains',
          'image': 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=300',
        },
        {
          'name': 'Eggs & Dairy',
          'image': 'https://images.unsplash.com/photo-1518569656558-1f25e69d93d7?w=300',
        },
        {
          'name': 'Herbs & Spices',
          'image': 'https://images.unsplash.com/photo-1506806732259-39c2d0268443?w=300',
        },
        {
          'name': 'Root Crops',
          'image': 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=300',
        },
        {
          'name': 'Legumes & Beans',
          'image':
              'https://images.unsplash.com/photo-1551462147-37885acc36f1?w=300',
        },
        {
          'name': 'Processed Foods',
          'image': 'https://images.unsplash.com/photo-1509722747041-616f39b57569?w=300',
        },
        {
          'name': 'Beverages',
          'image': 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=300',
        },
        {
          'name': 'Nuts & Seeds',
          'image': 'https://images.unsplash.com/photo-1508061252966-177bf504351a?w=300',
        },
        {
          'name': 'Flowers & Ornamentals',
          'image': 'https://images.unsplash.com/photo-1585320806297-9794b3e4eeae?w=300',
        },
        {
          'name': 'Honey & Natural',
          'image': 'https://images.unsplash.com/photo-1587049352847-4a222e784d38?w=300',
        },
      ],
    },
    {
      'title': 'Agricultural Supplies',
      'group': 'Agricultural Supplies',
      'items': [
        {
          'name': 'Seeds & Seedlings',
          'image': 'https://images.unsplash.com/photo-1523348837708-15d4a09cfac2?w=300',
        },
        {
          'name': 'Fertilizers',
          'image': 'https://images.unsplash.com/photo-1628352081506-83c43123ed6d?w=300',
        },
        {
          'name': 'Soil Amendments',
          'image': 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=300',
        },
        {
          'name': 'Pesticides',
          'image': 'https://images.unsplash.com/photo-1585314062340-f1a5a7c9328d?w=300',
        },
        {
          'name': 'Herbicides',
          'image': 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=300',
        },
        {
          'name': 'Fungicides',
          'image': 'https://images.unsplash.com/photo-1530836369250-ef72a3f5cda8?w=300',
        },
        {
          'name': 'Organic Farming',
          'image': 'https://images.unsplash.com/photo-1574943320219-553eb213f72d?w=300',
        },
        {
          'name': 'Soil & Growing Media',
          'image': 'https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=300',
        },
        {
          'name': 'Pots & Containers',
          'image': 'https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=300',
        },
        {
          'name': 'Seedling Trays',
          'image': 'https://images.unsplash.com/photo-1592417817098-8f3d6ef23a81?w=300',
        },
      ],
    },
    {
      'title': 'Farming Tools & Equipment',
      'group': 'Farming Tools',
      'items': [
        {
          'name': 'Hand Tools',
          'image': 'https://images.unsplash.com/photo-1617575521317-8686d1f03f39?w=300',
        },
        {
          'name': 'Power Tools',
          'image': 'https://images.unsplash.com/photo-1504148455328-c376907d081c?w=300',
        },
        {
          'name': 'Tractors & Vehicles',
          'image': 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?w=300',
        },
        {
          'name': 'Plowing Equipment',
          'image': 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=300',
        },
        {
          'name': 'Harvesting Equipment',
          'image': 'https://images.unsplash.com/photo-1595974482597-4b8da8879bc5?w=300',
        },
        {
          'name': 'Sprayers',
          'image': 'https://images.unsplash.com/photo-1563514227147-6d2ff665a6a0?w=300',
        },
      ],
    },
    {
      'title': 'Irrigation & Water Systems',
      'group': 'Irrigation',
      'items': [
        {
          'name': 'Water Pumps',
          'image': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=300',
        },
        {
          'name': 'Irrigation Pipes',
          'image': 'https://images.unsplash.com/photo-1541888946425-d0fbb186a5b7?w=300',
        },
        {
          'name': 'Sprinkler Systems',
          'image':
              'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=300',
        },
      ],
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
    final query = _searchQuery.trim().toLowerCase();

    final filteredSections = _categorySections
        .map((section) {
          final matchesGroup =
              _selectedFilter == 'All' ||
              section['group'] == _selectedFilter ||
              section['title'].toString().contains(_selectedFilter);

          final List<Map<String, String>> matchingItems =
              (section['items'] as List<Map<String, String>>).where((item) {
                final nameMatch =
                    query.isEmpty ||
                    item['name']!.toLowerCase().contains(query);
                return nameMatch;
              }).toList();

          return {
            'title': section['title'],
            'group': section['group'],
            'items': matchesGroup ? matchingItems : <Map<String, String>>[],
          };
        })
        .where((section) => (section['items'] as List).isNotEmpty)
        .toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: darkGreen,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor:
            Colors.transparent, // Changed to transparent for floating effect
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: pageBackground,
        extendBody: true, // REQUIRED for floating bottom navigation
        body: SafeArea(
          top: false,
          bottom: false,
          child: Column(
            children: [
              _buildHeader(),
              _buildFilterChips(),
              Expanded(
                child: filteredSections.isEmpty
                    ? const Center(
                        child: Text(
                          'No categories found.',
                          style: TextStyle(color: Color(0xFF6D776F)),
                        ),
                      )
                    : ListView.builder(
                        // Increased bottom padding to 110 to avoid overlap with floating bar
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
                        itemCount: filteredSections.length,
                        itemBuilder: (context, sectionIndex) {
                          final section = filteredSections[sectionIndex];
                          final items =
                              section['items'] as List<Map<String, String>>;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle(section['title'] as String),
                              const SizedBox(height: 10),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: items.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      mainAxisExtent: 130,
                                    ),
                                itemBuilder: (context, itemIndex) {
                                  return _buildCategoryCard(items[itemIndex]);
                                },
                              ),
                              const SizedBox(height: 20),
                            ],
                          );
                        },
                      ),
              ),
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
        MediaQuery.of(context).padding.top + 20,
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
                child: Text(
                  'Categories',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
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
                hintText: 'Search categories...',
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
          color: Colors.white.withValues(alpha: 0.18),
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

  Widget _buildFilterChips() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        scrollDirection: Axis.horizontal,
        itemCount: _filterChips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filterChips[index];
          final selected = _selectedFilter == filter;

          return InkWell(
            onTap: () => setState(() => _selectedFilter = filter),
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: selected ? primaryGreen : const Color(0xFFECEFEC),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  filter,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF4F5A52),
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 14,
          decoration: BoxDecoration(
            color: primaryGreen,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(Map<String, String> item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECE8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showMessage('Selected category: ${item['name']}'),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      item['image']!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: const Color(0xFFE8F0E7),
                        child: const Icon(
                          Icons.eco,
                          color: primaryGreen,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                child: Text(
                  item['name']!,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- FLOATING BOTTOM NAVIGATION (Matched exactly to HomeScreen) ---
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
          _navItem(
            Icons.home_filled,
            'Home',
            false,
            () => _goToPage(const HomeScreen()),
          ),
          _navItem(
            Icons.grid_view_rounded,
            'Categories',
            true,
            () {},
          ), // Currently Active tab
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
          color: selected
              ? const Color(0xFFE8F5E9)
              : Colors.transparent, // Light green pill for active state
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
