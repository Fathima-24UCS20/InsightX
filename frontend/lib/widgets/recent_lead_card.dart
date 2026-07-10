import 'package:flutter/material.dart';

class RecentLeadCard extends StatelessWidget {
  const RecentLeadCard({super.key});

  Widget activityTile({
    required IconData icon,
    required Color iconColor,
    required String activity,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: iconColor.withOpacity(0.15),
            child: Icon(icon, color: iconColor, size: 18),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1B2559),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  time,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Activity",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B2559),
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: ListView(
              children: [
                activityTile(
                  icon: Icons.shopping_cart_outlined,
                  iconColor: Colors.blue,
                  activity: "Carlos purchased Gaming Laptop",
                  time: "2 hours ago",
                ),

                const Divider(),

                activityTile(
                  icon: Icons.local_offer_outlined,
                  iconColor: Colors.orange,
                  activity: "Festival offer sent to Jennifer",
                  time: "5 hours ago",
                ),

                const Divider(),

                activityTile(
                  icon: Icons.person_add_alt_1_outlined,
                  iconColor: Colors.green,
                  activity: "Sarah created a new account",
                  time: "Yesterday",
                ),

                const Divider(),

                activityTile(
                  icon: Icons.workspace_premium_outlined,
                  iconColor: Colors.deepPurple,
                  activity: "David upgraded to Premium",
                  time: "2 days ago",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
