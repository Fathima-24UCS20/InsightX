import 'package:flutter/material.dart';

class AIInsightsCard extends StatelessWidget {
  const AIInsightsCard({super.key});

  Widget buildInsight({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(.15),
            child: Icon(icon, color: color, size: 18),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1B2559),
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  description,
                  style: TextStyle(color: Colors.grey.shade600, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "AI Insights",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B2559),
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  buildInsight(
                    icon: Icons.star,
                    color: Colors.orange,
                    title: "High Priority Lead",
                    description:
                        "Carlos has an AI Score of 94. Recommend premium offers to maximize conversion.",
                  ),

                  buildInsight(
                    icon: Icons.email_outlined,
                    color: Colors.blue,
                    title: "Follow-up Needed",
                    description:
                        "Jennifer hasn't placed an order in over 90 days. Send a promotional email.",
                  ),

                  buildInsight(
                    icon: Icons.shopping_bag_outlined,
                    color: Colors.green,
                    title: "Cross-sell Opportunity",
                    description:
                        "David purchased a laptop. Recommend accessories like a mouse and keyboard.",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
