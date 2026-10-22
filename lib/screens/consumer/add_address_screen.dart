import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddAddressScreen extends StatefulWidget {
  final Map<String, dynamic>? addressToEdit;

  const AddAddressScreen({
    super.key,
    this.addressToEdit,
  });

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  static const Color darkGreen = Color(0xFF105B31);
  static const Color pageBackground = Color(0xFFF7F9F7);
  static const Color ink = Color(0xFF17211B);
  static const Color mutedText = Color(0xFF6D776F);

  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _houseController;
  late TextEditingController _streetController;
  late TextEditingController _postalController;
  late TextEditingController _landmarkController;
  late TextEditingController _instructionsController;

  String? _selectedProvince;
  String? _selectedCity;
  String? _selectedBarangay;

  final List<String> _provinces = [
    'North Cotabato (Cotabato)',
    'Cavite',
    'Metro Manila',
    'Davao del Sur',
    'Laguna',
    'Benguet',
  ];

  final List<String> _cities = [
    'Quezon City',
    'Imus',
    'Kidapawan City',
    'Davao City',
    'Manila',
  ];

  final List<String> _barangays = [
    'Diliman',
    'Palico',
    'Poblacion',
    'Barangay 1',
    'Teachers Village',
  ];

  @override
  void initState() {
    super.initState();
    final edit = widget.addressToEdit;

    _nameController = TextEditingController(text: edit?['name'] ?? '');
    _phoneController = TextEditingController(text: edit?['phone'] ?? '');
    _houseController = TextEditingController();
    _streetController = TextEditingController();
    _postalController = TextEditingController();
    _landmarkController = TextEditingController();
    _instructionsController =
        TextEditingController(text: edit?['note'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _houseController.dispose();
    _streetController.dispose();
    _postalController.dispose();
    _landmarkController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      final String fullAddress = [
        if (_houseController.text.isNotEmpty) _houseController.text,
        if (_streetController.text.isNotEmpty) _streetController.text,
        if (_selectedBarangay != null) _selectedBarangay,
        if (_selectedCity != null) _selectedCity,
        if (_selectedProvince != null) _selectedProvince,
        if (_postalController.text.isNotEmpty) _postalController.text,
      ].join(', ');

      final newAddress = {
        'id': widget.addressToEdit?['id'] ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': fullAddress.isNotEmpty
            ? fullAddress
            : (widget.addressToEdit?['address'] ??
                '123 Maginhawa St., Quezon City'),
        'note': _instructionsController.text.isNotEmpty
            ? '"${_instructionsController.text.trim()}"'
            : '',
        'isDefault': widget.addressToEdit?['isDefault'] ?? false,
      };

      Navigator.pop(context, newAddress);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.addressToEdit != null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: darkGreen,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: pageBackground,
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              // ================= HEADER =================
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  8,
                  MediaQuery.of(context).padding.top + 8,
                  16,
                  20,
                ),
                decoration: const BoxDecoration(
                  color: darkGreen,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? 'Edit Address' : 'Add New Address',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Enter your delivery address',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ================= FORM BODY =================
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('RECIPIENT NAME *'),
                        _buildTextField(
                          controller: _nameController,
                          hintText: 'Full name of recipient',
                          validator: (v) => v == null || v.isEmpty
                              ? 'Please enter recipient name'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('MOBILE NUMBER *'),
                        _buildTextField(
                          controller: _phoneController,
                          hintText: '+63 9XX XXX XXXX',
                          keyboardType: TextInputType.phone,
                          validator: (v) => v == null || v.isEmpty
                              ? 'Please enter mobile number'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('HOUSE / UNIT / BUILDING NO.'),
                        _buildTextField(
                          controller: _houseController,
                          hintText: 'e.g. Unit 4B, Blk 2 Lot 5',
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('STREET *'),
                        _buildTextField(
                          controller: _streetController,
                          hintText: 'Street name',
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('PROVINCE *'),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedProvince,
                          hint: const Text(
                            'Select province',
                            style: TextStyle(
                              color: Color(0xFFA0AEC0),
                              fontSize: 12,
                            ),
                          ),
                          items: _provinces
                              .map(
                                (prov) => DropdownMenuItem(
                                  value: prov,
                                  child: Text(
                                    prov,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: ink,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedProvince = val),
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('CITY / MUNICIPALITY *'),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCity,
                          hint: const Text(
                            'Select city or municipality',
                            style: TextStyle(
                              color: Color(0xFFA0AEC0),
                              fontSize: 12,
                            ),
                          ),
                          items: _cities
                              .map(
                                (city) => DropdownMenuItem(
                                  value: city,
                                  child: Text(
                                    city,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: ink,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedCity = val),
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('BARANGAY *'),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedBarangay,
                          hint: const Text(
                            'Select barangay',
                            style: TextStyle(
                              color: Color(0xFFA0AEC0),
                              fontSize: 12,
                            ),
                          ),
                          items: _barangays
                              .map(
                                (brgy) => DropdownMenuItem(
                                  value: brgy,
                                  child: Text(
                                    brgy,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: ink,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedBarangay = val),
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('ZIP CODE / POSTAL CODE'),
                        _buildTextField(
                          controller: _postalController,
                          hintText: 'e.g. 9400',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('LANDMARK OR NEARBY AREA'),
                        _buildTextField(
                          controller: _landmarkController,
                          hintText:
                              'e.g. near USM, public market, school, or other landmark',
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Optional — helps riders find your location faster.',
                          style: TextStyle(fontSize: 10, color: mutedText),
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('DELIVERY INSTRUCTIONS'),
                        _buildTextField(
                          controller: _instructionsController,
                          hintText:
                              'e.g. Leave at the gate, call before arrival',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 24),

                        // Inline Action Buttons (Scrollable)
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  side: const BorderSide(
                                    color: Color(0xFFE2E8F0),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: ink,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _saveAddress,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: darkGreen,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Save Address',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: mutedText,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(fontSize: 13, color: ink),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFFA0AEC0),
            fontSize: 12,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(12),
        ),
      ),
    );
  }
}