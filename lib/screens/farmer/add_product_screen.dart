import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddNewProductScreen extends StatefulWidget {
  const AddNewProductScreen({super.key});

  @override
  State<AddNewProductScreen> createState() => _AddNewProductScreenState();
}

class _AddNewProductScreenState extends State<AddNewProductScreen> {
  final supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();

  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  final wholesalePriceController = TextEditingController();
  final wholesaleMinQtyController = TextEditingController();
  final descriptionController = TextEditingController();
  final deliveryController = TextEditingController();

  bool isWholesaleActive = false;
  bool isOrganic = true;
  bool isLoading = false;
  bool isFetchingDropdowns = true;

  Uint8List? selectedImageBytes;
  String? selectedImageExtension;

  List<Map<String, dynamic>> categoriesList = [];
  List<Map<String, dynamic>> unitsList = [];

  int? selectedCategoryId;
  int? selectedUnitId;

  final Color primaryGreen = const Color(0xFF1E713B);
  final Color inputFillColor = Colors.white;
  final Color borderColor = Colors.grey.shade300;

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    stockController.dispose();
    wholesalePriceController.dispose();
    wholesaleMinQtyController.dispose();
    descriptionController.dispose();
    deliveryController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // Pick a product image from the gallery.
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();
      final extension = image.name.contains('.')
          ? image.name.split('.').last.toLowerCase()
          : 'jpg';

      if (!mounted) return;

