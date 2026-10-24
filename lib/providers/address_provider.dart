import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddressProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  int? _addressId;
  String recipientName = '';
  String phoneNumber = '';
  String deliveryAddress = '';
  String landmark = '';

  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;

  bool get hasAddress =>
      recipientName.trim().isNotEmpty &&
      phoneNumber.trim().isNotEmpty &&
      deliveryAddress.trim().isNotEmpty;

  Map<String, dynamic> get addressMap => {
    if (_addressId != null) 'id': _addressId,
    'name': recipientName,
    'phone': phoneNumber,
    'address': deliveryAddress,
    'note': landmark,
  };

  Future<void> loadAddress() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      errorMessage = 'Please log in to load your saved address.';
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final data = await _supabase
          .from('user_addresses')
          .select()
          .eq('user_id', user.id)
          .order('is_default', ascending: false)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (data != null) {
        _addressId = data['id'] as int?;
        recipientName = data['full_name'] ?? '';
        phoneNumber = data['mobile_number'] ?? '';
        deliveryAddress = data['address_line'] ?? '';
        landmark = data['delivery_notes'] ?? '';
      } else {
        _clearAddress();
      }
    } catch (e) {
      errorMessage = 'Could not load address: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveAddress({
    required String name,
    required String phone,
    required String address,
    required String landmarkText,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      errorMessage = 'Please log in before saving your address.';
      notifyListeners();
      return false;
    }

    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      final values = <String, dynamic>{
        'user_id': user.id,
        'full_name': name.trim(),
        'mobile_number': phone.trim(),
        'address_line': address.trim(),
        'delivery_notes': landmarkText.trim().isEmpty
            ? null
            : landmarkText.trim(),
        'is_default': true,
      };

      if (_addressId != null) {
        await _supabase
            .from('user_addresses')
            .update(values)
            .eq('id', _addressId!)
            .eq('user_id', user.id);
      } else {
        final inserted = await _supabase
            .from('user_addresses')
            .insert(values)
            .select('id')
            .single();

        _addressId = inserted['id'] as int;
      }

      recipientName = name.trim();
      phoneNumber = phone.trim();
      deliveryAddress = address.trim();
      landmark = landmarkText.trim();

      return true;
    } catch (e) {
      errorMessage = 'Could not save address: $e';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  void _clearAddress() {
    _addressId = null;
    recipientName = '';
    phoneNumber = '';
    deliveryAddress = '';
    landmark = '';
  }
}
