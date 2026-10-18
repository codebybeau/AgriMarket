import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color primaryGreen = Color(0xFF176B3A);
  static const Color pageBackground = Color(0xFFF0F3F1);
  static const Color mutedText = Color(0xFF6D776F);

  bool orderNotifications = true;
  bool promotionalNotifications = false;
  String selectedLanguage = 'English';

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: primaryGreen,
        ),
      );
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Log out?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Are you sure you want to log out of your AgriMart account?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !mounted) return;

    try {
      await context.read<AuthProvider>().logout();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        _showMessage('Unable to log out. Please try again.');
      }
    }
  }

  Future<void> _chooseLanguage() async {
    final language = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: const Text('Choose Language'),
          children: [
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(dialogContext, 'English');
              },
              child: Row(
                children: [
                  const Expanded(child: Text('English')),
                  if (selectedLanguage == 'English')
                    const Icon(Icons.check, color: primaryGreen),
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(dialogContext, 'Filipino');
              },
              child: Row(
                children: [
                  const Expanded(child: Text('Filipino')),
                  if (selectedLanguage == 'Filipino')
                    const Icon(Icons.check, color: primaryGreen),
                ],
              ),
            ),
          ],
        );
      },
    );

    if (language != null && mounted) {
      setState(() {
        selectedLanguage = language;
      });

      _showMessage('$language selected for this session.');
    }
  }

  void _showAccountInfo() {
    _showMessage('Your account details are available in your Profile.');
  }

  void _showChangePassword() {
    _showMessage('Password reset will be connected to Supabase Auth.');
  }

  void _showAppearance() {
    _showMessage('Dark mode can be connected to your app theme.');
  }

  void _showHelp() {
    _showMessage('AgriMart Help Centre coming soon.');
  }

  void _showCustomerService() {
    _showMessage('AgriMart Customer Service coming soon.');
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'AgriMart',
      applicationVersion: '1.0.0',
      applicationLegalese:
          'Connecting farmers and consumers through a digital marketplace.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('ACCOUNT'),
          _buildSettingsCard([
            _buildSettingsTile(
              icon: Icons.person_outline,
              title: 'My Account',
              subtitle: 'View and manage your account',
              onTap: _showAccountInfo,
            ),
            _buildSettingsTile(
              icon: Icons.lock_outline,
              title: 'Change Password',
              subtitle: 'Update your account password',
              onTap: _showChangePassword,
              showDivider: false,
            ),
          ]),

          const SizedBox(height: 24),

          _buildSectionTitle('NOTIFICATIONS'),
          _buildSettingsCard([
            SwitchListTile(
              value: orderNotifications,
              activeThumbColor: primaryGreen,
              secondary: const Icon(
                Icons.local_shipping_outlined,
                color: primaryGreen,
              ),
              title: const Text(
                'Order Updates',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Receive updates about your orders'),
              onChanged: (value) {
                setState(() {
                  orderNotifications = value;
                });
              },
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            SwitchListTile(
              value: promotionalNotifications,
              activeThumbColor: primaryGreen,
              secondary: const Icon(
                Icons.campaign_outlined,
                color: primaryGreen,
              ),
              title: const Text(
                'Promotions',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Receive offers and announcements'),
              onChanged: (value) {
                setState(() {
                  promotionalNotifications = value;
                });
              },
            ),
          ]),

          const SizedBox(height: 24),

          _buildSectionTitle('PREFERENCES'),
          _buildSettingsCard([
            ListTile(
              leading: const Icon(Icons.language_outlined, color: primaryGreen),
              title: const Text(
                'Language',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(selectedLanguage),
              trailing: const Icon(Icons.chevron_right, color: mutedText),
              onTap: _chooseLanguage,
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _buildSettingsTile(
              icon: Icons.palette_outlined,
              title: 'Appearance',
              subtitle: 'Customize your display preferences',
              onTap: _showAppearance,
              showDivider: false,
            ),
          ]),

          const SizedBox(height: 24),

          _buildSectionTitle('SUPPORT'),
          _buildSettingsCard([
            _buildSettingsTile(
              icon: Icons.help_outline,
              title: 'Help Centre',
              subtitle: 'Get help using AgriMart',
              onTap: _showHelp,
            ),
            _buildSettingsTile(
              icon: Icons.support_agent,
              title: 'Customer Service',
              subtitle: 'Get assistance',
              onTap: _showCustomerService,
            ),
            _buildSettingsTile(
              icon: Icons.info_outline,
              title: 'About AgriMart',
              subtitle: 'Application information and version',
              onTap: _showAbout,
              showDivider: false,
            ),
          ]),

          const SizedBox(height: 28),

          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _confirmLogout,
              icon: const Icon(Icons.logout),
              label: const Text(
                'Log Out',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.red.shade200),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Center(
            child: Text(
              'AgriMart • Version 1.0.0',
              style: TextStyle(color: mutedText, fontSize: 12),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: mutedText,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8E3)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: primaryGreen),
          title: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
          trailing: const Icon(Icons.chevron_right, color: mutedText),
          onTap: onTap,
        ),
        if (showDivider) const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}
