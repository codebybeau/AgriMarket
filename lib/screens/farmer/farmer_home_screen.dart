import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'add_product_screen.dart';

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
    'My Products',
    'Orders',
    'My Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: agriBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.eco, color: agriGreen, size: 28),
            const SizedBox(width: 8),
            const Text(
              'AgriMart',
              style: TextStyle(
                color: agriDarkGreen,
                fontWeight: FontWeight.bold,
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
              color: agriDarkGreen,
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
            _buildProducts(),
            _buildOrders(),
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
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: agriGreen,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
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

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Welcome banner
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
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF263328),
              ),
            ),
            const SizedBox(height: 14),

            // Prototype statistics
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    title: 'Products',
                    value: '0',
                    icon: Icons.inventory_2_outlined,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    title: 'Pending Orders',
                    value: '0',
                    icon: Icons.pending_actions_outlined,
                    color: const Color(0xFFEF8C22),
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
                    color: const Color(0xFF1976D2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    title: 'Sales',
                    value: '₱0.00',
                    icon: Icons.payments_outlined,
                    color: const Color(0xFF7B1FA2),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF263328),
              ),
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

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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

  // STATISTIC CARD
  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF263328),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
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
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: agriGreen),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  // PRODUCTS
  Widget _buildProducts() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          _titles[1],
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

        const SizedBox(height: 40),
        const Icon(Icons.inventory_2_outlined, size: 76, color: Colors.black26),
        const SizedBox(height: 16),
        const Text(
          'No products yet',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your product listings will appear here after you add them.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54, height: 1.5),
        ),
      ],
    );
  }

  // ORDERS
  Widget _buildOrders() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          _titles[2],
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Track and manage orders from your customers.',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 50),
        const Icon(
          Icons.receipt_long_outlined,
          size: 76,
          color: Colors.black26,
        ),
        const SizedBox(height: 16),
        const Text(
          'No orders yet',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Customer orders will appear here when buyers place orders for your products.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54, height: 1.5),
        ),
      ],
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
        final farmName = user?.userMetadata?['farm_name']?.toString() ?? '';

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              _titles[3],
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            Center(
              child: CircleAvatar(
                radius: 44,
                backgroundColor: const Color(0xFFE8F5E9),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'F',
                  style: const TextStyle(
                    fontSize: 32,
                    color: agriGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Farmer / Seller',
              textAlign: TextAlign.center,
              style: TextStyle(color: agriGreen, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 28),

            _profileItem(
              icon: Icons.email_outlined,
              title: 'Email',
              value: email,
            ),
            _profileItem(
              icon: Icons.phone_outlined,
              title: 'Mobile number',
              value: mobile,
            ),
            if (farmName.isNotEmpty)
              _profileItem(
                icon: Icons.agriculture_outlined,
                title: 'Farm name',
                value: farmName,
              ),

            const SizedBox(height: 24),

            OutlinedButton.icon(
              onPressed: _confirmLogout,
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,
                minimumSize: const Size.fromHeight(50),
                side: BorderSide(color: Colors.red.shade200),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _profileItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: agriGreen),
        title: Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _addProduct() {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const AddNewProductScreen()),
  );
}

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
}
