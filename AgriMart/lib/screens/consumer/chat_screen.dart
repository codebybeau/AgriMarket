import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'messages_screen.dart'; // <--- Para sa back navigation pabalik sa Messages list

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const Color primaryGreen = Color(0xFF176B3A);
  static const Color darkGreen = Color(0xFF105B31);
  static const Color pageBackground = Color(0xFFF7F9F7);
  static const Color lightGreenBg = Color(0xFFF2F7F4);
  static const Color accentOrange = Color(0xFFD97706);
  static const Color ink = Color(0xFF17211B);
  static const Color mutedText = Color(0xFF6D776F);

  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _goToMessages() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MessagesScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: primaryGreen,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: pageBackground,
        appBar: AppBar(
          backgroundColor: primaryGreen,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _goToMessages,
          ),
          title: Row(
            children: [
              Stack(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.storefront_rounded, color: primaryGreen, size: 20),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'F23 Agri Parts & Supplies',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Online • 2K+ returning buyers',
                    style: TextStyle(color: Color(0xFFD0E5D5), fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.storefront_outlined, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Date Header
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8E4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Today',
                        style: TextStyle(fontSize: 10, color: mutedText, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  // ==========================================
                  // 1. SHARED PRODUCT CARD (Sent by user/shop)
                  // ==========================================
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 275,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8E4)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: lightGreenBg,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFE2E8E4)),
                                  ),
                                  child: const Icon(
                                    Icons.agriculture_rounded,
                                    color: primaryGreen,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Recoil Starter Assy Gx160, Gx200, 168F...',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: ink,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Text(
                                            '₱375',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: primaryGreen,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Text(
                                            '-20%',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: accentOrange,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1, color: Color(0xFFE8ECE8)),
                          SizedBox(
                            width: double.infinity,
                            height: 36,
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                foregroundColor: primaryGreen,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    bottom: Radius.circular(12),
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Buy Now',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: primaryGreen,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Text('07:16 ✓✓', style: TextStyle(fontSize: 9, color: mutedText)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ==========================================
                  // 2. TEXT MESSAGE FROM CHAT ASSISTANT
                  // ==========================================
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 15,
                        backgroundColor: primaryGreen,
                        child: Icon(Icons.support_agent, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8E4)),
                          ),
                          child: const Text(
                            'Hi! This Recoil Starter Assy fits GX160/GX200/168F/170F (5.5–7.5HP) and is brand new + tested—great for heavy-duty use. You can also grab an available voucher to save more 🛒✨',
                            style: TextStyle(fontSize: 12, color: ink),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 38, top: 4),
                    child: Text('Sent by Chat AI Assistant | T&Cs  07:16', style: TextStyle(fontSize: 9, color: mutedText)),
                  ),
                  const SizedBox(height: 16),

                  // ==========================================
                  // 3. SPECIAL VOUCHER CARD MESSAGE (Green Theme)
                  // ==========================================
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8E4)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                          child: Row(
                            children: const [
                              Icon(Icons.local_activity_rounded, color: primaryGreen, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'Special Voucher For You',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFE8ECE8)),
                        Container(
                          margin: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: lightGreenBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFD0E5D5)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                                decoration: const BoxDecoration(
                                  color: primaryGreen,
                                  borderRadius: BorderRadius.horizontal(
                                    left: Radius.circular(7),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text(
                                      '20%',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'OFF',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Min. Spend ₱249,\nCapped at ₱100',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: ink,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Valid till 01.19.2038',
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: mutedText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: darkGreen,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    minimumSize: Size.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  child: const Text(
                                    'Use',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ==========================================
            // CHAT INPUT BAR AT THE BOTTOM
            // ==========================================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: const Color(0xFFE2E8E4))),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: primaryGreen, size: 24),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.shopping_bag_outlined, color: primaryGreen, size: 24),
                      onPressed: () {},
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: lightGreenBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFD6DDD8)),
                        ),
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(fontSize: 12, color: mutedText),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.emoji_emotions_outlined, color: primaryGreen, size: 24),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}