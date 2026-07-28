import 'package:flutter/material.dart';


/// Suggested shape: campaigns(id, name, revenue, change_pct, is_active).
class CampaignItem {
  final String name;
  final String revenue;
  final String changePct;
  final bool isPositive;
  final Color badgeColor;

  const CampaignItem({
    required this.name,
    required this.revenue,
    required this.changePct,
    required this.isPositive,
    required this.badgeColor,
  });
}

class CampaignListCard extends StatelessWidget {
  final List<CampaignItem> campaigns;

  static const List<CampaignItem> _demoCampaigns = [
    CampaignItem(name: "AI Product Launch Campaign", revenue: "₹3.45L", changePct: "+24.5%", isPositive: true, badgeColor: Colors.deepPurple),
    CampaignItem(name: "Summer Offer Campaign", revenue: "₹2.78L", changePct: "+18.1%", isPositive: true, badgeColor: Colors.blue),
    CampaignItem(name: "Lead Generation Drive", revenue: "₹1.92L", changePct: "+15.3%", isPositive: true, badgeColor: Colors.teal),
    CampaignItem(name: "Re-engagement Campaign", revenue: "₹1.35L", changePct: "-4.2%", isPositive: false, badgeColor: Colors.orange),
    CampaignItem(name: "Brand Awareness Campaign", revenue: "₹1.12L", changePct: "+6.7%", isPositive: true, badgeColor: Colors.pink),
  ];

  const CampaignListCard({super.key, this.campaigns = _demoCampaigns});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Top Performing Campaigns",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    SizedBox(height: 2),
                    Text("By Revenue", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text("View All", style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const _DemoBadge(text: "Demo data — connect a campaigns table to make this live"),
          const SizedBox(height: 6),
          ...campaigns.asMap().entries.map((entry) {
            final i = entry.key;
            final c = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: c.badgeColor,
                    child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(c.name, overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 8),
                  Text(c.revenue, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  Text(
                    c.changePct,
                    style: TextStyle(color: c.isPositive ? Colors.green : Colors.red, fontSize: 12),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _DemoBadge extends StatelessWidget {
  final String text;
  const _DemoBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.amber.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: const TextStyle(fontSize: 10, color: Colors.brown)),
    );
  }
}