import 'package:flutter/material.dart';

class AddressProvider extends ChangeNotifier {
  String recipientName = '';
  String phoneNumber = '';
  String deliveryAddress = '';
  String landmark = '';

  bool get hasAddress =>
      recipientName.trim().isNotEmpty &&
      phoneNumber.trim().isNotEmpty &&
      deliveryAddress.trim().isNotEmpty;

  void saveAddress({
    required String name,
    required String phone,
    required String address,
    required String landmarkText,
  }) {
    recipientName = name.trim();
    phoneNumber = phone.trim();
    deliveryAddress = address.trim();
    landmark = landmarkText.trim();

    notifyListeners();
  }
}
