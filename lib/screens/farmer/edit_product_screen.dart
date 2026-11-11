
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProductScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const EditProductScreen({
    super.key,
    required this.product,
  });

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color backgroundColor = Color(0xFFF7F8F4);

  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  final descriptionController = TextEditingController();
  final deliveryController = TextEditingController();
  final wholesalePriceController = TextEditingController();
  final wholesaleMinQtyController = TextEditingController();

  List<Map<String, dynamic>> categoriesList = [];
  List<Map<String, dynamic>> unitsList = [];

  int? selectedCategoryId;
  int? selectedUnitId;
  int? currentImageId;

  String? currentImageUrl;
  String? selectedImageExtension;
  Uint8List? selectedImageBytes;

  bool isOrganic = false;
  bool isWholesaleActive = false;
  bool isLoading = true;
  bool isSaving = false;
  String? errorMessage;

  int? get productId {
    final id = widget.product['id'];
    return id is num ? id.toInt() : int.tryParse(id.toString());
  }

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    stockController.dispose();
    descriptionController.dispose();
    deliveryController.dispose();
    wholesalePriceController.dispose();
    wholesaleMinQtyController.dispose();
    super.dispose();
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  // Handles Supabase relationships returning either a Map or a List.
  List<Map<String, dynamic>> _toMapList(dynamic value) {
    if (value == null) return [];

    if (value is Map) {
      return [Map<String, dynamic>.from(value)];
    }

    if (value is Iterable) {
      return value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    return [];
  }

  Future<void> _loadProduct() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final userId = supabase.auth.currentUser?.id;
      final id = productId;

      if (userId == null) {
        throw Exception('Please log in first.');
      }

      if (id == null) {
        throw Exception('Invalid product ID.');
      }

      final results = await Future.wait([
        supabase.from('categories').select('id, name'),
        supabase.from('units').select('id, name'),
      ]);

      final productData = await supabase
          .from('products')
          .select('''
            id,
            seller_id,
            name,
            price,
            stock_quantity,
            unit_id,
            category_id,
            description,
            delivery_details,
            is_organic,
            status,
            product_images (
              id,
              image_url,
              display_order
            ),
            product_wholesale_details (
              product_id,
              wholesale_price,
              minimum_quantity
            )
          ''')
          .eq('id', id)
          .eq('seller_id', userId)
          .maybeSingle();

      if (productData == null) {
        throw Exception(
          'Product not found or you do not have permission to edit it.',
        );
      }

      // FIX: Safely convert relationship responses.
      final images = _toMapList(productData['product_images']);

      images.sort(
        (a, b) => (_toInt(a['display_order']) ?? 0)
            .compareTo(_toInt(b['display_order']) ?? 0),
      );

      final wholesaleDetails =
          _toMapList(productData['product_wholesale_details']);

      final wholesale =
          wholesaleDetails.isNotEmpty ? wholesaleDetails.first : null;

      // Safely convert category and unit responses too.
      final fetchedCategories = _toMapList(results[0]);
      final fetchedUnits = _toMapList(results[1]);

      if (!mounted) return;

      setState(() {
        categoriesList = fetchedCategories;
        unitsList = fetchedUnits;

        nameController.text = productData['name']?.toString() ?? '';
        priceController.text = productData['price']?.toString() ?? '';
        stockController.text =
            productData['stock_quantity']?.toString() ?? '0';
        descriptionController.text =
            productData['description']?.toString() ?? '';
        deliveryController.text =
            productData['delivery_details']?.toString() ?? '';

        selectedCategoryId = _toInt(productData['category_id']);
        selectedUnitId = _toInt(productData['unit_id']);
        isOrganic = productData['is_organic'] == true;

        if (images.isNotEmpty) {
          currentImageId = _toInt(images.first['id']);
          currentImageUrl = images.first['image_url']?.toString();
        } else {
          currentImageId = null;
          currentImageUrl = null;
        }

        if (wholesale != null) {
          isWholesaleActive = true;
          wholesalePriceController.text =
              wholesale['wholesale_price']?.toString() ?? '';
          wholesaleMinQtyController.text =
              wholesale['minimum_quantity']?.toString() ?? '';
        } else {
          isWholesaleActive = false;
          wholesalePriceController.clear();
          wholesaleMinQtyController.clear();
        }

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (image == null || !mounted) return;

      final bytes = await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        selectedImageBytes = bytes;
        selectedImageExtension = image.name.contains('.')
            ? image.name.split('.').last
            : 'jpg';
      });
    } catch (e) {
      _showMessage('Unable to select image: $e');
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedCategoryId == null || selectedUnitId == null) {
      _showMessage('Please select a category and unit.');
      return;
    }

    if (isWholesaleActive &&
        (wholesalePriceController.text.trim().isEmpty ||
            wholesaleMinQtyController.text.trim().isEmpty)) {
      _showMessage('Please complete the wholesale information.');
      return;
    }

    final price = double.tryParse(priceController.text.trim());
    final stock = int.tryParse(stockController.text.trim());

    if (price == null || price < 0 || stock == null || stock < 0) {
      _showMessage('Please enter a valid price and stock quantity.');
      return;
    }

    if (isWholesaleActive) {
      final wholesalePrice =
          double.tryParse(wholesalePriceController.text.trim());
      final minimumQuantity =
          int.tryParse(wholesaleMinQtyController.text.trim());

      if (wholesalePrice == null ||
          wholesalePrice < 0 ||
          minimumQuantity == null ||
          minimumQuantity <= 0) {
        _showMessage('Please enter valid wholesale details.');
        return;
      }
    }

    setState(() => isSaving = true);

    try {
      final userId = supabase.auth.currentUser?.id;
      final id = productId;

      if (userId == null || id == null) {
        throw Exception('Your session or product information is missing.');
      }

      // 1. Update the main product record.
      await supabase
          .from('products')
          .update({
            'name': nameController.text.trim(),
            'price': price,
            'stock_quantity': stock,
            'unit_id': selectedUnitId,
            'category_id': selectedCategoryId,
            'description': descriptionController.text.trim(),
            'delivery_details': deliveryController.text.trim(),
            'is_organic': isOrganic,
          })
          .eq('id', id)
          .eq('seller_id', userId);

      // 2. Upload a replacement image if selected.
      if (selectedImageBytes != null) {
        final extension = selectedImageExtension ?? 'jpg';
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}.$extension';
        final storagePath = '$userId/$fileName';

        await supabase.storage
            .from('product_images')
            .uploadBinary(storagePath, selectedImageBytes!);

        final imageUrl = supabase.storage
            .from('product_images')
            .getPublicUrl(storagePath);

        if (currentImageId != null) {
          await supabase
              .from('product_images')
              .update({
                'image_url': imageUrl,
                'display_order': 1,
              })
              .eq('id', currentImageId!)
              .eq('product_id', id);
        } else {
          await supabase.from('product_images').insert({
            'product_id': id,
            'image_url': imageUrl,
            'display_order': 1,
          });
        }
      }

      // 3. Save or remove wholesale information.
      if (isWholesaleActive) {
        await supabase.from('product_wholesale_details').upsert({
          'product_id': id,
          'wholesale_price':
              double.parse(wholesalePriceController.text.trim()),
          'minimum_quantity':
              int.parse(wholesaleMinQtyController.text.trim()),
        }, onConflict: 'product_id');
      } else {
        await supabase
            .from('product_wholesale_details')
            .delete()
            .eq('product_id', id);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product updated successfully!'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      _showMessage('Unable to update product: $e');
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    bool isNumber = false,
    bool isDecimal = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: isNumber
                ? TextInputType.numberWithOptions(decimal: isDecimal)
                : TextInputType.text,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label is required.';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: primaryGreen),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    int? selectedValue,
    List<Map<String, dynamic>> items,
    ValueChanged<int?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: items.any(
                  (item) => _toInt(item['id']) == selectedValue,
                )
                    ? selectedValue
                    : null,
                hint: Text('Select $label'),
                isExpanded: true,
                items: items.map((item) {
                  return DropdownMenuItem<int>(
                    value: _toInt(item['id']),
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

  Widget _buildImageSection() {
    Widget imageWidget;

    if (selectedImageBytes != null) {
      imageWidget = Image.memory(
        selectedImageBytes!,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      );
    } else if (currentImageUrl != null &&
        currentImageUrl!.isNotEmpty) {
      imageWidget = Image.network(
        currentImageUrl!,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _imagePlaceholder();
        },
      );
    } else {
      imageWidget = _imagePlaceholder();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PRODUCT IMAGE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: darkGreen,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 120,
                height: 120,
                child: imageWidget,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isSaving ? null : _pickImage,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Change Photo'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryGreen,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: Colors.grey.shade100,
      child: Icon(
        Icons.image_outlined,
        color: Colors.grey.shade400,
        size: 38,
      ),
    );
  }

  Widget _buildToggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: isSaving ? null : onChanged,
        activeTrackColor: primaryGreen,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        title: const Text(
          'Edit Product',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: primaryGreen),
            )
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 45,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadProduct,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildImageSection(),
                        const SizedBox(height: 24),

                        _buildTextField(
                          'PRODUCT NAME',
                          'Enter product name',
                          nameController,
                        ),
                        _buildTextField(
                          'PRICE (₱)',
                          'Enter price',
                          priceController,
                          isNumber: true,
                          isDecimal: true,
                        ),
                        _buildTextField(
                          'STOCK QUANTITY',
                          'Enter stock quantity',
                          stockController,
                          isNumber: true,
                        ),

                        _buildDropdown(
                          'UNIT',
                          selectedUnitId,
                          unitsList,
                          (value) {
                            setState(() => selectedUnitId = value);
                          },
                        ),
                        _buildDropdown(
                          'CATEGORY',
                          selectedCategoryId,
                          categoriesList,
                          (value) {
                            setState(() => selectedCategoryId = value);
                          },
                        ),

                        _buildTextField(
                          'DESCRIPTION',
                          'Describe your product',
                          descriptionController,
                          maxLines: 4,
                        ),
                        _buildTextField(
                          'DELIVERY DETAILS',
                          'Enter delivery details',
                          deliveryController,
                          maxLines: 2,
                        ),

                        _buildToggle(
                          title: 'Organic Product',
                          subtitle: 'Mark this product as organic',
                          value: isOrganic,
                          onChanged: (value) {
                            setState(() => isOrganic = value);
                          },
                        ),

                        _buildToggle(
                          title: 'Wholesale Pricing',
                          subtitle: 'Offer a price for bulk purchases',
                          value: isWholesaleActive,
                          onChanged: (value) {
                            setState(() => isWholesaleActive = value);
                          },
                        ),

                        if (isWholesaleActive) ...[
                          _buildTextField(
                            'WHOLESALE PRICE (₱)',
                            'Enter wholesale price',
                            wholesalePriceController,
                            isNumber: true,
                            isDecimal: true,
                          ),
                          _buildTextField(
                            'WHOLESALE MINIMUM QUANTITY',
                            'Enter minimum quantity',
                            wholesaleMinQtyController,
                            isNumber: true,
                          ),
                        ],

                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isSaving ? null : _saveChanges,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: isSaving
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }
}
