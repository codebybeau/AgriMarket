import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

// Helper class for multi-image storage
class ImageData {
  final Uint8List bytes;
  final String extension;

  ImageData({required this.bytes, required this.extension});
}

class AddNewProductScreen extends StatefulWidget {
  const AddNewProductScreen({Key? key}) : super(key: key);

  @override
  State<AddNewProductScreen> createState() => _AddNewProductScreenState();
}

class _AddNewProductScreenState extends State<AddNewProductScreen> {
  final supabase = Supabase.instance.client;

  // Form Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController wholesalePriceController = TextEditingController();
  final TextEditingController wholesaleMinQtyController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController deliveryController = TextEditingController();

  // State Variables
  bool isWholesaleActive = false;
  bool isOrganic = true;
  bool isLoading = false;
  bool isFetchingDropdowns = true;

  // Multi-Image Picking Variables
  List<ImageData> selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  // Dropdown Data
  List<Map<String, dynamic>> categoriesList = [];
  List<Map<String, dynamic>> unitsList = [];
  int? selectedCategoryId;
  int? selectedUnitId;

  // Theme Colors
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

  // --- 1. PICK MULTIPLE IMAGES FROM GALLERY ---
  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        final List<ImageData> newImages = [];
        for (final image in images) {
          final bytes = await image.readAsBytes();
          final ext = image.name.split('.').last;
          newImages.add(ImageData(bytes: bytes, extension: ext));
        }
        setState(() {
          selectedImages.addAll(newImages);
        });
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
    }
  }

  // --- 2. FETCH DROPDOWNS FROM DATABASE ---
  Future<void> _fetchDropdownData() async {
    try {
      final categoriesData = await supabase.from('categories').select('id, name');
      final unitsData = await supabase.from('units').select('id, name');

      setState(() {
        categoriesList = List<Map<String, dynamic>>.from(categoriesData);
        unitsList = List<Map<String, dynamic>>.from(unitsData);

        if (categoriesList.isNotEmpty) selectedCategoryId = categoriesList[0]['id'];
        if (unitsList.isNotEmpty) selectedUnitId = unitsList[0]['id'];
        isFetchingDropdowns = false;
      });
    } catch (e) {
      debugPrint('Error fetching dropdowns: $e');
      setState(() => isFetchingDropdowns = false);
    }
  }

  // --- 3. PUBLISH PRODUCT & MULTIPLE IMAGES TO DATABASE ---
  Future<void> _publishProduct() async {
    if (nameController.text.isEmpty || priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in the required fields.')),
      );
      return;
    }

    if (selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one product photo.')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      // A. Insert into main products table
      final productResponse = await supabase.from('products').insert({
        'seller_id': userId,
        'name': nameController.text,
        'price': double.tryParse(priceController.text) ?? 0.0,
        'stock_quantity': int.tryParse(stockController.text) ?? 0,
        'unit_id': selectedUnitId,
        'category_id': selectedCategoryId,
        'description': descriptionController.text,
        'delivery_details': deliveryController.text,
        'is_organic': isOrganic,
        'status': 'active'
      }).select('id').single();

      final newProductId = productResponse['id'];

      // B. Upload all selected images to Supabase Storage and product_images table
      for (int i = 0; i < selectedImages.length; i++) {
        final img = selectedImages[i];
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.${img.extension}';
        final storagePath = '$userId/$fileName';

        // Upload Binary Bytes
        await supabase.storage.from('product_images').uploadBinary(
          storagePath,
          img.bytes,
        );

        // Get Public URL
        final String imageUrl = supabase.storage
            .from('product_images')
            .getPublicUrl(storagePath);

        // Save URL record to product_images table
        await supabase.from('product_images').insert({
          'product_id': newProductId,
          'image_url': imageUrl,
          'display_order': i + 1, // First image display_order is 1
        });
      }

      // C. Insert into wholesale details if active
      if (isWholesaleActive) {
        await supabase.from('product_wholesale_details').insert({
          'product_id': newProductId,
          'wholesale_price': double.tryParse(wholesalePriceController.text) ?? 0.0,
          'minimum_quantity': int.tryParse(wholesaleMinQtyController.text) ?? 0,
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product published successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error inserting product: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // --- UI BUILDING ---
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
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: false,
      ),
      body: isFetchingDropdowns
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel('PRODUCT IMAGES'),
                  _buildMultiImageUploader(),
                  const SizedBox(height: 20),
                  _buildInputField('PRODUCT NAME', 'e.g. Organic Ampalaya (Bitter Gourd)', nameController),
                  _buildInputField('PRICE (₱)', '0.00', priceController, isNumber: true),
                  _buildInputField('STOCK QUANTITY', '0', stockController, isNumber: true),
                  _buildDropdownField('UNIT', selectedUnitId, unitsList, (newValue) {
                    setState(() => selectedUnitId = newValue);
                  }),
                  const SizedBox(height: 10),
                  _buildWholesaleToggle(),
                  const SizedBox(height: 20),
                  if (isWholesaleActive) ...[
                    _buildInputField('WHOLESALE PRICE (₱)', '0.00', wholesalePriceController, isNumber: true),
                    _buildInputField('WHOLESALE MINIMUM QUANTITY', 'e.g. 10', wholesaleMinQtyController, isNumber: true),
                  ],
                  _buildDropdownField('CATEGORY', selectedCategoryId, categoriesList, (newValue) {
                    setState(() => selectedCategoryId = newValue);
                  }),
                  _buildInputField('DESCRIPTION', 'Describe your product...', descriptionController, maxLines: 4),
                  _buildInputField('DELIVERY DETAILS', 'e.g. Ships within 1-2 days...', deliveryController, maxLines: 2),
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
      padding: const EdgeInsets.only(bottom: 8.0),
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
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel(label),
          TextFormField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400),
              filled: true,
              fillColor: inputFillColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
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
                value: selectedValue,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: items.map((item) {
                  return DropdownMenuItem<int>(
                    value: item['id'],
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

  // MULTI-IMAGE HORIZONTAL PREVIEW GRID
  Widget _buildMultiImageUploader() {
    return SizedBox(
      height: 95,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: selectedImages.length + 1,
        itemBuilder: (context, index) {
          // Last item is the "+" button to add more images
          if (index == selectedImages.length) {
            return GestureDetector(
              onTap: _pickImages,
              child: Container(
                width: 90,
                height: 90,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      selectedImages.isEmpty ? Icons.camera_alt : Icons.add_a_photo_outlined,
                      color: Colors.grey.shade500,
                      size: 28,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedImages.isEmpty ? 'Add Photos' : 'Add More',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
                    ),
                  ],
                ),
              ),
            );
          }

          final img = selectedImages[index];

          return Container(
            width: 90,
            height: 90,
            margin: const EdgeInsets.only(right: 12),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    img.bytes,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),
                // Cover badge for the first photo
                if (index == 0)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                      ),
                      child: const Text(
                        'Main Photo',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                // Remove photo button
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedImages.removeAt(index);
                      });
                    },
                    child: const CircleAvatar(
                      radius: 11,
                      backgroundColor: Colors.red,
                      child: Icon(Icons.close, size: 12, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWholesaleToggle() {
    return GestureDetector(
      onTap: () => setState(() => isWholesaleActive = !isWholesaleActive),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.45,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isWholesaleActive ? primaryGreen.withOpacity(0.1) : inputFillColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isWholesaleActive ? primaryGreen : borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Wholesale pricing',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
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
          color: isOrganic ? primaryGreen.withOpacity(0.1) : inputFillColor,
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
        onPressed: isLoading ? null : _publishProduct,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Text(
                'Publish Product',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}