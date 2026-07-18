import 'package:flutter/material.dart';
import '../models/lead.dart';

class LeadTableRow extends StatelessWidget {
  final Lead lead;
  final Color statusColor;

  const LeadTableRow({
    super.key,
    required this.lead,
    required this.statusColor,
  });

  Color getScoreColor() {
    final aiScore = lead.score;

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
                    lead.customer[0],
                    style: const TextStyle(
                      color: Color(0xFF1B2559),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    lead.customer,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
          ),

          // Orders
          Expanded(
            flex: 2,
            child: Text(lead.orders.toString(), textAlign: TextAlign.center),
          ),

          // Spend
          Expanded(
            flex: 2,
            child: Text(lead.spend.toString(), textAlign: TextAlign.center),
          ),

          // Score
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: getScoreColor().withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  lead.score.toString(),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  lead.status,
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
              child: FilledButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(
                        lead.customer,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      content: SizedBox(
                        width: 420,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _detail("Email", lead.email ?? "-"),
                              _detail("City", lead.city ?? "-"),
                              _detail("Orders", lead.orders.toString()),
                              _detail(
                                "Total Spend",
                                "₹${lead.spend.toStringAsFixed(2)}",
                              ),
                              _detail("AI Score", lead.score.toString()),
                              _detail("Status", lead.status),
                              _detail(
                                "Registration",
                                lead.registrationDate ?? "-",
                              ),
                              _detail(
                                "Last Purchase",
                                lead.lastPurchase ?? "-",
                              ),
                              _detail(
                                "Favorite Category",
                                lead.favoriteCategory ?? "-",
                              ),
                              _detail(
                                "Favorite Brand",
                                lead.favoriteBrand ?? "-",
                              ),

                              const SizedBox(height: 20),

                              const Text(
                                "AI Recommendation",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(lead.recommendation ?? "-"),

                              const SizedBox(height: 15),

                              const Text(
                                "Reason",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(lead.reason ?? "-"),

                              const SizedBox(height: 15),

                              const Text(
                                "Follow-up",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(lead.followup),
                            ],
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Close"),
                        ),
                      ],
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const FittedBox(
                  child: const Text("View", style: TextStyle(fontSize: 13)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detail(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
