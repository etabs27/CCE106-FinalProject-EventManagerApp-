import 'package:flutter/material.dart';
import 'package:event_manager_application_finalproject/theme.dart';

class ManagerDashboard extends StatefulWidget {
  const ManagerDashboard({super.key});

  @override
  State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add event functionality
          print('Add Event pressed');
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
              // Header
              _buildHeader(),
              
              // Stats Cards
              _buildStatsSection(),
              
              // My Events Section
              _buildMyEventsSection(),
              
              // Active Event Card
              _buildActiveEventCard(),
              
              // Pending Event Card
              _buildPendingEventCard(),
              
              SizedBox(height: 80), // Extra space for FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back', 
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onBackground.withOpacity(0.65), 
                  fontWeight: FontWeight.w500
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Sarah Manager', 
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onBackground,
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                ),
              ),
            ],
          ),
          // Notification Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20), 
              border: Border.all(color: colorScheme.outline.withOpacity(0.3))
            ),
            child: IconButton(
              onPressed: () {
                // Notification functionality
                print('Notification pressed');
              },
              icon: Icon(
                Icons.notifications_none,
                color: colorScheme.onBackground.withOpacity(0.7),
                size: 24,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard('Active Events', '8'),
          ),
          SizedBox(width: 12),
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
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
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
            SizedBox(width: 12),
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
                  SizedBox(height: 4),
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
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Events', 
            style: textTheme.titleLarge?.copyWith(
              fontSize: 18, 
              fontWeight: FontWeight.bold, 
              color: colorScheme.onBackground
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              _buildEventFilter('Active', true),
              SizedBox(width: 8),
              _buildEventFilter('Pending', false),
              SizedBox(width: 8),
              _buildEventFilter('Completed', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventFilter(String text, bool isActive) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        // Filter functionality
        print('$text filter pressed');
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? colorScheme.primary : colorScheme.outline.withOpacity(0.3)
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? colorScheme.onPrimary : colorScheme.onBackground.withOpacity(0.65),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveEventCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withOpacity(0.05), 
              blurRadius: 10, 
              offset: Offset(0, 4)
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              SizedBox(height: 12),
              Text(
                'Summer Music Festival', 
                style: textTheme.titleLarge?.copyWith(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold, 
                  color: colorScheme.onBackground
                ),
              ),
              SizedBox(height: 20),
              // Stats Table
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface, 
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
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
                      SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: 856 / 2000, 
                        backgroundColor: colorScheme.outline.withOpacity(0.3), 
                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary), 
                        borderRadius: BorderRadius.circular(10)
                      ),
                      SizedBox(height: 4),
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
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton('Scan', Icons.qr_code_scanner),
                  ),
                  SizedBox(width: 12),
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
      padding: EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              SizedBox(height: 12),
              Text(
                'Tech Conference 2024', 
                style: textTheme.titleLarge?.copyWith(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold, 
                  color: colorScheme.onBackground
                ),
              ),
              SizedBox(height: 20),
              // Stats Table
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
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
                      SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: 850 / 1000, 
                        backgroundColor: colorScheme.outline.withOpacity(0.3), 
                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary), 
                        borderRadius: BorderRadius.circular(10)
                      ),
                      SizedBox(height: 4),
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
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  // View details functionality
                  print('View Details pressed');
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
        SizedBox(height: 4),
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
        // Action button functionality
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
            SizedBox(width: 8),
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