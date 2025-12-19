import 'dart:async';
import 'package:flutter/material.dart';
import 'package:event_manager_application_finalproject/views/user/user_ticketpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserHomePageNotification extends StatefulWidget {
  const UserHomePageNotification({super.key});

  @override
  State<UserHomePageNotification> createState() => _UserHomePageNotificationState();
}

class _UserHomePageNotificationState extends State<UserHomePageNotification> {
  final List<Map<String, dynamic>> _notifications = [];
  StreamSubscription<QuerySnapshot>? _ticketsSubscription;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Set<String> _readNotificationIds = {};
  
  int _unreadCount = 0;
  int _readCount = 0;
  String _currentFilter = 'All'; // 'All', 'Unread', or 'Read'
  bool _hasNewNotifications = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _setupTicketsStream();
  }

  @override
  void dispose() {
    _ticketsSubscription?.cancel();
    super.dispose();
  }

  void _setupTicketsStream() {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      _ticketsSubscription = FirebaseFirestore.instance
          .collection('tickets')
          .where('userId', isEqualTo: currentUser.uid)
          .snapshots()
          .listen(_handleTicketsUpdate);
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleTicketsUpdate(QuerySnapshot snapshot) {
    if (!mounted) return;
    
    final tickets = snapshot.docs;
    final List<Map<String, dynamic>> newNotifications = [];

    for (final ticketDoc in tickets) {
      final ticketData = ticketDoc.data() as Map<String, dynamic>;
      final ticketId = ticketDoc.id;
      final eventId = ticketData['eventId'] as String?;
      final eventTitle = ticketData['eventTitle'] as String? ?? 'Unknown Event';
      final bookingTime = ticketData['createdAt'] as Timestamp?;
      final seatInfo = ticketData['seatInfo'] as String?;
      final notificationRead = ticketData['notificationRead'] as bool? ?? false;

      // Create booking confirmation notification
      final notificationId = 'booking_${ticketId}';
      if (!_notifications.any((n) => n['id'] == notificationId)) {
        newNotifications.add({
          'id': notificationId,
          'title': '🎉 Booking Successful!',
          'description': 'Your booking for "$eventTitle" has been confirmed${seatInfo != null ? '. Seat: $seatInfo.' : ''}. Tap to view your QR code.',
          'time': _calculateTimeAgo(bookingTime?.toDate() ?? DateTime.now()),
          'type': 'booking_success',
          // Prefer persisted read flag on the ticket document when available
          'isRead': notificationRead || _readNotificationIds.contains(notificationId),
          'icon': Icons.celebration_rounded,
          'ticketId': ticketId,
          'eventId': eventId,
          'eventTitle': eventTitle,
          'timestamp': bookingTime?.toDate() ?? DateTime.now(),
        });
      }
    }

    // Check for new notifications
    final previousCount = _notifications.length;
    final hasNewNotifications = newNotifications.length > previousCount;

    // Sort new notifications by timestamp (newest first)
    newNotifications.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));

    // Update notifications list
    setState(() {
      _isLoading = false;
      // Replace old notifications with new ones
      _notifications.clear();
      _notifications.addAll(newNotifications);
      _calculateNotificationCounts();
      _hasNewNotifications = hasNewNotifications;
    });

    // Reset the new notifications flag after a short delay
    if (hasNewNotifications) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _hasNewNotifications = false);
        }
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

  Future<void> _markNotificationAsRead(String notificationId) async {
    // Find the notification in the list
    final notificationIndex = _notifications.indexWhere((n) => n['id'] == notificationId);

    if (notificationIndex != -1 && !(_notifications[notificationIndex]['isRead'] as bool)) {
      // Persist read flag to the ticket document if available
      final ticketId = _notifications[notificationIndex]['ticketId'] as String?;
      if (ticketId != null && ticketId.isNotEmpty) {
        try {
          await FirebaseFirestore.instance.collection('tickets').doc(ticketId).update({'notificationRead': true});
        } catch (e) {
          // ignore write errors but continue to update local state
        }
      }

      setState(() {
        // Mark as read locally
        _notifications[notificationIndex]['isRead'] = true;
        _readNotificationIds.add(notificationId);

        // Recalculate counts
        _calculateNotificationCounts();
      });
    }
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
        title: Row(
          children: [
            Text(
              'Notifications',
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onBackground,
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
            ),
            if (_hasNewNotifications)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primary,
                  ),
                ),
              ),
          ],
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filter dropdown row placed below AppBar
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
                              width: 80,
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

                // Notifications List
                Expanded(
                  child: _filteredNotifications.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _filteredNotifications.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final notification = _filteredNotifications[index];
                            return _buildNotificationItem(notification);
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
              'All (${_notifications.length})',
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

    return GestureDetector(
      onTap: () {
        // MARK AS READ immediately when tapped
        if (!isRead) {
          _markNotificationAsRead(notification['id'] as String);
        }

        // Navigate to ticket page if it's a booking success notification
        if (notification['type'] == 'booking_success') {
          _navigateToTickets(notification['ticketId'] as String);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRead ? colorScheme.primary.withOpacity(0.1) : colorScheme.primary.withOpacity(0.3),
            width: isRead ? 1 : 1.5,
          ),
          boxShadow: isRead
              ? []
              : [
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
                  color: isRead ? colorScheme.primary.withOpacity(0.05) : colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  notification['icon'] as IconData,
                  color: isRead ? colorScheme.primary.withOpacity(0.5) : colorScheme.primary,
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
                          child: Row(
                            children: [
                              if (!isRead)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'NEW',
                                    style: TextStyle(
                                      color: colorScheme.primary,
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
                    const SizedBox(height: 4),
                    Text(
                      notification['description'] as String,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onBackground.withOpacity(isRead ? 0.5 : 0.7),
                        fontSize: 14,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          notification['time'] as String,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onBackground.withOpacity(isRead ? 0.4 : 0.5),
                            fontSize: 12,
                          ),
                        ),
                        if (notification['type'] == 'booking_success')
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isRead ? colorScheme.primary.withOpacity(0.05) : colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.qr_code_rounded,
                                  size: 12,
                                  color: isRead ? colorScheme.primary.withOpacity(0.5) : colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'View QR',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: isRead ? colorScheme.primary.withOpacity(0.5) : colorScheme.primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
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
      ),
    );
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
          return 'No Booking Notifications';
      }
    }

    String getEmptyMessage() {
      switch (_currentFilter) {
        case 'Unread':
          return 'You\'ve read all your notifications!';
        case 'Read':
          return 'No notifications have been marked as read yet.';
        default:
          return 'Your successful bookings will appear here.\nBook tickets for events to see your confirmations.';
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
                _currentFilter != 'All' ? 'View All Notifications' : 'Explore Events',
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

  void _navigateToTickets(String ticketId) {
    // Show a quick feedback that notification was marked as read
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notification marked as read'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    // Navigate to tickets page after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const TicketsPage(),
        ),
      ).then((_) {
        // Show a snackbar to guide user to their QR code
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.qr_code_rounded, color: Theme.of(context).colorScheme.onPrimary),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Find your ticket in the "Upcoming" tab and tap "View QR Code"',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      });
    });
  }

  Future<void> _markAllAsRead() async {
    // Persist read flag for all unread notifications
    final updates = <Future>[];
    for (var notification in _notifications) {
      if (!(notification['isRead'] as bool)) {
        final ticketId = notification['ticketId'] as String?;
        if (ticketId != null && ticketId.isNotEmpty) {
          updates.add(FirebaseFirestore.instance.collection('tickets').doc(ticketId).update({'notificationRead': true}).catchError((_) {}));
        }
        _readNotificationIds.add(notification['id'] as String);
        notification['isRead'] = true;
      }
    }

    // Wait for pending updates but don't fail on errors
    if (updates.isNotEmpty) {
      try {
        await Future.wait(updates);
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _calculateNotificationCounts();
      });
    }
  }
}