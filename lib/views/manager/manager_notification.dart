import 'package:flutter/material.dart';
import 'package:event_manager_application_finalproject/theme.dart';
import 'package:event_manager_application_finalproject/views/manager/manager_homepage.dart';

class ManagerNotificationPage extends StatefulWidget {
  const ManagerNotificationPage({super.key});

  @override
  State<ManagerNotificationPage> createState() => _ManagerNotificationPageState();
}

class _ManagerNotificationPageState extends State<ManagerNotificationPage> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'New Registration',
      'description': 'John Doe registered for Summer Music Festival. Ticket #TKT-789012',
      'time': '10 minutes ago',
      'type': 'registration',
      'isRead': false,
      'icon': Icons.person_add_rounded,
    },
    {
      'id': '2',
      'title': 'Event Reminder',
      'description': 'Tech Conference 2024 starts in 2 days. Final preparations needed.',
      'time': '2 hours ago',
      'type': 'event_reminder',
      'isRead': false,
      'icon': Icons.event_rounded,
    },
    {
      'id': '3',
      'title': 'Ticket Check-in',
      'description': 'Ticket #TKT-456789 was checked in at Summer Music Festival.',
      'time': 'Yesterday',
      'type': 'check_in',
      'isRead': true,
      'icon': Icons.qr_code_scanner_rounded,
    },
    {
      'id': '4',
      'title': 'Payment Received',
      'description': 'Payment of \$150 received for Tech Conference 2024 registration.',
      'time': '2 days ago',
      'type': 'payment',
      'isRead': true,
      'icon': Icons.payment_rounded,
    },
    {
      'id': '5',
      'title': 'Capacity Alert',
      'description': 'Summer Music Festival is at 85% capacity. Consider expanding.',
      'time': '3 days ago',
      'type': 'capacity_alert',
      'isRead': true,
      'icon': Icons.warning_rounded,
    },
    {
      'id': '6',
      'title': 'New Review',
      'description': 'New 5-star review received for Jazz Night Live event.',
      'time': '1 week ago',
      'type': 'review',
      'isRead': true,
      'icon': Icons.star_rounded,
    },
    {
      'id': '7',
      'title': 'Event Update',
      'description': 'Venue for Business Networking Mixer has been changed.',
      'time': '1 week ago',
      'type': 'event_update',
      'isRead': true,
      'icon': Icons.update_rounded,
    },
    {
      'id': '8',
      'title': 'System Maintenance',
      'description': 'Scheduled system maintenance will occur this weekend.',
      'time': '2 weeks ago',
      'type': 'system',
      'isRead': true,
      'icon': Icons.settings_rounded,
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
          // Filter dropdown row
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                      SizedBox(width: 4),
                      Container(
                        width: 80,
                        child: _buildFilterDropdown(),
                      ),
                      SizedBox(width: 2),
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

    // Calculate counts
    final int totalCount = _notifications.length;
    final int unreadCount = _unreadCount;

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
        if (!isRead) {
          setState(() {
            final index = _notifications.indexWhere((n) => n['id'] == notification['id']);
            if (index != -1) {
              _notifications[index]['isRead'] = true;
              _calculateUnreadCount();
            }
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
              _currentFilter == 'Unread' ? 'No Unread Notifications' : 'No Notifications',
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