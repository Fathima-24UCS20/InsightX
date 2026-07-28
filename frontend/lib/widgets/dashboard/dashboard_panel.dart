import 'package:flutter/material.dart';

// All data in this file is static placeholder content — swap for a real
// endpoint once you have tables/logic for alerts, recommendations,
// activity logs, etc. on the backend.

class _PanelShell extends StatelessWidget {
  final String title;
  final String badge;
  final Widget child;

  const _PanelShell({required this.title, required this.badge, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(width: 6),
                  Text("($badge)", style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                ],
              ),
              Text(
                "View All",
                style: TextStyle(color: Colors.deepPurple.shade300, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _AlertItem {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String time;
  const _AlertItem(this.icon, this.color, this.title, this.subtitle, this.time);
}

const _alerts = [
  _AlertItem(Icons.trending_down, Color(0xFFD64545), "Instagram engagement dropped 12%",
      "Compared to last week", "10 min ago"),
  _AlertItem(Icons.warning_amber_rounded, Color(0xFFC8940A), "6 high-value leads need follow-up",
      "These leads are waiting for your response", "30 min ago"),
  _AlertItem(Icons.warning_amber_rounded, Color(0xFFC8940A), "Product 'Wireless Earbuds' stock is low",
      "Only 15 items left in stock", "45 min ago"),
  _AlertItem(Icons.check_circle, Color(0xFF1E9E5A), "Revenue increased 18% this week",
      "Great job! Keep it up", "1 hour ago"),
];

class AiAlertsPanel extends StatelessWidget {
  const AiAlertsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return _PanelShell(
      title: "AI Alerts",
      badge: "Dummy",
      child: Column(
        children: _alerts.map((a) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: a.color.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(a.icon, size: 18, color: a.color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text(a.subtitle, style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(a.time, style: TextStyle(fontSize: 10.5, color: Colors.grey.shade400)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _RecItem {
  final IconData icon;
  final String title;
  final String subtitle;
  const _RecItem(this.icon, this.title, this.subtitle);
}

const _recommendations = [
  _RecItem(Icons.person, "Contact Lead #124 today", "Lead score is 92 (High priority)"),
  _RecItem(Icons.campaign, "Increase budget for Campaign 'Summer Sale'", "High ROI and good performance"),
  _RecItem(Icons.camera_alt, "Post 3 more times on Instagram this week", "Engagement is below your average"),
  _RecItem(Icons.mail, "Send discount email to inactive customers", "Win back potential customers"),
];

class AiRecommendationsPanel extends StatelessWidget {
  const AiRecommendationsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return _PanelShell(
      title: "AI Recommendations",
      badge: "Dummy",
      child: Column(
        children: _recommendations.map((r) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(r.icon, size: 15, color: Colors.deepPurple),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text(r.subtitle, style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ActivityCount {
  final IconData icon;
  final String label;
  final int count;
  const _ActivityCount(this.icon, this.label, this.count);
}

const _todayActivity = [
  _ActivityCount(Icons.receipt_long, "New orders received", 12),
  _ActivityCount(Icons.people, "New customers added", 8),
  _ActivityCount(Icons.campaign, "Campaigns updated", 3),
  _ActivityCount(Icons.person_add, "Leads added", 15),
  _ActivityCount(Icons.description, "Reports generated", 2),
];

class TodaysActivityPanel extends StatelessWidget {
  const TodaysActivityPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return _PanelShell(
      title: "Today's Activity",
      badge: "Dummy",
      child: Column(
        children: _todayActivity.map((a) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(a.icon, size: 17, color: Colors.grey.shade500),
                const SizedBox(width: 10),
                Expanded(child: Text(a.label, style: const TextStyle(fontSize: 13))),
                Text(a.count.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _RecentActivityItem {
  final Color dotColor;
  final String text;
  final String time;
  const _RecentActivityItem(this.dotColor, this.text, this.time);
}

const _recentActivity = [
  _RecentActivityItem(Colors.deepPurple, "Dataset 'Customers.csv' uploaded", "2 hours ago"),
  _RecentActivityItem(Colors.deepPurple, "Campaign 'Summer Sale' created", "3 hours ago"),
  _RecentActivityItem(Color(0xFFD64545), "Lead 'Rahul Sharma' added", "4 hours ago"),
  _RecentActivityItem(Color(0xFFC8940A), "Report 'Sales Summary' generated", "5 hours ago"),
  _RecentActivityItem(Colors.deepPurple, "Dataset 'Orders.csv' uploaded", "6 hours ago"),
];

class RecentActivityPanel extends StatelessWidget {
  const RecentActivityPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return _PanelShell(
      title: "Recent Activity",
      badge: "Dummy",
      child: Column(
        children: _recentActivity.map((r) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(color: r.dotColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(r.text, style: const TextStyle(fontSize: 12.5))),
                const SizedBox(width: 8),
                Text(r.time, style: TextStyle(fontSize: 10.5, color: Colors.grey.shade400)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}