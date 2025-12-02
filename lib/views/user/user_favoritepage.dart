import 'package:flutter/material.dart';
import 'package:event_manager_application_finalproject/theme.dart';
import 'package:event_manager_application_finalproject/views/user/user_homepage.dart';
import 'package:event_manager_application_finalproject/views/user/user_explorepage.dart';
import 'package:event_manager_application_finalproject/views/user/user_ticketpage.dart';
import 'package:event_manager_application_finalproject/views/user/user_profilepage.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 2;
  String _currentFilter = 'All';
  final List<String> _filters = ['All', 'Active', 'Inactive'];

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
          'Favorites',
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
            Tab(text: 'Places'),
            Tab(text: 'Events'),
            Tab(text: 'People'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Places Tab
          _buildPlacesTab(),
          
          // Events Tab
          _buildEventsTab(),
          
          // People Tab
          _buildPeopleTab(),
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

  Widget _buildPlacesTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.map((filter) {
                return Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      filter,
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                    selected: _currentFilter == filter,
                    onSelected: (selected) {
                      setState(() {
                        _currentFilter = filter;
                      });
                    },
                    selectedColor: colorScheme.primary,
                    checkmarkColor: colorScheme.onPrimary,
                    backgroundColor: colorScheme.surface,
                    labelStyle: TextStyle(
                      color: _currentFilter == filter ? colorScheme.onPrimary : colorScheme.onBackground.withOpacity(0.7),
                      fontWeight: _currentFilter == filter ? FontWeight.w600 : FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: _currentFilter == filter ? colorScheme.primary : colorScheme.outline.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 16),

          // Sort & Filter Button
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.filter_list_rounded,
                  color: colorScheme.onBackground.withOpacity(0.65),
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Sort & Filter',
                  style: TextStyle(
                    color: colorScheme.onBackground.withOpacity(0.65),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Favorites List
          _buildFavoriteItem(
            'Bella Vista Restaurant',
            'Italian Cuisine',
            '4.8',
            '2 days ago',
            true,
            Icons.restaurant_rounded,
          ),
          _buildDivider(),
          _buildFavoriteItem(
            'Artisan Coffee House',
            'Coffee Shop',
            '4.6',
            '1 week ago',
            true,
            Icons.coffee_rounded,
          ),
          _buildDivider(),
          _buildFavoriteItem(
            'Chapter & Verse Books',
            'Bookstore',
            '4.4',
            '3 weeks ago',
            false,
            Icons.menu_book_rounded,
          ),
          _buildDivider(),
          _buildFavoriteItem(
            'FitzZone Gym',
            'Fitness Center',
            '4.7',
            '5 days ago',
            true,
            Icons.fitness_center_rounded,
          ),
          _buildDivider(),
          _buildFavoriteItem(
            'Luxe Hair Salon',
            'Beauty Salon',
            '4.5',
            '2 months ago',
            false,
            Icons.cut_rounded,
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
            'Favorite Events',
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onBackground,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          _buildEventFavoriteItem(
            'Summer Music Festival',
            'June 15-17 • Central Park',
            '4.9',
            Icons.music_note_rounded,
          ),
          _buildDivider(),
          _buildEventFavoriteItem(
            'Food & Wine Expo',
            'Dec 28 • Convention Center',
            '4.7',
            Icons.restaurant_menu_rounded,
          ),
          _buildDivider(),
          _buildEventFavoriteItem(
            'Tech Conference 2024',
            'Jan 10-12 • Tech Hub',
            '4.8',
            Icons.computer_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildPeopleTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Favorite People',
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onBackground,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          _buildPersonFavoriteItem(
            'Sarah Johnson',
            'Event Organizer',
            Icons.person_rounded,
          ),
          _buildDivider(),
          _buildPersonFavoriteItem(
            'Mike Chen',
            'Music Director',
            Icons.person_rounded,
          ),
          _buildDivider(),
          _buildPersonFavoriteItem(
            'Emily Davis',
            'Art Curator',
            Icons.person_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteItem(String title, String subtitle, String rating, String addedDate, bool isActive, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          // Icon
          Container(
            width: 50,
            height: 50,
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
          SizedBox(width: 12),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onBackground,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: colorScheme.onBackground.withOpacity(0.65),
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.star_rounded,
                      color: colorScheme.primary,
                      size: 14,
                    ),
                    SizedBox(width: 2),
                    Text(
                      rating,
                      style: TextStyle(
                        color: colorScheme.onBackground.withOpacity(0.65),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Added $addedDate',
                      style: TextStyle(
                        color: colorScheme.onBackground.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(width: 12),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isActive ? colorScheme.primary.withOpacity(0.1) : colorScheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isActive ? colorScheme.primary.withOpacity(0.2) : colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color: isActive ? colorScheme.primary : colorScheme.onBackground.withOpacity(0.5),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Favorite Icon
          Icon(
            Icons.favorite_rounded,
            color: colorScheme.primary,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildEventFavoriteItem(String title, String date, String rating, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
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
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onBackground,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    color: colorScheme.onBackground.withOpacity(0.65),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: colorScheme.primary,
                      size: 14,
                    ),
                    SizedBox(width: 2),
                    Text(
                      rating,
                      style: TextStyle(
                        color: colorScheme.onBackground.withOpacity(0.65),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.favorite_rounded,
            color: colorScheme.primary,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonFavoriteItem(String name, String role, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              icon,
              color: colorScheme.primary,
              size: 24,
            ),
          ),
          SizedBox(width: 12),
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
                SizedBox(height: 4),
                Text(
                  role,
                  style: TextStyle(
                    color: colorScheme.onBackground.withOpacity(0.65),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.favorite_rounded,
            color: colorScheme.primary,
            size: 20,
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
      color: colorScheme.outline.withOpacity(0.3),
    );
  }
}