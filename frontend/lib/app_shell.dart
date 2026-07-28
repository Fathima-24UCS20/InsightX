import 'package:flutter/material.dart';
import 'screens/leads_page.dart';
import 'widgets/side_bar.dart';
import 'screens/dashboard_page.dart';
import 'screens/db_upload.dart';

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

      case 2:
        return Center(child: Text("Customers"));

      case 3:
        return Center(child: Text("Products"));

      case 4:
        return Center(child: Text("Orders"));

      case 5:
        return const LeadsPage();

      case 6:
        return Center(child: Text("Analytics"));

      case 7:
        return Center(child: Text("Settings"));

      default:
        return const SizedBox();
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
