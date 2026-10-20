import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import 'add_product_screen.dart';
import 'farmer_orders_screen.dart';
import 'farmer_products_screen.dart';
import 'farmer_sales_screen.dart';
import 'farmer_profile_screen.dart';
import 'farmer_theme.dart';

class FarmerHome extends StatefulWidget {
  const FarmerHome({super.key});

  @override
  State<FarmerHome> createState() => _FarmerHomeState();
}

class _FarmerHomeState extends State<FarmerHome> {
  int _selectedIndex = 0;

  void _goToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  late final List<Widget> _screens = [
    _buildHomeScreen(),
    const FarmerOrdersScreen(),
    const FarmerProductsScreen(),
    const FarmerSalesScreen(),
    const FarmerProfileScreen(),
  ];

  void _addProduct() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddNewProductScreen()),
    );
  }

  Widget _buildHomeScreen() {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        final name = auth.fullName;
        final firstName = name == 'Guest' || name.isEmpty
            ? 'Farmer'
            : name.split(' ').first;

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Welcome card
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
                  child: _statCard(
                    title: 'Products',
                    value: '0',
                    icon: Icons.inventory_2_outlined,
                    color: agriGreen,
                    onTap: () => _goToTab(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    title: 'Pending Orders',
                    value: '0',
                    icon: Icons.pending_actions_outlined,
                    color: Colors.orange,
                    onTap: () => _goToTab(1),
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
                    value: '₱0.00',
                    icon: Icons.payments_outlined,
                    color: Colors.purple,
                    onTap: () => _goToTab(3),
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

            _actionTile(
              icon: Icons.bar_chart_outlined,
              title: 'View sales',
              subtitle: 'Check your sales overview',
              onTap: () => _goToTab(3),
            ),

            const SizedBox(height: 12),

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
                      'Tip: Use clear product photos and accurate prices '
                      'to help buyers understand your products.',
                      style: TextStyle(color: agriDarkGreen, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        );
      },
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

  @override
  Widget build(BuildContext context) {
    const titles = ['Home', 'Orders', 'Products', 'Sales', 'Profile'];

    return Scaffold(
      backgroundColor: agriBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: agriDarkGreen,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                'assets/images/logo.png',
                width: 28,
                height: 28,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              titles[_selectedIndex],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
      ),
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _goToTab,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: agriGreen,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
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
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
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
}
