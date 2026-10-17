import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../providers/product_provider.dart';
import 'product_details.dart';

const Color agriGreen = Color(0xFF176638);
const Color agriDarkGreen = Color(0xFF10552D);
const Color agriLightGreen = Color(0xFFE8F6EB);
const Color agriBackground = Color(0xFFF7F8F6);
const Color agriText = Color(0xFF1D2939);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedCategory = 'All';
  int _selectedTab = 0;

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Vegetables',
      'emoji': '🥦',
      'image':
          'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400',
    },
    {
      'name': 'Fruits',
      'emoji': '🍎',
      'image':
          'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=400',
    },
    {
      'name': 'Meat & Poultry',
      'emoji': '🍗',
      'image':
          'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=400',
    },
    {
      'name': 'Fish & Seafood',
      'emoji': '🐟',
      'image':
          'https://images.unsplash.com/photo-1510130387422-82bed34b37e9?w=400',
    },
    {
      'name': 'Rice & Grains',
      'emoji': '🌾',
      'image':
          'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400',
    },
    {
      'name': 'Eggs & Dairy',
      'emoji': '🥚',
      'image':
          'https://images.unsplash.com/photo-1518569656558-1f25e69d93d7?w=400',
    },
    {
      'name': 'Herbs & Spices',
      'emoji': '🌶️',
      'image':
          'https://images.unsplash.com/photo-1532336414038-cf19250c5757?w=400',
    },
    {
      'name': 'Root Crops',
      'emoji': '🥔',
      'image':
          'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=400',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _filterProducts(List<Product> products) {
    return products.where((product) {
      final query = _searchQuery.trim().toLowerCase();

      final matchesSearch =
          product.name.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query) ||
          product.farmer.toLowerCase().contains(query);

      final category = product.category.toLowerCase();
      final selected = _selectedCategory.toLowerCase();

      bool matchesCategory = selected == 'all';

      if (!matchesCategory) {
        switch (selected) {
          case 'meat & poultry':
            matchesCategory =
                category.contains('livestock') ||
                category.contains('meat') ||
                category.contains('poultry') ||
                category.contains('chicken');
            break;
          case 'fish & seafood':
            matchesCategory =
                category.contains('fish') || category.contains('seafood');
            break;
          case 'rice & grains':
            matchesCategory =
                category.contains('grain') || category.contains('rice');
            break;
          case 'eggs & dairy':
            matchesCategory =
                category.contains('egg') ||
                category.contains('dairy') ||
                category.contains('milk');
            break;
          case 'herbs & spices':
            matchesCategory =
                category.contains('herb') || category.contains('spice');
            break;
          case 'root crops':
            matchesCategory =
                category.contains('root') ||
                category.contains('potato') ||
                category.contains('cassava');
            break;
          default:
            matchesCategory = category == selected;
        }
      }

      return matchesSearch && matchesCategory;
    }).toList();
  }

  void _openProduct(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailsScreen(product: product),
      ),
    );
  }

  void _openCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _selectedTab = 1;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().products;
    final filteredProducts = _filterProducts(products);

    return Scaffold(
      backgroundColor: agriBackground,
      bottomNavigationBar: _buildBottomNavigation(),
      body: _selectedTab == 0
          ? Stack(
              children: [
                Positioned.fill(child: _buildHome(filteredProducts, products)),
                Positioned(top: 0, left: 0, right: 0, child: _buildHeader()),
              ],
            )
          : _buildOtherTab(products),
    );
  }

  Widget _buildHome(List<Product> filteredProducts, List<Product> allProducts) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 190)),

        SliverToBoxAdapter(child: _buildSaleBanner()),
        SliverToBoxAdapter(child: _buildOffersHeading()),
        SliverToBoxAdapter(child: _buildOffers()),
        SliverToBoxAdapter(child: _buildCategoriesHeading()),
        SliverToBoxAdapter(child: _buildCategories()),
        SliverToBoxAdapter(child: _buildProductsHeading(filteredProducts)),

        if (filteredProducts.isEmpty)
          SliverToBoxAdapter(child: _buildEmptyProducts(allProducts))
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                final product = filteredProducts[index];
                return _buildProductCard(product);
              }, childCount: filteredProducts.length),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 270,
              ),
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: const BoxDecoration(
        color: agriGreen,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good morning! 🌤️',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Juan dela Cruz',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Colors.white70,
                        ),
                        SizedBox(width: 3),
                        Text(
                          'Metro Manila (NCR)',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildHeaderAction(
                icon: Icons.chat_bubble_outline,
                badge: 4,
                onTap: () => _showMessage('Messages will be available soon.'),
              ),
              const SizedBox(width: 10),
              _buildHeaderAction(
                icon: Icons.shopping_cart_outlined,
                badge: 2,
                onTap: () {
                  setState(() => _selectedTab = 2);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
            decoration: InputDecoration(
              hintText: 'Search products, farms, supplies...',
              hintStyle: const TextStyle(
                color: Color(0xFF98A2B3),
                fontSize: 13,
              ),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF98A2B3)),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      icon: const Icon(Icons.close),
                    ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAction({
    required IconData icon,
    required int badge,
    required VoidCallback onTap,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.white24,
          shape: const CircleBorder(),
          child: IconButton(
            onPressed: onTap,
            icon: Icon(icon, color: Colors.white, size: 23),
          ),
        ),
        Positioned(
          top: -4,
          right: -2,
          child: Container(
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
            decoration: const BoxDecoration(
              color: Color(0xFFFF3030),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$badge',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaleBanner() {
    return Container(
      height: 150,
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: agriDarkGreen,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1542838132-92c53300491e?w=1000',
            fit: BoxFit.cover,
            errorBuilder: (_, error, stackTrace) =>
                Container(color: agriDarkGreen),
          ),
          Container(color: agriDarkGreen.withValues(alpha: 0.76)),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🌾 Harvest Season Sale',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Up to 30% off fresh produce',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = 'All';
                      _selectedTab = 2;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: agriGreen,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Shop Now',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            bottom: 12,
            right: 16,
            child: Row(
              children: [
                _BannerDot(active: true),
                SizedBox(width: 5),
                _BannerDot(active: false),
                SizedBox(width: 5),
                _BannerDot(active: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOffersHeading() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        children: [
          Icon(Icons.sell_outlined, color: agriGreen, size: 19),
          SizedBox(width: 8),
          Text(
            'Special Offers',
            style: TextStyle(
              color: agriText,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOffers() {
    return SizedBox(
      height: 190,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        children: [
          _buildOfferCard(
            label: '🌱 LIMITED-TIME DEAL',
            title: 'Fresh from Local Farms!',
            description: 'Enjoy special deals on fresh produce and agricultural products.',
          ),
          const SizedBox(width: 12),
          _buildOfferCard(
            label: '🍃 WELCOME OFFER',
            title: 'Welcome to AgriMart!',
            description: 'Shop fresh produce and farming supplies directly from local farmers.',
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard({
    required String label,
    required String title,
    required String description,
  }) {
    return Container(
      width: 225,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 60,
            width: double.infinity,
            color: agriGreen,
            padding: const EdgeInsets.all(8),
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: agriText,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 10,
                        height: 1.3,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      height: 27,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() => _selectedTab = 2);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: agriGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                        ),
                        child: const Text(
                          'Shop Now',
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesHeading() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Popular Categories',
              style: TextStyle(
                color: agriText,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _selectedTab = 1),
            child: const Row(
              children: [
                Text(
                  'See all',
                  style: TextStyle(
                    color: agriGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(Icons.chevron_right, color: agriGreen),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 12,
          childAspectRatio: 0.78,
        ),
        itemBuilder: (context, index) {
          final category = _categories[index];

          return InkWell(
            onTap: () => _openCategory(category['name'] as String),
            borderRadius: BorderRadius.circular(12),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: SizedBox(
                      width: double.infinity,
                      child: Image.network(
                        category['image'] as String,
                        fit: BoxFit.cover,
                        errorBuilder: (_, error, stackTrace) => Container(
                          color: agriLightGreen,
                          alignment: Alignment.center,
                          child: Text(
                            category['emoji'] as String,
                            style: const TextStyle(fontSize: 30),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  category['name'] as String,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: agriText, fontSize: 10),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductsHeading(List<Product> products) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Farm Products',
              style: TextStyle(
                color: agriText,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            '${products.length} products',
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return InkWell(
      onTap: () => _openProduct(product),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: agriLightGreen,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Center(
                  child: Text(
                    product.emoji,
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: agriGreen,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '₱${product.price} / ${product.unit}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: agriGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    product.farmer,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black54, fontSize: 10),
                  ),
                  const SizedBox(height: 7),
                  const Center(
                    child: Text(
                      'View details  →',
                      style: TextStyle(
                        color: agriGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
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
  }

  Widget _buildEmptyProducts(List<Product> allProducts) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: 48,
            color: Colors.black38,
          ),
          const SizedBox(height: 10),
          Text(
            allProducts.isEmpty
                ? 'No products available yet'
                : 'No matching products found',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 5),
          Text(
            allProducts.isEmpty
                ? 'Products added by farmers will appear here.'
                : 'Try another search or category.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    const labels = [
      'Home',
      'Categories',
      'Marketplace',
      'Notifications',
      'Profile',
    ];

    const icons = [
      Icons.home_outlined,
      Icons.grid_view_outlined,
      Icons.storefront_outlined,
      Icons.notifications_none,
      Icons.person_outline,
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66,
          child: Row(
            children: List.generate(labels.length, (index) {
              final selected = _selectedTab == index;

              return Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() => _selectedTab = index);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 3,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFE8F8EC)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              selected
                                  ? [
                                      Icons.home,
                                      Icons.grid_view,
                                      Icons.storefront,
                                      Icons.notifications,
                                      Icons.person,
                                    ][index]
                                  : icons[index],
                              color: selected ? agriGreen : Colors.blueGrey,
                              size: 22,
                            ),
                            if (index == 3)
                              Positioned(
                                right: -8,
                                top: -7,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFF3030),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Text(
                                    '4',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          labels[index],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: selected ? agriGreen : Colors.blueGrey,
                            fontSize: 9,
                            fontWeight: selected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildOtherTab(List<Product> products) {
    switch (_selectedTab) {
      case 1:
        return Column(
          children: [
            _buildSimpleAppBar('Categories'),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                ),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => _openCategory(category['name'] as String),
                      child: Center(
                        child: Text(
                          '${category['emoji']}  ${category['name']}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      case 2:
        return Column(
          children: [
            _buildSimpleAppBar('Marketplace'),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: products.isEmpty
                  ? const Center(child: Text('No products available yet.'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filterProducts(products).length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            mainAxisExtent: 270,
                          ),
                      itemBuilder: (context, index) {
                        final product = _filterProducts(products)[index];
                        return _buildProductCard(product);
                      },
                    ),
            ),
          ],
        );
      case 3:
        return Column(
          children: [
            _buildSimpleAppBar('Notifications'),
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.notifications_none, size: 54, color: agriGreen),
                    SizedBox(height: 12),
                    Text(
                      'You’re all caught up!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'New notifications will appear here.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      case 4:
        return Column(
          children: [
            _buildSimpleAppBar('Profile'),
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: agriLightGreen,
                      child: Icon(Icons.person, size: 42, color: agriGreen),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Juan dela Cruz',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'AgriMart Customer',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSimpleAppBar(String title) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            color: agriGreen,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _BannerDot extends StatelessWidget {
  final bool active;

  const _BannerDot({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: active ? 18 : 7,
      height: 7,
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.white60,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
