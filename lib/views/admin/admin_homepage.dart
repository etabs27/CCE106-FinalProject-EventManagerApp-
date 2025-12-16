import 'package:flutter/material.dart';
import 'package:event_manager_application_finalproject/views/admin/admin_eventapproval.dart';
import 'package:event_manager_application_finalproject/theme.dart';
import 'package:event_manager_application_finalproject/views/admin/admin_managers.dart';
import 'package:event_manager_application_finalproject/views/admin/admin_allevents.dart';
import 'package:event_manager_application_finalproject/views/admin/admin_usermanagement.dart';
import 'package:event_manager_application_finalproject/views/admin/admin_notificationpage.dart';
import 'package:event_manager_application_finalproject/views/admin/admin_settings.dart';
import 'package:event_manager_application_finalproject/auth/login.dart';
import 'package:event_manager_application_finalproject/event_service.dart'; // Import EventService
import 'package:event_manager_application_finalproject/user_service.dart'; // Import UserService
import 'package:intl/intl.dart';

import '../../models/event.dart';
import '../../user_service.dart'; // For date formatting

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        automaticallyImplyLeading: false,
        title: Text(
          'Dashboard',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onBackground,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        elevation: 0,
        actions: [
          // Notification Icon
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminNotificationPage()),
                );
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.notifications_none,
                  color: colorScheme.onBackground.withOpacity(0.7),
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Profile with dropdown
          _buildProfileDropdown(),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Grid with real data
              _buildStatsGrid(),
              
              // Quick Actions
              _buildQuickActions(),
              
              // Recent Activity with real data
              _buildRecentActivity(),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileDropdown() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'settings') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminSettingsPage()),
          );
        } else if (value == 'signout') {
          _showSignOutConfirmation();
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'settings',
          child: Row(
            children: [
              Icon(
                Icons.settings_rounded, 
                size: 20, 
                color: colorScheme.onBackground.withOpacity(0.6)
              ),
              const SizedBox(width: 12),
              Text(
                'Settings',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onBackground,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'signout',
          child: Row(
            children: [
              Icon(
                Icons.logout_rounded, 
                size: 20, 
                color: colorScheme.onBackground.withOpacity(0.6)
              ),
              const SizedBox(width: 12),
              Text(
                'Sign Out',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onBackground,
                ),
              ),
            ],
          ),
        ),
      ],
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.primary.withOpacity(0.1),
        ),
        child: Icon(
          Icons.person_rounded,
          color: colorScheme.primary,
          size: 20,
        ),
      ),
    );
  }

  void _showSignOutConfirmation() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Sign Out',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onBackground,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onBackground.withOpacity(0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: Text(
              'Sign Out',
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: colorScheme.surface,
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GridView(
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Total Events
          StreamBuilder<int>(
            stream: EventService.getTotalEventsCount(),
            builder: (context, snapshot) {
              final totalEvents = snapshot.data ?? 0;
              return _buildStatCard(
                'Total Events',
                totalEvents.toString(),
                Icons.event_available_rounded,
              );
            },
          ),
          
          // Active Managers
          StreamBuilder<int>(
            stream: UserService.getManagersCount(),
            builder: (context, snapshot) {
              final managers = snapshot.data ?? 0;
              return _buildStatCard(
                'Active Managers',
                managers.toString(),
                Icons.people_alt_rounded,
              );
            },
          ),
          
          // Total Users
          StreamBuilder<int>(
            stream: UserService.getTotalUsersCount(),
            builder: (context, snapshot) {
              final totalUsers = snapshot.data ?? 0;
              return _buildStatCard(
                'Total Users',
                totalUsers.toString(),
                Icons.person_outline_rounded,
              );
            },
          ),
          
          // Pending Approvals
          StreamBuilder<int>(
            stream: EventService.getPendingEventsCount(),
            builder: (context, snapshot) {
              final pending = snapshot.data ?? 0;
              return _buildStatCard(
                'Pending Approvals',
                pending.toString(),
                Icons.pending_actions_rounded,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: colorScheme.primary,
                size: 20,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onBackground.withOpacity(0.65),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onBackground,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: textTheme.titleLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Event Approvals with real count
              StreamBuilder<int>(
                stream: EventService.getPendingEventsCount(),
                builder: (context, snapshot) {
                  final pendingCount = snapshot.data ?? 0;
                  return Expanded(
                    child: _buildQuickActionCard(
                      'Event Approvals',
                      '$pendingCount pending',
                      Icons.pending_actions_rounded,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EventApprovalsDesign())),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              // Managers with real count
              StreamBuilder<int>(
                stream: UserService.getManagersCount(),
                builder: (context, snapshot) {
                  final managersCount = snapshot.data ?? 0;
                  return Expanded(
                    child: _buildQuickActionCard(
                      'Managers',
                      '$managersCount active',
                      Icons.people_rounded,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManagersDesign())),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // All Events with real count
              StreamBuilder<int>(
                stream: EventService.getTotalEventsCount(),
                builder: (context, snapshot) {
                  final totalEvents = snapshot.data ?? 0;
                  return Expanded(
                    child: _buildQuickActionCard(
                      'All Events',
                      '$totalEvents events',
                      Icons.event_rounded,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AllEventsDesign())),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              // User Management with real count
              StreamBuilder<int>(
                stream: UserService.getTotalUsersCount(),
                builder: (context, snapshot) {
                  final totalUsers = snapshot.data ?? 0;
                  return Expanded(
                    child: _buildQuickActionCard(
                      'User Management',
                      '$totalUsers users',
                      Icons.person_rounded,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserManagementDesign())),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(String title, String subtitle, IconData icon, {VoidCallback? onTap}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(height: 16),
              // Title
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onBackground,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              // Subtitle
              Text(
                subtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onBackground.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Activity',
                    style: textTheme.titleLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onBackground,
                    ),
                  ),
                  Text(
                    'View all',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Real recent activity from events
              StreamBuilder<List<Event>>(
                stream: EventService.getRecentEvents(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No recent activity',
                        style: TextStyle(color: colorScheme.onBackground.withOpacity(0.6)),
                      ),
                    );
                  }
                  
                  final recentEvents = snapshot.data!;
                  return Column(
                    children: [
                      for (var i = 0; i < recentEvents.length; i++)
                        Column(
                          children: [
                            _buildActivityItem(
                              _getActivityText(recentEvents[i]),
                              _formatTimeAgo(recentEvents[i].submittedAt),
                              _getActivityIcon(recentEvents[i]),
                            ),
                            if (i < recentEvents.length - 1) _buildDivider(),
                          ],
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Divider(
      height: 1,
      color: colorScheme.onSurface.withOpacity(0.08),
    );
  }

  // Helper methods for activity items
  String _getActivityText(Event event) {
    switch (event.status) {
      case EventStatus.approved:
        return 'Event "${event.title}" approved';
      case EventStatus.rejected:
        return 'Event "${event.title}" rejected';
      case EventStatus.pending:
        return 'New event created: "${event.title}"';
      default:
        return 'Event "${event.title}" updated';
    }
  }

  IconData _getActivityIcon(Event event) {
    switch (event.status) {
      case EventStatus.approved:
        return Icons.check_circle_rounded;
      case EventStatus.rejected:
        return Icons.cancel_rounded;
      case EventStatus.pending:
        return Icons.event_available_rounded;
      default:
        return Icons.update_rounded;
    }
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}