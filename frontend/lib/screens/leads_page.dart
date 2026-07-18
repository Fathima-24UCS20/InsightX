import 'package:flutter/material.dart';
import '../widgets/lead_summary_card.dart';
import '../widgets/lead_table.dart';
import '../widgets/lead_suggestion_card.dart';
import '../widgets/recent_lead_card.dart';
import '../widgets/lead_status_chart.dart';
//import '../models/lead.dart';
import '../models/lead_summary.dart';
import '../services/lead_services.dart';
import '../models/lead_chart.dart';
//import '../services/lead_services.dart';

class LeadsPage extends StatelessWidget {
  const LeadsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========================= HEADER =========================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Leads",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B2559),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Manage prospects with AI-powered lead scoring.",
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ],
              ),

              Row(
                children: [
                  // Search Box
                  Container(
                    width: 250,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(width: 12),
                        Icon(Icons.search, color: Colors.grey),
                        SizedBox(width: 10),
                        Text(
                          "Search leads...",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 15),

                  // Filter Button
                  Container(
                    height: 45,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.filter_list),
                        SizedBox(width: 8),
                        Text("Filter"),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 30),

          // ========================= KPI CARDS =========================
          FutureBuilder<LeadSummary>(
            future: LeadService().fetchSummary(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              }

              final summary = snapshot.data!;

              return Row(
                children: [
                  Expanded(
                    child: LeadSummaryCard(
                      icon: Icons.people,
                      title: "Total Leads",
                      value: summary.totalLeads.toString(),
                      subtitle: "Customers",
                      iconColor: Colors.blue,
                      iconBackground: const Color(0xFFE8F3FF),
                    ),
                  ),

                  const SizedBox(width: 20),

                  Expanded(
                    child: LeadSummaryCard(
                      icon: Icons.local_fire_department,
                      title: "Hot Leads",
                      value: summary.hotLeads.toString(),
                      subtitle: "High Priority",
                      iconColor: Colors.red,
                      iconBackground: const Color(0xFFFFECE8),
                    ),
                  ),

                  const SizedBox(width: 20),

                  Expanded(
                    child: LeadSummaryCard(
                      icon: Icons.psychology,
                      title: "Avg AI Score",
                      value: summary.averageScore.toStringAsFixed(1),
                      subtitle: "Out of 100",
                      iconColor: Colors.deepPurple,
                      iconBackground: const Color(0xFFF1EBFF),
                    ),
                  ),

                  const SizedBox(width: 20),

                  Expanded(
                    child: LeadSummaryCard(
                      icon: Icons.notifications_active,
                      title: "Follow-ups",
                      value: summary.followups.toString(),
                      subtitle: "Need Action",
                      iconColor: Colors.green,
                      iconBackground: const Color(0xFFEAF8ED),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 30),

          // ========================= TOP SECTION =========================
          SizedBox(
            height: 500,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(flex: 3, child: LeadTable()),

                SizedBox(width: 20),

                Expanded(flex: 2, child: LeadSuggestionsCard()),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ========================= BOTTOM SECTION =========================
          SizedBox(
            height: 340,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: FutureBuilder<LeadChart>(
                    future: LeadService().fetchLeadChart(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text(snapshot.error.toString()));
                      }

                      final chart = snapshot.data!;

                      return LeadStatusChart(
                        hot: chart.hot,
                        warm: chart.warm,
                        cold: chart.cold,
                      );
                    },
                  ),
                ),

                SizedBox(width: 20),

                Expanded(flex: 2, child: RecentLeadCard()),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
