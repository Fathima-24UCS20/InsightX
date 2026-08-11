import 'dart:math' as math;
import 'package:flutter/material.dart';

/// TODO(backend): replace with real audience age-breakdown once customer
/// demographic data (e.g. date_of_birth or age_bracket on `customers`) exists.
class AudienceSegment {
  final String label;
  final double percent;
  final Color color;
  const AudienceSegment(this.label, this.percent, this.color);
}

class AudienceDonutCard extends StatelessWidget {
  final int totalAudience;
  final List<AudienceSegment> segments;
  final String insightText;

  const AudienceDonutCard({
    super.key,
    this.totalAudience = 24560,
    this.segments = const [
      AudienceSegment("18-24 years", 28.5, Colors.blue),
      AudienceSegment("25-34 years", 41.2, Colors.indigo),
      AudienceSegment("35-44 years", 18.7, Colors.green),
      AudienceSegment("45+ years", 11.6, Colors.orange),
    ],
    this.insightText =
        "The 25-34 age group is your most active audience and contributes the highest conversions.",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Audience Insights", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.amber.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
            child: const Text("Demo data — needs age data on customers", style: TextStyle(fontSize: 10, color: Colors.brown)),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(150, 150),
                  painter: _DonutPainter(segments),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Total Audience", style: TextStyle(fontSize: 11, color: Colors.grey)),
                    Text(totalAudience.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...segments.map(
            (s) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: s.color, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(s.label, style: const TextStyle(fontSize: 12))),
                  Text("${s.percent}%", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF1EEFF), borderRadius: BorderRadius.circular(12)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.auto_awesome, size: 16, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Expanded(child: Text(insightText, style: const TextStyle(fontSize: 12))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<AudienceSegment> segments;
  _DonutPainter(this.segments);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final strokeWidth = size.width * 0.18;
    double startAngle = -math.pi / 2;
    for (final s in segments) {
      final sweep = (s.percent / 100) * 2 * math.pi;
      final paint = Paint()
        ..color = s.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawArc(rect.deflate(strokeWidth / 2), startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) => false;
}