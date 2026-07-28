import 'package:flutter/material.dart';

import 'widgets/side_bar.dart';
import 'screens/dashboard_page.dart';
import 'screens/db_upload.dart';
import 'screens/ai_insights_page.dart';
import 'screens/campaign_generator_page.dart';
import 'services/campaign_services.dart';
class AppShell extends StatefulWidget {
  final String role;

  const AppShell({
    super.key,
    required this.role,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}
class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  // NEW
  bool _isSidebarExpanded = true;

  Widget _bodyFor(int index) {
    final visibleItems = AppSidebar.allItems
        .where((item) => item.roles.contains(widget.role))
        .toList();

    final label = visibleItems[index].label;

    switch (label) {
      case "Dashboard":
        return const DashboardPage();

      case "Dataset Upload":
        return const DatasetUploadPage();

      case "Customers":
        return const Center(
          child: Text("Customers - Coming Soon"),
        );

      case "Campaign Generator":
        return CampaignGeneratorPage(
          service: CampaignService(
            baseUrl: "http://127.0.0.1:8000",
          ),
        );

      case "Social Media":
        return const Center(
          child: Text("Social Media - Coming Soon"),
        );

      case "Leads":
        return const Center(
          child: Text("Leads - Coming Soon"),
        );

      case "AI Analytics":
        return const AIInsightsPage();

      case "Settings":
        return const Center(
          child: Text("Settings - Coming Soon"),
        );

      default:
        return const Center(
          child: Text("Coming Soon"),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      body: Row(
        children: [
          AppSidebar(
            role: widget.role,
            selectedIndex: _selectedIndex,

            // NEW
            isExpanded: _isSidebarExpanded,

            // NEW
            onToggle: () {
              setState(() {
                _isSidebarExpanded = !_isSidebarExpanded;
              });
            },

            onItemSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),

          Expanded(
            child: _bodyFor(_selectedIndex),
          ),
        ],
      ),
    );
  }
}