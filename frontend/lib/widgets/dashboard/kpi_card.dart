import 'package:flutter/material.dart';

class KpiCardData {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String displayValue;
  final double? changePct;
  final bool available;

  const KpiCardData({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.displayValue,
    required this.changePct,
    this.available = true,
  });
}

class KpiCard extends StatelessWidget {
  final KpiCardData data;
  const KpiCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final hasChange = data.available && data.changePct != null;
    final isPositive = (data.changePct ?? 0) >= 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: data.iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(data.icon, size: 18, color: data.iconColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  data.title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            data.displayValue,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          if (!data.available)
            Text(
              "No data yet",
              style: TextStyle(fontSize: 11.5, color: Colors.grey.shade400, fontStyle: FontStyle.italic),
            )
          else if (hasChange)
            Row(
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 13,
                  color: isPositive ? Colors.green.shade600 : Colors.red.shade600,
                ),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    "${data.changePct!.abs().toStringAsFixed(1)}% from last month",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isPositive ? Colors.green.shade600 : Colors.red.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            )
          else
            Text("—", style: TextStyle(fontSize: 11.5, color: Colors.grey.shade400)),
        ],
      ),
    );
  }
}