import 'dart:math'; 
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:event_manager_application_finalproject/theme.dart';
import 'package:event_manager_application_finalproject/models/event.dart';
import 'package:event_manager_application_finalproject/views/user/user_explorepage.dart';
import 'package:event_manager_application_finalproject/views/user/user_favoritepage.dart';
import 'package:event_manager_application_finalproject/views/user/user_ticketpage.dart';
import 'package:event_manager_application_finalproject/views/user/user_profilepage.dart';
import 'package:event_manager_application_finalproject/views/user/user_homepagenotification.dart';
import 'package:event_manager_application_finalproject/views/user/user_eventdetailspage.dart';

class UserHomePageWidget extends StatefulWidget {
  const UserHomePageWidget({super.key});

  @override
  State<UserHomePageWidget> createState() => _UserHomePageWidgetState();
}

class _UserHomePageWidgetState extends State<UserHomePageWidget> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  int _currentBannerIndex = 0;
  int _notificationCount = 0;
  StreamSubscription<QuerySnapshot>? _ticketsSubscription;

  
  int _totalEvents = 0;
  int _eventsThisMonth = 0;


  Set<String> _favoriteEventIds = {};
  bool _favoritesLoaded = false;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentBannerIndex = _pageController.page?.round() ?? 0;
      });
    });

    _fetchMetricsData();
    _loadFavorites();
    _setupTicketListener();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _ticketsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchMetricsData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final now = DateTime.now();
      final currentMonth = now.month;
      final currentYear = now.year;

      final ticketsSnapshot = await FirebaseFirestore.instance
          .collection('tickets')
          .where('userId', isEqualTo: user.uid)
          .get();

      final totalAttended = ticketsSnapshot.docs.length;

      final eventsThisMonth = ticketsSnapshot.docs.where((doc) {
        final data = doc.data();
        final timestamp = data['purchasedAt'] as Timestamp?;
        if (timestamp != null) {
          final date = timestamp.toDate();
          return date.month == currentMonth && date.year == currentYear;
        }
        return false;
      }).length;

      if (mounted) {
        setState(() {
          _totalEvents = totalAttended;
          _eventsThisMonth = eventsThisMonth;
        });
      }
    } catch (e) {
      print('Error fetching metrics: $e');
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final favoritesSnapshot = await FirebaseFirestore.instance
          .collection('favorites')
          .where('userId', isEqualTo: user.uid)
          .get();

      final favoriteIds = favoritesSnapshot.docs
          .map((doc) => doc['eventId'] as String)
          .toSet();

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

  void _setupTicketListener() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _ticketsSubscription = FirebaseFirestore.instance
        .collection('tickets')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
      if (!mounted) return;

      try {
        final unread = snapshot.docs.where((d) {
          final data = d.data() as Map<String, dynamic>;
          final readFlag = data['notificationRead'] as bool?;
          return readFlag != true;
        }).length;

        setState(() {
          _notificationCount = unread;
        });
      } catch (e) {
        
      }
    }, onError: (e) {
      
    });
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

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Removed from favorites'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        await FirebaseFirestore.instance.collection('favorites').add({
          'userId': user.uid,
          'eventId': eventId,
          'createdAt': FieldValue.serverTimestamp(),
        });

        setState(() {
          _favoriteEventIds.add(eventId);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Added to favorites'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update favorite: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please login to add events to favorites.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              
            },
            child: const Text('Login'),
          ),
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
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UserHomePageNotification(),
                  ),
                );
                if (mounted) {
                  setState(() {
                    _notificationCount = 0;
                  });
                }
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
                            color: colorScheme.error,
                            border: Border.all(
                              color: colorScheme.surface,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _notificationCount > 9 ? '9+' : '$_notificationCount',
                              style: TextStyle(
                                color: colorScheme.onError,
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
                'Error loading events: ${snapshot.error}',
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
              ),
            );
          }

          final events = snapshot.data ?? [];
          final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
          final upcomingEvents = events
              .where((event) => event.date.isAfter(today) || event.date.isAtSameMomentAs(today))
              .toList();
          upcomingEvents.sort((a, b) => a.date.compareTo(b.date));

          return SingleChildScrollView(
            child: Column(
              children: [
                // Metrics Section
                Padding(
                  padding: const EdgeInsets.all(16),
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
                            'Your Event Journey',
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
                              _buildMetricColumn('${_favoriteEventIds.length}', 'Favorites'),
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
                          if (upcomingEvents.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ExplorePage()),
                                );
                              },
                              child: Text(
                                'View all (${upcomingEvents.length})',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (upcomingEvents.isEmpty)
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
                                'No upcoming events available',
                                style: textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        SizedBox(
                          height: 320,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 290,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: min(upcomingEvents.length, 5),
                                  itemBuilder: (context, index) {
                                    final event = upcomingEvents[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.8,
                                        child: _buildEventCard(event, theme, colorScheme, textTheme),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
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
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ExplorePage()),
                              ),
                              child: _buildBannerCard(
                                'Discover Live Events',
                                'Explore exciting events happening near you',
                                'Explore Now',
                                'https://images.unsplash.com/photo-1753155292632-8c5dbac1fabc',
                                theme,
                                colorScheme,
                                textTheme,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ExplorePage()),
                              ),
                              child: _buildBannerCard(
                                'Get Your Tickets',
                                'Reserve your spot for upcoming shows',
                                'View Events',
                                'https://images.unsplash.com/photo-1615474268969-e880f76c8750',
                                theme,
                                colorScheme,
                                textTheme,
                              ),
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
                                  color: _currentBannerIndex == 0 ? colorScheme.surface : theme.dividerColor,
                                ),
                              ),
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentBannerIndex == 1 ? colorScheme.surface : theme.dividerColor,
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

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EventDetailsPage(event: event)),
        ).then((result) {
          if (result == true) {
            _fetchMetricsData();
          }
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        constraints: const BoxConstraints(maxHeight: 280),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 130,
              child: Stack(
                children: [
                  if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: Image.network(
                        event.imageUrl!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: colorScheme.primary.withOpacity(0.1),
                          child: Center(
                            child: Icon(Icons.event_rounded, size: 40, color: colorScheme.primary.withOpacity(0.5)),
                          ),
                        ),
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
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        color: colorScheme.primary.withOpacity(0.1),
                      ),
                      child: Center(
                        child: Icon(Icons.event_rounded, size: 48, color: colorScheme.primary.withOpacity(0.5)),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _toggleFavorite(event.id),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: colorScheme.onSurface.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: isFavorite ? Colors.red : colorScheme.onSurface.withOpacity(0.7),
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            event.category,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Active',
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.title,
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 12, color: colorScheme.onSurface.withOpacity(0.6)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            dateFormat,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (event.venue != null && event.venue!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded, size: 12, color: colorScheme.onSurface.withOpacity(0.6)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.venue!,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.7),
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Available',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.5),
                                  fontSize: 9,
                                ),
                              ),
                              Text(
                                '${(event.capacity - (event.registeredAttendees ?? 0))} left',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'View Details',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.surface,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
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

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _navigateToIndex(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);

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
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _navigateToIndex(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.6),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.6),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(String value, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
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
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Image.network(
              imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: colorScheme.primary.withOpacity(0.1),
                child: Center(
                  child: Icon(Icons.event_rounded, size: 48, color: colorScheme.primary.withOpacity(0.5)),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, colorScheme.onSurface.withOpacity(0.8)],
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
                      style: textTheme.bodyLarge?.copyWith(color: colorScheme.surface, fontSize: 12),
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