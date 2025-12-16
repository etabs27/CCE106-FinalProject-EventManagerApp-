import 'package:flutter/material.dart';
import 'package:event_manager_application_finalproject/theme.dart';
import 'package:event_manager_application_finalproject/event_service.dart';
import 'package:event_manager_application_finalproject/models/event.dart';
import 'package:event_manager_application_finalproject/views/user/user_explorepage.dart';
import 'package:event_manager_application_finalproject/views/user/user_favoritepage.dart';
import 'package:event_manager_application_finalproject/views/user/user_ticketpage.dart';
import 'package:event_manager_application_finalproject/views/user/user_profilepage.dart';
import 'package:event_manager_application_finalproject/views/user/user_homepagenotification.dart';
import 'package:event_manager_application_finalproject/views/user/user_eventdetailspage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'dart:async'; 
import 'package:firebase_auth/firebase_auth.dart';

class UserHomePageWidget extends StatefulWidget {
  const UserHomePageWidget({super.key});

  @override
  State<UserHomePageWidget> createState() => _UserHomePageWidgetState();
}

class _UserHomePageWidgetState extends State<UserHomePageWidget> {
  final PageController _pageController = PageController();
  final TextEditingController _searchController = TextEditingController();
  int _currentIndex = 0;
  int _currentBannerIndex = 0;
  int _notificationCount = 0;
  
  // For filter
  bool _showFilter = false;
  
  // Event categories with icons and selection state
  final List<Map<String, dynamic>> _eventCategories = [
    {'name': 'Music', 'icon': Icons.music_note_rounded, 'selected': false},
    {'name': 'Comedy', 'icon': Icons.theater_comedy_rounded, 'selected': false},
    {'name': 'Sports', 'icon': Icons.sports_basketball_rounded, 'selected': false},
    {'name': 'Art', 'icon': Icons.palette_rounded, 'selected': false},
    {'name': 'Theater', 'icon': Icons.theaters_rounded, 'selected': false},
    {'name': 'Food & Drink', 'icon': Icons.restaurant_rounded, 'selected': false},
    {'name': 'Technology', 'icon': Icons.computer_rounded, 'selected': false},
    {'name': 'Business', 'icon': Icons.business_center_rounded, 'selected': false},
    {'name': 'Education', 'icon': Icons.school_rounded, 'selected': false},
    {'name': 'Health & Wellness', 'icon': Icons.health_and_safety_rounded, 'selected': false},
  ];

  String _searchQuery = '';
  Timer? _searchDebounceTimer;
  bool _isDisposed = false;

