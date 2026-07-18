class Lead {
  final String customer;
  final String? email;
  final int orders;
  final double spend;
  final int score;
  final String status;
  final String followup;
  final String? city;
  final String? registrationDate;
  final String? lastPurchase;
  final String? favoriteCategory;
  final String? favoriteBrand;
  final String? recommendation;
  final String? reason;

  Lead({
    required this.customer,
    required this.email,
    required this.orders,
    required this.spend,
    required this.score,
    required this.status,
    required this.followup,
    this.city,
    this.registrationDate,
    this.lastPurchase,
    this.favoriteCategory,
    this.favoriteBrand,
    this.recommendation,
    this.reason,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      customer: json["customer"],
      email: json["email"],
      orders: json["orders"],
      spend: (json["spend"] as num).toDouble(),
      score: json["score"],
      status: json["status"],
      followup: json["followup"],
      city: json["city"],
      registrationDate: json["registration_date"],
      lastPurchase: json["last_purchase"],
      favoriteCategory: json["favorite_category"],
      favoriteBrand: json["favorite_brand"],
      recommendation: json["recommendation"],
      reason: json["reason"],
    );
  }
}
