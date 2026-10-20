import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'farmer_theme.dart';

class FarmerProfileScreen extends StatelessWidget {
  const FarmerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        final user = auth.currentUser;
        final name = auth.fullName;
        final email = user?.email ?? 'No email available';
        final mobile =
            user?.userMetadata?['mobile']?.toString() ?? 'Not provided';
        final farmName = user?.userMetadata?['farm_name']?.toString() ?? '';

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'My Profile',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: agriDarkGreen,
              ),
            ),
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 44,
              backgroundColor: const Color(0xFFE8F5E9),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'F',
                style: const TextStyle(
                  fontSize: 32,
                  color: agriGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Farmer / Seller',
              textAlign: TextAlign.center,
              style: TextStyle(color: agriGreen, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 28),
            _profileItem(Icons.email_outlined, 'Email', email),
            _profileItem(Icons.phone_outlined, 'Mobile number', mobile),
            if (farmName.isNotEmpty)
              _profileItem(Icons.agriculture_outlined, 'Farm name', farmName),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _confirmLogout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,
                minimumSize: const Size.fromHeight(50),
                side: BorderSide(color: Colors.red.shade200),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _profileItem(IconData icon, String title, String value) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: agriGreen),
        title: Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('Are you sure you want to log out of AgriMart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: agriGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !context.mounted) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.logout();

    if (!context.mounted) return;

    if (auth.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Unable to log out.')),
      );
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}
