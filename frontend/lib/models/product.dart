/// A row from your `products` table, used to populate the
/// "Product / Service" dropdown in Campaign Generator instead of
/// free text.
class Product {
  final String id;
  final String name;
  final String category;
  final String brand;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.brand,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] ?? json['p_id']).toString(),
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
    );
  }

  /// What's shown in the dropdown, e.g. "Wireless Earbuds Pro (Audio)"
  String get displayLabel => category.isEmpty ? name : '$name ($category)';
}

int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}