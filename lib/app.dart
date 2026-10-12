import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';

class AgriMart extends StatelessWidget {
  const AgriMart({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AgriMart',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F6F5),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF176B3A)),
        fontFamily: 'Arial',
      ),
      home: const SplashScreen(),
    );
  }
}
