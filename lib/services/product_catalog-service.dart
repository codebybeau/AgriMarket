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

  // Attach the product image and unit name to each product.
  Future<List<Map<String, dynamic>>> _attachProductDetails(
    List<dynamic> response,
  ) async {
    final products = List<Map<String, dynamic>>.from(response);

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

    final imageByProductId = <dynamic, String>{};

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
          imageByProductId.putIfAbsent(productId, () => imageUrl);
        }
      }
    }

    final unitNameById = <dynamic, String>{};

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

    return products.map((product) {
      return <String, dynamic>{
        ...product,
        'image_url': imageByProductId[product['id']],
        'unit_name': unitNameById[product['unit_id']] ?? 'unit',
      };
    }).toList();
  }
}
