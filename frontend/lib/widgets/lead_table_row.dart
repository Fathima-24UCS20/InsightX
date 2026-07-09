import 'package:flutter/material.dart';

class LeadTableRow extends StatelessWidget {
  final String customer;
  final String orders;
  final String spend;
  final String score;
  final String status;
  final Color statusColor;

  const LeadTableRow({
    super.key,
    required this.customer,
    required this.orders,
    required this.spend,
    required this.score,
    required this.status,
    required this.statusColor,
  });

  Color getScoreColor() {
    final aiScore = int.parse(score);

    if (aiScore >= 85) {
      return Colors.green;
    } else if (aiScore >= 60) {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Customer
          Expanded(
            flex: 4,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.deepPurple.shade100,
                  child: Text(
                    customer[0],
                    style: const TextStyle(
                      color: Color(0xFF1B2559),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(customer, style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),

          // Orders
          Expanded(flex: 2, child: Text(orders, textAlign: TextAlign.center)),

          // Spend
          Expanded(flex: 2, child: Text(spend, textAlign: TextAlign.center)),

          // Score
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: getScoreColor().withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  score,
                  style: TextStyle(
                    color: getScoreColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Status
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          // Action
          Expanded(
            flex: 2,
            child: Center(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("View", style: TextStyle(fontSize: 13)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
