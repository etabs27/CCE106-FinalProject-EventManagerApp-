import 'package:flutter/material.dart';
import 'package:event_manager_application_finalproject/theme.dart';
import 'package:event_manager_application_finalproject/views/user/user_homepage.dart';
import 'package:event_manager_application_finalproject/views/user/user_explorepage.dart';
import 'package:event_manager_application_finalproject/views/user/user_ticketpage.dart';
import 'package:event_manager_application_finalproject/views/user/user_profilepage.dart';
import 'package:event_manager_application_finalproject/models/event.dart';
import 'package:event_manager_application_finalproject/views/user/user_eventdetailspage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  int _currentIndex = 2;
  String _currentFilter = 'All';
  List<Event> _favoriteEvents = [];
  Map<String, Timestamp> _favoriteTimestamps = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteEvents();
  }

  Future<void> _loadFavoriteEvents() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
          _favoriteEvents = [];
        });
        return;
      }

   
      final favoritesSnapshot = await FirebaseFirestore.instance
          .collection('favorites')
          .where('userId', isEqualTo: user.uid)
          .get();

      if (favoritesSnapshot.docs.isEmpty) {
        setState(() {
          _isLoading = false;
          _favoriteEvents = [];
        });
        return;
      }

      final favoriteIds = <String>[];
      final favoriteDocs = favoritesSnapshot.docs;
      
      
      favoriteDocs.sort((a, b) {
        final timestampA = a['createdAt'] as Timestamp?;
        final timestampB = b['createdAt'] as Timestamp?;
        if (timestampA != null && timestampB != null) {
          return timestampB.compareTo(timestampA);
        }
        return 0;
      });

      for (var doc in favoriteDocs) {
        final eventId = doc['eventId'] as String;
        favoriteIds.add(eventId);
        _favoriteTimestamps[eventId] = doc['createdAt'] as Timestamp;
      }

      
      if (favoriteIds.isNotEmpty) {
        
        final List<Event> allEvents = [];
        
        for (var i = 0; i < favoriteIds.length; i += 30) {
          final batchIds = favoriteIds.sublist(i, i + 30 > favoriteIds.length ? favoriteIds.length : i + 30);
          
          final eventsSnapshot = await FirebaseFirestore.instance
              .collection('events')
              .where(FieldPath.documentId, whereIn: batchIds)
              .get();

          final events = eventsSnapshot.docs
              .map((doc) => Event.fromDocument(doc))
              .toList();
          
          allEvents.addAll(events);
        }

       
        allEvents.sort((a, b) {
          final timestampA = _favoriteTimestamps[a.id];
          final timestampB = _favoriteTimestamps[b.id];
          if (timestampA != null && timestampB != null) {
            return timestampB.compareTo(timestampA);
          }
          return 0;
        });

        setState(() {
          _favoriteEvents = allEvents;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _favoriteEvents = [];
        });
      }
    } catch (e) {
      print('Error loading favorite events: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error loading favorites. Please try again.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      setState(() {
        _isLoading = false;
        _favoriteEvents = [];
      });
    }
  }

  Future<void> _removeFromFavorites(String eventId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

    
      final querySnapshot = await FirebaseFirestore.instance
          .collection('favorites')
          .where('userId', isEqualTo: user.uid)
          .where('eventId', isEqualTo: eventId)
          .get();

      
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

     
      setState(() {
        _favoriteEvents.removeWhere((event) => event.id == eventId);
        _favoriteTimestamps.remove(eventId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from favorites'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error removing favorite: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  List<Event> _getFilteredEvents() {
    final now = DateTime.now();
    switch (_currentFilter) {
      case 'Upcoming':
        return _favoriteEvents.where((event) => event.date.isAfter(now)).toList();
      case 'Past':
        return _favoriteEvents.where((event) => event.date.isBefore(now)).toList();
      case 'All':
      default:
        return _favoriteEvents;
    }
  }

  String _getTimeAgo(Timestamp timestamp) {
    final now = DateTime.now();
    final time = timestamp.toDate();
    final difference = now.difference(time);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  IconData _getCategoryIcon(String category) {
    final lowerCategory = category.toLowerCase();
    
    if (lowerCategory.contains('music')) {
      return Icons.music_note_rounded;
    } else if (lowerCategory.contains('comedy')) {
      return Icons.theater_comedy_rounded;
    } else if (lowerCategory.contains('sport')) {
      return Icons.sports_basketball_rounded;
    } else if (lowerCategory.contains('art')) {
      return Icons.palette_rounded;
    } else if (lowerCategory.contains('theater')) {
      return Icons.theaters_rounded;
    } else if (lowerCategory.contains('food') || lowerCategory.contains('drink')) {
      return Icons.restaurant_menu_rounded;
    } else if (lowerCategory.contains('tech')) {
      return Icons.computer_rounded;
    } else if (lowerCategory.contains('business')) {
      return Icons.business_center_rounded;
    } else if (lowerCategory.contains('educat')) {
      return Icons.school_rounded;
    } else if (lowerCategory.contains('health') || lowerCategory.contains('wellness')) {
      return Icons.health_and_safety_rounded;
    }
    return Icons.event_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final filteredEvents = _getFilteredEvents();
    final upcomingCount = _favoriteEvents.where((event) => event.date.isAfter(DateTime.now())).length;
    final pastCount = _favoriteEvents.where((event) => event.date.isBefore(DateTime.now())).length;

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
        actions: [
          
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: colorScheme.onBackground,
            ),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadFavoriteEvents();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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
                        width: 100,
                        child: DropdownButtonHideUnderline(
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
                                  'All (${_favoriteEvents.length})',
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              DropdownMenuItem<String>(
                                value: 'Upcoming',
                                child: Text(
                                  'Upcoming ($upcomingCount)',
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              DropdownMenuItem<String>(
                                value: 'Past',
                                child: Text(
                                  'Past ($pastCount)',
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
                        ),
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
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : filteredEvents.isEmpty
                    ? _buildEmptyState(theme, colorScheme, textTheme)
                    : _buildEventsList(filteredEvents, theme, colorScheme, textTheme),
          ),
        ],
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
            _buildNavItem(Icons.favorite_rounded, 'Favorites', 2),
            _buildNavItem(Icons.confirmation_number_rounded, 'Tickets', 3),
            _buildNavItem(Icons.person_outline_rounded, 'Profile', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border_rounded,
              size: 64,
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 20),
            Text(
              'No favorite events yet',
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tap the heart icon on events in the\nHome or Explore pages to add them here',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.4),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                
                _navigateToIndex(0);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Browse Events'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList(List<Event> events, ThemeData theme, ColorScheme colorScheme, TextTheme textTheme) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _isLoading = true;
        });
        await _loadFavoriteEvents();
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final event = events[index];
          final isUpcoming = event.date.isAfter(DateTime.now());
          final favoriteTimestamp = _favoriteTimestamps[event.id];
          final timeAgo = favoriteTimestamp != null ? _getTimeAgo(favoriteTimestamp) : '';
          
          return _buildEventFavoriteItem(
            event,
            isUpcoming,
            timeAgo,
            theme,
            colorScheme,
            textTheme,
          );
        },
      ),
    );
  }

  Widget _buildEventFavoriteItem(Event event, bool isUpcoming, String timeAgo, 
                                ThemeData theme, ColorScheme colorScheme, TextTheme textTheme) {
    final dateFormat = '${event.date.month}/${event.date.day}/${event.date.year.toString().substring(2)} • ${_formatTime(event.startTime)}';

    return Container(
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
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EventDetailsPage(event: event),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
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
                      return Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 32,
                          color: colorScheme.primary.withOpacity(0.5),
                        ),
                      );
                    },
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(event.category),
                      color: colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                event.title,
                                style: textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onBackground,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              onPressed: () => _removeFromFavorites(event.id),
                              icon: Icon(
                                Icons.favorite_rounded,
                                color: Colors.red,
                                size: 22,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 36,
                                minHeight: 36,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormat,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onBackground.withOpacity(0.6),
                            fontSize: 13,
                          ),
                        ),
                        if (event.venue != null && event.venue!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            event.venue!,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onBackground.withOpacity(0.6),
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isUpcoming 
                                    ? Colors.green.withOpacity(0.1)
                                    : colorScheme.surface,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isUpcoming 
                                      ? Colors.green.withOpacity(0.3)
                                      : colorScheme.outline.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                isUpcoming ? 'Upcoming' : 'Past',
                                style: textTheme.bodySmall?.copyWith(
                                  color: isUpcoming ? Colors.green : colorScheme.onBackground.withOpacity(0.5),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            if (timeAgo.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: colorScheme.surface,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: colorScheme.outline.withOpacity(0.2),
                                  ),
                                ),
                                child: Text(
                                  'Added $timeAgo',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onBackground.withOpacity(0.5),
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                          ],
                        ),
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
                                    color: colorScheme.onBackground.withOpacity(0.5),
                                    fontSize: 11,
                                  ),
                                ),
                                Text(
                                  '${(event.capacity - (event.registeredAttendees ?? 0)).toString()} seats',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onBackground,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            Container(
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
                          ],
                        ),
                      ],
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

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _navigateToIndex(int index) {
    if (_currentIndex == index) return;
    
    setState(() {
      _currentIndex = index;
    });
    
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