import 'package:flutter/material.dart';
import 'package:event_manager_application_finalproject/theme.dart';
import 'package:event_manager_application_finalproject/views/user/user_homepage.dart';
import 'package:event_manager_application_finalproject/views/user/user_favoritepage.dart';
import 'package:event_manager_application_finalproject/views/user/user_ticketpage.dart';
import 'package:event_manager_application_finalproject/views/user/user_profilepage.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 1;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
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
    'Explore',
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
      Tab(text: 'For You'),
      Tab(text: 'Trending'),
      Tab(text: 'Events'),
    ],
  ),
),
      body: TabBarView(
        controller: _tabController,
        children: [
          // For You Tab
          _buildForYouTab(),
          
          // Trending Tab
          _buildTrendingTab(),
          
          // Events Tab
          _buildEventsTab(),
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

  Widget _buildForYouTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Container(
            width: double.infinity,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for events, venues, or categories...',
                hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onBackground.withOpacity(0.65)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorScheme.primary),
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colorScheme.surface,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                prefixIcon: Icon(Icons.search_rounded, color: colorScheme.onBackground.withOpacity(0.65), size: 20),
              ),
              style: textTheme.bodyLarge?.copyWith(color: colorScheme.onBackground),
            ),
          ),
          SizedBox(height: 32),

          // Popular Searches Section
          Text(
            'Popular Event Searches', 
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onBackground,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          _buildPopularSearchItem('Concerts & Live Music', Icons.music_note_rounded),
          _buildPopularSearchItem('Sports Events', Icons.sports_basketball_rounded),
          _buildPopularSearchItem('Conferences', Icons.business_center_rounded),
          _buildPopularSearchItem('Festivals', Icons.festival_rounded),
          _buildPopularSearchItem('Workshops', Icons.school_rounded),
          _buildPopularSearchItem('Art Exhibitions', Icons.palette_rounded),
          _buildPopularSearchItem('Food Festivals', Icons.restaurant_rounded),
          _buildPopularSearchItem('Networking Events', Icons.people_rounded),
        ],
      ),
    );
  }

  Widget _buildTrendingTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trending Events', 
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onBackground,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          _buildTrendingItem('Summer Music Festival 2024', '45K+ tickets sold'),
          _buildTrendingItem('Tech Startup Conference', '32K+ attending'),
          _buildTrendingItem('Food & Wine Expo', '28K+ interested'),
          _buildTrendingItem('Marathon Registration 2024', '15K+ registered'),
          _buildTrendingItem('Art Gallery Opening', '8K+ RSVPs'),
          _buildTrendingItem('Comedy Night Special', '12K+ tickets sold'),
          _buildTrendingItem('Yoga & Wellness Retreat', '6K+ registered'),
          _buildTrendingItem('Business Networking Mixer', '5K+ attending'),
        ],
      ),
    );
  }

  Widget _buildEventsTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming Events Near You', 
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onBackground,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          _buildEventCard(
            'Jazz Night Live Concert', 
            'Dec 20 • 8:00 PM', 
            'Blue Note Club • \$45',
            Icons.music_note_rounded
          ),
          _buildEventCard(
            'Food & Wine Festival', 
            'Dec 22 • 12:00 PM', 
            'Central Park • \$25',
            Icons.restaurant_rounded
          ),
          _buildEventCard(
            'Tech Innovation Summit', 
            'Dec 25 • 9:00 AM', 
            'Convention Center • \$120',
            Icons.computer_rounded
          ),
          _buildEventCard(
            'Yoga & Wellness Retreat', 
            'Dec 28 • 7:00 AM', 
            'Sunrise Park • \$60',
            Icons.self_improvement_rounded
          ),
          _buildEventCard(
            'Indie Film Screening', 
            'Jan 5 • 6:30 PM', 
            'Art House Cinema • \$18',
            Icons.movie_rounded
          ),
          _buildEventCard(
            'Business Networking Mixer', 
            'Jan 8 • 6:00 PM', 
            'Downtown Lounge • \$30',
            Icons.people_rounded
          ),
          _buildEventCard(
            'Charity Gala Dinner', 
            'Jan 12 • 7:30 PM', 
            'Grand Hotel • \$150',
            Icons.dinner_dining_rounded
          ),
        ],
      ),
    );
  }

  Widget _buildPopularSearchItem(String title, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: colorScheme.onBackground,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: colorScheme.outline.withOpacity(0.5),
          size: 16,
        ),
      ),
    );
  }

  Widget _buildTrendingItem(String title, String subtitle) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.trending_up_rounded,
            color: colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          title, 
          style: textTheme.bodyMedium?.copyWith(
            fontSize: 16, 
            fontWeight: FontWeight.w500, 
            color: colorScheme.onBackground
          ),
        ),
        subtitle: Text(
          subtitle, 
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onBackground.withOpacity(0.65), 
            fontSize: 12
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(String title, String date, String venue, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: colorScheme.primary,
            size: 24,
          ),
        ),
        title: Text(
          title, 
          style: textTheme.bodyMedium?.copyWith(
            fontSize: 16, 
            fontWeight: FontWeight.w600, 
            color: colorScheme.onBackground
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              date, 
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onBackground.withOpacity(0.65), 
                fontSize: 12
              ),
            ),
            Text(
              venue, 
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onBackground.withOpacity(0.65), 
                fontSize: 12
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Book', 
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onPrimary, 
              fontSize: 12, 
              fontWeight: FontWeight.w600
            ),
          ),
        ),
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
}