import 'package:flutter/material.dart';

import '../widgets/ai_insights/ai_kpi_card.dart';
import '../widgets/ai_insights/revenue_trend_chart.dart';
import '../widgets/campaign_list_card.dart';
import '../widgets/ai_insights/audience_card.dart';
import '../widgets/ai_insights/customer_distribuition.dart';
import '../widgets/ai_insights/sentiment_gauge_card.dart'; 
import '../widgets/ai_insights/top_product.dart'; // NEW — real data
import '../widgets/ai_insights/topic_intrest.dart';
import '../widgets/recomendation.dart';
import '../widgets/ai_insights/forecast_chart.dart';
import '../models/dashboard_stats.dart';
import '../services/analytics_services.dart';

String formatCurrency(num? v) {
  if (v == null) return '--';
  final value = v.toDouble();
  if (value >= 10000000) return '₹${(value / 10000000).toStringAsFixed(2)} Cr';
  if (value >= 100000) return '₹${(value / 100000).toStringAsFixed(2)} L';
  return '₹${value.toStringAsFixed(0)}';
}

String formatPct(double? p) =>
    p == null ? '' : '${p >= 0 ? '+' : ''}${p.toStringAsFixed(1)}%';

class AIInsightsPage extends StatelessWidget {
  const AIInsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildKpiRow(),
              const SizedBox(height: 20),
              _buildRow1(),
              const SizedBox(height: 20),
              _buildRow1b(), // NEW row: real-data cards
              const SizedBox(height: 20),
              _buildRow2(),
              const SizedBox(height: 20),
              const SalesForecastCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "AI Insights",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFF1B2559)),
            ),
            SizedBox(height: 6),
            Text(
              "AI-powered insights to help you make smarter marketing decisions.",
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ],
        ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.calendar_month),
              label: const Text("May 15 – May 21, 2025"),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.ios_share),
              label: const Text("Export Insights"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C4DFF),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiRow() {
    return FutureBuilder<DashboardStats>(
      future: AnalyticsService.fetchDashboardStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 128,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return SizedBox(
            height: 128,
            child: Center(child: Text("Couldn't load KPIs: ${snapshot.error}")),
          );
        }

        final stats = snapshot.data!;

        final cards = <Widget>[
          AIKpiCard(
            title: "Total Revenue",
            value: formatCurrency(stats.totalRevenue.value),
            change: formatPct(stats.totalRevenue.changePct),
            isPositive: (stats.totalRevenue.changePct ?? 0) >= 0,
            icon: Icons.trending_up,
            color: const Color(0xFF6C4DFF),
          ),
          const AIKpiCard(
            title: "New Leads",
            icon: Icons.person_add_alt,
            color: Colors.blue,
            available: false, // no `leads` table yet
          ),
          AIKpiCard(
            title: "Conversion Rate",
            icon: Icons.track_changes,
            color: Colors.green,
            available: stats.conversionRate.available,
          ),
          const AIKpiCard(
            title: "Click Through Rate",
            icon: Icons.mouse,
            color: Colors.deepOrange,
            available: false, // no ad-click tracking yet
          ),
          AIKpiCard(
            title: "Avg Order Value",
            value: formatCurrency(stats.avgOrderValue.value),
            change: formatPct(stats.avgOrderValue.changePct),
            isPositive: (stats.avgOrderValue.changePct ?? 0) >= 0,
            icon: Icons.shopping_cart,
            color: Colors.purple,
          ),
        ];

        return Row(
          children: [
            for (int i = 0; i < cards.length; i++) ...[
              Expanded(child: cards[i]),
              if (i != cards.length - 1) const SizedBox(width: 16),
            ],
          ],
        );
      },
    );
  }

  Widget _buildRow1() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
              child: const SizedBox(
                height: 320,
                // Already wired to real revenue-per-month data via analytics.py
                child: RevenueTrendChart(),
              ),
            ),
          ),
          const SizedBox(width: 20),    
          const Expanded(child: CampaignListCard()),
          const SizedBox(width: 20),
          
          const Expanded(child: AudienceDonutCard()),
        ],
      ),
    );
  }

  /// New row: the two cards that are now backed by real data.
  Widget _buildRow1b() {
    return const IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: TopProductsCard()), // real: order_items x products
          SizedBox(width: 20),
          Expanded(child: CustomerCityDistributionCard()), // real: customers.city
        ],
      ),
    );
  }

  Widget _buildRow2() {
    return const IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // NOTE: still demo data — needs review/social text + NLP pipeline
          Expanded(child: SentimentGaugeCard()),
          SizedBox(width: 20),
          Expanded(child: TopicsOfInterestCard()),
          SizedBox(width: 20),
          Expanded(child: AIRecommendationCard()),
        ],
      ),
    );
  }
}