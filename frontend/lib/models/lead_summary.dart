class LeadSummary {
  final int totalLeads;
  final int hotLeads;
  final double averageScore;
  final int followups;

  LeadSummary({
    required this.totalLeads,
    required this.hotLeads,
    required this.averageScore,
    required this.followups,
  });

  factory LeadSummary.fromJson(Map<String, dynamic> json) {
    return LeadSummary(
      totalLeads: json["total_leads"],
      hotLeads: json["hot_leads"],
      averageScore: (json["average_score"] as num).toDouble(),
      followups: json["followups"],
    );
  }
}
