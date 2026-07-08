import 'package:flutter/material.dart';

import '../models/dashboard_stats.dart';
import '../services/analytics_services.dart';
import '../widgets/kpi_card.dart';
import '../widgets/dashboard_panel.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<DashboardStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = AnalyticsService.fetchDashboardStats();
  }

  void _refresh() {
    setState(() {
      _statsFuture = AnalyticsService.fetchDashboardStats();
    });
  }

  // Manual Indian-style grouping (₹2,45,000) — avoids adding the `intl`
  // package as a new dependency just for this.
  String _indianGroup(int n) {
    final negative = n < 0;
    final s = n.abs().toString();
    String result;
    if (s.length <= 3) {
      result = s;
    } else {
      var head = s.substring(0, s.length - 3);
      final tail = s.substring(s.length - 3);
      final parts = <String>[];
      while (head.length > 2) {
        parts.insert(0, head.substring(head.length - 2));
        head = head.substring(0, head.length - 2);
      }
      if (head.isNotEmpty) parts.insert(0, head);
      result = "${parts.join(',')},$tail";
    }
    return negative ? "-$result" : result;
  }

  String _money(num? value) {
    if (value == null) return "—";
    return "₹${_indianGroup(value.round())}";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: FutureBuilder<DashboardStats>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 80),
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Column(
                  children: [
                    Text(
                      "Couldn't load dashboard data: ${snapshot.error}",
                      style: TextStyle(color: Colors.red.shade400),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _refresh,
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              ),
            );
          }

          final stats = snapshot.data!;

          final kpis = [
            KpiCardData(
              icon: Icons.attach_money,
              iconColor: const Color(0xFF1E9E5A),
              iconBg: const Color(0xFFE3F7EA),
              title: "Total Revenue",
              displayValue: _money(stats.totalRevenue.value),
              changePct: stats.totalRevenue.changePct,
              available: stats.totalRevenue.available,
            ),
            KpiCardData(
              icon: Icons.shopping_bag,
              iconColor: const Color(0xFF3B82F6),
              iconBg: const Color(0xFFE5EEFF),
              title: "Total Orders",
              displayValue: stats.totalOrders.value?.toStringAsFixed(0) ?? "—",
              changePct: stats.totalOrders.changePct,
              available: stats.totalOrders.available,
            ),
            KpiCardData(
              icon: Icons.people_alt,
              iconColor: Colors.deepPurple,
              iconBg: Colors.deepPurple.withValues(alpha: 0.08),
              title: "Total Customers",
              displayValue:
                  stats.totalCustomers.value?.toStringAsFixed(0) ?? "—",
              changePct: stats.totalCustomers.changePct,
              available: stats.totalCustomers.available,
            ),
            KpiCardData(
              icon: Icons.receipt,
              iconColor: const Color(0xFFC8940A),
              iconBg: const Color(0xFFFFF6DE),
              title: "Average Order Value",
              displayValue: _money(stats.avgOrderValue.value),
              changePct: stats.avgOrderValue.changePct,
              available: stats.avgOrderValue.available,
            ),
            KpiCardData(
              icon: Icons.percent,
              iconColor: const Color(0xFFD64545),
              iconBg: const Color(0xFFFDE7E7),
              title: "Conversion Rate",
              displayValue: stats.conversionRate.value != null
                  ? "${stats.conversionRate.value}%"
                  : "—",
              changePct: stats.conversionRate.changePct,
              available: stats.conversionRate.available,
            ),
            KpiCardData(
              icon: Icons.campaign,
              iconColor: const Color(0xFF14B8A6),
              iconBg: const Color(0xFFE0F7F4),
              title: "Active Campaigns",
              displayValue:
                  stats.activeCampaigns.value?.toStringAsFixed(0) ?? "—",
              changePct: stats.activeCampaigns.changePct,
              available: stats.activeCampaigns.available,
            ),
          ];

          return ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Welcome back, John! 👋",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Here's what's happening with your business today.",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13.5,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Refresh Data"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = (constraints.maxWidth - 5 * 16) / 6;
                  final useWrap = cardWidth < 150;
                  if (useWrap) {
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: kpis
                          .map(
                            (k) => SizedBox(
                              width: (constraints.maxWidth - 16) / 2,
                              child: KpiCard(data: k),
                            ),
                          )
                          .toList(),
                    );
                  }
                  return Row(
                    children: kpis
                        .map(
                          (k) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: KpiCard(data: k),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 900;

                  Widget rowOf(List<Widget> pair) {
                    if (isNarrow) {
                      return Column(
                        children: pair
                            .map(
                              (p) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: p,
                              ),
                            )
                            .toList(),
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: pair
                          .map(
                            (p) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: p,
                              ),
                            ),
                          )
                          .toList(),
                    );
                  }

                  return Column(
                    children: [
                      rowOf(const [AiAlertsPanel(), AiRecommendationsPanel()]),
                      const SizedBox(height: 16),
                      rowOf(const [
                        TodaysActivityPanel(),
                        RecentActivityPanel(),
                      ]),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
