import 'package:flutter/material.dart';
import '../models/lead_suggestions.dart';
import '../services/lead_services.dart';

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
            child: FutureBuilder<List<LeadSuggestion>>(
              future: LeadService().fetchSuggestions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }

                final suggestions = snapshot.data!;

                return ListView.builder(
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    final item = suggestions[index];

                    Color color;
                    IconData icon;
                    String buttonText;

                    switch (item.status) {
                      case "Hot":
                        color = Colors.red;
                        icon = Icons.priority_high;
                        buttonText = "Contact";
                        break;

                      case "Warm":
                        color = Colors.orange;
                        icon = Icons.local_offer_outlined;
                        buttonText = "Email";
                        break;

                      default:
                        color = Colors.blue;
                        icon = Icons.discount_outlined;
                        buttonText = "Offer";
                    }

                    return suggestionTile(
                      icon: icon,
                      color: color,
                      title: item.recommendation,
                      customer: item.customer,
                      suggestion: item.reason,
                      buttonText: buttonText,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
