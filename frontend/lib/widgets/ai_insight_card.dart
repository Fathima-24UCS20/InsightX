import 'package:flutter/material.dart';

class AIInsightsCard extends StatelessWidget {
  const AIInsightsCard({super.key});

  Widget buildInsight({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(.15),
            child: Icon(icon, color: color, size: 18),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
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

          buildInsight(
            icon: Icons.local_fire_department,
            color: Colors.red,
            title: "Carlos is likely to purchase again",
            subtitle: "High purchase frequency and strong order history.",
          ),

          buildInsight(
            icon: Icons.email,
            color: Colors.blue,
            title: "Jennifer needs a follow-up",
            subtitle: "No orders in the last 90 days.",
          ),

          buildInsight(
            icon: Icons.shopping_bag,
            color: Colors.green,
            title: "Recommend accessories",
            subtitle:
                "Customers who bought laptops often buy mice and keyboards.",
          ),
        ],
      ),
    );
  }
}
