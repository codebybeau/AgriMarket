import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class ImageData {
  final Uint8List? bytes;
  final String? extension;
  final String? existingUrl; // Used for pre-loaded photos
  final int? imageId;

  ImageData({this.bytes, this.extension, this.existingUrl, this.imageId});
}

class EditProductScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const EditProductScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final supabase = Supabase.instance.client;

  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController stockController;
  late TextEditingController descriptionController;
  late TextEditingController deliveryController;

  bool isOrganic = true;
  bool isLoading = false;
  bool isFetchingImages = true;

  List<ImageData> productImages = [];
  final ImagePicker _picker = ImagePicker();

  final Color primaryGreen = const Color(0xFF1E713B);

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.product['name'] ?? '');
    priceController = TextEditingController(text: (widget.product['price'] ?? 0).toString());
    stockController = TextEditingController(text: (widget.product['stock_quantity'] ?? 0).toString());
    descriptionController = TextEditingController(text: widget.product['description'] ?? '');
    deliveryController = TextEditingController(text: widget.product['delivery_details'] ?? '');
    isOrganic = widget.product['is_organic'] ?? true;

    _fetchExistingImages();
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    stockController.dispose();
    descriptionController.dispose();
    deliveryController.dispose();
    super.dispose();
  }

  // Load existing images from product_images table
  Future<void> _fetchExistingImages() async {
    try {
      final imagesData = await supabase
          .from('product_images')
          .select('id, image_url')
          .eq('product_id', widget.product['id'])
          .order('display_order', ascending: true);

      setState(() {
        productImages = (imagesData as List).map((img) {
          return ImageData(
            existingUrl: img['image_url'] as String?,
            imageId: img['id'] as int?,
          );
        }).toList();
        isFetchingImages = false;
      });
    } catch (e) {
      debugPrint('Error fetching images: $e');
      setState(() => isFetchingImages = false);
    }
  }

  // Pick new images to add
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
          productImages.addAll(newImages);
        });
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
    }
  }

  // Save changes to Supabase
  Future<void> _saveChanges() async {
    if (nameController.text.isEmpty || priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in required fields.')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final userId = supabase.auth.currentUser?.id;
      final productId = widget.product['id'];

      // 1. UPDATE products table
      await supabase.from('products').update({
        'name': nameController.text,
        'price': double.tryParse(priceController.text) ?? 0.0,
        'stock_quantity': int.tryParse(stockController.text) ?? 0,
        'description': descriptionController.text,
        'delivery_details': deliveryController.text,
        'is_organic': isOrganic,
      }).eq('id', productId);

      // 2. Upload any newly added binary images
      for (int i = 0; i < productImages.length; i++) {
        final img = productImages[i];

        if (img.bytes != null) {
          final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.${img.extension}';
          final storagePath = '$userId/$fileName';

          await supabase.storage.from('product_images').uploadBinary(
                storagePath,
                img.bytes!,
              );

          final String imageUrl = supabase.storage
              .from('product_images')
              .getPublicUrl(storagePath);

          await supabase.from('product_images').insert({
            'product_id': productId,
            'image_url': imageUrl,
            'display_order': i + 1,
          });
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error updating product: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // Delete product action
  Future<void> _deleteProduct() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product?'),
        content: const Text('This operation cannot be undone. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => isLoading = true);

    try {
      final productId = widget.product['id'];
      await supabase.from('product_images').delete().eq('product_id', productId);
      await supabase.from('products').delete().eq('id', productId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deleted successfully.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error deleting product: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: primaryGreen,
        title: const Text('Edit Product', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: isLoading ? null : _deleteProduct,
          ),
        ],
      ),
      body: isFetchingImages
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PRODUCT IMAGES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 8),
                  _buildImageGrid(),
                  const SizedBox(height: 20),
                  _buildTextField('PRODUCT NAME', nameController),
                  _buildTextField('PRICE (₱)', priceController, isNumber: true),
                  _buildTextField('STOCK QUANTITY', stockController, isNumber: true),
                  _buildTextField('DESCRIPTION', descriptionController, maxLines: 3),
                  _buildTextField('DELIVERY DETAILS', deliveryController, maxLines: 2),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
                      onPressed: isLoading ? null : _saveChanges,
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildImageGrid() {
    return SizedBox(
      height: 95,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: productImages.length + 1,
        itemBuilder: (context, index) {
          if (index == productImages.length) {
            return GestureDetector(
              onTap: _pickImages,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add_a_photo_outlined, color: Colors.grey),
              ),
            );
          }

          final img = productImages[index];

          return Container(
            width: 90,
            height: 90,
            margin: const EdgeInsets.only(right: 10),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: img.existingUrl != null
                      ? Image.network(img.existingUrl!, width: 90, height: 90, fit: BoxFit.cover)
                      : Image.memory(img.bytes!, width: 90, height: 90, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () async {
                      if (img.imageId != null) {
                        await supabase.from('product_images').delete().eq('id', img.imageId!);
                      }
                      setState(() {
                        productImages.removeAt(index);
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

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            maxLines: maxLines,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}