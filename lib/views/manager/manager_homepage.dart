import 'package:flutter/material.dart';
import 'package:event_manager_application_finalproject/theme.dart';
import 'package:event_manager_application_finalproject/views/manager/manager_notification.dart';
import 'package:event_manager_application_finalproject/views/manager/manager_addevent.dart';
import 'package:event_manager_application_finalproject/views/manager/manager_scanticket.dart';
import 'package:event_manager_application_finalproject/views/manager/manager_manualcheckin.dart';
import 'package:event_manager_application_finalproject/views/manager/manager_attendancereport.dart';
import 'package:event_manager_application_finalproject/views/manager/manager_settings.dart'; // Add this
import 'package:event_manager_application_finalproject/auth/login.dart'; // Import login page

class ManagerDashboard extends StatefulWidget {
  const ManagerDashboard({super.key});

  @override
  State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> {
  String _currentFilter = 'Active'; // Default filter

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
                // Navigate to Notification Page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManagerNotificationPage()),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Add Event Page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ManagerAddEventPage()),
          );
        },
        backgroundColor: colorScheme.primary,
        child: Icon(Icons.add, color: colorScheme.onPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Cards - Moved up since welcome section is removed
              _buildStatsSection(),
              
              // My Events Section with Filter Dropdown
              _buildMyEventsSection(),
              
              // Event Cards based on filter
              if (_currentFilter == 'Active' || _currentFilter == 'All') 
                _buildActiveEventCard(),
              
              if (_currentFilter == 'Pending' || _currentFilter == 'All') 
                _buildPendingEventCard(),
              
              if (_currentFilter == 'Completed') 
                _buildCompletedEventCard(),
              
              const SizedBox(height: 80), // Extra space for FAB
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
          // Navigate to Settings Page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ManagerSettingsPage()),
          );
        } else if (value == 'signout') {
          // Handle sign out
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
              // Close the dialog first
              Navigator.pop(dialogContext);
              
              // Navigate to login page and remove all routes
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

  Widget _buildStatsSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(20), // Changed from symmetric to all for top spacing
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard('Active Events', '8'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard('Total Attendees', '2,450'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      height: 100,
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                title == 'Active Events' ? Icons.event_available : Icons.people_alt,
                color: colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value, 
                    style: textTheme.titleLarge?.copyWith(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold, 
                      color: colorScheme.onBackground
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title, 
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onBackground.withOpacity(0.65), 
                      fontSize: 12, 
                      fontWeight: FontWeight.w500
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyEventsSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8), // Removed top padding since welcome section is gone
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'My Events', 
            style: textTheme.titleLarge?.copyWith(
              fontSize: 18, 
              fontWeight: FontWeight.bold, 
              color: colorScheme.onBackground
            ),
          ),
          // Filter Dropdown
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
                  width: 80, // Width to accommodate text
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
            value: 'All',
            child: Text(
              'All (2)',
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
              'Active (1)',
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          DropdownMenuItem<String>(
            value: 'Pending',
            child: Text(
              'Pending (1)',
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          DropdownMenuItem<String>(
            value: 'Completed',
            child: Text(
              'Completed (0)',
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

  Widget _buildActiveEventCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withOpacity(0.05), 
              blurRadius: 10, 
              offset: const Offset(0, 4)
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.08), 
                      borderRadius: BorderRadius.circular(20)
                    ),
                    child: Text(
                      'Active',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    'Dec 20, 2024 • 6:00 PM', 
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onBackground.withOpacity(0.65), 
                      fontSize: 12
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Summer Music Festival', 
                style: textTheme.titleLarge?.copyWith(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold, 
                  color: colorScheme.onBackground
                ),
              ),
              const SizedBox(height: 20),
              // Stats Table
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface, 
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn('Registered', '1,234'),
                          _buildVerticalDivider(),
                          _buildStatColumn('Checked In', '856'),
                          _buildVerticalDivider(),
                          _buildStatColumn('Capacity', '2,000'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: 856 / 2000, 
                        backgroundColor: colorScheme.outline.withOpacity(0.3), 
                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary), 
                        borderRadius: BorderRadius.circular(10)
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${(856 / 2000 * 100).toStringAsFixed(1)}% capacity',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onBackground.withOpacity(0.65), 
                            fontSize: 10
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton('Scan', Icons.qr_code_scanner),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton('Report', Icons.analytics),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPendingEventCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.08), 
                      borderRadius: BorderRadius.circular(20)
                    ),
                    child: Text(
                      'Pending', 
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary, 
                        fontSize: 12, 
                        fontWeight: FontWeight.w600
                      ),
                    ),
                  ),
                  Text(
                    'Dec 25, 2024 • 9:00 AM', 
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onBackground.withOpacity(0.65), 
                      fontSize: 12
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Tech Conference 2024', 
                style: textTheme.titleLarge?.copyWith(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold, 
                  color: colorScheme.onBackground
                ),
              ),
              const SizedBox(height: 20),
              // Stats Table
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn('Registered', '850'),
                          _buildVerticalDivider(),
                          _buildStatColumn('Checked In', '0'),
                          _buildVerticalDivider(),
                          _buildStatColumn('Capacity', '1,000'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: 850 / 1000, 
                        backgroundColor: colorScheme.outline.withOpacity(0.3), 
                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary), 
                        borderRadius: BorderRadius.circular(10)
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${(850 / 1000 * 100).toStringAsFixed(1)}% registered', 
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onBackground.withOpacity(0.65), 
                            fontSize: 10
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  // Navigate to Attendance Report Page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ManagerAttendanceReportPage(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'View Details', 
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimary, 
                        fontSize: 14, 
                        fontWeight: FontWeight.w600
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedEventCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withOpacity(0.08), 
                      borderRadius: BorderRadius.circular(20)
                    ),
                    child: Text(
                      'Completed', 
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onBackground.withOpacity(0.7), 
                        fontSize: 12, 
                        fontWeight: FontWeight.w600
                      ),
                    ),
                  ),
                  Text(
                    'Nov 15, 2024 • 8:00 PM', 
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onBackground.withOpacity(0.65), 
                      fontSize: 12
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Jazz Night Live', 
                style: textTheme.titleLarge?.copyWith(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold, 
                  color: colorScheme.onBackground
                ),
              ),
              const SizedBox(height: 20),
              // Stats Table
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn('Attended', '750'),
                          _buildVerticalDivider(),
                          _buildStatColumn('Revenue', '\$12,500'),
                          _buildVerticalDivider(),
                          _buildStatColumn('Rating', '4.8/5'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  // Navigate to Attendance Report Page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ManagerAttendanceReportPage(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'View Report', 
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onBackground.withOpacity(0.7), 
                        fontSize: 14, 
                        fontWeight: FontWeight.w600
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      children: [
        Text(
          value, 
          style: textTheme.bodyLarge?.copyWith(
            fontSize: 16, 
            fontWeight: FontWeight.bold, 
            color: colorScheme.onBackground
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label, 
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onBackground.withOpacity(0.65), 
            fontSize: 12
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 1, 
      height: 30, 
      color: colorScheme.outline.withOpacity(0.3)
    );
  }

  Widget _buildActionButton(String text, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        // Action button functionality based on text
        if (text == 'Scan') {
          // Navigate to Scan Ticket Page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ManagerScanTicketPage()),
          );
        } else if (text == 'Report') {
          // Navigate to Attendance Report Page for the Summer Music Festival
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ManagerAttendanceReportPage(),
            ),
          );
        }
        print('$text pressed');
      },
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: colorScheme.primary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}