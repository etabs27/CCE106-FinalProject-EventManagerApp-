import 'package:flutter/material.dart';
import 'package:event_manager_application_finalproject/theme.dart';
import 'package:event_manager_application_finalproject/views/user/user_homepage.dart';
import 'package:event_manager_application_finalproject/views/user/user_explorepage.dart';
import 'package:event_manager_application_finalproject/views/user/user_favoritepage.dart';
import 'package:event_manager_application_finalproject/views/user/user_profilepage.dart';

class TicketsPage extends StatefulWidget {
  const TicketsPage({super.key});

  @override
  State<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 3;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    'My Tickets',
    style: textTheme.titleLarge?.copyWith(
      color: colorScheme.onBackground,
      fontWeight: FontWeight.w700,
      fontSize: 24,
    ),
  ),
  elevation: 0,
  bottom: TabBar(
    controller: _tabController,
    labelColor: colorScheme.primary,
    unselectedLabelColor: colorScheme.onBackground.withOpacity(0.65),
    indicatorColor: colorScheme.primary,
    labelStyle: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 14,
    ),
    unselectedLabelStyle: TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 14,
    ),
    tabs: [
      Tab(text: 'Upcoming'),
      Tab(text: 'Past'),
      Tab(text: 'Cancelled'),
    ],
  ),
),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Upcoming Tab
          _buildUpcomingTab(),
          
          // Past Tab
          _buildPastTab(),
          
          // Cancelled Tab
          _buildCancelledTab(),
        ],
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withOpacity(0.08),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_rounded, 'Home', 0),
            _buildNavItem(Icons.explore_rounded, 'Explore', 1),
            _buildNavItem(Icons.favorite_border_rounded, 'Like', 2),
            _buildNavItem(Icons.confirmation_number_rounded, 'Tickets', 3),
            _buildNavItem(Icons.person_outline_rounded, 'Profile', 4),
          ],
        ),
      ),
    );
  }

  void _navigateToIndex(int index) {
    if (_currentIndex == index) return;
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UserHomePageWidget()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ExplorePage()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const FavoritesPage()));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TicketsPage()));
        break;
      case 4:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
        break;
    }
  }

  Widget _buildUpcomingTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming Events', 
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onBackground,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),

          // Dayful Quetta Ultra Miami 2025
          _buildTicketCard(
            'Dayful Quetta Ultra Miami 2025',
            'Music Festival',
            'Nov 25, 2025, 02:00 PM',
            '3 tickets',
            '12 days left',
            Icons.music_note_rounded,
            true,
          ),
          SizedBox(height: 16),

          // Ed Sheeran Live Concert
          _buildTicketCard(
            'Ed Sheeran Live Concert',
            'Station Square',
            'Feb 10, 2025, 08:00 PM',
            '3 tickets',
            '12 days left',
            Icons.music_note_rounded,
            true,
          ),
          SizedBox(height: 16),

          // Additional upcoming events
          _buildTicketCard(
            'Tech Conference 2024',
            'Innovation Hub',
            'Dec 15, 2024, 09:00 AM',
            '2 tickets',
            '3 days left',
            Icons.computer_rounded,
            true,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _navigateToIndex(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? colorScheme.primary : colorScheme.onBackground.withOpacity(0.65),
            size: 24,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? colorScheme.primary : colorScheme.onBackground.withOpacity(0.65),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPastTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Past Events', 
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onBackground,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),

          _buildTicketCard(
            'Summer Jazz Festival',
            'Central Park',
            'Aug 20, 2024, 06:00 PM',
            '2 tickets',
            'Event completed',
            Icons.music_note_rounded,
            false,
          ),
          SizedBox(height: 16),

          _buildTicketCard(
            'Food & Wine Expo',
            'Convention Center',
            'Jul 15, 2024, 11:00 AM',
            '4 tickets',
            'Event completed',
            Icons.restaurant_rounded,
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildCancelledTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cancelled Events', 
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onBackground,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),

          _buildTicketCard(
            'Rock Concert Night',
            'Stadium Arena',
            'Sep 10, 2024, 07:00 PM',
            '2 tickets',
            'Cancelled',
            Icons.music_note_rounded,
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(String eventName, String venue, String dateTime, String ticketCount, String status, IconData icon, bool isUpcoming) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
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
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and event name
            Row(
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
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eventName, 
                        style: textTheme.bodyLarge?.copyWith(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold, 
                          color: colorScheme.onBackground
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        venue, 
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onBackground.withOpacity(0.65), 
                          fontSize: 14
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Date and Time
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded, 
                  color: colorScheme.onBackground.withOpacity(0.65), 
                  size: 16
                ),
                SizedBox(width: 8),
                Text(
                  dateTime, 
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onBackground.withOpacity(0.65), 
                    fontSize: 14
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),

            // Ticket count and status
            Row(
              children: [
                Icon(
                  Icons.confirmation_number_rounded, 
                  color: colorScheme.onBackground.withOpacity(0.65), 
                  size: 16
                ),
                SizedBox(width: 8),
                Text(
                  ticketCount, 
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onBackground.withOpacity(0.65), 
                    fontSize: 14
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isUpcoming ? colorScheme.primary.withOpacity(0.08) : colorScheme.onSurface.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status, 
                    style: textTheme.bodySmall?.copyWith(
                      color: isUpcoming ? colorScheme.primary : colorScheme.onBackground.withOpacity(0.7), 
                      fontSize: 12, 
                      fontWeight: FontWeight.w600
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // QR Code Button
            if (isUpcoming)
              Container(
                width: double.infinity,
                height: 44,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.qr_code_2_rounded, 
                      color: colorScheme.onPrimary, 
                      size: 20
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Show QR Code', 
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimary, 
                        fontSize: 14, 
                        fontWeight: FontWeight.w600
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 44,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'View Details', 
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onBackground.withOpacity(0.65), 
                      fontSize: 14, 
                      fontWeight: FontWeight.w600
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}