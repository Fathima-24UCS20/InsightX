class RecentLead {
  final String customer;
  final double spend;
  final String lastPurchase;

  RecentLead({
    required this.customer,
    required this.spend,
    required this.lastPurchase,
  });

  factory RecentLead.fromJson(Map<String, dynamic> json) {
    return RecentLead(
      customer: json["customer"],
      spend: (json["spend"] as num).toDouble(),
      lastPurchase: json["last_purchase"],
    );
  }
}
