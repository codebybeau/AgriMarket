import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductCatalogService {
  ProductCatalogService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const String _productColumns =
      'id, seller_id, name, price, stock_quantity, unit_id, '
      'category_id, description, delivery_details, is_organic, status';

  // Fetch only the logged-in farmer's products.
  Future<List<Map<String, dynamic>>> fetchSellerProducts(
    String sellerId,
  ) async {
    final response = await _client
        .from('products')
        .select(_productColumns)
        .eq('seller_id', sellerId)
        .order('id', ascending: false);

    return _attachProductDetails(response);
  }

  // Fetch all active products for consumers.
  Future<List<Map<String, dynamic>>> fetchActiveProducts() async {
    final response = await _client
        .from('products')
        .select(_productColumns)
        .eq('status', 'active')
        .order('id', ascending: false);

    return _attachProductDetails(response);
  }

  // Fetch active products belonging to a particular farmer.
  Future<List<Map<String, dynamic>>> fetchFarmerProducts(
    String sellerId,
  ) async {
    final response = await _client
        .from('products')
        .select(_productColumns)
        .eq('seller_id', sellerId)
        .eq('status', 'active')
        .order('id', ascending: false);

    return _attachProductDetails(response);
  }

  // Attach images, units, categories, and farmer information.
  Future<List<Map<String, dynamic>>> _attachProductDetails(
    List<dynamic> response,
  ) async {
    final products = response
        .map((item) => Map<String, dynamic>.from(item))
        .toList();

    if (products.isEmpty) {
      return [];
    }

    // Collect product IDs.
    final productIds = products
        .map((product) => product['id'])
        .where((id) => id != null)
        .toList();

    // Collect unit IDs.
    final unitIds = products
        .map((product) => product['unit_id'])
        .where((id) => id != null)
        .toSet()
        .toList();

    // Collect category IDs.
    final categoryIds = products
        .map((product) => product['category_id'])
        .where((id) => id != null)
        .toSet()
        .toList();

    // Collect seller IDs as strings.
    final sellerIds = products
        .map((product) => product['seller_id']?.toString())
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    // -----------------------------------------
    // PRODUCT IMAGES
    // -----------------------------------------

    final Map<String, List<String>> imagesByProductId = {};

    if (productIds.isNotEmpty) {
      final imageResponse = await _client
          .from('product_images')
          .select('product_id, image_url, display_order')
          .inFilter('product_id', productIds)
          .order('display_order', ascending: true);

      for (final image in imageResponse) {
        final productId = image['product_id']?.toString();
        final imageUrl = image['image_url']?.toString();

        if (productId != null &&
            imageUrl != null &&
            imageUrl.trim().isNotEmpty) {
          imagesByProductId.putIfAbsent(productId, () => []);
          imagesByProductId[productId]!.add(imageUrl);
        }
      }
    }

    // -----------------------------------------
    // UNIT NAMES
    // -----------------------------------------

    final Map<String, String> unitNameById = {};

    if (unitIds.isNotEmpty) {
      final unitResponse = await _client
          .from('units')
          .select('id, name')
          .inFilter('id', unitIds);

      for (final unit in unitResponse) {
        final id = unit['id']?.toString();

        if (id != null) {
          unitNameById[id] = unit['name']?.toString() ?? 'unit';
        }
      }
    }

    // -----------------------------------------
    // CATEGORY NAMES
    // -----------------------------------------

    final Map<String, String> categoryNameById = {};

    if (categoryIds.isNotEmpty) {
      final categoryResponse = await _client
          .from('categories')
          .select('id, name')
          .inFilter('id', categoryIds);

      for (final category in categoryResponse) {
        final id = category['id']?.toString();

        if (id != null) {
          categoryNameById[id] =
              category['name']?.toString() ?? 'Uncategorized';
        }
      }
    }

    // -----------------------------------------
    // FARMER PROFILES
    // -----------------------------------------

    final Map<String, Map<String, dynamic>> farmerByUserId = {};

    if (sellerIds.isNotEmpty) {
      final farmerResponse = await _client
          .from('farmer_profiles')
          .select(
            'user_id, full_name, farm_name, farm_origin, '
            'bio, contact_number, avatar_url',
          )
          .inFilter('user_id', sellerIds);

      for (final farmer in farmerResponse) {
        final userId = farmer['user_id']?.toString();

        if (userId != null && userId.isNotEmpty) {
          farmerByUserId[userId] = Map<String, dynamic>.from(farmer);
        }
      }

      // Diagnostic information for debugging.
      debugPrint('Product sellers found: ${sellerIds.length}');
      debugPrint('Farmer profiles found: ${farmerByUserId.length}');
    }

    // -----------------------------------------
    // ATTACH INFORMATION TO PRODUCTS
    // -----------------------------------------

    return products.map((product) {
      final productId = product['id']?.toString();
      final unitId = product['unit_id']?.toString();
      final categoryId = product['category_id']?.toString();
      final sellerId = product['seller_id']?.toString();

      final farmer = sellerId == null
          ? <String, dynamic>{}
          : farmerByUserId[sellerId] ?? <String, dynamic>{};

      final productImages = imagesByProductId[productId] ?? <String>[];

      final farmerName = farmer['full_name']?.toString().trim() ?? '';

      final farmName = farmer['farm_name']?.toString().trim() ?? '';

      final farmOrigin = farmer['farm_origin']?.toString().trim() ?? '';

      return <String, dynamic>{
        ...product,

        // Images.
        'image_url': productImages.isNotEmpty ? productImages.first : null,
        'images': productImages,

        // Unit and category.
        'unit_name': unitNameById[unitId] ?? 'unit',
        'category_name': categoryNameById[categoryId] ?? 'Uncategorized',

        // Farmer information.
        'farmer_name': farmerName.isNotEmpty ? farmerName : 'Farmer',
        'farm_name': farmName.isNotEmpty ? farmName : 'Farm',
        'farm_origin': farmOrigin.isNotEmpty
            ? farmOrigin
            : 'Location not provided',
        'farmer_bio': farmer['bio'],
        'farmer_contact': farmer['contact_number'],
        'farmer_avatar': farmer['avatar_url'],
      };
    }).toList();
  }
}
