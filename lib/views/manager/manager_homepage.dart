import 'package:flutter/material.dart';
import 'package:event_manager_application_finalproject/theme.dart';
import 'package:event_manager_application_finalproject/views/manager/manager_notification.dart';
import 'package:event_manager_application_finalproject/views/manager/manager_addevent.dart';
import 'package:event_manager_application_finalproject/views/manager/manager_scanticket.dart';
import 'package:event_manager_application_finalproject/views/manager/manager_attendancereport.dart';
import 'package:event_manager_application_finalproject/views/manager/manager_settings.dart';
import 'package:event_manager_application_finalproject/auth/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_manager_application_finalproject/models/event.dart';
import 'package:event_manager_application_finalproject/event_service.dart';

class ManagerDashboard extends StatefulWidget {
  const ManagerDashboard({super.key});

  @override
  State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> {
  String _currentFilter = 'Active';
  Stream<List<Event>>? _eventsStream;
  bool _isIndexError = false;
  bool _debugPrinted = false;
  
  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    setState(() {
      _isIndexError = false;
      _debugPrinted = false;
      _eventsStream = _getEventsWithFallback();
    });
  }

  Stream<List<Event>> _getEventsWithFallback() {
    try {
      return EventService.getEventsByManager(
        FirebaseAuth.instance.currentUser!.email!
      );
    } catch (e) {
      print('Falling back to manual query: $e');
      return _getEventsWithoutOrdering();
    }
  }

  Stream<List<Event>> _getEventsWithoutOrdering() {
    return FirebaseFirestore.instance
        .collection('events')
        .where('managerEmail', isEqualTo: FirebaseAuth.instance.currentUser!.email!)
        .snapshots()
        .map((snapshot) {
          final events = snapshot.docs
              .map((doc) => Event.fromFirestore(doc))
              .toList();
          events.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
          return events;
        });
  }

