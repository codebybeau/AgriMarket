
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const Color agriGreen = Color(0xFF2E7D32);
const Color agriDarkGreen = Color(0xFF1B5E20);
const Color agriBackground = Color(0xFFE8F0E6);
const Color agriCard = Color(0xFFF1F6EF);
const Color agriText = Color(0xFF1B3D2A);
const Color agriDescription = Color(0xFF526357);

class FarmerProfileScreen extends StatefulWidget {
  const FarmerProfileScreen({super.key});

  @override
  State<FarmerProfileScreen> createState() =>
      _FarmerProfileScreenState();
}

class _FarmerProfileScreenState extends State<FarmerProfileScreen> {
  final supabase = Supabase.instance.client;

  String _fullName = 'Farmer';
  String _email = '';
  bool _isLoading = true;
  bool _notificationsEnabled = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // LOAD FARMER PROFILE
  Future<void> _loadProfile() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'No logged-in user found.';
      });
      return;
    }

    try {
      final response = await supabase
          .from('profiles')
          .select('full_name')
          .eq('id', user.id)
          .maybeSingle();

      if (!mounted) return;

      setState(() {
        _fullName = response?['full_name'] ??
            user.userMetadata?['full_name'] ??
            'Farmer';

        _email = user.email ?? 'No email available';
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _email = user.email ?? 'No email available';
        _isLoading = false;
        _errorMessage = 'Unable to load profile information.';
      });

      debugPrint('Error loading farmer profile: $e');
    }
  }

  // GET FARMER INITIALS
  String _getInitials() {
    final words = _fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    if (words.isEmpty) return 'F';

    if (words.length == 1) {
      return words.first[0].toUpperCase();
    }

    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }

  // SHOW MESSAGE
  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: agriDarkGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // EDIT PROFILE
  Future<void> _editProfile() async {
    final controller = TextEditingController(text: _fullName);

    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: agriCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Edit Profile',
            style: TextStyle(
              color: agriDarkGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: controller,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Full Name',
              prefixIcon: const Icon(
                Icons.person_outline,
                color: agriGreen,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: agriGreen,
                  width: 1.5,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancel',
                style: TextStyle(color: agriDescription),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: agriGreen,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final name = controller.text.trim();

                if (name.isEmpty) return;

                Navigator.pop(dialogContext, name);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (newName == null || !mounted) return;

    final user = supabase.auth.currentUser;

    if (user == null) {
      _showMessage('Please log in again.');
      return;
    }

    try {
      await supabase
          .from('profiles')
          .update({'full_name': newName})
          .eq('id', user.id);

      if (!mounted) return;

      setState(() {
        _fullName = newName;
      });

      _showMessage('Profile updated successfully!');
    } catch (e) {
      debugPrint('Error updating profile: $e');

      if (!mounted) return;

      _showMessage('Unable to update profile. Please try again.');
    }
  }

  // SEND PASSWORD RESET EMAIL
  Future<void> _sendPasswordReset() async {
    if (_email.isEmpty || _email == 'No email available') {
      _showMessage('No email address is available.');
      return;
    }

    try {
      await supabase.auth.resetPasswordForEmail(_email);

      if (!mounted) return;

      _showMessage('Password reset email sent to $_email');
    } catch (e) {
      debugPrint('Password reset error: $e');

      if (!mounted) return;

      _showMessage('Unable to send password reset email.');
    }
  }

  // PRIVACY AND SECURITY
  void _showPrivacySecurity() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: agriCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.security,
                color: agriGreen,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Privacy & Security',
                  style: TextStyle(
                    color: agriDarkGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            'Keep your account secure. You can request a password '
            'reset email to update your account password.',
            style: TextStyle(
              color: agriDescription,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: agriGreen,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                _sendPasswordReset();
              },
              child: const Text('Reset Password'),
            ),
          ],
        );
      },
    );
  }

  // ABOUT AGRIMART
  void _showAboutAgriMart() {
    showAboutDialog(
      context: context,
      applicationName: 'AgriMart',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.agriculture,
        color: agriGreen,
        size: 40,
      ),
      children: const [
        Text(
          'AgriMart is a platform designed to connect farmers '
          'and customers through convenient agricultural '
          'product management and marketplace services.',
        ),
      ],
    );
  }

  // LOGOUT
  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: agriCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              color: agriDarkGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to log out?',
            style: TextStyle(color: agriDescription),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: agriDescription),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: agriGreen,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !mounted) return;

    try {
      await supabase.auth.signOut();
    } catch (e) {
      debugPrint('Logout error: $e');

      if (!mounted) return;

      _showMessage('Logout failed. Please try again.');
    }
  }

  // ACCOUNT INFORMATION CARD
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: agriCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: agriGreen.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: agriGreen.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: agriGreen,
              size: 22,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: agriDescription,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: agriText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // SETTINGS TILE
  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 5,
      ),
      leading: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: agriGreen.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: agriGreen,
          size: 21,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: agriText,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 11,
          color: agriDescription,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: agriGreen,
      ),
      onTap: onTap,
    );
  }

  // PROFILE CONTENT
  Widget _buildProfileContent() {
    return RefreshIndicator(
      onRefresh: _loadProfile,
      color: agriGreen,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 30),
        children: [
          // PROFILE HEADER
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 24,
            ),
            decoration: BoxDecoration(
              color: agriDarkGreen,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 43,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 39,
                    backgroundColor: agriGreen,
                    child: Text(
                      _getInitials(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 29,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  _fullName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'AgriMart Farmer',
                  style: TextStyle(
                    color: Color(0xFFDCEBDD),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        color: Colors.white,
                        size: 14,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Farmer Account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // ACCOUNT INFORMATION
          const Text(
            'Account Information',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: agriDarkGreen,
            ),
          ),

          const SizedBox(height: 12),

          _buildInfoCard(
            icon: Icons.person_outline,
            title: 'Full Name',
            value: _fullName,
          ),

          const SizedBox(height: 11),

          _buildInfoCard(
            icon: Icons.email_outlined,
            title: 'Email Address',
            value: _email,
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ],

          const SizedBox(height: 25),

          // SETTINGS
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: agriDarkGreen,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: agriCard,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: agriGreen.withValues(alpha: 0.10),
              ),
            ),
            child: Column(
              children: [
                _buildSettingsTile(
                  icon: Icons.edit_outlined,
                  title: 'Edit Profile',
                  subtitle: 'Update your farmer name',
                  onTap: _editProfile,
                ),

                const Divider(
                  height: 1,
                  indent: 15,
                  endIndent: 15,
                  color: Color(0xFFD5E3D3),
                ),

                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 4,
                  ),
                  secondary: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: agriGreen.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: agriGreen,
                      size: 21,
                    ),
                  ),
                  title: const Text(
                    'Notifications',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: agriText,
                    ),
                  ),
                  subtitle: const Text(
                    'Notification preference',
                    style: TextStyle(
                      fontSize: 11,
                      color: agriDescription,
                    ),
                  ),
                  activeThumbColor: agriGreen,
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });

                    _showMessage(
                      value
                          ? 'Notifications enabled.'
                          : 'Notifications disabled.',
                    );
                  },
                ),

                const Divider(
                  height: 1,
                  indent: 15,
                  endIndent: 15,
                  color: Color(0xFFD5E3D3),
                ),

                _buildSettingsTile(
                  icon: Icons.lock_outline,
                  title: 'Privacy & Security',
                  subtitle: 'Manage your account security',
                  onTap: _showPrivacySecurity,
                ),

                const Divider(
                  height: 1,
                  indent: 15,
                  endIndent: 15,
                  color: Color(0xFFD5E3D3),
                ),

                _buildSettingsTile(
                  icon: Icons.info_outline,
                  title: 'About AgriMart',
                  subtitle: 'App information and version',
                  onTap: _showAboutAgriMart,
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // LOGOUT BUTTON
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text(
                'Logout',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: agriGreen,
                foregroundColor: Colors.white,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),

          const Center(
            child: Text(
              'AgriMart • Version 1.0.0',
              style: TextStyle(
                color: agriDescription,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // MAIN SCREEN
  @override
  Widget build(BuildContext context) {
    return Container(
      color: agriBackground,
      child: Column(
        children: [
          // HEADER
          Container(
            width: double.infinity,
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: const BoxDecoration(
              color: agriDarkGreen,
              boxShadow: [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  color: Colors.white,
                  size: 23,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'My Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _loadProfile,
                  tooltip: 'Refresh profile',
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // PROFILE BODY
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: agriGreen,
                    ),
                  )
                : _buildProfileContent(),
          ),
        ],
      ),
    );
  }
}