      setState(() {
        selectedImageBytes = bytes;
        selectedImageExtension = extension;
      });
    } catch (e) {
      debugPrint('Error picking image: $e');
      _showMessage('Could not select the product image.');
    }
  }

  // Fetch categories and units from Supabase.
  Future<void> _fetchDropdownData() async {
    try {
      final categoriesData = await supabase
          .from('categories')
          .select('id, name');

      final unitsData = await supabase.from('units').select('id, name');

      if (!mounted) return;

      setState(() {
        categoriesList = List<Map<String, dynamic>>.from(categoriesData);

        unitsList = List<Map<String, dynamic>>.from(unitsData);

        if (categoriesList.isNotEmpty) {
          selectedCategoryId = (categoriesList.first['id'] as num).toInt();
        }

        if (unitsList.isNotEmpty) {
          selectedUnitId = (unitsList.first['id'] as num).toInt();
        }

        isFetchingDropdowns = false;
      });
    } catch (e) {
      debugPrint('Error fetching dropdowns: $e');

      if (!mounted) return;

      setState(() {
        isFetchingDropdowns = false;
      });

      _showMessage('Could not load categories and units.');
    }
  }

  // Validate and publish the product.
  Future<void> _publishProduct() async {
    final name = nameController.text.trim();
    final price = double.tryParse(priceController.text.trim());
    final stock = int.tryParse(stockController.text.trim());

    if (name.isEmpty || price == null || price <= 0) {
      _showMessage('Enter a product name and a valid price greater than 0.');
      return;
    }

    if (stock == null || stock < 0) {
      _showMessage('Enter a valid stock quantity.');
      return;
    }

    if (selectedImageBytes == null) {
      _showMessage('Please select a product photo.');
      return;
    }

    if (selectedCategoryId == null || selectedUnitId == null) {
      _showMessage('Please select a category and unit.');
      return;
    }

    double? wholesalePrice;
    int? wholesaleMinQty;

    if (isWholesaleActive) {
      wholesalePrice = double.tryParse(wholesalePriceController.text.trim());
      wholesaleMinQty = int.tryParse(wholesaleMinQtyController.text.trim());

      if (wholesalePrice == null ||
          wholesalePrice <= 0 ||
          wholesaleMinQty == null ||
          wholesaleMinQty <= 0) {
        _showMessage('Enter a valid wholesale price and minimum quantity.');
        return;
      }
    }

    setState(() => isLoading = true);

    String? uploadedStoragePath;

    try {
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('You must be logged in to publish a product.');
      }

      // Upload the image first, so a failed upload does not create
      // a product record without its image.
      final extension = selectedImageExtension ?? 'jpg';
      final fileName = '${DateTime.now().microsecondsSinceEpoch}.$extension';
      uploadedStoragePath = '$userId/$fileName';

      await supabase.storage
          .from('product_images')
          .uploadBinary(uploadedStoragePath, selectedImageBytes!);

      final imageUrl = supabase.storage
          .from('product_images')
          .getPublicUrl(uploadedStoragePath);

      // Create the main product record.
      final productResponse = await supabase
          .from('products')
          .insert({
            'seller_id': userId,
            'name': name,
            'price': price,
            'stock_quantity': stock,
            'unit_id': selectedUnitId,
            'category_id': selectedCategoryId,
            'description': descriptionController.text.trim(),
            'delivery_details': deliveryController.text.trim(),
            'is_organic': isOrganic,
            'status': 'active',
          })
          .select('id')
          .single();

      final newProductId = productResponse['id'];

      // Save the image URL.
      await supabase.from('product_images').insert({
        'product_id': newProductId,
        'image_url': imageUrl,
        'display_order': 1,
      });

      // Save wholesale details when enabled.
      if (isWholesaleActive) {
        await supabase.from('product_wholesale_details').insert({
          'product_id': newProductId,
          'wholesale_price': wholesalePrice,
          'minimum_quantity': wholesaleMinQty,
        });
      }

      if (!mounted) return;

      _showMessage('Product published successfully!');
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Error publishing product: $e');

      // Best-effort cleanup of the uploaded image if a later database
      // operation fails. Database records already inserted may still
      // require cleanup if the failure occurred after product creation.
      if (uploadedStoragePath != null) {
        try {
          await supabase.storage.from('product_images').remove([
            uploadedStoragePath,
          ]);
        } catch (cleanupError) {
          debugPrint('Image cleanup failed: $cleanupError');
        }
      }

      _showMessage('Could not publish product: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add New Product',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: isFetchingDropdowns
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel('PRODUCT IMAGES'),
                  _buildImageUploaders(),
                  const SizedBox(height: 20),
                  _buildInputField(
                    'PRODUCT NAME',
                    'e.g. Organic Ampalaya (Bitter Gourd)',
                    nameController,
                  ),
                  _buildInputField(
                    'PRICE (₱)',
                    '0.00',
                    priceController,
                    isNumber: true,
                  ),
                  _buildInputField(
                    'STOCK QUANTITY',
                    '0',
                    stockController,
                    isNumber: true,
                  ),
                  _buildDropdownField(
                    'UNIT',
                    selectedUnitId,
                    unitsList,
                    (value) => setState(() => selectedUnitId = value),
                  ),
                  const SizedBox(height: 10),
                  _buildWholesaleToggle(),
                  const SizedBox(height: 20),
                  if (isWholesaleActive) ...[
                    _buildInputField(
                      'WHOLESALE PRICE (₱)',
                      '0.00',
                      wholesalePriceController,
                      isNumber: true,
                    ),
                    _buildInputField(
                      'WHOLESALE MINIMUM QUANTITY',
                      'e.g. 10',
                      wholesaleMinQtyController,
                      isNumber: true,
                    ),
                  ],
                  _buildDropdownField(
                    'CATEGORY',
                    selectedCategoryId,
                    categoriesList,
                    (value) => setState(() => selectedCategoryId = value),
                  ),
                  _buildInputField(
                    'DESCRIPTION',
                    'Describe your product...',
                    descriptionController,
                    maxLines: 4,
                  ),
                  _buildInputField(
                    'DELIVERY DETAILS',
                    'e.g. Ships within 1-2 days...',
                    deliveryController,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 10),
                  _buildOrganicCheckbox(),
                  const SizedBox(height: 30),
                  _buildPublishButton(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey.shade700,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String hint,
    TextEditingController controller, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel(label),
          TextFormField(
            controller: controller,
            keyboardType: isNumber
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400),
              filled: true,
              fillColor: inputFillColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: primaryGreen),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    int? selectedValue,
    List<Map<String, dynamic>> items,
    ValueChanged<int?> onChanged,
  ) {
    final validValue =
        items.any((item) => (item['id'] as num).toInt() == selectedValue)
        ? selectedValue
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel(label),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: inputFillColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: validValue,
                hint: Text('Select $label'),
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: items.map((item) {
                  return DropdownMenuItem<int>(
                    value: (item['id'] as num).toInt(),
                    child: Text(item['name'].toString()),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploaders() {
    return Row(
      children: [
        _buildDashedBox(
          Icons.camera_alt,
          selectedImageBytes == null ? 'Add Photo' : 'Change Photo',
          isMainPhoto: true,
        ),
        const SizedBox(width: 12),
        _buildDashedBox(Icons.add, 'Optional', isMainPhoto: false),
      ],
    );
  }

  Widget _buildDashedBox(
    IconData icon,
    String text, {
    required bool isMainPhoto,
  }) {
    final hasImage = isMainPhoto && selectedImageBytes != null;

    return GestureDetector(
      onTap: isMainPhoto ? _pickImage : null,
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          image: hasImage
              ? DecorationImage(
                  image: MemoryImage(selectedImageBytes!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: hasImage
            ? null
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.grey.shade400, size: 28),
                  if (text.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      text,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _buildWholesaleToggle() {
    return GestureDetector(
      onTap: () {
        setState(() => isWholesaleActive = !isWholesaleActive);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isWholesaleActive
              ? primaryGreen.withValues(alpha: 0.1)
              : inputFillColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isWholesaleActive ? primaryGreen : borderColor,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Wholesale pricing',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Set minimums and bulk discounts',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrganicCheckbox() {
    return GestureDetector(
      onTap: () => setState(() => isOrganic = !isOrganic),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isOrganic
              ? primaryGreen.withValues(alpha: 0.1)
              : inputFillColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isOrganic ? primaryGreen : borderColor),
        ),
        child: Row(
          children: [
            Icon(
              isOrganic ? Icons.check_box : Icons.check_box_outline_blank,
              color: isOrganic ? primaryGreen : Colors.grey.shade400,
            ),
            const SizedBox(width: 12),
            Text(
              'Mark as Organic Product',
              style: TextStyle(
                color: isOrganic ? primaryGreen : Colors.black87,
                fontWeight: isOrganic ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPublishButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        onPressed: isLoading ? null : _publishProduct,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Publish Product',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
