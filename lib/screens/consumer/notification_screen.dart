import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/notification_provider.dart';

import 'home_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import 'cart_screen.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

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
            // HEADER
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
                  // BACK BUTTON
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

                  // TITLE
                  const Expanded(
                    child: Text(
                      'Notifications',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // CART BUTTON
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
            ),

            // NOTIFICATIONS
            Expanded(
              child: Consumer<NotificationProvider>(
                builder: (context, notificationProvider, child) {
                  final notifications = notificationProvider.notifications;

                  // EMPTY STATE
                  if (notifications.isEmpty) {
                    return const Center(
                      child: Text(
                        'No notifications',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }

                  // NOTIFICATION LIST
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 1,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),

                          // ICON
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF176B3A),
                            child: const Icon(
                              Icons.message,
                              color: Colors.white,
                            ),
                          ),

                          // TITLE
                          title: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),

                          // MESSAGE
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(notification.message),
                          ),

                          // UNREAD DOT
                          trailing: notification.isRead
                              ? null
                              : const Icon(
                                  Icons.circle,
                                  color: Colors.red,
                                  size: 10,
                                ),

                          // MARK AS READ
                          onTap: () {
                            notificationProvider.markAsRead(notification.id);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // BOTTOM NAVIGATION
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
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
            return;
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
