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

  // Fetch products belonging to a particular farmer.
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
    final products = List<Map<String, dynamic>>.from(
      response.map((item) => Map<String, dynamic>.from(item)),
    );

    if (products.isEmpty) {
      return [];
    }

    final productIds = products
        .map((product) => product['id'])
        .where((id) => id != null)
        .toList();

    final unitIds = products
        .map((product) => product['unit_id'])
        .where((id) => id != null)
        .toSet()
        .toList();

    final categoryIds = products
        .map((product) => product['category_id'])
        .where((id) => id != null)
        .toSet()
        .toList();

    final sellerIds = products
        .map((product) => product['seller_id'])
        .where((id) => id != null)
        .toSet()
        .toList();

    // Product images.
    final Map<dynamic, List<String>> imagesByProductId = {};

    if (productIds.isNotEmpty) {
      final imageResponse = await _client
          .from('product_images')
          .select('product_id, image_url, display_order')
          .inFilter('product_id', productIds)
          .order('display_order', ascending: true);

      for (final image in imageResponse) {
        final productId = image['product_id'];
        final imageUrl = image['image_url']?.toString();

        if (productId != null && imageUrl != null && imageUrl.isNotEmpty) {
          imagesByProductId.putIfAbsent(productId, () => []);
          imagesByProductId[productId]!.add(imageUrl);
        }
      }
    }

    // Unit names.
    final Map<dynamic, String> unitNameById = {};

    if (unitIds.isNotEmpty) {
      final unitResponse = await _client
          .from('units')
          .select('id, name')
          .inFilter('id', unitIds);

      for (final unit in unitResponse) {
        if (unit['id'] != null) {
          unitNameById[unit['id']] = unit['name']?.toString() ?? 'unit';
        }
      }
    }

    // Category names.
    final Map<dynamic, String> categoryNameById = {};

    if (categoryIds.isNotEmpty) {
      final categoryResponse = await _client
          .from('categories')
          .select('id, name')
          .inFilter('id', categoryIds);

      for (final category in categoryResponse) {
        if (category['id'] != null) {
          categoryNameById[category['id']] =
              category['name']?.toString() ?? 'Uncategorized';
        }
      }
    }

    // Farmer profiles.
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

        if (userId != null) {
          farmerByUserId[userId] = Map<String, dynamic>.from(farmer);
        }
      }
    }

    // Attach all retrieved information to each product.
    return products.map((product) {
      final productId = product['id'];
      final unitId = product['unit_id'];
      final categoryId = product['category_id'];
      final sellerId = product['seller_id']?.toString();

      final farmer = sellerId == null
          ? <String, dynamic>{}
          : farmerByUserId[sellerId] ?? <String, dynamic>{};

      final productImages = imagesByProductId[productId] ?? <String>[];

      return <String, dynamic>{
        ...product,

        // Images.
        'image_url': productImages.isNotEmpty ? productImages.first : null,
        'images': productImages,

        // Unit and category.
        'unit_name': unitNameById[unitId] ?? 'unit',
        'category_name': categoryNameById[categoryId] ?? 'Uncategorized',

        // Farmer information.
        'farmer_name': farmer['full_name'] ?? 'Farmer',
        'farm_name': farmer['farm_name'] ?? 'Farm',
        'farm_origin': farmer['farm_origin'] ?? 'Location not provided',
        'farmer_bio': farmer['bio'],
        'farmer_contact': farmer['contact_number'],
        'farmer_avatar': farmer['avatar_url'],
      };
    }).toList();
  }
}
