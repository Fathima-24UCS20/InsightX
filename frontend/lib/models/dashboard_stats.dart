/// One KPI value returned by GET /analytics/dashboard.
///
/// `available` is false for metrics that can't be computed yet (e.g.
/// Conversion Rate, Active Campaigns) because the backend has no
/// leads/campaigns tables. The UI should show "No data yet" in that case
/// rather than a fabricated number.
class KpiValue {
  final num? value;
  final double? changePct;
  final bool available;

  const KpiValue({
    required this.value,
    required this.changePct,
    required this.available,
  });

  factory KpiValue.fromJson(Map<String, dynamic> json) {
    return KpiValue(
      value: json['value'] as num?,
      changePct: (json['change_pct'] as num?)?.toDouble(),
      available: json['available'] as bool? ?? true,
    );
  }
}

class DashboardStats {
  final KpiValue totalRevenue;
  final KpiValue totalOrders;
  final KpiValue totalCustomers;
  final KpiValue avgOrderValue;
  final KpiValue conversionRate;
  final KpiValue activeCampaigns;

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
      totalRevenue: KpiValue.fromJson(json['total_revenue']),
      totalOrders: KpiValue.fromJson(json['total_orders']),
      totalCustomers: KpiValue.fromJson(json['total_customers']),
      avgOrderValue: KpiValue.fromJson(json['avg_order_value']),
      conversionRate: KpiValue.fromJson(json['conversion_rate']),
      activeCampaigns: KpiValue.fromJson(json['active_campaigns']),
    );
  }
}