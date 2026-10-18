import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';

class AgriMartApp extends StatelessWidget {
  const AgriMartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AgriMart',
      home: const SplashScreen(),
    );
  }
}
