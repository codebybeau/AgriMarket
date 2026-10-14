import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'home_screen.dart';
import 'chat_screen.dart'; // <--- Siguraduhing naka-import ang chat_screen.dart

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  static const Color primaryGreen = Color(0xFF176B3A);
  static const Color darkGreen = Color(0xFF105B31);
  static const Color pageBackground = Color(0xFFF7F9F7);
  static const Color ink = Color(0xFF17211B);
  static const Color mutedText = Color(0xFF8D9A91);
  static const Color activeGreen = Color(0xFF2ECC71);

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // 10 Sample Conversations matching AgriMart sellers & farm suppliers
  final List<Map<String, dynamic>> _conversations = [
    {
      'id': '1',
      'name': 'Green Valley Farm',
      'message': 'Your order of ampalaya is freshly packed and ready for delivery!',
      'time': '2 min ago',
      'unreadCount': 3,
      'isOnline': true,
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300',
    },
    {
      'id': '2',
      'name': 'Fresh Harvest Farm',
      'message': 'We have new stock of Carabao mangoes from Guimaras.',
      'time': '1 hr ago',
      'unreadCount': 1,
      'isOnline': true,
      'avatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300',
    },
    {
      'id': '3',
      'name': 'Farm Supplies PH',
      'message': 'The fertilizer stocks have arrived. Ready for pickup or delivery.',
      'time': 'Yesterday',
      'unreadCount': 0,
      'isOnline': false,
      'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=300',
    },
    {
      'id': '4',
      'name': 'Laguna Free Range Farm',
      'message': 'Thank you for your order! Enjoy your native chicken.',
      'time': '3 days ago',
      'unreadCount': 0,
      'isOnline': false,
      'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300',
    },
    {
      'id': '5',
      'name': 'Dela Cruz Family Organic',
      'message': 'Good morning! Would you like us to schedule weekly produce shipments?',
      'time': '4 days ago',
      'unreadCount': 2,
      'isOnline': true,
      'avatar': 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=300',
    },
    {
      'id': '6',
      'name': 'Nueva Ecija Grain Co-op',
      'message': 'Your 50kg sack of Dinorado Premium Rice is on its way.',
      'time': '5 days ago',
      'unreadCount': 0,
      'isOnline': false,
      'avatar': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=300',
    },
    {
      'id': '7',
      'name': 'Batangas Poultry Hub',
      'message': 'Fresh table eggs grade AA are now on sale at ₱210 per tray!',
      'time': '1 wk ago',
      'unreadCount': 1,
      'isOnline': true,
      'avatar': 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=300',
    },
    {
      'id': '8',
      'name': 'Benguet Highland Veggies',
      'message': 'Salamat po! Please send us a photo once your carrots arrive.',
      'time': '1 wk ago',
      'unreadCount': 0,
      'isOnline': false,
      'avatar': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=300',
    },
    {
      'id': '9',
      'name': 'AgriSeeds & Equipment',
      'message': 'Hello, the hybrid tomato seed packets you requested are available.',
      'time': '2 wks ago',
      'unreadCount': 0,
      'isOnline': false,
      'avatar': 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=300',
    },
    {
      'id': '10',
      'name': 'Pampanga Freshwater Fisheries',
      'message': 'Live Tilapia can be delivered tomorrow by 8:00 AM.',
      'time': '2 wks ago',
      'unreadCount': 0,
      'isOnline': false,
      'avatar': 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=300',
    },
  ];

  int get _totalUnread {
    int total = 0;
    for (var c in _conversations) {
      total += (c['unreadCount'] as int);
    }
    return total;
  }

  List<Map<String, dynamic>> get _filteredConversations {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _conversations;
    return _conversations.where((c) {
      final nameMatch = c['name'].toString().toLowerCase().contains(query);
      final messageMatch = c['message'].toString().toLowerCase().contains(query);
      return nameMatch || messageMatch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _goToPage(Widget page) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: darkGreen,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: pageBackground,
        body: Column(
          children: [
            // ==============================================
            // GREEN TOP HEADER CARD
            // ==============================================
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                12,
                MediaQuery.of(context).padding.top + 12,
                16,
                20,
              ),
              decoration: const BoxDecoration(
                color: darkGreen,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
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
                      const SizedBox(width: 4),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Messages',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$_totalUnread unread',
                            style: const TextStyle(
                              color: Color(0xFFD0E5D5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Search Field
                  Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: const TextStyle(fontSize: 13, color: ink),
                      decoration: InputDecoration(
                        hintText: 'Search conversations',
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFADB5AF),
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF8D9A91),
                          size: 20,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 11),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ==============================================
            // CONVERSATIONS LIST
            // ==============================================
            Expanded(
              child: _filteredConversations.isEmpty
                  ? const Center(
                      child: Text(
                        'No conversations found.',
                        style: TextStyle(color: mutedText, fontSize: 13),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _filteredConversations.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        indent: 72,
                        endIndent: 16,
                        color: Color(0xFFEBF0EC),
                      ),
                      itemBuilder: (context, index) {
                        final chat = _filteredConversations[index];
                        return _buildConversationTile(chat);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================
  // CONVERSATION TILE WIDGET
  // ==============================================

  Widget _buildConversationTile(Map<String, dynamic> chat) {
    final bool hasUnread = (chat['unreadCount'] as int) > 0;

    return InkWell(
      // Konekto patungo sa ChatScreen kapag pinindot ang conversation
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ChatScreen(),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFE2E8E4),
                  backgroundImage: NetworkImage(chat['avatar']),
                ),
                if (chat['isOnline'] == true)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: activeGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          chat['name'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
                            color: ink,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        chat['time'],
                        style: TextStyle(
                          fontSize: 11,
                          color: hasUnread ? primaryGreen : mutedText,
                          fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat['message'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: hasUnread
                                ? const Color(0xFF2C3E30)
                                : const Color(0xFF7A867E),
                            fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (hasUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(5),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          decoration: const BoxDecoration(
                            color: primaryGreen,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${chat['unreadCount']}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}