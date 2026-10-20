import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'settings_screen.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import 'marketplace_screen.dart';
import 'home_screen.dart';
import 'categories_screen.dart';
import 'orders_screen.dart';
import 'notification_screen.dart';
import 'cart_screen.dart';
import '../farmer/farmer_home_screen.dart';

import '../auth/login_screen.dart';
import '../auth/register_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color primaryGreen = Color(0xFF176B3A);
  static const Color darkGreen = Color(0xFF105B31);
  static const Color pageBackground = Color(0xFFF0F3F1);
  static const Color ink = Color(0xFF17211B);
  static const Color mutedText = Color(0xFF6D776F);
  static const Color highlightOrange = Color(0xFFD97706);

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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor:
            Colors.transparent, // Required for floating bar effect
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: pageBackground,
        extendBody: true, // Required for floating bar effect
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileHeader(),
              _buildPurchasesSection(),
              _buildWalletSection(),
              _buildFinancialServices(),
              _buildMoreActivities(),
              _buildSupportSection(),
              const SizedBox(
                height: 100,
              ), // Padding to prevent bottom floating bar overlap
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavigation(),
      ),
    );
  }

  // ==========================================
  // HEADER & GUEST / USER INFO
  // ==========================================

  Widget _buildProfileHeader() {
    final auth = context.watch<AuthProvider>();
    final isLoggedIn = auth.isLoggedIn;
    final name = auth.fullName.trim();
    final displayName = name.isEmpty || name == 'Guest' ? 'Guest User' : name;

    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      decoration: const BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _headerAction(
                    Icons.settings_outlined,
                    onTap: () => _goToPage(const SettingsScreen()),
                  ),
                  const SizedBox(width: 8),
                  _headerAction(
                    Icons.shopping_cart_outlined,
                    onTap: () => _goToPage(const CartScreen()),
                  ),
                  const SizedBox(width: 8),
                  Consumer<NotificationProvider>(
                    builder: (context, provider, _) => _headerAction(
                      Icons.chat_bubble_outline_rounded,
                      onTap: () => _goToPage(const NotificationScreen()),
                      badge: provider.unreadCount,
                    ),
                  ),
                ],
              ),
            ),

            // Real user information when logged in
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: primaryGreen,
                      size: 38,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isLoggedIn ? displayName : 'Guest User',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isLoggedIn
                              ? (auth.role == 'farmer'
                                    ? 'Farmer Account'
                                    : 'Consumer Account')
                              : 'Sign in or create an account',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Show authentication buttons only to guests
            if (!isLoggedIn)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: ElevatedButton(
                          onPressed: () => _goToPage(const LoginScreen()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: primaryGreen,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Log In',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: OutlinedButton(
                          onPressed: () => _goToPage(const RegisterScreen()),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Create Account',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
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

  // ==========================================
  // SECTIONS
  // ==========================================

  Widget _buildPurchasesSection() {
    return _buildCardWrapper(
      child: Column(
        children: [
          _buildSectionHeader(
            'My Purchases',
            'View Purchase History',
            () => _goToPage(const OrdersScreen()),
          ),
          const Divider(height: 1, color: Color(0xFFE8ECE8)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionIcon(
                  Icons.account_balance_wallet_outlined,
                  'To Pay',
                  badge: 0,
                  onTap: () => _goToPage(const OrdersScreen()),
                ),
                _buildActionIcon(
                  Icons.inventory_2_outlined,
                  'To Ship',
                  badge: 2,
                  onTap: () => _goToPage(const OrdersScreen()),
                ),
                _buildActionIcon(
                  Icons.local_shipping_outlined,
                  'To Receive',
                  badge: 1,
                  onTap: () => _goToPage(const OrdersScreen()),
                ),
                _buildActionIcon(
                  Icons.assignment_return_outlined,
                  'Return/Refund',
                  badge: 0,
                  onTap: () => _goToPage(const OrdersScreen()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletSection() {
    return _buildCardWrapper(
      child: Column(
        children: [
          _buildSectionHeader('My Wallet', '', null),
          const Divider(height: 1, color: Color(0xFFE8ECE8)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionIcon(
                  Icons.account_balance_wallet,
                  'AgriPay',
                  subtitle: '₱ 0.00',
                  iconColor: primaryGreen,
                  onTap: () => _showMessage('AgriPay Balance'),
                ),
                _buildActionIcon(
                  Icons.monetization_on,
                  'Coins',
                  subtitle: '2.10 Coins',
                  subtitleColor: highlightOrange,
                  iconColor: const Color(0xFFFFB300),
                  onTap: () => _showMessage('AgriMart Coins'),
                ),
                _buildActionIcon(
                  Icons.local_activity,
                  'Vouchers',
                  subtitle: '50+ Vouchers',
                  subtitleColor: highlightOrange,
                  badge: 1,
                  iconColor: highlightOrange,
                  onTap: () => _showMessage('My Vouchers'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialServices() {
    return _buildCardWrapper(
      child: Column(
        children: [
          _buildSectionHeader('Financial Services', '', null),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildGridItem(
                    Icons.pie_chart,
                    'APayLater',
                    '₱ 0.00',
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildGridItem(
                    Icons.request_quote,
                    'ALoan',
                    '₱ 50.00',
                    highlightOrange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreActivities() {
    return _buildCardWrapper(
      child: Column(
        children: [
          _buildSectionHeader(
            'More Activities',
            'See All',
            () => _showMessage('More Activities'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildGridItem(
                    Icons.volunteer_activism,
                    'Earn with Us',
                    'Explore Programs',
                    primaryGreen,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildGridItem(
                    Icons.card_giftcard,
                    'Free Samples',
                    'Try products for free',
                    primaryGreen,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildGridItem(
                    Icons.store_rounded,
                    'My Shop',
                    'Manage your shop',
                    highlightOrange,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildGridItem(
                    Icons.dashboard_rounded,
                    'Seller Dashboard',
                    'Sales & orders hub',
                    primaryGreen,
                    onTap: () {
                      final auth = context.read<AuthProvider>();
                      if (auth.isLoggedIn && auth.isFarmer) {
                        _goToPage(const FarmerHome());
                      } else {
                        _showMessage('Seller Dashboard');
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection() {
    return _buildCardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Support',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: ink,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline, color: mutedText),
            title: const Text(
              'Help Center',
              style: TextStyle(fontSize: 13, color: ink),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: mutedText,
              size: 20,
            ),
            dense: true,
            onTap: () => _showMessage('Help Centre'),
          ),
          const Divider(height: 1, indent: 48, color: Color(0xFFE8ECE8)),
          ListTile(
            leading: const Icon(Icons.support_agent, color: mutedText),
            title: const Text(
              'Customer Service',
              style: TextStyle(fontSize: 13, color: ink),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: mutedText,
              size: 20,
            ),
            dense: true,
            onTap: () => _showMessage('Customer Service'),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // HELPER REUSABLE COMPONENTS
  // ==========================================

  Widget _buildCardWrapper({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE8ECE8)),
          bottom: BorderSide(color: Color(0xFFE8ECE8)),
        ),
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(
    String title,
    String actionText,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: ink,
                ),
              ),
            ),
            if (actionText.isNotEmpty) ...[
              Text(
                actionText,
                style: const TextStyle(fontSize: 12, color: mutedText),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: mutedText, size: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionIcon(
    IconData icon,
    String label, {
    int badge = 0,
    String? subtitle,
    Color? subtitleColor,
    Color iconColor = const Color(0xFF4F5A52),
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () => _showMessage(label),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: iconColor, size: 26),
              if (badge > 0)
                Positioned(
                  right: -6,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    constraints: const BoxConstraints(
                      minWidth: 15,
                      minHeight: 15,
                    ),
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
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: ink,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 10, color: subtitleColor ?? mutedText),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGridItem(
    IconData icon,
    String title,
    String subtitle,
    Color iconColor, {
    bool isSubtitleHighlight = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () => _showMessage(title),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE8ECE8)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ink,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: isSubtitleHighlight
                            ? highlightOrange
                            : mutedText,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: mutedText, size: 16),
          ],
        ),
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

  // ==========================================
  // FLOATING BOTTOM NAVIGATION BAR (Matches HomeScreen)
  // ==========================================

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
              badge: provider.unreadCount > 0 ? provider.unreadCount : 4,
            ),
          ),
          // Profile/Me Tab Active
          _navItem(Icons.person_outline_rounded, 'Me', true, () {}),
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
