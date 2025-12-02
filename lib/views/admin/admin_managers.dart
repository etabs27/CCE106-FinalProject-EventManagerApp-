import 'package:flutter/material.dart';
import 'package:event_manager_application_finalproject/theme.dart';

class ManagersDesign extends StatelessWidget {
  const ManagersDesign({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Managers',
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
              Icons.add_circle_rounded, 
              color: colorScheme.primary
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(context),
          
          // Filter Tabs
          _buildFilterTabs(context),
          
          // Managers List
          Expanded(
            child: _buildManagersList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      color: colorScheme.surface,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search managers...',
            prefixIcon: Icon(
              Icons.search_rounded, 
              color: colorScheme.onBackground.withOpacity(0.6)
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: colorScheme.surface,
      child: Row(
        children: [
          _buildFilterTab(context, 'All (24)', true),
          const SizedBox(width: 12),
          _buildFilterTab(context, 'Active (22)', false),
          const SizedBox(width: 12),
          _buildFilterTab(context, 'Restricted (2)', false),
        ],
      ),
    );
  }

  Widget _buildFilterTab(BuildContext context, String label, bool active) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: active ? colorScheme.primary.withOpacity(0.06) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? colorScheme.primary.withOpacity(0.2) : colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? colorScheme.primary : colorScheme.onBackground.withOpacity(0.7),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildManagersList(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _ManagerCard(
          name: 'Sarah Johnson',
          email: 'sarahj@eventhub.com',
          status: 'Active',
          eventsCount: '15 events',
          isRestricted: false,
        ),
        const SizedBox(height: 12),
        _ManagerCard(
          name: 'Mike Chen',
          email: 'mike.c@eventhub.com',
          status: 'Active',
          eventsCount: '8 events',
          isRestricted: false,
        ),
        const SizedBox(height: 12),
        _ManagerCard(
          name: 'Lisa Rodriguez',
          email: 'lisa.r@eventhub.com',
          status: 'Restricted',
          eventsCount: '3 events',
          isRestricted: true,
        ),
      ],
    );
  }
}

class _ManagerCard extends StatelessWidget {
  final String name;
  final String email;
  final String status;
  final String eventsCount;
  final bool isRestricted;

  const _ManagerCard({
    required this.name,
    required this.email,
    required this.status,
    required this.eventsCount,
    required this.isRestricted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Manager Info Row
            Row(
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getStatusColor(colorScheme).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: _getStatusColor(colorScheme),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Manager Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onBackground,
                        ),
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
                              color: _getStatusColor(colorScheme).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: _getStatusColor(colorScheme),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            eventsCount,
                            style: TextStyle(
                              color: colorScheme.onBackground.withOpacity(0.6),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Action Buttons (only for active managers)
            if (!isRestricted) ...[
              const SizedBox(height: 16),
              Container(
                height: 1,
                color: colorScheme.outline.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildActionButton('View', Icons.visibility_rounded, colorScheme),
                  const SizedBox(width: 12),
                  _buildActionButton('Edit', Icons.edit_rounded, colorScheme),
                  const SizedBox(width: 12),
                  _buildActionButton('Suspend', Icons.pause_circle_rounded, colorScheme),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, ColorScheme colorScheme) {
    return Expanded(
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: colorScheme.primary,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ColorScheme colorScheme) {
    if (isRestricted) {
      return colorScheme.error; // Use theme error color for restricted status
    }
    return colorScheme.primary; // Use theme primary color for active status
  }
}