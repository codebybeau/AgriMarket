class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final String unit;
  final String farmer;
  final String location;
  final String description;
  final String emoji;
  int stock;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.unit,
    required this.farmer,
    required this.location,
    required this.description,
    required this.emoji,
    required this.stock,
  });
}
