import 'package:flutter/material.dart';
import 'package:event_manager_application_finalproject/theme.dart';

class UserManagementDesign extends StatelessWidget {
  const UserManagementDesign({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'User Management',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onBackground,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        foregroundColor: colorScheme.onBackground,
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list_rounded, 
              color: colorScheme.onBackground.withOpacity(0.6)
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert_rounded, 
              color: colorScheme.onBackground.withOpacity(0.6)
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Stats
          _buildStatsHeader(context),
          
          // Search and Filters
          _buildSearchSection(context),
          
          // Users List
          Expanded(
            child: _buildUsersList(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: colorScheme.primary,
        child: Icon(
          Icons.person_add_rounded, 
          color: colorScheme.onPrimary, 
          size: 24
        ),
      ),
    );
  }

  Widget _buildStatsHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total Users', '8,542', Icons.people_alt_rounded, colorScheme),
          _buildStatItem('Active', '7,892', Icons.check_circle_rounded, colorScheme),
          _buildStatItem('Managers', '24', Icons.manage_accounts_rounded, colorScheme),
          _buildStatItem('Pending', '12', Icons.pending_actions_rounded, colorScheme),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, ColorScheme colorScheme) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.2), 
              width: 1
            ),
          ),
          child: Icon(
            icon, 
            color: colorScheme.primary, 
            size: 28
          ),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onBackground.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      color: colorScheme.surface,
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search users by name or email...',
                prefixIcon: Icon(
                  Icons.search_rounded, 
                  color: colorScheme.onBackground.withOpacity(0.6)
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All Users', true, colorScheme),
                const SizedBox(width: 8),
                _buildFilterChip('Admins', false, colorScheme),
                const SizedBox(width: 8),
                _buildFilterChip('Managers', false, colorScheme),
                const SizedBox(width: 8),
                _buildFilterChip('Attendees', false, colorScheme),
                const SizedBox(width: 8),
                _buildFilterChip('Active', false, colorScheme),
                const SizedBox(width: 8),
                _buildFilterChip('Suspended', false, colorScheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: selected ? colorScheme.primary.withOpacity(0.06) : colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? colorScheme.primary.withOpacity(0.2) : colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? colorScheme.primary : colorScheme.onBackground.withOpacity(0.7),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildUsersList(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _UserCard(
          name: 'Sarah Johnson',
          email: 'sarah.j@example.com',
          role: 'Manager',
          status: 'Active',
          joinDate: 'Jan 15, 2024',
          lastActive: '2 hours ago',
          eventsCount: '12 events',
        ),
        const SizedBox(height: 12),
        _UserCard(
          name: 'Mike Chen',
          email: 'mike.chen@example.com',
          role: 'Attendee',
          status: 'Active',
          joinDate: 'Feb 20, 2024',
          lastActive: '1 day ago',
          eventsCount: '8 events',
        ),
        const SizedBox(height: 12),
        _UserCard(
          name: 'Emily Davis',
          email: 'emily.davis@example.com',
          role: 'Admin',
          status: 'Active',
          joinDate: 'Nov 10, 2023',
          lastActive: '30 minutes ago',
          eventsCount: '45 events',
        ),
        const SizedBox(height: 12),
        _UserCard(
          name: 'Alex Rodriguez',
          email: 'alex.r@example.com',
          role: 'Manager',
          status: 'Inactive',
          joinDate: 'Mar 5, 2024',
          lastActive: '2 weeks ago',
          eventsCount: '3 events',
        ),
        const SizedBox(height: 12),
        _UserCard(
          name: 'Lisa Wang',
          email: 'lisa.wang@example.com',
          role: 'Attendee',
          status: 'Suspended',
          joinDate: 'Jan 30, 2024',
          lastActive: '1 month ago',
          eventsCount: '2 events',
        ),
      ],
    );
  }
}

class _UserCard extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final String status;
  final String joinDate;
  final String lastActive;
  final String eventsCount;

  const _UserCard({
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.joinDate,
    required this.lastActive,
    required this.eventsCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine colors based on role and status
    final roleColor = colorScheme.primary; // All roles use primary color
    final statusColor = _getStatusColor(colorScheme);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // User Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: roleColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _getRoleIcon(role),
                color: roleColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onBackground,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(
                      color: colorScheme.onBackground.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: roleColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          role,
                          style: TextStyle(
                            color: roleColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: TextStyle(
                          color: colorScheme.onBackground.withOpacity(0.2),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Joined $joinDate',
                        style: TextStyle(
                          color: colorScheme.onBackground.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$eventsCount • Last active $lastActive',
                    style: TextStyle(
                      color: colorScheme.onBackground.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // Actions Menu
            IconButton(
              icon: Icon(
                Icons.more_vert_rounded, 
                color: colorScheme.onBackground.withOpacity(0.4)
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Icons.security_rounded;
      case 'manager':
        return Icons.manage_accounts_rounded;
      case 'attendee':
        return Icons.person_rounded;
      default:
        return Icons.people_rounded;
    }
  }

  Color _getStatusColor(ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'active':
        return colorScheme.primary; // Use primary color for active
      case 'suspended':
        return colorScheme.error; // Use error color for suspended
      case 'inactive':
        return colorScheme.primary.withOpacity(0.7); // Use primary with opacity for inactive
      default:
        return colorScheme.primary; // Default to primary color
    }
  }
}