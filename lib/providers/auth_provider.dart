import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  StreamSubscription<AuthState>? _authSubscription;

  bool isLoading = false;
  String? errorMessage;
  String? infoMessage;

  AuthProvider() {
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      _,
    ) {
      notifyListeners();
    });
  }

  User? get currentUser => _authService.currentUser;

  bool get isLoggedIn => currentUser != null;

  String get fullName {
    final metadata = currentUser?.userMetadata;

    final name = metadata?['full_name']?.toString().trim();

    if (name != null && name.isNotEmpty) {
      return name;
    }

    final alternativeName = metadata?['name']?.toString().trim();

    if (alternativeName != null && alternativeName.isNotEmpty) {
      return alternativeName;
    }

    return 'Guest';
  }

  String get role => currentUser?.userMetadata?['role']?.toString() ?? 'guest';

  bool get isFarmer => role.toLowerCase() == 'farmer';

  bool get isConsumer => role.toLowerCase() == 'consumer';

  // LOGIN
  Future<bool> login({required String email, required String password}) async {
    isLoading = true;
    errorMessage = null;
    infoMessage = null;
    notifyListeners();

    try {
      await _authService.login(email: email, password: password);

      debugPrint('Login successful');
      debugPrint('User: ${currentUser?.email}');
      debugPrint('Metadata: ${currentUser?.userMetadata}');
      debugPrint('Name: $fullName');

      return true;
    } on AuthException catch (e) {
      errorMessage = e.message;
      return false;
    } catch (e) {
      errorMessage = 'Login failed. Please try again.';
      debugPrint('Login error: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // REGISTER
  Future<bool> register({
    required String fullName,
    required String mobile,
    required String email,
    required String password,
    required String accountType,
    String? farmName,
  }) async {
    isLoading = true;
    errorMessage = null;
    infoMessage = null;
    notifyListeners();

    try {
      final response = await _authService.register(
        fullName: fullName,
        mobile: mobile,
        email: email,
        password: password,
        accountType: accountType,
        farmName: farmName,
      );

      if (response.user == null) {
        errorMessage = 'Registration failed. No user was returned.';
        return false;
      }

      if (response.session == null) {
        infoMessage = 'Account created. Please check your email to confirm your account, then log in.';
        return false;
      }

      debugPrint('Registration successful');
      debugPrint('Metadata: ${response.user!.userMetadata}');

      return true;
    } on AuthException catch (e) {
      errorMessage = e.message;
      return false;
    } catch (e) {
      errorMessage = 'Registration failed. Please try again.';
      debugPrint('Registration error: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // RESET PASSWORD
  Future<bool> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);

      errorMessage = null;
      infoMessage = 'Password reset email sent. Check your inbox.';

      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Could not send password reset email. Please try again.';
      infoMessage = null;

      notifyListeners();
      debugPrint('Password reset error: $e');
      return false;
    }
  }

  // LOGOUT
  Future<void> logout() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authService.logout();
    } on AuthException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = 'Logout failed. Please try again.';
      debugPrint('Logout error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    errorMessage = null;
    infoMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
