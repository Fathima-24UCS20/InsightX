class Lead {
  final String customer;
  final int orders;
  final double spend;
  final int score;
  final String status;
  final String followup;
  final String? city;
  final String? favoriteCategory;
  final String? favoriteBrand;
  final String? recommendation;
  final String? reason;

  Lead({
    required this.customer,
    required this.orders,
    required this.spend,
    required this.score,
    required this.status,
    required this.followup,
    this.city,
    this.favoriteCategory,
    this.favoriteBrand,
    this.recommendation,
    this.reason,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      customer: json["customer"],
      orders: json["orders"],
      spend: (json["spend"] as num).toDouble(),
      score: json["score"],
      status: json["status"],
      followup: json["followup"],
      city: json["city"],
      favoriteCategory: json["favorite_category"],
      favoriteBrand: json["favorite_brand"],
      recommendation: json["recommendation"],
      reason: json["reason"],
    );
  }
}
