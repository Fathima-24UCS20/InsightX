import 'package:flutter/material.dart';

class LeadSuggestionsCard extends StatelessWidget {
  const LeadSuggestionsCard({super.key});

  Widget suggestionTile({
    required IconData icon,
    required Color color,
    required String title,
    required String customer,
    required String suggestion,
    required String buttonText,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: color.withOpacity(.15),
                child: Icon(icon, color: color, size: 18),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1B2559),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(customer, style: const TextStyle(fontWeight: FontWeight.w600)),

          const SizedBox(height: 4),

          Text(suggestion, style: TextStyle(color: Colors.grey.shade700)),

          const SizedBox(height: 12),

          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(buttonText),
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
            "Lead Suggestions",
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
                suggestionTile(
                  icon: Icons.shopping_bag_outlined,
                  color: Colors.blue,
                  title: "Product Recommendation",
                  customer: "Carlos",
                  suggestion: "Wireless Mouse + Laptop Bag",
                  buttonText: "View Products",
                ),

                suggestionTile(
                  icon: Icons.local_offer_outlined,
                  color: Colors.orange,
                  title: "Promotion Opportunity",
                  customer: "Jennifer",
                  suggestion: "Festival Sale -15%",
                  buttonText: "Send Offer",
                ),

                suggestionTile(
                  icon: Icons.workspace_premium_outlined,
                  color: Colors.green,
                  title: "Loyalty Upgrade",
                  customer: "David",
                  suggestion: "Premium Membership",
                  buttonText: "Invite",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
