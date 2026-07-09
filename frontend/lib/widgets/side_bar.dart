import 'package:flutter/material.dart';

class SidebarItem {
  final IconData icon;
  final String label;

  const SidebarItem({required this.icon, required this.label});
}

class AppSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  // Index order here drives routing in AppShell — keep them in sync.
  static const items = [
    SidebarItem(icon: Icons.dashboard_rounded, label: "Dashboard"),
    SidebarItem(icon: Icons.cloud_upload_rounded, label: "Dataset Upload"),
    SidebarItem(icon: Icons.people_rounded, label: "Customers"),
    SidebarItem(icon: Icons.inventory_2_rounded, label: "Products"),
    SidebarItem(icon: Icons.receipt_long_rounded, label: "Orders"),
    SidebarItem(icon: Icons.track_changes_rounded, label: "Leads"),
    SidebarItem(icon: Icons.insights_rounded, label: "Analytics"),
    SidebarItem(icon: Icons.settings_rounded, label: "Settings"),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      color: const Color(0xFF1B2559),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),
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
          const SizedBox(height: 36),
          for (var i = 0; i < items.length; i++)
            _SidebarTile(
              item: items[i],
              active: i == selectedIndex,
              onTap: () => onItemSelected(i),
            ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, size: 18, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Admin",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: active
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                Text(
                  item.label,
                  style: TextStyle(
                    color: active ? Colors.white : Colors.white60,
                    fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 14,
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
