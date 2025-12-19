import 'dart:async';
import 'package:flutter/material.dart';
import 'package:event_manager_application_finalproject/theme.dart';
import 'package:event_manager_application_finalproject/views/user/user_homepage.dart';
import 'package:event_manager_application_finalproject/views/user/user_favoritepage.dart';
import 'package:event_manager_application_finalproject/views/user/user_ticketpage.dart';
import 'package:event_manager_application_finalproject/views/user/user_profilepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_manager_application_finalproject/models/event.dart';
import 'package:event_manager_application_finalproject/views/user/user_eventdetailspage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  int _currentIndex = 1;
  final TextEditingController _searchController = TextEditingController();

  
  String _searchQuery = '';
  Timer? _debounceTimer;

  final List<Map<String, dynamic>> _categories = [
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

 
  Set<String> _favoriteEventIds = {};
  bool _favoritesLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _searchQuery = _searchController.text.trim().toLowerCase();
        });
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  void _toggleCategory(int index) {
    setState(() {
      _categories[index]['selected'] = !_categories[index]['selected'];
    });
  }

  void _clearAllFilters() {
    setState(() {
      for (var cat in _categories) {
        cat['selected'] = false;
      }
      _clearSearch();
    });
  }

  List<String> get _selectedCategories {
    return _categories
        .where((c) => c['selected'] == true)
        .map((c) => c['name'] as String)
        .toList();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet(
        categories: _categories,
        onToggleCategory: _toggleCategory,
        onClearAll: _clearAllFilters,
        onApply: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _loadFavorites() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final favoritesSnapshot = await FirebaseFirestore.instance
          .collection('favorites')
          .where('userId', isEqualTo: user.uid)
          .get();

      final favoriteIds = favoritesSnapshot.docs.map((doc) => doc['eventId'] as String).toSet();

      if (mounted) {
        setState(() {
          _favoriteEventIds = favoriteIds;
          _favoritesLoaded = true;
        });
      }
    } catch (e) {
      print('Error loading favorites: $e');
      if (mounted) {
        setState(() {
          _favoritesLoaded = true;
        });
      }
    }
  }

  Future<void> _toggleFavorite(String eventId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showLoginRequiredDialog();
        return;
      }

      final isCurrentlyFavorite = _favoriteEventIds.contains(eventId);

      if (isCurrentlyFavorite) {
        await FirebaseFirestore.instance
            .collection('favorites')
            .where('userId', isEqualTo: user.uid)
            .where('eventId', isEqualTo: eventId)
            .get()
            .then((snapshot) {
              for (var doc in snapshot.docs) {
                doc.reference.delete();
              }
            });

        setState(() {
          _favoriteEventIds.remove(eventId);
        });

        
      } else {
        await FirebaseFirestore.instance.collection('favorites').add({
          'userId': user.uid,
          'eventId': eventId,
          'createdAt': FieldValue.serverTimestamp(),
        });

        setState(() {
          _favoriteEventIds.add(eventId);
        });

      
      }
    } catch (e) {
      print('Error toggling favorite: $e');
     
    }
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please login to add events to favorites.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Login')),
        ],
      ),
    );
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
      ),
      body: StreamBuilder<List<Event>>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .where('status', isEqualTo: 1)
            .snapshots()
            .map((snapshot) => snapshot.docs.map((doc) => Event.fromDocument(doc)).toList()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading events',
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
              ),
            );
          }

          final events = snapshot.data ?? [];

          final filteredEvents = events.where((event) {
            
            if (!event.date.isAfter(DateTime.now().subtract(const Duration(days: 1)))) return false;

            
            if (_searchQuery.isNotEmpty) {
              final query = _searchQuery;
              final title = event.title.toLowerCase();
              final desc = event.description?.toLowerCase() ?? '';
              final venue = event.venue?.toLowerCase() ?? '';
              final category = event.category.toLowerCase();

              if (!(title.contains(query) ||
                  desc.contains(query) ||
                  venue.contains(query) ||
                  category.contains(query))) {
                return false;
              }
            }

            
            if (_selectedCategories.isNotEmpty) {
              if (!_selectedCategories
                  .any((cat) => event.category.toLowerCase().contains(cat.toLowerCase()))) {
                return false;
              }
            }

            return true;
          }).toList();

          filteredEvents.sort((a, b) => a.date.compareTo(b.date));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onBackground.withOpacity(0.65)),
                    prefixIcon: Icon(Icons.search_rounded, color: colorScheme.onBackground.withOpacity(0.65), size: 20),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_searchQuery.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: _clearSearch,
                          ),
                        IconButton(
                          icon: Icon(
                            Icons.tune_rounded,
                            color: _selectedCategories.isNotEmpty
                                ? colorScheme.primary
                                : colorScheme.onBackground.withOpacity(0.7),
                          ),
                          onPressed: _showFilterBottomSheet,
                        ),
                      ],
                    ),
                    filled: true,
                    fillColor: colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.primary, width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  style: textTheme.bodyLarge?.copyWith(color: colorScheme.onBackground),
                ),
                const SizedBox(height: 24),

                Text(
                  'Recommended for You',
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                if (filteredEvents.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Icon(Icons.event_busy_rounded, size: 64, color: colorScheme.onBackground.withOpacity(0.3)),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty || _selectedCategories.isNotEmpty
                                ? 'No events match your filters'
                                : 'No upcoming events available',
                            style: textTheme.bodyLarge?.copyWith(color: colorScheme.onBackground.withOpacity(0.6)),
                            textAlign: TextAlign.center,
                          ),
                          if (_searchQuery.isNotEmpty || _selectedCategories.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: TextButton(
                                onPressed: _clearAllFilters,
                                child: Text('Clear filters', style: TextStyle(color: colorScheme.primary)),
                              ),
                            ),
                        ],
                      ),
                    ),
                  )
                else
                  ...filteredEvents.take(10).map((event) => _buildEventCard(event, theme, colorScheme, textTheme)),
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
            _buildNavItem(Icons.favorite_border_rounded, 'Favorites', 2),
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

    final isFavorite = _favoriteEventIds.contains(event.id);

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
          if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                color: colorScheme.primary.withOpacity(0.1),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                    child: Image.network(
                      event.imageUrl!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(Icons.image_not_supported, size: 32, color: colorScheme.primary.withOpacity(0.5)),
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
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _toggleFavorite(event.id),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: colorScheme.onSurface.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: isFavorite ? Colors.red : colorScheme.onSurface.withOpacity(0.6),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                color: colorScheme.primary.withOpacity(0.1),
              ),
              child: Stack(
                children: [
                  Center(child: Icon(Icons.event_rounded, size: 48, color: colorScheme.primary.withOpacity(0.5))),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _toggleFavorite(event.id),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: colorScheme.onSurface.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: isFavorite ? Colors.red : colorScheme.onSurface.withOpacity(0.6),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

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
                if (event.venue != null && event.venue!.isNotEmpty) ...[
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
                ],
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
                          '${(event.capacity - (event.registeredAttendees ?? 0))} seats',
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
                          MaterialPageRoute(builder: (_) => EventDetailsPage(event: event)),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(8)),
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

  Widget _buildNavItem(IconData icon, String label, int index) {
    final colorScheme = Theme.of(context).colorScheme;
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
          const SizedBox(height: 4),
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

class _FilterBottomSheet extends StatefulWidget {
  final List<Map<String, dynamic>> categories;
  final Function(int) onToggleCategory;
  final VoidCallback onClearAll;
  final VoidCallback onApply;

  const _FilterBottomSheet({
    required this.categories,
    required this.onToggleCategory,
    required this.onClearAll,
    required this.onApply,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 5,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filter Events', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  TextButton(
                    onPressed: () {
                      widget.onClearAll();
                      setState(() {});
                    },
                    child: Text('Clear All', style: TextStyle(color: colorScheme.primary)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: controller,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemCount: widget.categories.length,
                itemBuilder: (context, index) {
                  final category = widget.categories[index];
                  final bool selected = category['selected'];
                  return ListTile(
                    onTap: () {
                      widget.onToggleCategory(index);
                      setState(() {});
                    },
                    leading: Icon(category['icon'], size: 28),
                    title: Text(category['name']),
                    trailing: selected
                        ? Icon(Icons.check_circle, color: colorScheme.primary)
                        : const Icon(Icons.circle_outlined),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: widget.onApply,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: colorScheme.primary,
                ),
                child: const Text('Apply Filters', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}