import 'package:flutter/material.dart';

import '../../models/insight_model.dart';
import '../../services/analytics_services.dart';

String _formatCurrency(num v) {
  final value = v.toDouble();
  if (value >= 10000000) return '₹${(value / 10000000).toStringAsFixed(2)} Cr';
  if (value >= 100000) return '₹${(value / 100000).toStringAsFixed(2)} L';
  return '₹${value.toStringAsFixed(0)}';
}

const List<Color> _badgeColors = [
  Colors.deepPurple,
  Colors.blue,
  Colors.teal,
  Colors.orange,
  Colors.pink,
];

class TopProductsCard extends StatelessWidget {
  final int limit;
  const TopProductsCard({super.key, this.limit = 5});

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Top Products",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    SizedBox(height: 2),
                    Text("By Revenue", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FutureBuilder<List<TopProduct>>(
            future: AnalyticsService.fetchTopProducts(limit: limit),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text("Couldn't load top products: ${snapshot.error}"),
                );
              }
              final products = snapshot.data ?? [];
              if (products.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text("No product sales yet", style: TextStyle(color: Colors.black38)),
                );
              }
              return Column(
                children: products.asMap().entries.map((entry) {
                  final i = entry.key;
                  final p = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: _badgeColors[i % _badgeColors.length],
                          child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name, overflow: TextOverflow.ellipsis, maxLines: 1),
                              Text(
                                "${p.brand} · ${p.category}",
                                style: const TextStyle(fontSize: 11, color: Colors.black38),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(_formatCurrency(p.revenue), style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text(
                              "${p.unitsSold} sold",
                              style: const TextStyle(fontSize: 11, color: Colors.black38),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}