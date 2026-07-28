import 'package:flutter/material.dart';


/// pipeline over social/review content (no such data source exists yet).
class TopicItem {
  final String label;
  final int percent;
  const TopicItem(this.label, this.percent);
}

class TopicsOfInterestCard extends StatelessWidget {
  final List<TopicItem> topics;

  const TopicsOfInterestCard({
    super.key,
    this.topics = const [
      TopicItem("AI Automation", 34),
      TopicItem("Digital Marketing", 28),
      TopicItem("Productivity Tools", 18),
      TopicItem("Business Growth", 12),
      TopicItem("Data Analytics", 8),
    ],
  });

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
              const Expanded(
                child: Text(
                  "Top Topics of Interest",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
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
          const Text("Topics your audience talks about most", style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.amber.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
            child: const Text(
              "Demo data — needs a text-mining pipeline over social/review content",
              style: TextStyle(fontSize: 10, color: Colors.brown),
            ),
          ),
          const SizedBox(height: 10),
          ...topics.map(
            (t) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SizedBox(width: 110, child: Text(t.label, style: const TextStyle(fontSize: 12))),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: t.percent / 100,
                        minHeight: 8,
                        backgroundColor: const Color(0xFFF0F0F5),
                        valueColor: const AlwaysStoppedAnimation(Color(0xFF6C4DFF)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text("${t.percent}%", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}