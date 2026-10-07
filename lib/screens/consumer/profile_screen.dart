import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/notification_provider.dart';

import 'home_screen.dart';
import 'orders_screen.dart';
import 'notification_screen.dart';
import 'cart_screen.dart';

import '../auth/login_screen.dart';
import '../auth/register_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _goToPage(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F5),

      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),

        child: Column(
          children: [
            // =====================================================
            // GREEN PROFILE HEADER
            // =====================================================
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                16,
                MediaQuery.of(context).padding.top + 12,
                16,
                20,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF176B3A),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),

              child: Column(
                children: [
                  // =================================================
                  // HEADER TITLE + NOTIFICATION + CART
                  // =================================================
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // =============================================
                      // NOTIFICATION BUTTON
                      // =============================================
                      Consumer<NotificationProvider>(
                        builder: (context, notificationProvider, child) {
                          final count = notificationProvider.unreadCount;

                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    _goToPage(
                                      context,
                                      const NotificationScreen(),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.notifications_outlined,
                                    color: Colors.white,
                                    size: 21,
                                  ),
                                ),
                              ),

                              // RED NOTIFICATION BADGE
                              if (count > 0)
                                Positioned(
                                  right: -2,
                                  top: -3,
                                  child: Container(
                                    width: 17,
                                    height: 17,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        count > 99 ? '99+' : count.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(width: 8),

                      // =============================================
                      // CART BUTTON
                      // =============================================
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            _goToPage(context, const CartScreen());
                          },
                          icon: const Icon(
                            Icons.shopping_cart_outlined,
                            color: Colors.white,
                            size: 21,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // =================================================
                  // USER INFORMATION
                  // =================================================
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // PROFILE ICON
                      Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          color: Color(0xFF176B3A),
                          size: 38,
                        ),
                      ),

                      const SizedBox(width: 14),

                      // USER DETAILS
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Guest User',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 3),

                            Text(
                              'Not signed in',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),

                            SizedBox(height: 3),

                            Text(
                              'Sign in or create an account',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // =================================================
                  // LOGIN + CREATE ACCOUNT
                  // =================================================
                  Row(
                    children: [
                      // LOGIN
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () {
                              _goToPage(context, const LoginScreen());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF176B3A),
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

                      // CREATE ACCOUNT
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: OutlinedButton(
                            onPressed: () {
                              _goToPage(context, const RegisterScreen());
                            },
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

                  const SizedBox(height: 18),

                  // =================================================
                  // FIRST STATS ROW
                  // =================================================
                  Row(
                    children: [
                      _buildStat(number: '0', label: 'Orders'),
                      const SizedBox(width: 3),
                      _buildStat(number: '0', label: 'Reviews'),
                      const SizedBox(width: 3),
                      _buildStat(number: '0', label: 'Favorites'),
                    ],
                  ),

                  const SizedBox(height: 3),

                  // =================================================
                  // SECOND STATS ROW
                  // =================================================
                  Row(
                    children: [
                      _buildStat(number: '0', label: 'Followers'),
                      const SizedBox(width: 3),
                      _buildStat(number: '0', label: 'Following'),
                      const SizedBox(width: 3),

                      const Expanded(child: SizedBox(height: 42)),
                    ],
                  ),
                ],
              ),
            ),

            // =====================================================
            // SCROLLABLE WHITE CONTENT
            // =====================================================
            Expanded(
              child: ListView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  // MY ORDERS
                  _buildProfileOption(
                    icon: Icons.shopping_bag_outlined,
                    title: 'My Orders',
                    subtitle: 'View your orders',
                    onTap: () {
                      _goToPage(context, const OrdersScreen());
                    },
                  ),

                  // FAVORITES
                  _buildProfileOption(
                    icon: Icons.favorite_border,
                    title: 'Favorites',
                    subtitle: 'Your favorite products',
                    onTap: () {},
                  ),

                  // DELIVERY ADDRESS
                  _buildProfileOption(
                    icon: Icons.location_on_outlined,
                    title: 'Delivery Address',
                    subtitle: 'Manage your addresses',
                    onTap: () {},
                  ),

                  // SETTINGS
                  _buildProfileOption(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    subtitle: 'App preferences',
                    onTap: () {},
                  ),

                  // HELP & SUPPORT
                  _buildProfileOption(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    subtitle: 'Get help with AgriMarket',
                    onTap: () {},
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),

      // =========================================================
      // BOTTOM NAVIGATION
      // =========================================================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF176B3A),
        unselectedItemColor: Colors.grey,

        onTap: (index) {
          // HOME
          if (index == 0) {
            _goToPage(context, const HomeScreen());
          }

          // ORDERS
          if (index == 1) {
            _goToPage(context, const OrdersScreen());
          }

          // NOTIFICATIONS
          if (index == 2) {
            _goToPage(context, const NotificationScreen());
          }

          // PROFILE
          if (index == 3) {
            return;
          }
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Notifications',
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

  // ===========================================================
  // PROFILE STAT
  // ===========================================================
  Widget _buildStat({required String number, required String label}) {
    return Expanded(
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 1),

            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================
  // PROFILE OPTION
  // ===========================================================
  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),

        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFF176B3A).withOpacity(0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF176B3A), size: 22),
        ),

        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),

        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),

        trailing: const Icon(Icons.chevron_right, color: Colors.grey),

        onTap: onTap,
      ),
    );
  }
}
