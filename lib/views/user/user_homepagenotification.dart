import 'package:flutter/material.dart';
import 'package:event_manager_application_finalproject/theme.dart';

class UserHomePageNotification extends StatefulWidget {
  const UserHomePageNotification({super.key});

  @override
  State<UserHomePageNotification> createState() => _UserHomePageNotificationState();
}

class _UserHomePageNotificationState extends State<UserHomePageNotification> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'Event Reminder: Jazz Night Tonight',
      'description': 'Your Jazz Night at Blue Note starts at 8:00 PM. Doors open at 7:00 PM.',
      'time': '2 hours ago',
      'type': 'event_reminder',
      'isRead': false,
      'icon': Icons.music_note_rounded,
    },
    {
      'id': '2',
      'title': 'Ticket Confirmed!',
      'description': 'Your ticket for Hamilton Musical has been confirmed. Seat: B12, Row 5.',
      'time': 'Yesterday',
      'type': 'ticket_confirmed',
      'isRead': false,
      'icon': Icons.confirmation_number_rounded,
    },
    {
      'id': '3',
      'title': 'New Event Near You',
      'description': 'Stand-Up Comedy Show just announced near your location. Check it out!',
      'time': '2 days ago',
      'type': 'new_event',
      'isRead': true,
      'icon': Icons.new_releases_rounded,
    },
    {
      'id': '4',
      'title': 'Friend Going to Same Event',
      'description': 'Sarah is also attending Symphony Orchestra this weekend.',
      'time': '3 days ago',
      'type': 'friend_activity',
      'isRead': true,
      'icon': Icons.people_rounded,
    },
    {
      'id': '5',
      'title': 'Event Updated',
      'description': 'The start time for Modern Art Exhibition has changed to 6:30 PM.',
      'time': '1 week ago',
      'type': 'event_update',
      'isRead': true,
      'icon': Icons.update_rounded,
    },
    {
      'id': '6',
      'title': 'Special Offer Available',
      'description': 'Get 20% off on your next booking. Limited time offer!',
      'time': '1 week ago',
      'type': 'special_offer',
      'isRead': true,
      'icon': Icons.local_offer_rounded,
    },
    {
      'id': '7',
      'title': 'Event Review Reminder',
      'description': 'How was your experience at The Lion King? Share your review.',
      'time': '2 weeks ago',
      'type': 'review_reminder',
      'isRead': true,
      'icon': Icons.star_rounded,
    },
    {
      'id': '8',
      'title': 'Welcome Bonus!',
      'description': 'Welcome to Event Manager! Here\'s 100 points to get started.',
      'time': '2 weeks ago',
      'type': 'welcome',
      'isRead': true,
      'icon': Icons.celebration_rounded,
    },
  ];

  int _unreadCount = 2;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: colorScheme.onBackground,
            size: 24,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Notifications',
          style: textTheme.displayLarge?.copyWith(
            color: colorScheme.onBackground,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: _markAllAsRead,
              child: Stack(
                children: [
                  // Icon container
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primary.withOpacity(0.1),
                    ),
                    child: Icon(
                      Icons.done_all_rounded,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  // Notification badge
                  if (_unreadCount > 0)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 18,
                        height: 18,
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
                            _unreadCount > 9 ? '9+' : '$_unreadCount',
                            style: TextStyle(
                              color: colorScheme.onError,
                              fontSize: 8,
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
        ],
        centerTitle: false,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', true),
                  const SizedBox(width: 8),
                  _buildFilterChip('Unread', false),
                  const SizedBox(width: 8),
                  _buildFilterChip('Events', false),
                  const SizedBox(width: 8),
                  _buildFilterChip('Tickets', false),
                  const SizedBox(width: 8),
                  _buildFilterChip('Offers', false),
                ],
              ),
            ),
          ),

          // Notifications List
          Expanded(
            child: _notifications.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _notifications.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return _buildNotificationItem(notification);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? colorScheme.onPrimary : colorScheme.onBackground.withOpacity(0.7),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: isSelected,
      backgroundColor: colorScheme.surface,
      selectedColor: colorScheme.primary,
      checkmarkColor: colorScheme.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? colorScheme.primary : colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      onSelected: (selected) {
        // Handle filter selection
      },
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isRead = notification['isRead'] as bool;

    return GestureDetector(
      onTap: () {
        if (!isRead) {
          setState(() {
            notification['isRead'] = true;
            _unreadCount--;
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  notification['icon'] as IconData,
                  color: colorScheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),

              // Notification Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'] as String,
                            style: textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onBackground,
                              fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                              fontSize: 15,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification['description'] as String,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onBackground.withOpacity(0.7),
                        fontSize: 14,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification['time'] as String,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onBackground.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_off_rounded,
                color: colorScheme.primary,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Notifications',
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onBackground,
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You\'re all caught up! Check back later\nfor new updates and events.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onBackground.withOpacity(0.6),
                fontSize: 15,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              child: Text(
                'Explore Events',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        if (!notification['isRead']) {
          notification['isRead'] = true;
        }
      }
      _unreadCount = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'All notifications marked as read',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}