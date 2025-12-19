import 'dart:async';
import 'package:flutter/material.dart';
import 'package:event_manager_application_finalproject/theme.dart';
import 'package:event_manager_application_finalproject/event_service.dart';
import 'package:event_manager_application_finalproject/models/event.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManagerNotificationPage extends StatefulWidget {
  const ManagerNotificationPage({super.key});

  @override
  State<ManagerNotificationPage> createState() => _ManagerNotificationPageState();
}

class _ManagerNotificationPageState extends State<ManagerNotificationPage> {
  final List<Map<String, dynamic>> _notifications = [];
  StreamSubscription<List<Event>>? _eventsSubscription;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Set<String> _readNotificationIds = {};
  
  int _unreadCount = 0;
  int _readCount = 0;
  String _currentFilter = 'All'; // 'All', 'Unread', or 'Read'

  @override
  void initState() {
    super.initState();
    _setupRealtimeNotifications();
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    super.dispose();
  }

  void _setupRealtimeNotifications() {
    _eventsSubscription = EventService.getAllEvents().listen((events) {
      _processEventsForNotifications(events);
    });
  }

  void _processEventsForNotifications(List<Event> events) {
    final userEmail = _auth.currentUser?.email;
    if (userEmail == null) return;

    final managerEvents = events.where((e) => e.managerEmail == userEmail).toList();
    final List<Map<String, dynamic>> newNotifications = [];

    // Process each event for notifications
    for (final event in managerEvents) {
      final now = DateTime.now();
      
      // Event approved notification - Show this only when status changes to approved
      if (event.status == EventStatus.approved) {
        final notificationId = 'approved_${event.id}';
        if (!_notifications.any((n) => n['id'] == notificationId)) {
          newNotifications.add({
            'id': notificationId,
            'title': 'Event Application Approved! 🎉',
            'description': 'Congratulations! Your event application "${event.title}" has been approved by the admin.\n\nYour event is now live and available for users to book tickets.',
            'time': _calculateTimeAgo(now),
            'type': 'event_approved',
            'isRead': _readNotificationIds.contains(notificationId),
            'icon': Icons.check_circle_rounded,
            'eventId': event.id,
            'eventTitle': event.title,
            'eventDescription': event.description,
            'eventDate': event.date,
            'eventLocation': event.venue,
            'timestamp': now,
          });
        }
      }

      // New bookings notification - Show when new attendees register
      if ((event.registeredAttendees ?? 0) > 0) {
        final notificationId = 'booking_${event.id}_${DateTime.now().millisecondsSinceEpoch}';
        final hasRecentBookingNotification = _notifications.any((n) => 
          n['id'].toString().startsWith('booking_${event.id}') && 
          DateTime.now().difference(n['timestamp'] as DateTime).inHours < 1
        );
        
        if (!hasRecentBookingNotification) {
          newNotifications.add({
            'id': notificationId,
            'title': 'New Booking Received! 📝',
            'description': 'Great news! A new user has booked a ticket for your event "${event.title}".\n\nTotal bookings: ${event.registeredAttendees}',
            'time': _calculateTimeAgo(now),
            'type': 'booking',
            'isRead': _readNotificationIds.contains(notificationId),
            'icon': Icons.person_add_rounded,
            'eventId': event.id,
            'eventTitle': event.title,
            'timestamp': now,
          });
        }
      }

      // Event starting soon notification (within 24 hours)
      if (event.date.isAfter(DateTime.now()) && 
          event.date.isBefore(DateTime.now().add(const Duration(hours: 24)))) {
        final notificationId = 'starting_${event.id}';
        if (!_notifications.any((n) => n['id'] == notificationId)) {
          final hoursUntil = event.date.difference(DateTime.now()).inHours;
          newNotifications.add({
            'id': notificationId,
            'title': 'Event Starting Soon! ⏰',
            'description': 'Your event "${event.title}" starts in ${hoursUntil} hours.\n\nMake sure everything is ready for a successful event!',
            'time': _calculateTimeAgo(event.date),
            'type': 'event_reminder',
            'isRead': _readNotificationIds.contains(notificationId),
            'icon': Icons.event_rounded,
            'eventId': event.id,
            'eventTitle': event.title,
            'timestamp': event.date,
          });
        }
      }

      // Event completed notification (if event ended in last 24 hours)
      if (event.date.isBefore(DateTime.now()) && 
          event.date.isAfter(DateTime.now().subtract(const Duration(hours: 24)))) {
        final notificationId = 'completed_${event.id}';
        if (!_notifications.any((n) => n['id'] == notificationId)) {
          newNotifications.add({
            'id': notificationId,
            'title': 'Event Completed Successfully! 🎊',
            'description': 'Congratulations on completing your event "${event.title}"!\n\nCheck the attendance report in your dashboard to see event insights.',
            'time': _calculateTimeAgo(event.date),
            'type': 'event_completed',
            'isRead': _readNotificationIds.contains(notificationId),
            'icon': Icons.flag_rounded,
            'eventId': event.id,
            'eventTitle': event.title,
            'timestamp': event.date,
          });
        }
      }

      // Event application submitted notification (when status is pending)
      if (event.status == EventStatus.pending) {
        final notificationId = 'submitted_${event.id}';
        if (!_notifications.any((n) => n['id'] == notificationId)) {
          newNotifications.add({
            'id': notificationId,
            'title': 'Event Application Submitted 📤',
            'description': 'Your event "${event.title}" has been submitted for admin approval.\n\nYou will receive a notification once it\'s reviewed.',
            'time': _calculateTimeAgo(event.submittedAt ?? now),
            'type': 'application_submitted',
            'isRead': _readNotificationIds.contains(notificationId),
            'icon': Icons.send_rounded,
            'eventId': event.id,
            'eventTitle': event.title,
            'timestamp': event.submittedAt ?? now,
          });
        }
      }
    }

    // Add new notifications to the beginning of the list
    if (newNotifications.isNotEmpty) {
      setState(() {
        // Remove duplicate IDs
        _notifications.removeWhere((n) => newNotifications.any((nn) => nn['id'] == n['id']));
        // Add new notifications to the beginning
        _notifications.insertAll(0, newNotifications);
        // Sort by timestamp (newest first)
        _notifications.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));
        _calculateNotificationCounts();
      });
    }
  }

  String _calculateTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    }
  }

  void _calculateNotificationCounts() {
    setState(() {
      _unreadCount = _notifications.where((notification) => !(notification['isRead'] as bool)).length;
      _readCount = _notifications.where((notification) => (notification['isRead'] as bool)).length;
    });
  }

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_currentFilter == 'Unread') {
      return _notifications.where((notification) => !(notification['isRead'] as bool)).toList();
    } else if (_currentFilter == 'Read') {
      return _notifications.where((notification) => (notification['isRead'] as bool)).toList();
    }
    return _notifications; // All notifications
  }

  void _onNotificationTap(Map<String, dynamic> notification) {
    final notificationId = notification['id'] as String;
    
    // Mark as read FIRST
    if (!_readNotificationIds.contains(notificationId)) {
      setState(() {
        _readNotificationIds.add(notificationId);
        notification['isRead'] = true;
        _calculateNotificationCounts();
      });
    }

    // Show event details dialog
    _showEventNotificationDialog(notification);
  }

  void _showEventNotificationDialog(Map<String, dynamic> notification) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    
    final type = notification['type'] as String;
    final eventTitle = notification['eventTitle'] as String? ?? 'Unknown Event';
    final description = notification['description'] as String? ?? '';
    final eventDate = notification['eventDate'] as DateTime?;
    final eventLocation = notification['eventLocation'] as String?;

    String title;
    String actionText;
    IconData icon;
    Color color;

    switch (type) {
      case 'event_approved':
        title = 'Event Application Approved!';
        actionText = 'View Event Details';
        icon = Icons.check_circle_rounded;
        color = Colors.green;
        break;
      case 'booking':
        title = 'New Booking Received';
        actionText = 'Check Attendance';
        icon = Icons.person_add_rounded;
        color = Colors.blue;
        break;
      case 'event_reminder':
        title = 'Event Starting Soon';
        actionText = 'View Event';
        icon = Icons.event_rounded;
        color = Colors.orange;
        break;
      case 'event_completed':
        title = 'Event Completed';
        actionText = 'View Report';
        icon = Icons.flag_rounded;
        color = Colors.purple;
        break;
      case 'application_submitted':
        title = 'Application Submitted';
        actionText = 'View Application';
        icon = Icons.send_rounded;
        color = Colors.blueGrey;
        break;
      default:
        title = 'Notification';
        actionText = 'View Details';
        icon = Icons.notifications_rounded;
        color = colorScheme.primary;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onBackground,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eventTitle,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onBackground,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onBackground.withOpacity(0.8),
              ),
            ),
            if (eventDate != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 16, color: colorScheme.onBackground.withOpacity(0.6)),
                  const SizedBox(width: 8),
                  Text(
                    'Date: ${_formatEventDate(eventDate)}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onBackground.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
            if (eventLocation != null && eventLocation.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on_rounded, size: 16, color: colorScheme.onBackground.withOpacity(0.6)),
                  const SizedBox(width: 8),
                  Text(
                    'Location: $eventLocation',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onBackground.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToEventAction(notification);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
            ),
            child: Text(actionText),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: colorScheme.surface,
      ),
    );
  }

  String _formatEventDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _navigateToEventAction(Map<String, dynamic> notification) {
    final eventId = notification['eventId'] as String?;
    final type = notification['type'] as String;
    
    if (eventId == null || eventId.isEmpty) return;

    // Close notification page
    Navigator.pop(context);
    
    // TODO: Implement navigation to appropriate page based on notification type
    // Example:
    // switch (type) {
    //   case 'event_approved':
    //     Navigator.push(context, MaterialPageRoute(
    //       builder: (context) => EventDetailsPage(eventId: eventId),
    //     ));
    //     break;
    //   case 'booking':
    //     Navigator.push(context, MaterialPageRoute(
    //       builder: (context) => AttendanceReportPage(eventId: eventId),
    //     ));
    //     break;
    //   case 'event_reminder':
    //     Navigator.push(context, MaterialPageRoute(
    //       builder: (context) => EventDetailsPage(eventId: eventId),
    //     ));
    //     break;
    //   case 'event_completed':
    //     Navigator.push(context, MaterialPageRoute(
    //       builder: (context) => EventReportPage(eventId: eventId),
    //     ));
    //     break;
    // }
    
    // For now, show a simple message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to event: ${notification['eventTitle'] ?? 'Unknown Event'}'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
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
        leading: Navigator.canPop(context) ? IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: colorScheme.onBackground,
            size: 24,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ) : null,
        title: Text(
          'Notifications',
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
              onTap: _markAllAsRead,
              child: Stack(
                children: [
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
                        constraints: const BoxConstraints(maxWidth: 80),
                        child: _buildFilterDropdown(),
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
            child: _filteredNotifications.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _filteredNotifications.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final notification = _filteredNotifications[index];
                      return GestureDetector(
                        onTap: () => _onNotificationTap(notification),
                        child: _buildNotificationItem(notification),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final int totalCount = _notifications.length;

    return DropdownButtonHideUnderline(
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
              'All ($totalCount)',
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          DropdownMenuItem<String>(
            value: 'Unread',
            child: Text(
              'Unread ($_unreadCount)',
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          DropdownMenuItem<String>(
            value: 'Read',
            child: Text(
              'Read ($_readCount)',
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
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isRead = (notification['isRead'] as bool?) ?? false;

    Color getNotificationColor() {
      switch (notification['type'] as String) {
        case 'event_approved':
          return Colors.green;
        case 'booking':
          return Colors.blue;
        case 'event_reminder':
          return Colors.orange;
        case 'event_completed':
          return Colors.purple;
        case 'application_submitted':
          return Colors.blueGrey;
        default:
          return colorScheme.primary;
      }
    }

    final notificationColor = getNotificationColor();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isRead ? colorScheme.surface.withOpacity(0.8) : colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRead ? notificationColor.withOpacity(0.1) : notificationColor.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: isRead
            ? []
            : [
                BoxShadow(
                  color: notificationColor.withOpacity(0.05),
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
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isRead ? notificationColor.withOpacity(0.05) : notificationColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                notification['icon'] as IconData,
                color: isRead ? notificationColor.withOpacity(0.5) : notificationColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            if (!isRead)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: notificationColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _getNotificationTypeText(notification['type'] as String),
                                  style: TextStyle(
                                    color: notificationColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            if (isRead)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'READ',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                notification['title'] as String,
                                style: textTheme.bodyLarge?.copyWith(
                                  color: isRead
                                      ? colorScheme.onBackground.withOpacity(0.6)
                                      : colorScheme.onBackground,
                                  fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                                  fontSize: 15,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
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
                  const SizedBox(height: 6),
                  Text(
                    notification['description'] as String,
                    style: textTheme.bodyMedium?.copyWith(
                      color: isRead
                          ? colorScheme.onBackground.withOpacity(0.5)
                          : colorScheme.onBackground.withOpacity(0.7),
                      fontSize: 14,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        notification['time'] as String,
                        style: textTheme.bodySmall?.copyWith(
                          color: isRead
                              ? colorScheme.onBackground.withOpacity(0.4)
                              : colorScheme.onBackground.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                      if (notification['eventId'] != null && notification['eventId'].toString().isNotEmpty)
                        Text(
                          'Tap to view details',
                          style: textTheme.bodySmall?.copyWith(
                            color: isRead ? Colors.grey : notificationColor,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
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
    );
  }

  String _getNotificationTypeText(String type) {
    switch (type) {
      case 'event_approved':
        return 'APPROVED';
      case 'booking':
        return 'BOOKINGS';
      case 'event_reminder':
        return 'REMINDER';
      case 'event_completed':
        return 'COMPLETED';
      case 'application_submitted':
        return 'SUBMITTED';
      default:
        return 'NOTIFICATION';
    }
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    String getEmptyTitle() {
      switch (_currentFilter) {
        case 'Unread':
          return 'No Unread Notifications';
        case 'Read':
          return 'No Read Notifications';
        default:
          return 'No Notifications';
      }
    }

    String getEmptyMessage() {
      switch (_currentFilter) {
        case 'Unread':
          return 'You\'ve read all your notifications!';
        case 'Read':
          return 'No notifications have been marked as read yet.';
        default:
          return 'You\'re all caught up! Check back later\nfor event updates and bookings.';
      }
    }

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
                _currentFilter == 'Read'
                    ? Icons.check_circle_outline_rounded
                    : Icons.notifications_off_rounded,
                color: colorScheme.primary,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              getEmptyTitle(),
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onBackground,
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              getEmptyMessage(),
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
                if (_currentFilter != 'All') {
                  setState(() {
                    _currentFilter = 'All';
                  });
                } else {
                  Navigator.pop(context);
                }
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
                _currentFilter != 'All' ? 'View All Notifications' : 'Back to Dashboard',
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
          _readNotificationIds.add(notification['id'] as String);
        }
      }
      _calculateNotificationCounts();
    });
  }
}