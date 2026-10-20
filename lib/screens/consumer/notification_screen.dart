import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/notification_provider.dart';
import 'home_screen.dart';
import 'categories_screen.dart';
import 'marketplace_screen.dart';
import 'profile_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  static const Color primaryGreen = Color(0xFF176B3A);
  static const Color pageBackground = Color(0xFFF7F9F7);
  static const Color unreadBg = Color(0xFFEEF9F1);
  static const Color ink = Color(0xFF17211B);
  static const Color mutedText = Color(0xFF6D776F);

  String _selectedTab = 'All';

  // Mock data perfectly matching the UI reference image
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 1,
      'isNew': true,
      'type': 'alert',
      'title': 'Fresh Harvest Alert',
      'message': 'Mang Celso Farm listed freshly harvested ampalaya for the Kidapawan service area. Sample alert only.',
      'time': '10 min ago',
      'isRead': false,
    },
    {
      'id': 2,
      'isNew': true,
      'type': 'order',
      'title': 'Order Confirmed',
      'message': 'Your order #ORD-2024-001 has been confirmed by the seller. Mang Celso Farm is preparing your items.',
      'time': '30 min ago',
      'isRead': false,
    },
    {
      'id': 3,
      'isNew': true,
      'type': 'order',
      'title': 'Order Shipped',
      'message': 'Your order #ORD-2024-001 is on its way! Expected delivery: Nov 25. Tracking: AGM-2024-1234.',
      'time': '2 hours ago',
      'isRead': false,
    },
    {
      'id': 4,
      'isNew': true,
      'type': 'promo',
      'title': '🎊 Harvest Season Sale!',
      'message': 'Get up to 30% off on all fresh vegetables and fruits this weekend only. Sample promotional content.',
      'time': '5 hours ago',
      'isRead': false,
    },
    {
      'id': 5,
      'isNew': false,
      'type': 'order_muted',
      'title': 'Order Delivered',
      'message': 'Your order #ORD-2024-002 has been delivered successfully. Enjoy your Carabao Mangoes! Please rate the seller.',
      'time': '1 day ago',
      'isRead': true,
    },
    {
      'id': 6,
      'isNew': false,
      'type': 'alert_muted',
      'title': 'Product Update',
      'message': 'New features have been added to your AgriMart experience. Tap here to learn more about the latest updates.',
      'time': '2 days ago',
      'isRead': true,
    },
  ];

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

  void _markAllRead() {
    setState(() {
      for (var n in _notifications) {
        n['isRead'] = true;
      }
    });
    // In a real app, you would also call your provider here:
    // context.read<NotificationProvider>().markAllAsRead();
  }

  @override
  Widget build(BuildContext context) {
    // Filter lists based on sections
    final newNotifications = _notifications
        .where((n) => n['isNew'] == true)
        .toList();
    final earlierNotifications = _notifications
        .where((n) => n['isNew'] == false)
        .toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: primaryGreen,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor:
            Colors.transparent, // Required for floating bar effect
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: pageBackground,
        extendBody: true, // Required for floating bar effect
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 20),
                children: [
                  if (newNotifications.isNotEmpty) ...[
                    _buildSectionTitle('NEW'),
                    ...newNotifications.map((n) => _buildNotificationItem(n)),
                  ],
                  if (earlierNotifications.isNotEmpty) ...[
                    _buildSectionTitle('EARLIER'),
                    ...earlierNotifications.map(
                      (n) => _buildNotificationItem(n),
                    ),
                  ],
                  const SizedBox(
                    height: 110,
                  ), // Padding to avoid floating nav bar overlap
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNavigation(),
      ),
    );
  }

  // ==============================================
  // HEADER
  // ==============================================

  Widget _buildHeader() {
    int unreadCount = _notifications
        .where((n) => !(n['isRead'] as bool))
        .length;

    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        MediaQuery.of(context).padding.top + 12,
        16,
        16,
      ),
      decoration: const BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => _goToPage(const HomeScreen()),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$unreadCount unread',
                      style: const TextStyle(
                        color: Color(0xFFB1D4B8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _markAllRead,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check, color: Colors.white, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'Mark all read',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // TABS
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Row(
              children: [
                _buildTabPill('All'),
                const SizedBox(width: 16),
                _buildTabPill('Orders'),
                const SizedBox(width: 16),
                _buildTabPill('Updates'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabPill(String label) {
    bool isSelected = _selectedTab == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = label),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14 : 4,
          vertical: 6,
        ),
        decoration: isSelected
            ? BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? primaryGreen : const Color(0xFFB1D4B8),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ==============================================
  // NOTIFICATION LIST
  // ==============================================

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF8A958E),
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    bool isRead = notification['isRead'];
    String type = notification['type'];

    // Icon Configuration based on notification type
    Color iconBgColor;
    Color iconColor;
    IconData iconData;

    switch (type) {
      case 'alert':
      case 'promo':
        iconBgColor = const Color(0xFFFFEDDB);
        iconColor = const Color(0xFFFF8A5C);
        iconData = Icons.local_offer_outlined;
        break;
      case 'order':
        iconBgColor = const Color(0xFFF1E4FF);
        iconColor = const Color(0xFF9E47FF);
        iconData = Icons.inventory_2_outlined;
        break;
      case 'order_muted':
        iconBgColor = const Color(0xFFF5EDFF);
        iconColor = const Color(0xFFC9A1FF);
        iconData = Icons.inventory_2_outlined;
        break;
      default:
        iconBgColor = const Color(0xFFF0F4F1);
        iconColor = const Color(0xFFA1AFA5);
        iconData = Icons.notifications_outlined;
    }

    return Container(
      decoration: BoxDecoration(
        color: isRead ? Colors.white : unreadBg,
        border: const Border(
          bottom: BorderSide(color: Color(0xFFEFEFEF), width: 0.5),
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() => notification['isRead'] = true);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, color: iconColor, size: 18),
              ),
              const SizedBox(width: 14),
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification['title'],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isRead ? FontWeight.w600 : FontWeight.w800,
                        color: ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification['message'],
                      style: const TextStyle(
                        fontSize: 11,
                        color: mutedText,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification['time'],
                      style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xFF9AA59D),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Unread Dot Indicator
              if (!isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF00C853),
                    shape: BoxShape.circle,
                  ),
                )
              else
                const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================================
  // FLOATING BOTTOM NAV (Matches HomeScreen)
  // ==============================================

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
          // Notifications Tab Active
          Consumer<NotificationProvider>(
            builder: (context, provider, _) => _navItem(
              Icons.notifications_none_rounded,
              'Notifications',
              true,
              () {}, // Current page
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
