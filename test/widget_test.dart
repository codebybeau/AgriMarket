import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:agri_market/app.dart';
import 'package:agri_market/providers/cart_provider.dart';
import 'package:agri_market/providers/notification_provider.dart';
import 'package:agri_market/providers/order_provider.dart';
import 'package:agri_market/providers/product_provider.dart';

void main() {
  testWidgets('AgriMart app starts successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ProductProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(create: (_) => OrderProvider()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ],
        child: const AgriMart(),
      ),
    );

    await tester.pump();

    expect(find.byType(AgriMart), findsOneWidget);
  });
}
