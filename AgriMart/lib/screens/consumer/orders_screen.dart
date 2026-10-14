import 'package:flutter/material.dart';
import 'profile_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF176B3A),
        title: const Text('My Orders', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },
        ),
      ),
      body: const Center(
        child: Text(
          'No orders yet',
          style: TextStyle(fontSize: 16, color: Color(0xFF6D776F)),
        ),
      ),
    );
  }
}