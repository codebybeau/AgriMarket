import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'add_product_screen.dart';
import 'farmer_products_screen.dart';
import 'farmer_orders_screen.dart';
import 'sales_screen.dart';

const Color agriBackground = Color(0xFFE8F0E6);
const Color agriCard = Color(0xFFF1F6EF);
const Color agriText = Color(0xFF1B3D2A);
const Color agriDescription = Color(0xFF526357);
const Color agriHeader = Color(0xFF1B5E20);
const Color agriGreen = Color(0xFF2E7D32);

class FarmerHome extends StatefulWidget {
  const FarmerHome({super.key});

  @override
  State<FarmerHome> createState() => _FarmerHomeState();
}

class _FarmerHomeState extends State<FarmerHome> {
  int _selectedIndex = 0;

  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _dashboardProducts = [];
  bool _isLoadingDashboardProducts = true;
  String? _dashboardProductError;

  int _pendingOrdersCount = 0;
  bool _isLoadingPendingOrders = true;

  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardProducts();
  }

  // FETCH FARMER PRODUCTS
  Future<void> _fetchDashboardProducts() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        _isLoadingDashboardProducts = false;
        _isLoadingPendingOrders = false;
        _dashboardProductError = 'Please log in to view your products.';
      });
      return;
    }

    if (mounted) {
      setState(() {
        _isLoadingDashboardProducts = true;
        _dashboardProductError = null;
      });
    }

    try {
      final response = await supabase
          .from('products')
          .select(
            'id, name, price, stock_quantity, status, product_images(image_url)',
          )
          .eq('seller_id', user.id)
          .order('created_at', ascending: false);

      final products = List<Map<String, dynamic>>.from(response);

      if (!mounted) return;

      setState(() {
        _dashboardProducts = products;
        _isLoadingDashboardProducts = false;
        _dashboardProductError = null;
      });

      final productIds =
          products.map((product) => product['id']).toList();

      await _fetchPendingOrdersCount(productIds);
    } catch (e) {
      debugPrint('Error fetching dashboard products: $e');

      if (!mounted) return;

      setState(() {
        _isLoadingDashboardProducts = false;
        _isLoadingPendingOrders = false;
        _dashboardProductError = e.toString();
      });
    }
  }

  // FETCH PENDING ORDERS
  Future<void> _fetchPendingOrdersCount(
    List<dynamic> productIds,
  ) async {
    if (!mounted) return;

    setState(() {
      _isLoadingPendingOrders = true;
    });

    try {
      if (productIds.isEmpty) {
        if (!mounted) return;

        setState(() {
          _pendingOrdersCount = 0;
          _isLoadingPendingOrders = false;
        });
        return;
      }

      final itemResponse = await supabase
          .from('order_items')
          .select('order_id')
          .inFilter('product_id', productIds);

      final orderIds = itemResponse
          .map((item) => item['order_id'])
          .where((id) => id != null)
          .toSet()
          .toList();

      if (orderIds.isEmpty) {
        if (!mounted) return;

        setState(() {
          _pendingOrdersCount = 0;
          _isLoadingPendingOrders = false;
        });
        return;
      }

      final pendingResponse = await supabase
          .from('orders')
          .select('id')
          .inFilter('id', orderIds)
          .eq('status', 'pending');

      if (!mounted) return;

      setState(() {
        _pendingOrdersCount = pendingResponse.length;
        _isLoadingPendingOrders = false;
      });
    } catch (e) {
      debugPrint('Error fetching pending orders: $e');

      if (!mounted) return;

      setState(() {
        _isLoadingPendingOrders = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: agriBackground,
      appBar: AppBar(
        backgroundColor: agriHeader,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 34,
              height: 34,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.eco,
                  color: Colors.white,
                  size: 30,
                );
              },
            ),
            const SizedBox(width: 10),
            const Text(
              'AgriMart',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {
              _showMessage('Notifications will be available soon.');
            },
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildDashboard(),
            const FarmerProductsScreen(),
            const FarmerOrdersScreen(),
            const SalesScreen(),
            _buildProfile(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          if (index == 0) {
            _fetchDashboardProducts();
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: agriCard,
        elevation: 8,
        selectedItemColor: agriGreen,
        unselectedItemColor: agriDescription,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payments_outlined),
            activeIcon: Icon(Icons.payments),
            label: 'Sales',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // DASHBOARD
  Widget _buildDashboard() {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        final farmerName = auth.fullName;
        final firstName = farmerName == 'Guest'
            ? 'Farmer'
            : farmerName.split(' ').first;

        return RefreshIndicator(
          color: agriGreen,
          onRefresh: _fetchDashboardProducts,
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              _buildWelcomeCard(firstName),
              const SizedBox(height: 24),
              _buildSectionHeading('Overview'),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      title: 'Products',
                      value: _isLoadingDashboardProducts
                          ? '...'
                          : _dashboardProducts.length.toString(),
                      icon: Icons.inventory_2_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard(
                      title: 'Pending Orders',
                      value: _isLoadingPendingOrders
                          ? '...'
                          : _pendingOrdersCount.toString(),
                      icon: Icons.pending_actions_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      title: 'Completed Orders',
                      value: '0',
                      icon: Icons.task_alt,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard(
                      title: 'Sales',
                      value: '₱0.00',
                      icon: Icons.payments_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              _buildRecentProducts(),
              const SizedBox(height: 26),
              _buildSectionHeading('Quick Actions'),
              const SizedBox(height: 12),
              _actionTile(
                icon: Icons.add_box_outlined,
                title: 'Add a product',
                subtitle: 'List fresh produce for buyers',
                onTap: _addProduct,
              ),
              _actionTile(
                icon: Icons.inventory_outlined,
                title: 'Manage products',
                subtitle: 'View and update your product listings',
                onTap: () {
                  setState(() => _selectedIndex = 1);
                },
              ),
              _actionTile(
                icon: Icons.receipt_long_outlined,
                title: 'View orders',
                subtitle: 'Check customer orders',
                onTap: () {
                  setState(() => _selectedIndex = 2);
                },
              ),
              _actionTile(
                icon: Icons.payments_outlined,
                title: 'View sales',
                subtitle: 'Check your completed sales and earnings',
                onTap: () {
                  setState(() => _selectedIndex = 3);
                },
              ),
              const SizedBox(height: 16),
              _buildTipCard(),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // WELCOME CARD
  Widget _buildWelcomeCard(String firstName) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [agriHeader, agriGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.eco_outlined,
                color: Colors.white70,
                size: 18,
              ),
              SizedBox(width: 7),
              Text(
                'FARMER ACCOUNT',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Hello, $firstName! 🌱',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Manage your farm products and connect with buyers.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addProduct,
              icon: const Icon(Icons.add),
              label: const Text('Add New Product'),
              style: ElevatedButton.styleFrom(
                backgroundColor: agriCard,
                foregroundColor: agriHeader,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
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

  // SECTION HEADING
  Widget _buildSectionHeading(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.bold,
        color: agriText,
      ),
    );
  }

  // RECENT PRODUCTS
  Widget _buildRecentProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'My Recent Products',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: agriText,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() => _selectedIndex = 1);
              },
              child: const Text(
                'See All',
                style: TextStyle(
                  color: agriGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_isLoadingDashboardProducts)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: agriGreen),
            ),
          )
        else if (_dashboardProductError != null)
          _buildEmptyCard(
            icon: Icons.error_outline,
            message: 'Unable to load products.',
          )
        else if (_dashboardProducts.isEmpty)
          _buildEmptyCard(
            icon: Icons.inventory_2_outlined,
            message: 'No products available yet. Add your first product!',
          )
        else
          ..._dashboardProducts.take(4).map((product) {
            final dynamic images = product['product_images'];
            String? imageUrl;

            if (images is List && images.isNotEmpty) {
              final firstImage = images.first;
              if (firstImage is Map) {
                imageUrl = firstImage['image_url']?.toString();
              }
            } else if (images is Map) {
              imageUrl = images['image_url']?.toString();
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: agriCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: agriGreen.withValues(alpha: 0.10),
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(10),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          width: 62,
                          height: 62,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _productPlaceholder();
                          },
                        )
                      : _productPlaceholder(),
                ),
                title: Text(
                  product['name']?.toString() ?? 'Unnamed Product',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: agriText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    '₱${product['price'] ?? '0.00'}  •  Stock: ${product['stock_quantity'] ?? 0}',
                    style: const TextStyle(
                      color: agriDescription,
                      fontSize: 12,
                    ),
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: agriGreen,
                ),
                onTap: () {
                  setState(() => _selectedIndex = 1);
                },
              ),
            );
          }),
      ],
    );
  }

  Widget _productPlaceholder() {
    return Container(
      width: 62,
      height: 62,
      color: agriBackground,
      child: const Icon(
        Icons.agriculture,
        color: agriGreen,
        size: 29,
      ),
    );
  }

  Widget _buildEmptyCard({
    required IconData icon,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: agriCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: agriGreen, size: 34),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: agriDescription,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // STATISTIC CARD
  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: agriCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: agriGreen.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: agriGreen.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: agriGreen, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: agriText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: agriDescription,
            ),
          ),
        ],
      ),
    );
  }

  // QUICK ACTION TILE
  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: agriCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: agriGreen.withValues(alpha: 0.10),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 5,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: agriBackground,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: agriGreen),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: agriText,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: agriDescription,
            fontSize: 11,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: agriGreen,
        ),
        onTap: onTap,
      ),
    );
  }

  // TIP CARD
  Widget _buildTipCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: agriCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: agriGreen.withValues(alpha: 0.15),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: agriGreen,
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Farmer Tip',
                  style: TextStyle(
                    color: agriText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Use clear product photos and accurate prices to help buyers understand your products.',
                  style: TextStyle(
                    color: agriDescription,
                    height: 1.5,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // PROFILE
  Widget _buildProfile() {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        final user = auth.currentUser;
        final name = auth.fullName;
        final email = user?.email ?? 'No email available';
        final mobile =
            user?.userMetadata?['mobile']?.toString() ?? 'Not provided';
        final farmName =
            user?.userMetadata?['farm_name']?.toString() ?? '';

        final initial = name.trim().isNotEmpty
            ? name.trim()[0].toUpperCase()
            : 'F';

        return ListView(
          padding: const EdgeInsets.all(18),
          children: [
            _buildProfileHeader(
              name: name,
              email: email,
              initial: initial,
            ),
            const SizedBox(height: 22),
            _buildSectionHeading('Account Information'),
            const SizedBox(height: 12),
            _profileItem(
              icon: Icons.person_outline,
              title: 'Full Name',
              value: name,
            ),
            _profileItem(
              icon: Icons.email_outlined,
              title: 'Email Address',
              value: email,
            ),
            _profileItem(
              icon: Icons.phone_outlined,
              title: 'Mobile Number',
              value: mobile,
            ),
            if (farmName.isNotEmpty)
              _profileItem(
                icon: Icons.agriculture_outlined,
                title: 'Farm Name',
                value: farmName,
              ),
            const SizedBox(height: 22),
            _buildSectionHeading('Account Settings'),
            const SizedBox(height: 12),
            _settingsTile(
              icon: Icons.edit_outlined,
              title: 'Edit Profile',
              subtitle: 'View your current account information',
              onTap: () {
                _showProfileInformation(
                  name: name,
                  email: email,
                  mobile: mobile,
                  farmName: farmName,
                );
              },
            ),
            _settingsTile(
              icon: Icons.storefront_outlined,
              title: 'Shop Information',
              subtitle: 'View your farmer and shop details',
              onTap: () {
                _showShopInformation(
                  name: name,
                  farmName: farmName,
                  email: email,
                );
              },
            ),
            _settingsSwitchTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Enable or disable this screen preference',
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });

                _showMessage(
                  value
                      ? 'Notifications preference enabled.'
                      : 'Notifications preference disabled.',
                );
              },
            ),
            _settingsTile(
              icon: Icons.lock_outline,
              title: 'Privacy & Security',
              subtitle: 'Account security information',
              onTap: _showPrivacyInformation,
            ),
            _settingsTile(
              icon: Icons.info_outline,
              title: 'About AgriMart',
              subtitle: 'Learn about the AgriMart platform',
              onTap: _showAboutAgriMart,
            ),
            const SizedBox(height: 24),
            _buildLogoutButton(),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  // PROFILE HEADER
  Widget _buildProfileHeader({
    required String name,
    required String email,
    required String initial,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [agriHeader, agriGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 43,
            backgroundColor: agriCard,
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 32,
                color: agriHeader,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 13),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            email,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 13),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  color: Colors.white,
                  size: 15,
                ),
                SizedBox(width: 6),
                Text(
                  'Farmer / Seller Account',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // PROFILE INFORMATION ITEM
  Widget _profileItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: agriCard,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: agriGreen.withValues(alpha: 0.10),
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: agriBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: agriGreen),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: agriDescription,
            fontSize: 11,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            color: agriText,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // SETTINGS TILE
  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: agriCard,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: agriGreen.withValues(alpha: 0.10),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 5,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: agriBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: agriGreen, size: 21),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: agriText,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: agriDescription,
            fontSize: 11,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: agriGreen,
        ),
      ),
    );
  }

  // NOTIFICATION SETTINGS SWITCH
  Widget _settingsSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: agriCard,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: agriGreen.withValues(alpha: 0.10),
        ),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 5,
        ),
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: agriBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: agriGreen, size: 21),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: agriText,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: agriDescription,
            fontSize: 11,
          ),
        ),
        value: value,
        activeThumbColor: agriGreen,
        onChanged: onChanged,
      ),
    );
  }

  // PROFILE INFORMATION DIALOG
  void _showProfileInformation({
    required String name,
    required String email,
    required String mobile,
    required String farmName,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: agriCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Profile Information',
            style: TextStyle(
              color: agriText,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dialogInfoRow('Full Name', name),
              _dialogInfoRow('Email', email),
              _dialogInfoRow('Mobile Number', mobile),
              if (farmName.isNotEmpty)
                _dialogInfoRow('Farm Name', farmName),
              const SizedBox(height: 10),
              const Text(
                'Profile editing is not connected to an update function yet.',
                style: TextStyle(
                  color: agriDescription,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Close',
                style: TextStyle(color: agriGreen),
              ),
            ),
          ],
        );
      },
    );
  }

  // SHOP INFORMATION DIALOG
  void _showShopInformation({
    required String name,
    required String farmName,
    required String email,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: agriCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Shop Information',
            style: TextStyle(
              color: agriText,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dialogInfoRow(
                'Shop / Farm Name',
                farmName.isEmpty ? 'Not provided' : farmName,
              ),
              _dialogInfoRow('Seller Name', name),
              _dialogInfoRow('Contact Email', email),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Close',
                style: TextStyle(color: agriGreen),
              ),
            ),
          ],
        );
      },
    );
  }

  // PRIVACY AND SECURITY DIALOG
  void _showPrivacyInformation() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: agriCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Privacy & Security',
            style: TextStyle(
              color: agriText,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Your AgriMart account uses Supabase authentication. '
            'Keep your login credentials private and always log out '
            'when using a shared device.\n\n'
            'Additional account security settings are not connected yet.',
            style: TextStyle(
              color: agriDescription,
              height: 1.5,
              fontSize: 13,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Close',
                style: TextStyle(color: agriGreen),
              ),
            ),
          ],
        );
      },
    );
  }

  // ABOUT AGRIMART DIALOG
  void _showAboutAgriMart() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: agriCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.eco,
                color: agriGreen,
                size: 48,
              ),
              SizedBox(height: 12),
              Text(
                'AgriMart',
                style: TextStyle(
                  color: agriText,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'AgriMart connects farmers and buyers through an '
                'online marketplace for agricultural products.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: agriDescription,
                  height: 1.5,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Close',
                style: TextStyle(color: agriGreen),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _dialogInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: agriDescription,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: agriText,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // LOGOUT BUTTON
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: _confirmLogout,
        icon: const Icon(Icons.logout),
        label: const Text(
          'Log Out',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red.shade700,
          side: BorderSide(color: Colors.red.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ADD PRODUCT NAVIGATION
  Future<void> _addProduct() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddNewProductScreen(),
      ),
    );

    if (!mounted) return;

    await _fetchDashboardProducts();
  }

  // SHOW MESSAGE
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: agriHeader,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // LOGOUT CONFIRMATION
  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: agriCard,
          title: const Text(
            'Log out?',
            style: TextStyle(
              color: agriText,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to log out of AgriMart?',
            style: TextStyle(color: agriDescription),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: agriDescription),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: agriHeader,
                foregroundColor: Colors.white,
              ),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !mounted) return;

    final auth = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    await auth.logout();

    if (!mounted) return;

    if (auth.isLoggedIn) {
      _showMessage(
        auth.errorMessage ?? 'Unable to log out.',
      );
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }
}
