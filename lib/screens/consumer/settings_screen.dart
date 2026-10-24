import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'address_screen.dart';
import '../../providers/address_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _openAddressScreen(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddressScreen()),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature is not available yet.')));
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      // Connect this to your authentication provider or Supabase sign-out.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connect this button to your logout function.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ACCOUNT SECTION
          _buildSectionTitle('Account'),

          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _buildSettingsTile(
                  icon: Icons.person_outline,
                  title: 'My Account',
                  subtitle: 'Manage your profile information',
                  onTap: () {
                    _showComingSoon(context, 'My Account');
                  },
                ),
                const Divider(height: 1),

                // DELIVERY ADDRESS BUTTON
                _buildSettingsTile(
                  icon: Icons.location_on_outlined,
                  title: 'Delivery Address',
                  subtitle: 'Add or edit your checkout address',
                  trailing: Consumer<AddressProvider>(
                    builder: (context, address, child) {
                      return Icon(
                        address.hasAddress
                            ? Icons.check_circle
                            : Icons.chevron_right,
                        color: address.hasAddress ? Colors.green : null,
                      );
                    },
                  ),
                  onTap: () => _openAddressScreen(context),
                ),

                const Divider(height: 1),
                _buildSettingsTile(
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  subtitle: 'Update your account password',
                  onTap: () {
                    _showComingSoon(context, 'Change Password');
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // PREFERENCES SECTION
          _buildSectionTitle('Preferences'),

          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _buildSettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Manage notification preferences',
                  onTap: () {
                    _showComingSoon(context, 'Notifications');
                  },
                ),
                const Divider(height: 1),
                _buildSettingsTile(
                  icon: Icons.language_outlined,
                  title: 'Language',
                  subtitle: 'Choose your preferred language',
                  onTap: () {
                    _showComingSoon(context, 'Language');
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // SUPPORT SECTION
          _buildSectionTitle('Support'),

          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _buildSettingsTile(
                  icon: Icons.help_outline,
                  title: 'Help Center',
                  subtitle: 'Get help with AgriMarket',
                  onTap: () {
                    _showComingSoon(context, 'Help Center');
                  },
                ),
                const Divider(height: 1),
                _buildSettingsTile(
                  icon: Icons.info_outline,
                  title: 'About AgriMarket',
                  subtitle: 'App information',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'AgriMarket',
                      applicationVersion: '1.0.0',
                      applicationLegalese: 'Connecting farmers and consumers.',
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // LOGOUT BUTTON
          OutlinedButton.icon(
            onPressed: () => _showLogoutDialog(context),
            icon: const Icon(Icons.logout),
            label: const Text('Log Out'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: theme.colorScheme.error),
            ),
          ),

          const SizedBox(height: 24),
          Center(
            child: Text(
              'AgriMarket v1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
