class LeadChart {
  final int hot;
  final int warm;
  final int cold;

  LeadChart({required this.hot, required this.warm, required this.cold});

  factory LeadChart.fromJson(Map<String, dynamic> json) {
    return LeadChart(hot: json["Hot"], warm: json["Warm"], cold: json["Cold"]);
  }
}
