import 'package:flutter/material.dart';
import 'package:event_manager_application_finalproject/theme.dart';

class UserManagementDesign extends StatefulWidget {
  const UserManagementDesign({super.key});

  @override
  State<UserManagementDesign> createState() => _UserManagementDesignState();
}

class _UserManagementDesignState extends State<UserManagementDesign> {
  String _currentFilter = 'All Users';
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.hasClients 
          ? _scrollController.offset 
          : 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Calculate background color based on scroll position
    final double scrollThreshold = 50.0;
    final double maxScroll = 150.0;
    
    double opacity = 0.0;
    if (_scrollOffset > scrollThreshold) {
      opacity = ((_scrollOffset - scrollThreshold) / maxScroll).clamp(0.0, 1.0);
    }

    final appBarColor = Color.lerp(
      Colors.white,
      theme.scaffoldBackgroundColor,
      opacity,
    )!;

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
        backgroundColor: appBarColor,
        elevation: 0,
        foregroundColor: colorScheme.onBackground,
      ),
      body: NotificationListener<ScrollUpdateNotification>(
        onNotification: (notification) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              setState(() {
                _scrollOffset = _scrollController.offset;
              });
            }
          });
          return false;
        },
        child: Column(
          children: [
            // Filter button row placed below AppBar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colorScheme.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.filter_list_rounded,
                          color: colorScheme.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 70,
                          child: _buildFilterDropdown(),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.arrow_drop_down_rounded,
                          color: colorScheme.primary,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
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
      ),
    );
  }

  Widget _buildFilterDropdown() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _currentFilter,
        icon: Container(width: 0, height: 0),
        iconSize: 0,
        elevation: 0,
        isDense: true,
        isExpanded: true,
        style: TextStyle(
          color: colorScheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        dropdownColor: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        items: [
          DropdownMenuItem<String>(
            value: 'All Users',
            child: Text(
              'All Users',
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          DropdownMenuItem<String>(
            value: 'Admins',
            child: Text(
              'Admins',
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          DropdownMenuItem<String>(
            value: 'Managers',
            child: Text(
              'Managers',
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          DropdownMenuItem<String>(
            value: 'Attendees',
            child: Text(
              'Attendees',
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          DropdownMenuItem<String>(
            value: 'Active',
            child: Text(
              'Active',
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          DropdownMenuItem<String>(
            value: 'Suspended',
            child: Text(
              'Suspended',
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _currentFilter = newValue;
            });
          }
        },
        underline: Container(),
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
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total Users', '8,542', Icons.people_alt_rounded, colorScheme),
          _buildStatItem('Active', '7,892', Icons.check_circle_rounded, colorScheme),
          _buildStatItem('Managers', '24', Icons.manage_accounts_rounded, colorScheme),
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
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 2),
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
      color: theme.scaffoldBackgroundColor,
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
                hintText: 'Search...',
                prefixIcon: Icon(
                  Icons.search_rounded, 
                  color: colorScheme.onBackground.withOpacity(0.6)
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList(BuildContext context) {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
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
        // Add more items for scrolling
        _UserCard(
          name: 'David Wilson',
          email: 'david.w@example.com',
          role: 'Attendee',
          status: 'Active',
          joinDate: 'Feb 10, 2024',
          lastActive: '3 days ago',
          eventsCount: '5 events',
        ),
        const SizedBox(height: 12),
        _UserCard(
          name: 'Maria Garcia',
          email: 'maria.g@example.com',
          role: 'Manager',
          status: 'Active',
          joinDate: 'Mar 15, 2024',
          lastActive: '5 hours ago',
          eventsCount: '10 events',
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
    final roleColor = colorScheme.primary;
    final statusColor = _getStatusColor(colorScheme);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // User Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: roleColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getRoleIcon(role),
                color: roleColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onBackground,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: TextStyle(
                      color: colorScheme.onBackground.withOpacity(0.6),
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: roleColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          role,
                          style: TextStyle(
                            color: roleColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '•',
                        style: TextStyle(
                          color: colorScheme.onBackground.withOpacity(0.2),
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Joined $joinDate',
                          style: TextStyle(
                            color: colorScheme.onBackground.withOpacity(0.5),
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$eventsCount • Last active $lastActive',
                    style: TextStyle(
                      color: colorScheme.onBackground.withOpacity(0.5),
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Actions Menu
            IconButton(
              iconSize: 20,
              padding: EdgeInsets.zero,
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
        return colorScheme.primary;
      case 'suspended':
        return colorScheme.error;
      case 'inactive':
        return colorScheme.primary.withOpacity(0.7);
      default:
        return colorScheme.primary;
    }
  }
}