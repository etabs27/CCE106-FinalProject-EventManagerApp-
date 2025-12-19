import 'package:flutter/material.dart';
import 'package:event_manager_application_finalproject/theme.dart';
import 'package:event_manager_application_finalproject/event_service.dart';
import 'package:event_manager_application_finalproject/models/event.dart';
import 'package:event_manager_application_finalproject/views/admin/admin_eventapproval.dart';

class AdminNotificationPage extends StatefulWidget {
  const AdminNotificationPage({super.key});

  @override
  State<AdminNotificationPage> createState() => _AdminNotificationPageState();
}

class _AdminNotificationPageState extends State<AdminNotificationPage> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'New Event Created',
      'description': 'Summer Music Festival needs approval. Review event details.',
      'time': '2 hours ago',
      'type': 'event',
      'isRead': false,
      'icon': Icons.event_rounded,
    },
    {
      'id': '2',
      'title': 'New Manager Registered',
      'description': 'John Doe has registered as a manager. Review profile.',
      'time': '4 hours ago',
      'type': 'manager',
      'isRead': false,
      'icon': Icons.person_add_rounded,
    },
    {
      'id': '3',
      'title': 'Event Completed',
      'description': 'Tech Conference 2024 has ended. View final report.',
      'time': '1 day ago',
      'type': 'event',
      'isRead': true,
      'icon': Icons.check_circle_rounded,
    },
    {
      'id': '4',
      'title': 'Weekly Report Ready',
      'description': 'Weekly admin report for Nov 25 - Dec 1 is available.',
      'time': '2 days ago',
      'type': 'report',
      'isRead': true,
      'icon': Icons.analytics_rounded,
    },
    {
      'id': '5',
      'title': 'Event Approval Required',
      'description': 'Winter Gala needs your review before approval.',
      'time': '3 days ago',
      'type': 'event',
      'isRead': true,
      'icon': Icons.pending_rounded,
    },
    {
      'id': '6',
      'title': 'Manager Update',
      'description': 'Manager Sarah Johnson updated her profile information.',
      'time': '5 days ago',
      'type': 'manager',
      'isRead': true,
      'icon': Icons.person_rounded,
    },
    {
      'id': '7',
      'title': 'Event Capacity Alert',
      'description': 'Summer Music Festival reached 90% capacity.',
      'time': '1 week ago',
      'type': 'event',
      'isRead': true,
      'icon': Icons.warning_rounded,
    },
    {
      'id': '8',
      'title': 'Monthly Report',
      'description': 'Monthly platform usage report is available.',
      'time': '2 weeks ago',
      'type': 'report',
      'isRead': true,
      'icon': Icons.summarize_rounded,
    },
  ];

  int _unreadCount = 2;
  String _currentFilter = 'All'; // 'All' or 'Unread'

  @override
  void initState() {
    super.initState();
    _calculateUnreadCount();
  }

  void _calculateUnreadCount() {
    _unreadCount = _notifications.where((notification) => !(notification['isRead'] as bool)).length;
  }

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_currentFilter == 'Unread') {
      return _notifications.where((notification) => !(notification['isRead'] as bool)).toList();
    }
    return _notifications; // All notifications
  }

  // Method to mark a specific notification as read
  void _markAsRead(String id) {
    setState(() {
      for (var notification in _notifications) {
        if (notification['id'] == id && !notification['isRead']) {
          notification['isRead'] = true;
          _calculateUnreadCount();
          break;
        }
      }
    });
  }

  // Method to mark a pending event notification as read
  void _markEventNotificationAsRead(String eventId) {
    setState(() {
      for (var notification in _notifications) {
        if (notification['type'] == 'event' && 
            notification['id'] == eventId && 
            !notification['isRead']) {
          notification['isRead'] = true;
          _calculateUnreadCount();
          break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Event>>(
      stream: EventService.getPendingEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final pendingEvents = snapshot.data ?? [];
        final eventNotifications = pendingEvents.map((event) => Map<String, dynamic>.from({
          'id': event.id,
          'title': 'New Event Created',
          'description': '${event.title} needs approval. Review event details.',
          'time': 'Recently',
          'type': 'event',
          'isRead': false,
          'icon': Icons.event_rounded,
          'event': event, // Store the event object for navigation
        })).toList();
        final allNotifications = [...eventNotifications, ..._notifications];
        final unreadCount = allNotifications.where((n) => !(n['isRead'] as bool)).length;
        final filteredNotifications = _currentFilter == 'Unread' ? allNotifications.where((n) => !(n['isRead'] as bool)).toList() : _currentFilter == 'Read' ? allNotifications.where((n) => n['isRead'] as bool).toList() : allNotifications;
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
                      if (unreadCount > 0)
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
                                unreadCount > 9 ? '9+' : '$unreadCount',
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
              // Filter dropdown row
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
                            child: _buildFilterDropdown(allNotifications),
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
                child: filteredNotifications.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filteredNotifications.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final notification = filteredNotifications[index];
                          return _buildNotificationItem(notification);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterDropdown(List<Map<String, dynamic>> notifications) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Calculate counts
    final int totalCount = notifications.length;
    final int unreadCount = notifications.where((n) => !(n['isRead'] as bool)).length;
    final int readCount = notifications.where((n) => n['isRead'] as bool).length;

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
              'Unread ($unreadCount)',
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
              'Read ($readCount)',
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
        case 'event':
          return Colors.blue;
        case 'manager':
          return Colors.green;
        case 'report':
          return Colors.orange;
        default:
          return colorScheme.primary;
      }
    }

    VoidCallback? onTap;
    if (notification['type'] == 'event') {
      onTap = () {
        // Mark the notification as read first
        if (!isRead) {
          if (notification['event'] != null) {
            // This is a pending event notification
            _markEventNotificationAsRead(notification['id'] as String);
          } else {
            // This is a regular notification
            _markAsRead(notification['id'] as String);
          }
        }
        // Navigate to event approvals page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const EventApprovalsDesign(),
          ),
        );
      };
    } else {
      onTap = () {
        // Mark the notification as read when tapped
        if (!isRead) {
          _markAsRead(notification['id'] as String);
        }
        // You can add other navigation logic here for different notification types
      };
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
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
                  color: getNotificationColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  notification['icon'] as IconData,
                  color: getNotificationColor(),
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),

              // Notification Content - Wrap in Expanded with width constraint
              Expanded(
                child: SizedBox(
                  width: double.infinity, // Constrains the width
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
              _currentFilter == 'Unread' ? 'No Unread Notifications' : _currentFilter == 'Read' ? 'No Read Notifications' : 'No Notifications',
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onBackground,
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _currentFilter == 'Unread'
                  ? 'You\'ve read all your notifications!'
                  : _currentFilter == 'Read'
                      ? 'No notifications have been read yet.'
                      : 'You\'re all caught up! Check back later\nfor new updates.',
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
                'Back to Dashboard',
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
      _calculateUnreadCount();
    });
  }
}