import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddressProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _addresses = [];

  List<Map<String, dynamic>> get addresses => List.unmodifiable(_addresses);

  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;

  Map<String, dynamic>? get defaultAddress {
    for (final address in _addresses) {
      if (address['is_default'] == true) return address;
    }

    return _addresses.isEmpty ? null : _addresses.first;
  }

  bool get hasAddress => _addresses.isNotEmpty;

  Future<void> loadAddress() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      errorMessage = 'Please log in to view your addresses.';
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _supabase
          .from('user_addresses')
          .select()
          .eq('user_id', user.id)
          .order('is_default', ascending: false)
          .order('created_at', ascending: false);

      _addresses = List<Map<String, dynamic>>.from(result);
    } catch (e) {
      errorMessage = 'Could not load addresses: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveAddress({
    int? id,
    required String name,
    required String phone,
    required String address,
    required String landmarkText,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      errorMessage = 'Please log in before saving an address.';
      notifyListeners();
      return false;
    }

    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      final shouldBeDefault = id != null
          ? _addresses.any(
              (item) => item['id'] == id && item['is_default'] == true,
            )
          : _addresses.isEmpty;

      final values = <String, dynamic>{
        'user_id': user.id,
        'full_name': name.trim(),
        'mobile_number': phone.trim(),
        'address_line': address.trim(),
        'delivery_notes': landmarkText.trim().isEmpty
            ? null
            : landmarkText.trim(),
        'is_default': shouldBeDefault,
      };

      if (id != null) {
        await _supabase
            .from('user_addresses')
            .update(values)
            .eq('id', id)
            .eq('user_id', user.id);
      } else {
        await _supabase.from('user_addresses').insert(values);
      }

      await loadAddress();
      return errorMessage == null;
    } catch (e) {
      errorMessage = 'Could not save address: $e';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> setDefaultAddress(int id) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      errorMessage = 'Please log in first.';
      notifyListeners();
      return false;
    }

    try {
      await _supabase
          .from('user_addresses')
          .update({'is_default': false})
          .eq('user_id', user.id);

      await _supabase
          .from('user_addresses')
          .update({'is_default': true})
          .eq('id', id)
          .eq('user_id', user.id);

      await loadAddress();
      return errorMessage == null;
    } catch (e) {
      errorMessage = 'Could not update default address: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAddress(int id) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      errorMessage = 'Please log in first.';
      notifyListeners();
      return false;
    }

    try {
      final wasDefault = _addresses.any(
        (item) => item['id'] == id && item['is_default'] == true,
      );

      await _supabase
          .from('user_addresses')
          .delete()
          .eq('id', id)
          .eq('user_id', user.id);

      await loadAddress();

      if (wasDefault && _addresses.isNotEmpty) {
        await setDefaultAddress(_addresses.first['id'] as int);
      }

      return errorMessage == null;
    } catch (e) {
      errorMessage = 'Could not delete address: $e';
      notifyListeners();
      return false;
    }
  }
}