  // Method to cancel an event
  Future<void> _cancelEvent(Event event) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    bool? confirmCancel = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Cancel Event',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.error,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to cancel this event?',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Event: ${event.title}',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onBackground,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone. Registered attendees will be notified.',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.error.withOpacity(0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Keep Event',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'Cancel Event',
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: colorScheme.surface,
      ),
    );

    if (confirmCancel == true) {
      try {
        // Show loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        // Update event status to cancelled (status index 3)
        await FirebaseFirestore.instance
            .collection('events')
            .doc(event.id)
            .update({
          'status': 3, // cancelled status
          'cancelledAt': Timestamp.now(),
          'cancelledBy': FirebaseAuth.instance.currentUser!.email,
        });

        // Close loading dialog
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Event "${event.title}" has been cancelled'),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh events
        _loadEvents();
        
      } catch (e) {
        // Close loading dialog
        Navigator.pop(context);
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel event: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
        automaticallyImplyLeading: false,
        title: Text(
          'Dashboard',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onBackground,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManagerNotificationPage()),
                );
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.notifications_none,
                  color: colorScheme.onBackground.withOpacity(0.7),
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _buildProfileDropdown(),
          const SizedBox(width: 16),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ManagerAddEventPage()),
          );
        },
        backgroundColor: colorScheme.primary,
        child: Icon(Icons.add, color: colorScheme.onPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overview stats section
              StreamBuilder<List<Event>>(
                stream: _eventsStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    final error = snapshot.error.toString();
                    if (error.contains('index')) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!_isIndexError) {
                          setState(() {
                            _isIndexError = true;
                            _eventsStream = _getEventsWithoutOrdering();
                          });
                        }
                      });
                      return _buildIndexWarning();
                    }
                    return _buildErrorState(error);
                  }

                  final events = snapshot.data ?? [];
                  
                  if (!_debugPrinted && events.isNotEmpty) {
                    _debugPrinted = true;
                    _debugEvents(events);
                  }
                  
                  return Column(
                    children: [
                      // Quick Stats Cards
                      _buildStatsSection(events),
                      
                      // My Events Section with Filter
                      _buildMyEventsSection(events),
                      
                      // Event Cards
                      _buildEventCardsSection(snapshot, events),
                    ],
                  );
                },
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  void _debugEvents(List<Event> events) {
    print('=== DEBUG: Events Analysis ===');
    print('Total unique events: ${events.length}');
    
    // Count by status
    final pendingEvents = events.where((e) => e.status == EventStatus.pending).toList();
    final approvedEvents = events.where((e) => e.status == EventStatus.approved).toList();
    final rejectedEvents = events.where((e) => e.status == EventStatus.rejected).toList();
    final cancelledEvents = events.where((e) => e.status == EventStatus.cancelled).toList();
    
    print('Pending events: ${pendingEvents.length}');
    print('Approved events: ${approvedEvents.length}');
    print('Rejected events: ${rejectedEvents.length}');
    print('Cancelled events: ${cancelledEvents.length}');
    
    print('=== END DEBUG ===\n');
  }

  Widget _buildIndexWarning() {
    return Column(
      children: [
        _buildStatsSection([]),
        _buildMyEventsSection([]),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  'Optimizing Database',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Events are loading with basic sorting. '
                  'This will improve automatically once Firebase indexes are ready.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Column(
      children: [
        _buildStatsSection([]),
        _buildMyEventsSection([]),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).colorScheme.error.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: Theme.of(context).colorScheme.error,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error Loading Events',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.length > 100 ? '${error.substring(0, 100)}...' : error,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadEvents,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventCardsSection(AsyncSnapshot<List<Event>> snapshot, List<Event> events) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final filteredEvents = _filterEvents(events);
    
    if (filteredEvents.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: filteredEvents.map((event) => _buildEventCard(event)).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              Icons.event_note_rounded,
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No ${_currentFilter.toLowerCase()} events',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentFilter == 'Active' 
                ? 'Create your first active event by tapping the + button'
                : 'Switch to a different filter or create new events',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.4),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDropdown() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'settings') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ManagerSettingsPage()),
          );
        } else if (value == 'signout') {
          _showSignOutConfirmation();
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'settings',
          child: Row(
            children: [
              Icon(
                Icons.settings_rounded, 
                size: 20, 
                color: colorScheme.onBackground.withOpacity(0.6)
              ),
              const SizedBox(width: 12),
              Text(
                'Settings',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onBackground,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'signout',
          child: Row(
            children: [
              Icon(
                Icons.logout_rounded, 
                size: 20, 
                color: colorScheme.onBackground.withOpacity(0.6)
              ),
              const SizedBox(width: 12),
              Text(
                'Sign Out',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onBackground,
                ),
              ),
            ],
          ),
        ),
      ],
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.primary.withOpacity(0.1),
        ),
        child: Icon(
          Icons.person_rounded,
          color: colorScheme.primary,
          size: 20,
        ),
      ),
    );
  }

  void _showSignOutConfirmation() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Sign Out',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onBackground,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onBackground.withOpacity(0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: Text(
              'Sign Out',
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: colorScheme.surface,
      ),
    );
  }

  Widget _buildStatsSection(List<Event> events) {
    final uniqueEvents = <String, Event>{};
    for (var event in events) {
      uniqueEvents[event.id] = event;
    }
    final deduplicatedEvents = uniqueEvents.values.toList();
    
    final activeEvents = deduplicatedEvents.where((e) => e.status == EventStatus.approved && e.date.isAfter(DateTime.now())).length;
    final pendingEvents = deduplicatedEvents.where((e) => e.status == EventStatus.pending).length;
    final totalAttendees = deduplicatedEvents.fold<int>(0, (sum, event) => sum + (event.checkedInAttendees ?? 0));

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard('Active Events', activeEvents.toString(), Icons.event_available),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard('Pending', pendingEvents.toString(), Icons.pending_actions),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard('Total Attendees', totalAttendees.toString(), Icons.people_alt),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
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
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Left align column
          children: [
            // Icon on TOP (left aligned)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            
            // Number/text below the icon (right-aligned)
            Align(
              alignment: Alignment.centerRight, // Right align
              child: Text(
                value,
                style: textTheme.titleLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onBackground,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),
            
            // Label below the number (left-aligned)
            Text(
              title,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onBackground.withOpacity(0.65),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyEventsSection(List<Event> events) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final uniqueEvents = <String, Event>{};
    for (var event in events) {
      uniqueEvents[event.id] = event;
    }
    final deduplicatedEvents = uniqueEvents.values.toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'My Events', 
            style: textTheme.titleLarge?.copyWith(
              fontSize: 18, 
              fontWeight: FontWeight.bold, 
              color: colorScheme.onBackground
            ),
          ),
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
                  width: 80, // Width for filter dropdown
                  child: _buildFilterDropdown(deduplicatedEvents),
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
    );
  }

  Widget _buildFilterDropdown(List<Event> events) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final allCount = events.length;
    final activeCount = events.where((e) => e.status == EventStatus.approved && e.date.isAfter(DateTime.now())).length;
    final pendingCount = events.where((e) => e.status == EventStatus.pending).length;
    final completedCount = events.where((e) => e.status == EventStatus.approved && e.date.isBefore(DateTime.now())).length;
    final cancelledCount = events.where((e) => e.status == EventStatus.cancelled).length;

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
              'All ($allCount)',
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          DropdownMenuItem<String>(
            value: 'Active',
            child: Text(
              'Active ($activeCount)',
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          DropdownMenuItem<String>(
            value: 'Pending',
            child: Text(
              'Pending ($pendingCount)',
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          DropdownMenuItem<String>(
            value: 'Completed',
            child: Text(
              'Completed ($completedCount)',
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          DropdownMenuItem<String>(
            value: 'Cancelled',
            child: Text(
              'Cancelled ($cancelledCount)',
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

  List<Event> _filterEvents(List<Event> events) {
    final uniqueEvents = <String, Event>{};
    for (var event in events) {
      uniqueEvents[event.id] = event;
    }
    final deduplicatedEvents = uniqueEvents.values.toList();

    switch (_currentFilter) {
      case 'Active':
        return deduplicatedEvents.where((event) => event.status == EventStatus.approved && event.date.isAfter(DateTime.now())).toList();
      case 'Pending':
        return deduplicatedEvents.where((event) => event.status == EventStatus.pending).toList();
      case 'Completed':
        return deduplicatedEvents.where((event) => event.status == EventStatus.approved && event.date.isBefore(DateTime.now())).toList();
      case 'Cancelled':
        return deduplicatedEvents.where((event) => event.status == EventStatus.cancelled).toList();
      case 'All':
      default:
        return deduplicatedEvents;
    }
  }

  Widget _buildEventCard(Event event) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Determine status
    String statusText;
    Color statusColor;
    Color statusBgColor;
    
    switch (event.status) {
      case EventStatus.pending:
        statusText = 'Pending';
        statusColor = colorScheme.primary;
        statusBgColor = colorScheme.primary.withOpacity(0.08);
        break;
      case EventStatus.approved:
        if (event.date.isBefore(DateTime.now())) {
          statusText = 'Completed';
          statusColor = colorScheme.onBackground.withOpacity(0.7);
          statusBgColor = colorScheme.onSurface.withOpacity(0.08);
        } else {
          statusText = 'Active';
          statusColor = colorScheme.primary;
          statusBgColor = colorScheme.primary.withOpacity(0.08);
        }
        break;
      case EventStatus.rejected:
        statusText = 'Rejected';
        statusColor = Colors.red;
        statusBgColor = Colors.red.withOpacity(0.08);
        break;
      case EventStatus.cancelled:
        statusText = 'Cancelled';
        statusColor = Colors.grey;
        statusBgColor = Colors.grey.withOpacity(0.08);
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withOpacity(0.05), 
              blurRadius: 10, 
              offset: const Offset(0, 4)
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image Banner
            if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
              Container(
                width: double.infinity,
                height: 160,
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
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 48,
                          color: colorScheme.primary.withOpacity(0.5),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: colorScheme.primary,
                        ),
                      );
                    },
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  color: colorScheme.primary.withOpacity(0.08),
                ),
                child: Center(
                  child: Icon(
                    Icons.image,
                    size: 36,
                    color: colorScheme.primary.withOpacity(0.5),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusBgColor, 
                          borderRadius: BorderRadius.circular(20)
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${event.date.month}/${event.date.day}/${event.date.year} • ${event.startTime.format(context)}', 
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onBackground.withOpacity(0.65), 
                          fontSize: 12
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    event.title, 
                    style: textTheme.titleLarge?.copyWith(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold, 
                      color: colorScheme.onBackground
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description ?? 'No description',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onBackground.withOpacity(0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface, 
                      borderRadius: BorderRadius.circular(12)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatColumn('Registered', event.registeredAttendees?.toString() ?? '0'),
                              _buildVerticalDivider(),
                              _buildStatColumn('Checked In', event.checkedInAttendees?.toString() ?? '0'),
                              _buildVerticalDivider(),
                              _buildStatColumn('Capacity', event.capacity.toString()),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (event.status == EventStatus.approved && event.date.isAfter(DateTime.now())) ...[
                            LinearProgressIndicator(
                              value: (event.checkedInAttendees ?? 0) / event.capacity, 
                              backgroundColor: colorScheme.outline.withOpacity(0.3), 
                              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary), 
                              borderRadius: BorderRadius.circular(10)
                            ),
                            const SizedBox(height: 4),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '${(((event.checkedInAttendees ?? 0) / event.capacity) * 100).toStringAsFixed(1)}% capacity',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onBackground.withOpacity(0.65), 
                                  fontSize: 10
                                ),
                              ),
                            ),
                          ] else if (event.status == EventStatus.pending) ...[
                            LinearProgressIndicator(
                              value: (event.registeredAttendees ?? 0) / event.capacity, 
                              backgroundColor: colorScheme.outline.withOpacity(0.3), 
                              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary), 
                              borderRadius: BorderRadius.circular(10)
                            ),
                            const SizedBox(height: 4),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '${(((event.registeredAttendees ?? 0) / event.capacity) * 100).toStringAsFixed(1)}% registered', 
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onBackground.withOpacity(0.65), 
                                  fontSize: 10
                                ),
                              ),
                            ),
                          ] else if (event.status == EventStatus.approved && event.date.isBefore(DateTime.now())) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatColumn('Attended', event.checkedInAttendees?.toString() ?? '0'),
                                _buildVerticalDivider(),
                                _buildStatColumn('Revenue', '\$${(event.checkedInAttendees ?? 0) * (event.price ?? 25)}'),
                                _buildVerticalDivider(),
                                _buildStatColumn('Rating', '4.8/5'),
                              ],
                            ),
                          ] else if (event.status == EventStatus.cancelled) ...[
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    color: Colors.grey,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'This event has been cancelled',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Show different action buttons based on event status
                  if (event.status == EventStatus.pending) ...[
                    // PENDING EVENTS: Cancel button and status message in ONE ROW
                    Row(
                      children: [
                        // Cancel Event Button
                        Expanded(
                          child: _buildCancelButton(
                            'Cancel Event',
                            Icons.cancel,
                            onPressed: () => _cancelEvent(event),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Status message container
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colorScheme.outline.withOpacity(0.3),
                              ),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    color: colorScheme.onBackground.withOpacity(0.6),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'Awaiting',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onBackground.withOpacity(0.6),
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else if (event.status == EventStatus.approved && event.date.isAfter(DateTime.now())) ...[
                    // ACTIVE EVENTS: Show event management buttons (No Cancel button)
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton('Scan Ticket', Icons.qr_code_scanner, onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ManagerScanTicketPage()),
                            );
                          }),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton('View Details', Icons.info_outline, onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ManagerAttendanceReportPage()),
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton('Attendance Report', Icons.analytics, onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ManagerAttendanceReportPage()),
                            );
                          }),
                        ),
                      ],
                    ),
                  ] else if (event.status == EventStatus.approved && event.date.isBefore(DateTime.now())) ...[
                    // COMPLETED EVENTS: Show report button only
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ManagerAttendanceReportPage()),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'View Detailed Report',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ] else if (event.status == EventStatus.cancelled) ...[
                    // CANCELLED EVENTS: Show cancellation info
                    Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cancel,
                              color: Colors.grey,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Event Cancelled',
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else if (event.status == EventStatus.rejected) ...[
                    // REJECTED EVENTS: Show rejection info
                    Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.3),
                        ),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.block,
                              color: Colors.red,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Event Rejected by Admin',
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelButton(String text, IconData icon, {VoidCallback? onPressed}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onPressed ?? () {},
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.red.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.red,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      children: [
        Text(
          value, 
          style: textTheme.bodyLarge?.copyWith(
            fontSize: 16, 
            fontWeight: FontWeight.bold, 
            color: colorScheme.onBackground
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label, 
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onBackground.withOpacity(0.65), 
            fontSize: 12
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 1, 
      height: 30, 
      color: colorScheme.outline.withOpacity(0.3)
    );
  }

  Widget _buildActionButton(String text, IconData icon, {VoidCallback? onPressed}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onPressed ?? () {},
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: colorScheme.primary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}