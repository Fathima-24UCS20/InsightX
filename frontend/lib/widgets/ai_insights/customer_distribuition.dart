import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../models/insight_model.dart';
import '../../services/analytics_services.dart';

/// Real customer distribution by city — pulled from GET /analytics/customer-distribution.
///
/// This is a genuine-data replacement for the *demo* AudienceDonutCard
/// (widgets/audience_card.dart), which breaks customers down by AGE —
/// something we can't compute since `customers` has no birthdate/age
/// column. City is the dimension we actually have real data for.
class CustomerCityDistributionCard extends StatelessWidget {
  const CustomerCityDistributionCard({super.key});

  static const List<Color> _colors = [
    Colors.blue,
    Colors.indigo,
    Colors.green,
    Colors.orange,
    Colors.pink,
    Colors.grey,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Customers by City", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          FutureBuilder<CustomerDistribution>(
            future: AnalyticsService.fetchCustomerDistribution(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 150,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return SizedBox(
                  height: 150,
                  child: Center(child: Text("Couldn't load: ${snapshot.error}")),
                );
              }
              final dist = snapshot.data!;
              if (dist.segments.isEmpty) {
                return const SizedBox(
                  height: 150,
                  child: Center(child: Text("No customer data yet", style: TextStyle(color: Colors.black38))),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 150,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(150, 150),
                          painter: _DonutPainter(dist.segments, _colors),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("Total Customers", style: TextStyle(fontSize: 11, color: Colors.grey)),
                            Text(dist.totalCustomers.toString(),
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...dist.segments.asMap().entries.map((entry) {
                    final i = entry.key;
                    final s = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(color: _colors[i % _colors.length], shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(s.label, style: const TextStyle(fontSize: 12))),
                          Text("${s.percent}%", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<CitySegment> segments;
  final List<Color> colors;
  _DonutPainter(this.segments, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final strokeWidth = size.width * 0.18;
    double startAngle = -math.pi / 2;
    for (int i = 0; i < segments.length; i++) {
      final sweep = (segments[i].percent / 100) * 2 * math.pi;
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawArc(rect.deflate(strokeWidth / 2), startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) => false;
}