  // Metrics data
  int _totalEvents = 0;
  int _eventsThisMonth = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentBannerIndex = _pageController.page?.round() ?? 0;
      });
    });

    // Add search listener
    _searchController.addListener(() {
      _onSearchChanged();
    });

    // Fetch metrics data
    _fetchMetricsData();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _pageController.dispose();
    _searchController.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!_isDisposed) {
        setState(() {
          _searchQuery = _searchController.text.trim().toLowerCase();
        });
      }
    });
  }

  Future<void> _fetchMetricsData() async {
    try {
      // Get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Get current month and year
      final now = DateTime.now();
      final currentMonth = now.month;
      final currentYear = now.year;

      // Fetch user's ticket history
      final ticketsSnapshot = await FirebaseFirestore.instance
          .collection('tickets')
          .where('userId', isEqualTo: user.uid)
          .get();

      // Count total attended events
      final totalAttended = ticketsSnapshot.docs.length;

      // Count events this month
      final eventsThisMonth = ticketsSnapshot.docs.where((doc) {
        final data = doc.data();
        final timestamp = data['purchasedAt'] as Timestamp?;
        if (timestamp != null) {
          final date = timestamp.toDate();
          return date.month == currentMonth && date.year == currentYear;
        }
        return false;
      }).length;

      if (!_isDisposed) {
        setState(() {
          _totalEvents = totalAttended;
          _eventsThisMonth = eventsThisMonth;
        });
      }
    } catch (e) {
      print('Error fetching metrics: $e');
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _searchDebounceTimer?.cancel();
    if (!_isDisposed) {
      setState(() {
        _searchQuery = '';
      });
    }
  }

  void _toggleCategory(int index) {
    setState(() {
      _eventCategories[index]['selected'] = !_eventCategories[index]['selected'];
    });
  }

  void _selectAllCategories() {
    setState(() {
      for (var category in _eventCategories) {
        category['selected'] = true;
      }
    });
  }

  void _clearAllCategories() {
    setState(() {
      for (var category in _eventCategories) {
        category['selected'] = false;
      }
    });
  }

  List<String> get _selectedCategories {
    return _eventCategories
      .where((category) => (category['selected'] as bool?) ?? false)
        .map((category) => category['name'] as String)
        .toList();
  }

  void _clearAllFilters() {
    _clearAllCategories();
    _clearSearch();
  }

  void _applyFilters() {
    setState(() {
      _showFilter = false;
    });
  }

  // Filter events based on search, categories, and date
  List<Event> _filterEvents(List<Event> events) {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);  // Get today's date at midnight
    List<Event> filteredEvents = events.where((event) {
      // Only show events on or after today
      if (event.date.isBefore(today)) {
        return false;
      }

      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final title = event.title.toLowerCase();
        final description = event.description?.toLowerCase() ?? '';
        final category = event.category.toLowerCase();
        final venue = event.venue?.toLowerCase() ?? '';
        final managerEmail = event.managerEmail.toLowerCase();

        if (!title.contains(_searchQuery) &&
            !description.contains(_searchQuery) &&
            !category.contains(_searchQuery) &&
            !venue.contains(_searchQuery) &&
            !managerEmail.contains(_searchQuery)) {
          return false;
        }
      }

      // Filter by selected categories
      if (_selectedCategories.isNotEmpty) {
        if (!_selectedCategories.any((category) => 
            event.category.toLowerCase().contains(category.toLowerCase()))) {
          return false;
        }
      }

      return true;
    }).toList();

    // Sort by date (soonest first)
    filteredEvents.sort((a, b) => a.date.compareTo(b.date));
    
    return filteredEvents;
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
          'Discover Events',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onBackground,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UserHomePageNotification(),
                  ),
                );
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      color: colorScheme.onBackground,
                      size: 24,
                    ),
                    if (_notificationCount > 0)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.primary,
                            border: Border.all(
                              color: colorScheme.surface,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _notificationCount > 9 ? '9+' : '$_notificationCount',
                              style: TextStyle(
                                color: colorScheme.surface,
                                fontSize: 6,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
        centerTitle: false,
        elevation: 0,
      ),
      body: StreamBuilder<List<Event>>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .where('status', isEqualTo: 1)  // Fetch only approved events (status 1)
            .snapshots()
            .map((snapshot) => snapshot.docs.map((doc) => Event.fromDocument(doc)).toList()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            print('Stream error: ${snapshot.error}');  // Add this for debugging
            return Center(
              child: Text(
                'Error loading events: ${snapshot.error}',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            );
          }
          
          final events = snapshot.data ?? [];
          print('Fetched approved events count: ${events.length}');  // Updated message
          for (var event in events) {
            print('Approved Event: ${event.title}, Date: ${event.date}, ImageUrl: "${event.imageUrl}"');  // Updated message
          }
          final filteredEvents = _filterEvents(events);
          print('Filtered upcoming events count: ${filteredEvents.length}');  // Updated message
          
          return SingleChildScrollView(
            child: Column(
              children: [
                // Search Bar with Filter Button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            hintStyle: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.65),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: theme.dividerColor),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: colorScheme.primary),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: colorScheme.surface,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: colorScheme.onSurface.withOpacity(0.7),
                              size: 22,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear_rounded,
                                      color: colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                    onPressed: _clearSearch,
                                  )
                                : null,
                          ),
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      
                      // Filter Section (Expandable)
                      if (_showFilter) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Event Categories',
                                      style: textTheme.bodyLarge?.copyWith(
                                        color: colorScheme.onSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (_selectedCategories.isNotEmpty)
                                      GestureDetector(
                                        onTap: _clearAllCategories,
                                        child: Text(
                                          'Clear all',
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: colorScheme.primary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                
                                SizedBox(
                                  height: 180,
                                  child: GridView.builder(
                                    padding: EdgeInsets.zero,
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                      childAspectRatio: 2.5,
                                    ),
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: _eventCategories.length,
                                    itemBuilder: (context, index) {
                                      final category = _eventCategories[index];
                                      final categoryName = category['name'] as String;
                                      final categoryIcon = category['icon'] as IconData;
                                      final isSelected = (category['selected'] as bool?) ?? false;
                                      
                                      return GestureDetector(
                                        onTap: () => _toggleCategory(index),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? colorScheme.primary.withOpacity(0.1)
                                                : colorScheme.surface,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: isSelected
                                                  ? colorScheme.primary
                                                  : theme.dividerColor,
                                              width: 1,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                categoryIcon,
                                                color: isSelected
                                                    ? colorScheme.primary
                                                    : colorScheme.onSurface.withOpacity(0.7),
                                                size: 16,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                categoryName,
                                                style: textTheme.bodyMedium?.copyWith(
                                                  color: isSelected
                                                      ? colorScheme.primary
                                                      : colorScheme.onSurface,
                                                  fontSize: 11,
                                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                                ),
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                
                                if (_selectedCategories.length < _eventCategories.length)
                                  GestureDetector(
                                    onTap: _selectAllCategories,
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: colorScheme.surface,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: theme.dividerColor),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Select All',
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                
                                if (_selectedCategories.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Selected (${_selectedCategories.length}):',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurface.withOpacity(0.6),
                                          fontSize: 11,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: _selectedCategories.map((categoryName) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: colorScheme.primary.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  categoryName,
                                                  style: textTheme.bodySmall?.copyWith(
                                                    color: colorScheme.primary,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                GestureDetector(
                                                  onTap: () {
                                                    final index = _eventCategories.indexWhere(
                                                      (cat) => cat['name'] == categoryName
                                                    );
                                                    if (index != -1) {
                                                      _toggleCategory(index);
                                                    }
                                                  },
                                                  child: Icon(
                                                    Icons.close_rounded,
                                                    size: 14,
                                                    color: colorScheme.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ],
                                
                                const SizedBox(height: 20),

                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: _clearAllFilters,
                                        child: Container(
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: colorScheme.surface,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: theme.dividerColor),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Clear All',
                                              style: textTheme.bodyLarge?.copyWith(
                                                color: colorScheme.onSurface,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: _applyFilters,
                                        child: Container(
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: colorScheme.primary,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Apply Filters',
                                              style: textTheme.bodyLarge?.copyWith(
                                                color: colorScheme.surface,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Metrics Section with Real Data
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            'Your Metrics',
                            style: textTheme.titleLarge?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildMetricColumn('$_totalEvents', 'Total Attended'),
                              _buildMetricColumn('$_eventsThisMonth', 'This Month'),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),

                // Upcoming Events Section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Upcoming Events',
                            style: textTheme.titleLarge?.copyWith(
                              color: colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (filteredEvents.isNotEmpty)
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                'View all (${filteredEvents.length})',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      if (filteredEvents.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.event_note_outlined,
                                size: 64,
                                color: colorScheme.onSurface.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isNotEmpty || _selectedCategories.isNotEmpty
                                    ? 'No events match your filters'
                                    : 'No upcoming events available',
                                style: textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                              if (_searchQuery.isNotEmpty || _selectedCategories.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: TextButton(
                                    onPressed: _clearAllFilters,
                                    child: Text(
                                      'Clear filters',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )
                      else
                        Column(
                          children: filteredEvents.map((event) {
                            return _buildEventCard(event, theme, colorScheme, textTheme);
                          }).toList(),
                        ),
                    ],
                  ),
                ),

                // Banner Carousel
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: SizedBox(
                    height: 200,
                    child: Stack(
                      children: [
                        PageView(
                          controller: _pageController,
                          children: [
                            _buildBannerCard(
                              'Discover Live Events',
                              'Explore exciting events happening near you',
                              'Explore Now',
                              'https://images.unsplash.com/photo-1753155292632-8c5dbac1fabc',
                              theme,
                              colorScheme,
                              textTheme,
                            ),
                            _buildBannerCard(
                              'Get Your Tickets',
                              'Reserve your spot for upcoming shows',
                              'View Events',
                              'https://images.unsplash.com/photo-1615474268969-e880f76c8750',
                              theme,
                              colorScheme,
                              textTheme,
                            ),
                          ],
                        ),
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentBannerIndex == 0
                                      ? colorScheme.surface
                                      : theme.dividerColor,
                                ),
                              ),
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentBannerIndex == 1
                                      ? colorScheme.surface
                                      : theme.dividerColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
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

  Widget _buildEventCard(Event event, ThemeData theme, ColorScheme colorScheme, TextTheme textTheme) {
    final dateFormat = DateTime.now().day == event.date.day 
        ? 'Today • ${_formatTime(event.startTime)}' 
        : '${event.date.month}/${event.date.day} • ${_formatTime(event.startTime)}';

    print('Building event card: ${event.title}, ImageUrl: "${event.imageUrl}"');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Event Image Banner
          if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                color: colorScheme.primary.withOpacity(0.1),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.network(
                  event.imageUrl!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print('Error loading image for ${event.title}: $error');
                    return Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 32,
                        color: colorScheme.primary.withOpacity(0.5),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                        color: colorScheme.primary,
                      ),
                    );
                  },
                ),
              ),
            ),
          // Event Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
                      ),
                      child: Text(
                        event.category,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Text(
                        'Active',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  event.title,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  dateFormat,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
                ...(event.venue != null && event.venue!.isNotEmpty ? [
                  const SizedBox(height: 4),
                  Text(
                    event.venue!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ] : []),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.5),
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          '${(event.capacity - (event.registeredAttendees ?? 0)).toString()} seats',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EventDetailsPage(event: event),
                          ),
                        ).then((result) {
                          // Refresh events if booking was successful
                          if (result == true) {
                            setState(() {
                              _fetchMetricsData();
                            });
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'View Details',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.surface,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _navigateToIndex(int index) {
    if (_currentIndex == index) return;
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UserHomePageWidget()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ExplorePage()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const FavoritesPage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TicketsPage()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfilePage()),
        );
        break;
    }
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
            color: isSelected
                ? colorScheme.primary
                : colorScheme.onSurface.withOpacity(0.6),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurface.withOpacity(0.6),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(String value, String label) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.65),
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBannerCard(String title, String subtitle, String buttonText, String imageUrl, 
                         ThemeData theme, ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Image.network(
              imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    colorScheme.onSurface.withOpacity(0.8),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.displayMedium?.copyWith(
                        color: colorScheme.surface,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.surface,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          buttonText,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}