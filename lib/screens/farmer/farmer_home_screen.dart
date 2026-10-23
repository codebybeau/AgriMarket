import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';

const Color agriGreen = Color(0xFF2E7D32);
const Color agriDarkGreen = Color(0xFF1B5E20);
const Color agriBackground = Color(0xFFF7F8F4);

class FarmerHome extends StatefulWidget {
  const FarmerHome({super.key});

  @override
  State<FarmerHome> createState() => _FarmerHomeState();
}

class _FarmerHomeState extends State<FarmerHome> {
  int _selectedIndex = 0;

  final List<String> _titles = const [
    'Farmer Dashboard',
    'My Orders',
    'My Products',
    'My Profile',
  ];

  void _goToTab(int index) {
    if (index < 0 || index >= _titles.length) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  void _addProduct() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddNewProductScreen()),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Log out?'),
          content: const Text('Are you sure you want to log out of AgriMart?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: agriGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !mounted) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.logout();
    if (!mounted) return;

    if (auth.isLoggedIn) {
      _showMessage(auth.errorMessage ?? 'Unable to log out.');
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      _buildHomeScreen(),
      const Center(child: Text('Orders Screen Placeholder')),
      _buildProducts(),
      const Center(child: Text('Profile Screen Placeholder')),
    ];

    return Scaffold(
      backgroundColor: agriBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: agriDarkGreen,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 32,
              height: 32,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.agriculture, color: agriGreen),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _titles[_selectedIndex],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                  color: agriDarkGreen,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => _showMessage('Notifications will be available soon.'),
            icon: const Icon(Icons.notifications_none_rounded, color: agriDarkGreen),
          ),
          PopupMenuButton<String>(
            tooltip: 'Account options',
            onSelected: (value) {
              if (value == 'logout') _confirmLogout();
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Log Out'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: screens),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _goToTab,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: agriGreen,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Products',
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

  // DASHBOARD TAB (With Real-Time Supabase Stream Overview)
  Widget _buildHomeScreen() {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        final name = auth.fullName;
        final firstName = name == 'Guest' || name.isEmpty
            ? 'Farmer'
            : name.split(' ').first;
        final currentUserId = Supabase.instance.client.auth.currentUser?.id ?? '';

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: agriGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FARMER ACCOUNT',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Hello, $firstName!',
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
                      fontSize: 14,
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
                        backgroundColor: Colors.white,
                        foregroundColor: agriDarkGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            const Text(
              'Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: Supabase.instance.client
                        .from('products')
                        .stream(primaryKey: ['id'])
                        .eq('seller_id', currentUserId),
                    builder: (context, snapshot) {
                      final productCount = snapshot.data?.length ?? 0;
                      return _statCard(
                        title: 'Products',
                        value: '$productCount',
                        icon: Icons.inventory_2_outlined,
                        color: agriGreen,
                        onTap: () => _goToTab(2),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: Supabase.instance.client
                        .from('orders')
                        .stream(primaryKey: ['id'])
                        .eq('seller_id', currentUserId)
                        .eq('status', 'pending'),
                    builder: (context, snapshot) {
                      final pendingCount = snapshot.data?.length ?? 0;
                      return _statCard(
                        title: 'Pending Orders',
                        value: '$pendingCount',
                        icon: Icons.pending_actions_outlined,
                        color: Colors.orange,
                        onTap: () => _goToTab(1),
                      );
                    },
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
                    color: Colors.blue,
                    onTap: () => _goToTab(1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    title: 'Sales',
                    value: 'P0.00',
                    icon: Icons.payments_outlined,
                    color: Colors.purple,
                    onTap: () => _goToTab(1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            _actionTile(
              icon: Icons.add_box_outlined,
              title: 'Add a product',
              subtitle: 'List fresh produce for buyers',
              onTap: _addProduct,
            ),
            _actionTile(
              icon: Icons.inventory_outlined,
              title: 'Manage products',
              subtitle: 'View your product listings',
              onTap: () => _goToTab(2),
            ),
            _actionTile(
              icon: Icons.receipt_long_outlined,
              title: 'View orders',
              subtitle: 'Check customer orders',
              onTap: () => _goToTab(1),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: agriGreen),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tip: Use clear product photos and accurate prices to help buyers understand your products.',
                      style: TextStyle(color: agriDarkGreen, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // MY PRODUCTS TAB (With Dynamic Supabase Products, Multi-Image Fetch, and Edit Button)
  Widget _buildProducts() {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          _titles[2],
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Manage the products you sell on AgriMart.',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _addProduct,
            icon: const Icon(Icons.add),
            label: const Text('Add New Product'),
            style: ElevatedButton.styleFrom(
              backgroundColor: agriGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (currentUserId == null)
          const Center(child: Text('User not logged in.'))
        else
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: Supabase.instance.client
                .from('products')
                .stream(primaryKey: ['id'])
                .eq('seller_id', currentUserId)
                .order('id', ascending: false),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.only(top: 40.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }

              final products = snapshot.data ?? [];
              if (products.isEmpty) {
                return Column(
                  children: const [
                    SizedBox(height: 40),
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 76,
                      color: Colors.black26,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No products yet',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your product listings will appear here after you add them.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54, height: 1.5),
                    ),
                  ],
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  final dynamic rawStock = product['stock_quantity'];
                  final int stock = rawStock is int
                      ? rawStock
                      : (int.tryParse(rawStock?.toString() ?? '0') ?? 0);
                  final String unit = product['unit']?.toString() ?? 'kg';
                  final bool isOutOfStock = stock <= 0;
                  final dynamic productId = product['id'];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: FutureBuilder<List<dynamic>>(
                            future: Supabase.instance.client
                                .from('product_images')
                                .select('image_url')
                                .eq('product_id', productId),
                            builder: (context, imageSnapshot) {
                              String? imageUrl;
                              if (imageSnapshot.hasData &&
                                  imageSnapshot.data != null &&
                                  imageSnapshot.data!.isNotEmpty) {
                                imageUrl = imageSnapshot.data!.first['image_url']
                                    as String?;
                              }

                              if (imageUrl != null && imageUrl.isNotEmpty) {
                                return Image.network(
                                  imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              }

                              return Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name']?.toString() ?? 'Unnamed Product',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'P${product['price'] ?? 0}/$unit',
                                style: const TextStyle(color: Colors.black54),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: isOutOfStock
                                      ? const Color(0xFFFFE8E8)
                                      : const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isOutOfStock
                                      ? 'Out of stock'
                                      : '$stock in stock',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isOutOfStock
                                        ? Colors.red
                                        : agriGreen,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // EDIT PRODUCT BUTTON
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: agriGreen),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditProductScreen(product: product),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(title, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Icon(icon, color: agriGreen),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}