import 'dart:math' as math;
import 'package:flutter/material.dart';

/// TODO(backend): replace with output from a real sentiment-analysis
/// pipeline over review/social text (no such data source exists yet).
class SentimentGaugeCard extends StatelessWidget {
  final double score; // 0.0 (very negative) – 1.0 (very positive)
  final String label;

  const SentimentGaugeCard({
    super.key,
    this.score = 0.72,
    this.label = "Mostly Positive",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Customer Sentiment", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Text("Overall sentiment from reviews & social mentions",
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.amber.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
            child: const Text(
              "Demo data — needs a sentiment-analysis pipeline over review/social text",
              style: TextStyle(fontSize: 10, color: Colors.brown),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 110,
            child: CustomPaint(
              size: const Size(double.infinity, 110),
              painter: _GaugePainter(score),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              "${(score * 100).toStringAsFixed(0)}%",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double score;
  _GaugePainter(this.score);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);
    const start = math.pi;
    const sweepTotal = math.pi;

    final bg = Paint()
      ..color = const Color(0xFFF0F0F5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect.deflate(14), start, sweepTotal, false, bg);

    final color = score >= 0.6
        ? Colors.green
        : score >= 0.4
            ? Colors.orange
            : Colors.red;

    final fg = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect.deflate(14), start, sweepTotal * score.clamp(0, 1), false, fg);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) => oldDelegate.score != score;
}