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

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _activeEvents = 0;
  int _pendingEvents = 0;
  int _totalAttendees = 0;
  int _totalUsers = 0;
  int _managersCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      // Load all data
      final futures = await Future.wait([
        _getActiveEventsCount(),
        _getPendingEventsCount(),
        _getAllUsersCount(), // Updated to include all users
        _getManagersCount(),
        _calculateTotalAttendees(),
      ]);

      if (mounted) {
        setState(() {
          _activeEvents = futures[0];
          _pendingEvents = futures[1];
          _totalUsers = futures[2]; // This now includes all users
          _managersCount = futures[3];
          _totalAttendees = futures[4];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading dashboard data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<int> _getActiveEventsCount() async {
    try {
      // If getActiveEventsCount doesn't exist, try getTotalEventsCount
      final count = await EventService.getTotalEventsCount().first;
      return count;
    } catch (e) {
      print('Error getting active events count: $e');
      return 0;
    }
  }

  Future<int> _getPendingEventsCount() async {
    try {
      final count = await EventService.getPendingEventsCount().first;
      return count;
    } catch (e) {
      print('Error getting pending events count: $e');
      return 0;
    }
  }

  Future<int> _getAllUsersCount() async {
    try {
      // Get count of all users including admin, managers, and regular users
      final count = await UserService.getTotalUsersCount().first;
      return count;
    } catch (e) {
      print('Error getting all users count: $e');
      return 0;
    }
  }

  Future<int> _getManagersCount() async {
    try {
      final count = await UserService.getManagersCount().first;
      return count;
    } catch (e) {
      print('Error getting managers count: $e');
      return 0;
    }
  }

  Future<int> _calculateTotalAttendees() async {
    try {
      final events = await EventService.getAllEvents().first;
      int total = 0;
      for (var event in events) {
        total += event.registeredAttendees ?? 0;
      }
      return total;
    } catch (e) {
      print('Error calculating total attendees: $e');
      return 0;
    }
  }

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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Grid with real data
                    _buildStatsGrid(),
                    
                    // Quick Actions
                    _buildQuickActions(),
                    
                    // Recent Activity
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Active Events
          _buildStatCard(
            'Active Events',
            _activeEvents.toString(),
            Icons.event_available_rounded,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          
          // Pending Approvals
          _buildStatCard(
            'Pending',
            _pendingEvents.toString(),
            Icons.pending_actions_rounded,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          
          // Total Attendees
          _buildStatCard(
            'Total Attendees',
            _totalAttendees.toString(),
            Icons.people_alt_rounded,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          
          // Total Users (includes admin + managers + users)
          _buildStatCard(
            'Total Users',
            _totalUsers.toString(),
            Icons.person_outline_rounded,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title, 
    String value, 
    IconData icon, {
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
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
          children: [
            // Icon at the top (left aligned)
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
            const SizedBox(height: 12),
            // Number text in middle, right aligned
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                value,
                style: textTheme.titleLarge?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onBackground,
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Title at the bottom, left aligned
            Text(
              title,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onBackground.withOpacity(0.65),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
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
              // Event Approvals
              Expanded(
                child: _buildQuickActionCard(
                  title: 'Event Approvals',
                  value: '$_pendingEvents pending',
                  icon: Icons.pending_actions_rounded,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EventApprovalsDesign())),
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
              ),
              const SizedBox(width: 12),
              // Managers
              Expanded(
                child: _buildQuickActionCard(
                  title: 'Managers',
                  value: '$_managersCount active',
                  icon: Icons.people_rounded,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManagersDesign())),
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // All Events
              Expanded(
                child: _buildQuickActionCard(
                  title: 'All Events',
                  value: '$_activeEvents active',
                  icon: Icons.event_rounded,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AllEventsDesign())),
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
              ),
              const SizedBox(width: 12),
              // User Management (includes all users)
              Expanded(
                child: _buildQuickActionCard(
                  title: 'User Management',
                  value: '$_totalUsers users',
                  icon: Icons.person_rounded,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserManagementDesign())),
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required String value,
    required IconData icon,
    VoidCallback? onTap,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
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
              // Icon at the top (left aligned)
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
              const SizedBox(height: 12),
              // Value/Number in middle, right aligned
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  value,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onBackground,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Title at the bottom, left aligned
              Text(
                title,
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
              // Simple placeholder for recent activity
              Center(
                child: Text(
                  'No recent activity',
                  style: TextStyle(color: colorScheme.onBackground.withOpacity(0.6)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}