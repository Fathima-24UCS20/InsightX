import 'package:flutter/material.dart';
import '../widgets/lead_summary_card.dart';
import '../widgets/lead_table.dart';
import '../widgets/lead_suggestion_card.dart';
import '../widgets/recent_lead_card.dart';
import '../widgets/lead_status_chart.dart';

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
          Row(
            children: const [
              LeadSummaryCard(
                icon: Icons.people,
                title: "Total Leads",
                value: "350",
                subtitle: "+12 this week",
                iconColor: Colors.blue,
                iconBackground: Color(0xFFE8F3FF),
              ),
              LeadSummaryCard(
                icon: Icons.local_fire_department,
                title: "Hot Leads",
                value: "62",
                subtitle: "High Priority",
                iconColor: Colors.red,
                iconBackground: Color(0xFFFFECE8),
              ),
              LeadSummaryCard(
                icon: Icons.psychology,
                title: "Avg AI Score",
                value: "74",
                subtitle: "Out of 100",
                iconColor: Colors.deepPurple,
                iconBackground: Color(0xFFF1EBFF),
              ),
              LeadSummaryCard(
                icon: Icons.notifications_active,
                title: "Follow-ups",
                value: "18",
                subtitle: "Due Today",
                iconColor: Colors.green,
                iconBackground: Color(0xFFEAF8ED),
              ),
            ],
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
              children: const [
                Expanded(
                  flex: 3,
                  child: LeadStatusChart(hot: 62, warm: 158, cold: 130),
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
