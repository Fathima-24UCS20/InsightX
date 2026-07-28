/// Mirrors the `_card()` shape returned by every KPI field in
/// GET /analytics/dashboard: { value, change_pct, available }.
class KpiStat {
  final num? value;
  final double? changePct;
  final bool available;

  const KpiStat({this.value, this.changePct, this.available = true});

  factory KpiStat.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const KpiStat(available: false);
    return KpiStat(
      value: json['value'] as num?,
      changePct: (json['change_pct'] as num?)?.toDouble(),
      available: json['available'] as bool? ?? true,
    );
  }
}

/// Mirrors the full JSON body of GET /analytics/dashboard.
class DashboardStats {
  final KpiStat totalRevenue;
  final KpiStat totalOrders;
  final KpiStat totalCustomers;
  final KpiStat avgOrderValue;
  final KpiStat conversionRate;
  final KpiStat activeCampaigns;

  const DashboardStats({
    required this.totalRevenue,
    required this.totalOrders,
    required this.totalCustomers,
    required this.avgOrderValue,
    required this.conversionRate,
    required this.activeCampaigns,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalRevenue: KpiStat.fromJson(json['total_revenue']),
      totalOrders: KpiStat.fromJson(json['total_orders']),
      totalCustomers: KpiStat.fromJson(json['total_customers']),
      avgOrderValue: KpiStat.fromJson(json['avg_order_value']),
      conversionRate: KpiStat.fromJson(json['conversion_rate']),
      activeCampaigns: KpiStat.fromJson(json['active_campaigns']),
    );
  }
}