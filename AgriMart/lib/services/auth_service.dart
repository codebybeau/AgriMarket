import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

  // REGISTER
  Future<AuthResponse> register({
    required String fullName,
    required String mobile,
    required String email,
    required String password,
    required String accountType,
    String? farmName,
  }) async {
    final normalizedType = accountType.trim().toLowerCase();

    final role = normalizedType == 'farmer' || normalizedType == 'seller'
        ? 'farmer'
        : 'consumer';

    return await _supabase.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'full_name': fullName.trim(),
        'mobile': mobile.trim(),
        'role': role,
        'account_type': normalizedType,
        'farm_name': farmName?.trim() ?? '',
      },
    );
  }

  // LOGIN
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  // LOGOUT
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  // SEND PASSWORD RESET EMAIL
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email.trim());
  }
}
