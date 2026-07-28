import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RevenueTrendChart extends StatelessWidget {
  const RevenueTrendChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "Revenue Trend",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            "Monthly Revenue (Dummy Data)",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),

                borderData: FlBorderData(show: false),

                titlesData: FlTitlesData(

                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),

                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),

                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {

                        const months = [
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'May',
                          'Jun'
                        ];

                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            months[value.toInt()],
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      },
                    ),
                  ),

                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                    ),
                  ),
                ),

                minX: 0,
                maxX: 5,

                minY: 0,
                maxY: 100,

                lineBarsData: [

                  LineChartBarData(
                    isCurved: true,

                    color: Colors.deepPurple,

                    barWidth: 4,

                    dotData: const FlDotData(
                      show: true,
                    ),

                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.deepPurple.withOpacity(0.15),
                    ),

                    spots: const [

                      FlSpot(0, 20),

                      FlSpot(1, 35),

                      FlSpot(2, 45),

                      FlSpot(3, 65),

                      FlSpot(4, 58),

                      FlSpot(5, 82),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}