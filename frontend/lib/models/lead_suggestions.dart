class LeadSuggestion {
  final String customer;
  final String recommendation;
  final String reason;
  final String status;

  LeadSuggestion({
    required this.customer,
    required this.recommendation,
    required this.reason,
    required this.status,
  });

  factory LeadSuggestion.fromJson(Map<String, dynamic> json) {
    return LeadSuggestion(
      customer: json["customer"],
      recommendation: json["recommendation"],
      reason: json["reason"],
      status: json["status"],
    );
  }
}
