import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/notification_provider.dart';

import 'home_screen.dart';
import 'orders_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

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
            // =========================
            // GREEN HEADER
            // =========================
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                8,
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

              child: Row(
                children: [
                  // =========================
                  // BACK BUTTON
                  // =========================
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      _goToPage(context, const HomeScreen());
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 4),

                  // =========================
                  // CART TITLE
                  // =========================
                  const Expanded(
                    child: Text(
                      'Cart',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // =========================
                  // NOTIFICATION BUTTON
                  // =========================
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
                                _goToPage(context, const NotificationScreen());
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
                ],
              ),
            ),

            // =========================
            // CART CONTENT
            // =========================
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      color: Color(0xFF176B3A),
                      size: 60,
                    ),

                    SizedBox(height: 12),

                    Text(
                      'Your cart is empty',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 6),

                    Text(
                      'Products you add will appear here.',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // =========================
      // BOTTOM NAVIGATION
      // =========================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF176B3A),
        unselectedItemColor: Colors.grey,

        onTap: (index) {
          if (index == 0) {
            _goToPage(context, const HomeScreen());
          }

          if (index == 1) {
            _goToPage(context, const OrdersScreen());
          }

          if (index == 2) {
            _goToPage(context, const NotificationScreen());
          }

          if (index == 3) {
            _goToPage(context, const ProfileScreen());
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
}
