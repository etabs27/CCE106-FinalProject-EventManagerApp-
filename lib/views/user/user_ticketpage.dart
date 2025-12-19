import 'package:flutter/material.dart';
import 'package:event_manager_application_finalproject/theme.dart';
import 'package:event_manager_application_finalproject/views/user/user_homepage.dart';
import 'package:event_manager_application_finalproject/views/user/user_explorepage.dart';
import 'package:event_manager_application_finalproject/views/user/user_favoritepage.dart';
import 'package:event_manager_application_finalproject/views/user/user_profilepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          tabs: const [
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
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(
        child: Text(
          'Please login to view tickets',
          style: textTheme.bodyLarge,
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tickets')
          .where('userId', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, ticketSnapshot) {
        if (ticketSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ticketSnapshot.hasError) {
          print('Ticket Error: ${ticketSnapshot.error}');
          return Center(
            child: Text(
              'Error loading tickets: ${ticketSnapshot.error}',
              style: textTheme.bodyLarge?.copyWith(color: colorScheme.error),
            ),
          );
        }

        final allTickets = ticketSnapshot.data?.docs ?? [];
        print('Total tickets found: ${allTickets.length}');

        if (allTickets.isEmpty) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
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
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.confirmation_number_outlined,
                        size: 64,
                        color: colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No upcoming tickets',
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
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
              const SizedBox(height: 16),
              ...allTickets.map((ticketDoc) {
                final ticketData = ticketDoc.data() as Map<String, dynamic>;
                final ticketId = ticketData['ticketId'] as String;
                final eventId = ticketData['eventId'] as String;
                
                print('Processing ticket: $ticketId for event: $eventId');

                return StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('events')
                      .doc(eventId)
                      .snapshots(),
                  builder: (context, eventSnapshot) {
                    if (!eventSnapshot.hasData || !eventSnapshot.data!.exists) {
                      print('Event $eventId not found');
                      return const SizedBox.shrink();
                    }

                    try {
                      final eventData = eventSnapshot.data!.data() as Map<String, dynamic>;
                      final eventDateField = eventData['date'];
                      
                      if (eventDateField == null) {
                        print('Event $eventId has no date field');
                        return const SizedBox.shrink();
                      }
                      
                      final eventDate = (eventDateField as Timestamp).toDate();
                      final eventDateOnly = DateTime(eventDate.year, eventDate.month, eventDate.day);
                      final now = DateTime.now(); // FIX: Use DateTime.now() instead of just 'now'
                      final nowDateOnly = DateTime(now.year, now.month, now.day);

                      print('Event $eventId date: $eventDateOnly, now: $nowDateOnly');

                      // Only show if event is today or in the future
                      if (eventDateOnly.isBefore(nowDateOnly)) {
                        print('Event $eventId is in the past, hiding');
                        return const SizedBox.shrink();
                      }

                      // Safe field extraction with debugging
                      String eventTitle = 'Unknown Event';
                      String venue = 'TBA';
                      String startTime = '00:00';
                      String category = 'Other';

                      try {
                        final titleField = eventData['title'];
                        eventTitle = titleField is String ? titleField : titleField?.toString() ?? 'Unknown Event';
                        print('Title: $eventTitle (type: ${titleField.runtimeType})');
                      } catch (e) {
                        print('Error parsing title: $e');
                      }

                      try {
                        final venueField = eventData['venue'];
                        venue = venueField is String ? venueField : venueField?.toString() ?? 'TBA';
                        print('Venue: $venue (type: ${venueField.runtimeType})');
                      } catch (e) {
                        print('Error parsing venue: $e');
                      }

                      try {
                        final startTimeField = eventData['startTime'];
                        if (startTimeField is String) {
                          startTime = startTimeField;
                        } else if (startTimeField is Map) {
                          // If it's a TimeOfDay-like object, try to format it
                          startTime = '${startTimeField['hour']?.toString().padLeft(2, '0') ?? '00'}:${startTimeField['minute']?.toString().padLeft(2, '0') ?? '00'}';
                        } else {
                          startTime = startTimeField?.toString() ?? '00:00';
                        }
                        print('StartTime: $startTime (type: ${startTimeField.runtimeType})');
                      } catch (e) {
                        print('Error parsing startTime: $e');
                      }

                      try {
                        final categoryField = eventData['category'];
                        category = categoryField is String ? categoryField : categoryField?.toString() ?? 'Other';
                        print('Category: $category (type: ${categoryField.runtimeType})');
                      } catch (e) {
                        print('Error parsing category: $e');
                      }

                      final dateStr = '${eventDate.month}/${eventDate.day}/${eventDate.year}';
                      final timeStr = startTime;
                      final dateTimeStr = '$dateStr, $timeStr';

                      final daysLeft = eventDateOnly.difference(nowDateOnly).inDays;
                      final status = daysLeft > 0 ? '$daysLeft days left' : 'Today';

                      print('Showing ticket for event: $eventTitle');

                      return Column(
                        children: [
                          _buildTicketCard(
                            eventTitle,
                            venue,
                            dateTimeStr,
                            '1 ticket', // Since each ticket is individual
                            status,
                            _getCategoryIcon(category),
                            true,
                            ticketId,
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    } catch (e) {
                      print('Error processing event $eventId: $e');
                      return const SizedBox.shrink();
                    }
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
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

  Widget _buildPastTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(
        child: Text(
          'Please login to view tickets',
          style: textTheme.bodyLarge,
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tickets')
          .where('userId', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, ticketSnapshot) {
        if (ticketSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ticketSnapshot.hasError) {
          return Center(
            child: Text(
              'Error loading tickets: ${ticketSnapshot.error}',
              style: textTheme.bodyLarge?.copyWith(color: colorScheme.error),
            ),
          );
        }

        final allTickets = ticketSnapshot.data?.docs ?? [];

        if (allTickets.isEmpty) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
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
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.history_rounded,
                        size: 64,
                        color: colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No past events',
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
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
              const SizedBox(height: 16),
              ...allTickets.map((ticketDoc) {
                final ticketData = ticketDoc.data() as Map<String, dynamic>;
                final ticketId = ticketData['ticketId'] as String;
                final eventId = ticketData['eventId'] as String;

                return StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('events')
                      .doc(eventId)
                      .snapshots(),
                  builder: (context, eventSnapshot) {
                    if (!eventSnapshot.hasData || !eventSnapshot.data!.exists) {
                      return const SizedBox.shrink();
                    }

                    try {
                      final eventData = eventSnapshot.data!.data() as Map<String, dynamic>;
                      final eventDateField = eventData['date'];

                      if (eventDateField == null) {
                        return const SizedBox.shrink();
                      }

                      final eventDate = (eventDateField as Timestamp).toDate();
                      final eventDateOnly = DateTime(eventDate.year, eventDate.month, eventDate.day);
                      final now = DateTime.now();
                      final nowDateOnly = DateTime(now.year, now.month, now.day);

                      // Only show if event is in the past
                      if (eventDateOnly.isAfter(nowDateOnly) || eventDateOnly.isAtSameMomentAs(nowDateOnly)) {
                        return const SizedBox.shrink();
                      }

                      // Safe field extraction
                      String eventTitle = eventData['title']?.toString() ?? 'Unknown Event';
                      String venue = eventData['venue']?.toString() ?? 'TBA';
                      String startTime = '00:00';
                      String category = 'Other';

                      try {
                        final startTimeField = eventData['startTime'];
                        if (startTimeField is String) {
                          startTime = startTimeField;
                        } else if (startTimeField is Map) {
                          startTime = '${startTimeField['hour']?.toString().padLeft(2, '0') ?? '00'}:${startTimeField['minute']?.toString().padLeft(2, '0') ?? '00'}';
                        }
                      } catch (e) {
                        // Keep default
                      }

                      try {
                        final categoryField = eventData['category'];
                        category = categoryField?.toString() ?? 'Other';
                      } catch (e) {
                        // Keep default
                      }

                      final dateStr = '${eventDate.month}/${eventDate.day}/${eventDate.year}';
                      final timeStr = startTime;
                      final dateTimeStr = '$dateStr, $timeStr';

                      return Column(
                        children: [
                          _buildTicketCard(
                            eventTitle,
                            venue,
                            dateTimeStr,
                            '1 ticket',
                            'Event completed',
                            _getCategoryIcon(category),
                            false,
                            null,
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    } catch (e) {
                      return const SizedBox.shrink();
                    }
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCancelledTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(
        child: Text(
          'Please login to view tickets',
          style: textTheme.bodyLarge,
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tickets')
          .where('userId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'cancelled') // Assuming cancelled tickets have this status
          .snapshots(),
      builder: (context, ticketSnapshot) {
        if (ticketSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ticketSnapshot.hasError) {
          return Center(
            child: Text(
              'Error loading tickets: ${ticketSnapshot.error}',
              style: textTheme.bodyLarge?.copyWith(color: colorScheme.error),
            ),
          );
        }

        final cancelledTickets = ticketSnapshot.data?.docs ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
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
              const SizedBox(height: 16),

              if (cancelledTickets.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cancel_rounded,
                        size: 64,
                        color: colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No cancelled events',
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...cancelledTickets.map((ticketDoc) {
                  final ticketData = ticketDoc.data() as Map<String, dynamic>;
                  final ticketId = ticketData['ticketId'] as String;
                  final eventId = ticketData['eventId'] as String;

                  return StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('events')
                        .doc(eventId)
                        .snapshots(),
                    builder: (context, eventSnapshot) {
                      if (!eventSnapshot.hasData || !eventSnapshot.data!.exists) {
                        return const SizedBox.shrink();
                      }

                      try {
                        final eventData = eventSnapshot.data!.data() as Map<String, dynamic>;
                        final eventDateField = eventData['date'];

                        if (eventDateField == null) {
                          return const SizedBox.shrink();
                        }

                        final eventDate = (eventDateField as Timestamp).toDate();

                        // Safe field extraction
                        String eventTitle = eventData['title']?.toString() ?? 'Unknown Event';
                        String venue = eventData['venue']?.toString() ?? 'TBA';
                        String startTime = '00:00';
                        String category = 'Other';

                        try {
                          final startTimeField = eventData['startTime'];
                          if (startTimeField is String) {
                            startTime = startTimeField;
                          } else if (startTimeField is Map) {
                            startTime = '${startTimeField['hour']?.toString().padLeft(2, '0') ?? '00'}:${startTimeField['minute']?.toString().padLeft(2, '0') ?? '00'}';
                          }
                        } catch (e) {
                          // Keep default
                        }

                        try {
                          final categoryField = eventData['category'];
                          category = categoryField?.toString() ?? 'Other';
                        } catch (e) {
                          // Keep default
                        }

                        final dateStr = '${eventDate.month}/${eventDate.day}/${eventDate.year}';
                        final timeStr = startTime;
                        final dateTimeStr = '$dateStr, $timeStr';

                        return Column(
                          children: [
                            _buildTicketCard(
                              eventTitle,
                              venue,
                              dateTimeStr,
                              '1 ticket',
                              'Cancelled',
                              _getCategoryIcon(category),
                              false,
                              null,
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      } catch (e) {
                        return const SizedBox.shrink();
                      }
                    },
                  );
                }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTicketCard(String eventName, String venue, String dateTime, String ticketCount, String status, IconData icon, bool isUpcoming, [String? ticketId]) {
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
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                const SizedBox(width: 12),
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
                      const SizedBox(height: 2),
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
            const SizedBox(height: 16),

            // Date and Time
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded, 
                  color: colorScheme.onBackground.withOpacity(0.65), 
                  size: 16
                ),
                const SizedBox(width: 8),
                Text(
                  dateTime, 
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onBackground.withOpacity(0.65), 
                    fontSize: 14
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Ticket count and status
            Row(
              children: [
                Icon(
                  Icons.confirmation_number_rounded, 
                  color: colorScheme.onBackground.withOpacity(0.65), 
                  size: 16
                ),
                const SizedBox(width: 8),
                Text(
                  ticketCount, 
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onBackground.withOpacity(0.65), 
                    fontSize: 14
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            const SizedBox(height: 16),

            // QR Code Button
            if (isUpcoming)
              GestureDetector(
                onTap: ticketId != null ? () => _showQRCodeDialog(ticketId) : null,
                child: Container(
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
                      const SizedBox(width: 8),
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

  void _showQRCodeDialog(String ticketId) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ticket QR Code',
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onBackground,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: QrImageView(
                  data: ticketId,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Show this QR code at the event entrance',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onBackground.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Close',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'music':
        return Icons.music_note_rounded;
      case 'comedy':
        return Icons.theater_comedy_rounded;
      case 'sports':
        return Icons.sports_basketball_rounded;
      case 'art':
        return Icons.palette_rounded;
      case 'theater':
        return Icons.theaters_rounded;
      case 'food & drink':
        return Icons.restaurant_rounded;
      case 'technology':
        return Icons.computer_rounded;
      case 'business':
        return Icons.business_center_rounded;
      case 'education':
        return Icons.school_rounded;
      case 'health & wellness':
        return Icons.health_and_safety_rounded;
      default:
        return Icons.event_rounded;
    }
  }
}