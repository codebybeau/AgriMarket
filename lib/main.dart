import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/notification_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => NotificationProvider(),
      child: const AgriMartApp(),
    ),
  );
}
