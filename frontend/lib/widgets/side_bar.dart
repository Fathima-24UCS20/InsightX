import 'package:flutter/material.dart';

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

  const SidebarSection({
    super.key,
    required this.title,
  });

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
      icon: Icons.people_rounded,
      label: "Customers",
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
      label: "Settings",
      roles: ["admin"],
    ),
  ];

  List<SidebarItem> get visibleItems =>
      allItems.where((item) => item.roles.contains(role)).toList();

  Widget _buildSection(
    String title,
    int start,
    int end,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isExpanded)
          SidebarSection(title: title),

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

         const SizedBox(height: 20),

Padding(
  padding: const EdgeInsets.symmetric(horizontal: 10),
  child: isExpanded
      ? Row(
          children: [
            IconButton(
              onPressed: onToggle,
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
              ),
            ),
            /*const SizedBox(width: 10),
            Expanded(
              child: Text(
                role == "admin"
                    ? "Admin"
                    : "Marketing Manager",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13,
                ),
              ),
            ),*/
          ],
        )
      : const Center(
          child: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
),

          const SizedBox(height: 12),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (role == "admin") ...[
                    _buildSection("Main", 0, 0),
                    _buildSection("Data", 1, 2),
                    _buildSection("AI Marketing Studio", 3, 5),
                    _buildSection("Workspace", 6, 7),
                  ] else ...[
                    _buildSection("Main", 0, 0),
                    _buildSection("Customers", 1, 1),
                    _buildSection("AI Marketing Studio", 2, 4),
                    _buildSection("Workspace", 5, 5),
                  ],
                ],
              ),
            ),
          ),
          const Divider(
            color: Colors.white24,
            thickness: 1,
            height: 1,
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white24,
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 18,
                  ),
                ),

                if (isExpanded) ...[
                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      role == "admin"
                          ? "Admin"
                          : "Marketing Manager",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
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
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      child: Material(
        color: active
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            child: Row(
  mainAxisAlignment:
      isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
  children: [
    if (isExpanded)
      Container(
        width: 3,
        height: 18,
        color: active
            ? Colors.deepPurpleAccent
            : Colors.transparent,
      ),

    if (isExpanded)
      const SizedBox(width: 12),

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
            fontWeight:
                active ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    ],
  ],
)
          ),
        ),
      ),
    );
  }
}