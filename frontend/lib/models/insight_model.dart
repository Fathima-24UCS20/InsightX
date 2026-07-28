/// One row from GET /analytics/top-products
class TopProduct {
  final int pId;
  final String name;
  final String category;
  final String brand;
  final double revenue;
  final int unitsSold;

  const TopProduct({
    required this.pId,
    required this.name,
    required this.category,
    required this.brand,
    required this.revenue,
    required this.unitsSold,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
  return TopProduct(
    pId: _toInt(json['p_id']),
    name: json['name'] as String? ?? '',
    category: json['category'] as String? ?? '',
    brand: json['brand'] as String? ?? '',
    revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
    unitsSold: _toInt(json['units_sold']),
  );
}
}
int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

/// One segment from GET /analytics/customer-distribution
class CitySegment {
  final String label;
  final int count;
  final double percent;

  const CitySegment({
    required this.label,
    required this.count,
    required this.percent,
  });

  factory CitySegment.fromJson(Map<String, dynamic> json) {
    return CitySegment(
      label: json['label'] as String? ?? '',
      count: json['count'] as int? ?? 0,
      percent: (json['percent'] as num?)?.toDouble() ?? 0,
    );
  }
}

class CustomerDistribution {
  final int totalCustomers;
  final List<CitySegment> segments;

  const CustomerDistribution({
    required this.totalCustomers,
    required this.segments,
  });

  factory CustomerDistribution.fromJson(Map<String, dynamic> json) {
    return CustomerDistribution(
      totalCustomers: json['total_customers'] as int? ?? 0,
      segments: (json['segments'] as List<dynamic>? ?? [])
          .map((e) => CitySegment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}