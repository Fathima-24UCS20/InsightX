import 'package:flutter/material.dart';
import 'lead_table_row.dart';

class LeadTable extends StatelessWidget {
  const LeadTable({super.key});

  @override
  Widget build(BuildContext context) {
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
          // ================= Header =================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Lead Overview",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B2559),
                ),
              ),
              TextButton(onPressed: () {}, child: const Text("View All")),
            ],
          ),

          const SizedBox(height: 20),

          // ================= Table Header =================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    "Customer",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),

                Expanded(
                  flex: 2,
                  child: Text(
                    "Orders",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),

                Expanded(
                  flex: 2,
                  child: Text(
                    "Spend",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),

                Expanded(
                  flex: 2,
                  child: Text(
                    "Score",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),

                Expanded(
                  flex: 2,
                  child: Text(
                    "Status",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),

                Expanded(
                  flex: 2,
                  child: Text(
                    "Action",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: const [
                  LeadTableRow(
                    customer: "Carlos",
                    orders: "12",
                    spend: "₹2.5L",
                    score: "94",
                    status: "Hot",
                    statusColor: Colors.red,
                  ),

                  LeadTableRow(
                    customer: "Jennifer",
                    orders: "8",
                    spend: "₹1.8L",
                    score: "81",
                    status: "Warm",
                    statusColor: Colors.orange,
                  ),

                  LeadTableRow(
                    customer: "David",
                    orders: "3",
                    spend: "₹45K",
                    score: "38",
                    status: "Cold",
                    statusColor: Colors.blue,
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
