import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/login.dart';

class SidebarItem {
  final IconData icon;
  final String label;
  final List<String> roles;

  const SidebarItem({
    required this.icon,
    required this.label,
    required this.roles,
  });
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
  final String role;
  final int selectedIndex;
  final bool isExpanded;
  final VoidCallback onToggle;
  final ValueChanged<int> onItemSelected;

  const AppSidebar({
    super.key,
    required this.role,
    required this.selectedIndex,
    required this.isExpanded,
    required this.onToggle,
    required this.onItemSelected,
  });

  static const List<SidebarItem> allItems = [
    SidebarItem(
      icon: Icons.dashboard_rounded,
      label: "Dashboard",
      roles: ["admin", "marketing manager"],
    ),
    SidebarItem(
      icon: Icons.cloud_upload_rounded,
      label: "Dataset Upload",
      roles: ["admin"],
    ),
    SidebarItem(
      icon: Icons.shopping_bag_outlined,
      label: "Products",
      roles: ["admin", "marketing manager"],
    ),
    SidebarItem(
      icon: Icons.campaign_rounded,
      label: "Campaign Generator",
      roles: ["admin", "marketing manager"],
    ),
    SidebarItem(
      icon: Icons.auto_awesome_rounded,
      label: "Social Media",
      roles: ["admin", "marketing manager"],
    ),
    SidebarItem(
      icon: Icons.person_search_rounded,
      label: "Leads",
      roles: ["admin", "marketing manager"],
    ),
    SidebarItem(
      icon: Icons.insights_rounded,
      label: "AI Analytics",
      roles: ["admin", "marketing manager"],
    ),
    SidebarItem(
      icon: Icons.settings_rounded,
      label: "Reports",
      roles: ["admin"],
    ),
  ];

  List<SidebarItem> get visibleItems =>
      allItems.where((item) => item.roles.contains(role)).toList();

  Widget _buildSection(String title, int start, int end) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isExpanded) SidebarSection(title: title),
        for (int i = start; i <= end; i++)
          _SidebarTile(
            item: visibleItems[i],
            active: selectedIndex == i,
            isExpanded: isExpanded,
            onTap: () => onItemSelected(i),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: isExpanded ? 230 : 80,
      color: const Color(0xFF1B2559),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Toggle button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: isExpanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: onToggle,
                  icon: const Icon(Icons.menu, color: Colors.white),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Scrollable Menu
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: role == "admin"
                    ? [
                        _buildSection("Main", 0, 0),
                        _buildSection("Data", 1, 2),
                        _buildSection("AI Marketing Studio", 3, 5),
                        _buildSection("Workspace", 6, 7),
                      ]
                    : [
                        _buildSection("Main", 0, 0),
                        _buildSection("Products", 1, 1),
                        _buildSection("AI Marketing Studio", 2, 4),
                        _buildSection("Workspace", 5, 5),
                      ],
              ),
            ),
          ),

          const Divider(color: Colors.white24, thickness: 1, height: 1),

          // Bottom Profile
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white, size: 18),
                ),
                if (isExpanded) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: PopupMenuButton<String>(
                      tooltip: '',
                      offset: const Offset(0, -60),
                      color: const Color(0xFF2B315C),
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
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove('access_token');

                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                          }
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
                          Expanded(
                            child: Text(
                              role == "admin" ? "Admin" : "Marketing Manager",
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white70,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
  final bool isExpanded;
  final VoidCallback onTap;

  const _SidebarTile({
    required this.item,
    required this.active,
    required this.isExpanded,
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
              mainAxisAlignment: isExpanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                if (isExpanded)
                  Container(
                    width: 3,
                    height: 18,
                    color: active
                        ? Colors.deepPurpleAccent
                        : Colors.transparent,
                  ),
                if (isExpanded) const SizedBox(width: 12),
                Icon(
                  item.icon,
                  size: 22,
                  color: active ? Colors.white : Colors.white60,
                ),
                if (isExpanded) ...[
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      item.label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: active ? Colors.white : Colors.white60,
                        fontWeight: active
                            ? FontWeight.w600
                            : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
