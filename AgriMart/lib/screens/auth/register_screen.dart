import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'login_screen.dart';
import '../consumer/profile_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const Color primaryGreen = Color(0xFF176B3A);
  static const Color darkGreen = Color(0xFF105B31);
  static const Color pageBackground = Color(0xFFF7F9F7);
  static const Color ink = Color(0xFF17211B);
  static const Color mutedText = Color(0xFF6D776F);

  String _accountType = 'Buyer';

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _farmNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _farmNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _goToPage(Widget page) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  void _handleRegister() {
    _showMessage('Account created successfully!');
    _goToPage(const ProfileScreen());
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: darkGreen,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: primaryGreen,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: pageBackground,
        body: SingleChildScrollView(
          child: Column(
            children: [
              // HEADER CARD
              _buildHeaderCard(),

              // FORM CONTENT
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ACCOUNT TYPE TOGGLE SWITCH
                    _buildAccountTypeToggle(),
                    const SizedBox(height: 20),

                    // Full Name Field
                    _buildFieldLabel('FULL NAME'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _fullNameController,
                      textCapitalization: TextCapitalization.words,
                      style: const TextStyle(fontSize: 13, color: ink),
                      decoration: _inputDecoration(
                        hintText: 'Enter full name',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Mobile Number Field
                    _buildFieldLabel('MOBILE NUMBER'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _mobileController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(fontSize: 13, color: ink),
                      decoration: _inputDecoration(
                        hintText: 'Enter mobile number',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Email Address Field
                    _buildFieldLabel('EMAIL ADDRESS'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(fontSize: 13, color: ink),
                      decoration: _inputDecoration(
                        hintText: 'Enter email address',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Extra field for Seller/Farmer mode
                    if (_accountType == 'Seller') ...[
                      _buildFieldLabel('FARM/BUSINESS NAME'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _farmNameController,
                        textCapitalization: TextCapitalization.words,
                        style: const TextStyle(fontSize: 13, color: ink),
                        decoration: _inputDecoration(
                          hintText: 'Enter your farm or business name',
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Password Field
                    _buildFieldLabel('PASSWORD'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(fontSize: 13, color: ink),
                      decoration: _inputDecoration(
                        hintText: 'Create a strong password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: const Color(0xFF98A19B),
                            size: 18,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Terms & Conditions Disclaimer
                    Wrap(
                      alignment: WrapAlignment.start,
                      children: [
                        const Text(
                          'By creating an account, you agree to AgriMart\'s ',
                          style: TextStyle(color: mutedText, fontSize: 11),
                        ),
                        GestureDetector(
                          onTap: () => _showMessage('Terms of Service opened'),
                          child: const Text(
                            'Terms of Service',
                            style: TextStyle(
                              color: primaryGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Text(
                          ' and ',
                          style: TextStyle(color: mutedText, fontSize: 11),
                        ),
                        GestureDetector(
                          onTap: () => _showMessage('Privacy Policy opened'),
                          child: const Text(
                            'Privacy Policy',
                            style: TextStyle(
                              color: primaryGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Text(
                          '.',
                          style: TextStyle(color: mutedText, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Create Account Button with Shadow Effect
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: darkGreen,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: darkGreen.withOpacity(0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _handleRegister,
                          borderRadius: BorderRadius.circular(12),
                          child: const Center(
                            child: Text(
                              'Create Account',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Already have an account? Log In
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(color: mutedText, fontSize: 12),
                        ),
                        GestureDetector(
                          onTap: () => _goToPage(const LoginScreen()),
                          child: const Text(
                            'Log In',
                            style: TextStyle(
                              color: primaryGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================================
  // HEADER CARD BUILDER
  // ==============================================

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 12,
        16,
        28,
      ),
      decoration: const BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back Button
          GestureDetector(
            onTap: () => _goToPage(const ProfileScreen()),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.chevron_left, color: Colors.white, size: 20),
                Text(
                  'Back',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Title & Subtitle
          const Text(
            'Create Account',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Join the AgriMart community',
            style: TextStyle(
              color: Color(0xFFD0E5D5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================
  // ACCOUNT TYPE TOGGLE SWITCH
  // ==============================================

  Widget _buildAccountTypeToggle() {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF2F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _accountType = 'Buyer'),
              child: Container(
                decoration: BoxDecoration(
                  color: _accountType == 'Buyer' ? darkGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Buyer',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _accountType == 'Buyer' ? Colors.white : const Color(0xFF6B756E),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _accountType = 'Seller'),
              child: Container(
                decoration: BoxDecoration(
                  color: _accountType == 'Seller' ? darkGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Seller/Farmer',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _accountType == 'Seller' ? Colors.white : const Color(0xFF6B756E),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================
  // HELPER COMPONENTS
  // ==============================================

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF6A756E),
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  InputDecoration _inputDecoration({required String hintText, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFFADB5AF), fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF2F5F3),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFD6DDD8),
          width: 1.0,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFD6DDD8),
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: primaryGreen,
          width: 1.5,
        ),
      ),
    );
  }
}