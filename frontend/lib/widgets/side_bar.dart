import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/login.dart';

class SidebarItem {
  final IconData icon;
  final String label;

  const SidebarItem({required this.icon, required this.label});
}

class SidebarSection extends StatelessWidget {
  final String title;

  const SidebarSection({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class AppSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  static const List<SidebarItem> items = [
    SidebarItem(icon: Icons.dashboard_rounded, label: "Dashboard"),
    SidebarItem(icon: Icons.cloud_upload_rounded, label: "Dataset Upload"),
    SidebarItem(icon: Icons.people_rounded, label: "Customers"),
    SidebarItem(icon: Icons.campaign_rounded, label: "Campaign Generator"),
    SidebarItem(icon: Icons.auto_awesome_rounded, label: "Social Media"),
    SidebarItem(icon: Icons.person_search_rounded, label: "Leads"),
    SidebarItem(icon: Icons.insights_rounded, label: "AI Analytics"),
    SidebarItem(icon: Icons.settings_rounded, label: "Settings"),
  ];

  Widget _buildSection(String title, int startIndex, int endIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SidebarSection(title: title),
        for (int i = startIndex; i <= endIndex; i++)
          _SidebarTile(
            item: items[i],
            active: selectedIndex == i,
            onTap: () => onItemSelected(i),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      color: const Color(0xFF1B2559),
      child: Column(
        children: [
          const SizedBox(height: 28),

          // Logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.auto_graph,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  "INSIGHTX",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Scrollable Menu
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection("Main", 0, 0),

                  _buildSection("Data", 1, 2),

                  _buildSection("AI Marketing Studio", 3, 5),

                  _buildSection("Workspace", 6, 7),
                ],
              ),
            ),
          ),

          const Divider(color: Colors.white24, thickness: 1, height: 1),

          // Bottom Profile
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PopupMenuButton<String>(
                    tooltip: '',
                    offset: const Offset(0, -60),
                    color: const Color(0xFF2B315C), // Match your sidebar theme
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                        color: Color(0xFF4A4F7A),
                        width: 1,
                      ),
                    ),
                    onSelected: (value) async {
                      if (value == 'logout') {
                        // logout code
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();

                        await prefs.remove('access_token'); // or prefs.clear()

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem<String>(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              color: Colors.white70,
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Logout',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    child: Row(
                      children: [
                        SizedBox(width: 10),
                        Text(
                          "Admin",
                          style: const TextStyle(
                            color: Colors
                                .white70, // same as your sidebar menu text
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(Icons.arrow_drop_down),
                      ],
                    ),
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

class _SidebarTile extends StatelessWidget {
  final SidebarItem item;
  final bool active;
  final VoidCallback onTap;

  const _SidebarTile({
    required this.item,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: active
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 18,
                  color: active ? Colors.deepPurpleAccent : Colors.transparent,
                ),
                const SizedBox(width: 12),
                Icon(
                  item.icon,
                  size: 20,
                  color: active ? Colors.white : Colors.white60,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: active ? Colors.white : Colors.white60,
                      fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
