import 'package:flutter/material.dart';

class ProductSummaryCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String value;
  final String subtitle;
  final String? change;
  final bool isPositive;

  const ProductSummaryCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.value,
    required this.subtitle,
    this.change,
    this.isPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 23),
          ),

          const SizedBox(height: 10),

          // Title
          Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 4),

          // Value
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Color(0xFF172033),
            ),
          ),

          const SizedBox(height: 4),

          // Bottom information
          if (change != null)
            Row(
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 12,
                  color: isPositive
                      ? const Color(0xFF22A06B)
                      : const Color(0xFFEF4444),
                ),
                const SizedBox(width: 2),
                Text(
                  change!,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isPositive
                        ? const Color(0xFF22A06B)
                        : const Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    subtitle,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ),
              ],
            )
          else
            Text(
              subtitle,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
        ],
      ),
    );
  }
}
