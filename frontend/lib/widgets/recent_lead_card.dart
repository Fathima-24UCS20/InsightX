import 'package:flutter/material.dart';
import '../models/recent_lead.dart';
import '../services/lead_services.dart';
import 'package:intl/intl.dart';

class RecentLeadCard extends StatelessWidget {
  const RecentLeadCard({super.key});

  Widget activityTile(RecentLead lead) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.blue.withOpacity(.15),
            child: const Icon(
              Icons.shopping_cart_outlined,
              color: Colors.blue,
              size: 18,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lead.customer,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "Purchased ₹${NumberFormat('#,##,###').format(lead.spend)}",
                  style: TextStyle(color: Colors.grey.shade700),
                ),

                const SizedBox(height: 4),

                Text(
                  DateFormat(
                    "MMM dd, yyyy",
                  ).format(DateTime.parse(lead.lastPurchase)),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Activity",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B2559),
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: FutureBuilder<List<RecentLead>>(
              future: LeadService().fetchRecentLeads(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }

                final recent = snapshot.data!;

                return ListView.builder(
                  itemCount: recent.length,
                  itemBuilder: (context, index) {
                    final lead = recent[index];
                    return activityTile(lead);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
