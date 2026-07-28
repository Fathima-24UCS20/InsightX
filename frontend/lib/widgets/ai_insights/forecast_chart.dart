import 'package:flutter/material.dart';


/// (e.g. Prophet/ARIMA) run over historical revenue from `orders`.
class SalesForecastCard extends StatelessWidget {
  final String rangeLabel;
  final String changeLabel;
  final List<double> forecastPoints;
  final List<String> dayLabels;

  const SalesForecastCard({
    super.key,
    this.rangeLabel = "₹15.8L – ₹17.2L",
    this.changeLabel = "↑ 16% – 26% vs this week",
    this.forecastPoints = const [7.2, 8.5, 7.9, 8.8, 8.2, 9.1, 8.6],
    this.dayLabels = const ["May 22", "May 23", "May 24", "May 25", "May 26", "May 27", "May 28"],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 210,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Sales Forecast", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Text("AI predicted revenue for next 7 days", style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 12),
                Text(rangeLabel, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFEFFAF0), borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    changeLabel,
                    style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.amber.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                  child: const Text(
                    "Demo data — needs a real forecasting model over historical revenue",
                    style: TextStyle(fontSize: 10, color: Colors.brown),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: [
                SizedBox(
                  height: 120,
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _DashedForecastPainter(forecastPoints),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: dayLabels
                      .map((d) => Text(d, style: const TextStyle(fontSize: 10, color: Colors.grey)))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedForecastPainter extends CustomPainter {
  final List<double> points;
  _DashedForecastPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final maxVal = points.reduce((a, b) => a > b ? a : b);
    final minVal = points.reduce((a, b) => a < b ? a : b);
    final range = (maxVal - minVal) == 0 ? 1 : (maxVal - minVal);
    final stepX = size.width / (points.length - 1);

    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final x = i * stepX;
      final y = size.height - ((points[i] - minVal) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final dashPaint = Paint()
      ..color = const Color(0xFF6C4DFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      const dashWidth = 6.0;
      const dashGap = 4.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          dashPaint,
        );
        distance = next + dashGap;
      }
    }

    final dotPaint = Paint()..color = const Color(0xFF6C4DFF);
    for (int i = 0; i < points.length; i++) {
      final x = i * stepX;
      final y = size.height - ((points[i] - minVal) / range) * size.height;
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashedForecastPainter oldDelegate) => false;
}