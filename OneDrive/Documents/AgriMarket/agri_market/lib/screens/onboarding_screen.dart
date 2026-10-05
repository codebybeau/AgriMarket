import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🌱', style: TextStyle(fontSize: 70)),

              const SizedBox(height: 20),

              const Text(
                'Shop Fresh Produce',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              const Text(
                'Directly from Farmers',
                style: TextStyle(color: Color(0xFF18A34A), fontSize: 16),
              ),

              const SizedBox(height: 30),

              ElevatedButton(onPressed: () {}, child: const Text('Next')),
            ],
          ),
        ),
      ),
    );
  }
}
