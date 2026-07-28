import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LeadStatusChart extends StatelessWidget {
  final int hot;
  final int warm;
  final int cold;

  const LeadStatusChart({
    super.key,
    required this.hot,
    required this.warm,
    required this.cold,
  });

  @override
  Widget build(BuildContext context) {
    final total = hot + warm + cold;

    double percent(int value) => total == 0 ? 0 : (value / total) * 100;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Lead Status Distribution",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B2559),
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      centerSpaceRadius: 50,
                      sectionsSpace: 4,
                      sections: [
                        PieChartSectionData(
                          value: hot.toDouble(),
                          color: Colors.red,
                          title: "${percent(hot).toStringAsFixed(0)}%",
                          radius: 55,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        PieChartSectionData(
                          value: warm.toDouble(),
                          color: Colors.orange,
                          title: "${percent(warm).toStringAsFixed(0)}%",
                          radius: 55,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        PieChartSectionData(
                          value: cold.toDouble(),
                          color: Colors.blue,
                          title: "${percent(cold).toStringAsFixed(0)}%",
                          radius: 55,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 20),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _LegendTile(
                        color: Colors.red,
                        title: "Hot Leads",
                        value: hot.toString(),
                      ),
                      const SizedBox(height: 18),
                      _LegendTile(
                        color: Colors.orange,
                        title: "Warm Leads",
                        value: warm.toString(),
                      ),
                      const SizedBox(height: 18),
                      _LegendTile(
                        color: Colors.blue,
                        title: "Cold Leads",
                        value: cold.toString(),
                      ),
                    ],
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

class _LegendTile extends StatelessWidget {
  final Color color;
  final String title;
  final String value;

  const _LegendTile({
    required this.color,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),

        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
