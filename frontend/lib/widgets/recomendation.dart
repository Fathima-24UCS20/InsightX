import 'package:flutter/material.dart';

/// that compares campaign performance (needs the `campaigns` table + logic).
class AIRecommendationCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onApply;

  const AIRecommendationCard({
    super.key,
    this.title = "Increase budget for AI Product Launch Campaign",
    this.description =
        "This campaign is performing 24.5% better than others. Increasing budget can maximize results.",
    this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("AI Recommendation", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Text("Recommended action for better performance", style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.amber.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
            child: const Text(
              "Demo data — needs a recommendation engine over campaign performance",
              style: TextStyle(fontSize: 10, color: Colors.brown),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFF1EEFF), borderRadius: BorderRadius.circular(14)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(color: Colors.deepPurple, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.lightbulb, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
                  ],
                ),
                const SizedBox(height: 10),
                Text(description, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onApply ?? () {},
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text("Apply Recommendation"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C4DFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}