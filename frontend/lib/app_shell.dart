import 'package:flutter/material.dart';

import 'widgets/side_bar.dart';
import 'screens/dashboard/dashboard_page.dart';
import 'screens/dataset_upload/db_upload.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0; // 0 = Dashboard, matches AppSidebar.items order

  Widget _bodyFor(int index) {
    switch (index) {
      case 0:
        return const DashboardPage();
      case 1:
        return const DatasetUploadPage();
      default:
        // Customers / Products / Orders / Analytics / Settings screens
        // aren't built yet — add them here as you build them out.
        final label = AppSidebar.items[index].label;
        return Center(
          child: Text(
            "$label — coming soon",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
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
            selectedIndex: _selectedIndex,
            onItemSelected: (i) => setState(() => _selectedIndex = i),
          ),
          Expanded(child: _bodyFor(_selectedIndex)),
        ],
      ),
    );
  }
}