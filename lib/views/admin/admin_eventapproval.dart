import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this import
import 'package:event_manager_application_finalproject/theme.dart';
import 'package:event_manager_application_finalproject/models/event.dart';
import 'package:event_manager_application_finalproject/event_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventApprovalsDesign extends StatefulWidget {
  const EventApprovalsDesign({super.key});

  @override
  State<EventApprovalsDesign> createState() => _EventApprovalsDesignState();
}

class _EventApprovalsDesignState extends State<EventApprovalsDesign> {
  String _currentFilter = 'All';
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Add debugging when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _runDebugChecks();
    });
  }

  Future<void> _runDebugChecks() async {
    print('🛠️ ADMIN DASHBOARD DEBUGGING...');
    
    // 1. Check event status values
    await EventService.checkEventStatusValues();
    
    // 2. Test event parsing
    await EventService.testEventParsing();
    
    // 3. Simple test query
    await EventService.simpleTest();
    
    // 4. Get event counts
    final counts = await EventService.getEventCounts();
    print('📊 Pending events count: ${counts['pending']}');
    
    print('🛠️ DEBUGGING COMPLETE');
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.hasClients 
          ? _scrollController.offset 
          : 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Calculate background color based on scroll position
    final double scrollThreshold = 50.0;
    final double maxScroll = 150.0;
    
    double opacity = 0.0;
    if (_scrollOffset > scrollThreshold) {
      opacity = ((_scrollOffset - scrollThreshold) / maxScroll).clamp(0.0, 1.0);
    }

    final appBarColor = Color.lerp(
      Colors.white,
      theme.scaffoldBackgroundColor,
      opacity,
    )!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Event Approvals',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onBackground,
          ),
        ),
        backgroundColor: appBarColor,
        elevation: 0,
        foregroundColor: colorScheme.onBackground,
        actions: [
          // Debug button in app bar
          IconButton(
            icon: Icon(Icons.bug_report),
            onPressed: () async {
              await _runDebugChecks();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Debug checks completed. Check console.')),
              );
            },
          ),
        ],
      ),
      body: NotificationListener<ScrollUpdateNotification>(
        onNotification: (notification) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              setState(() {
                _scrollOffset = _scrollController.offset;
              });
            }
          });
          return false;
        },
        child: StreamBuilder<List<Event>>(
          stream: EventService.getPendingEvents(),
          builder: (context, snapshot) {
            // Debug stream state
            print('🔄 StreamBuilder state:');
            print('  - Connection state: ${snapshot.connectionState}');
            print('  - Has data: ${snapshot.hasData}');
            print('  - Has error: ${snapshot.hasError}');
            print('  - Error: ${snapshot.error}');
            
            if (snapshot.hasError) {
              print('❌ ERROR fetching pending events: ${snapshot.error}');
              return _buildErrorState(context, snapshot.error.toString());
            }
            
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState(context);
            }
            
            final events = snapshot.data ?? [];
            
            if (snapshot.hasData) {
              print('✅ ADMIN: Received ${events.length} pending events');
              for (var event in events) {
                print('  - ${event.id}: ${event.title} by ${event.managerEmail}');
                print('    Date: ${event.date}');
                print('    Status: ${event.status}');
                print('    Has startTime: ${event.startTime != null}');
                print('    Has endTime: ${event.endTime != null}');
                print('    Has capacity: ${event.capacity != null}');
              }
            }
            
            return Column(
              children: [
                // Filter button row
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
                              width: 60,
                              child: _buildFilterDropdown(events),
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
                
                // Header with stats
                _buildHeaderStats(context, events),
                
                // Events List with ScrollController
                Expanded(
                  child: _buildEventsList(context, events),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 20),
            Text(
              'Error Loading Events',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {}); // Retry
              },
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text('Loading pending events...'),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(List<Event> events) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final allCount = events.length;
    final urgentCount = events.where((event) => event.date.difference(DateTime.now()).inDays <= 3).length;
    final todayCount = events.where((event) => event.date.day == DateTime.now().day && event.date.month == DateTime.now().month && event.date.year == DateTime.now().year).length;

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
            value: 'Urgent',
            child: Text(
              'Urgent ($urgentCount)',
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          DropdownMenuItem<String>(
            value: 'Today',
            child: Text(
              'Today ($todayCount)',
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

  Widget _buildHeaderStats(BuildContext context, List<Event> events) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final pendingCount = events.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review pending events',
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onBackground.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.pending_actions_rounded,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$pendingCount Pending',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                    Text(
                      'Events awaiting review',
                      style: TextStyle(
                        color: colorScheme.primary.withOpacity(0.8),
                        fontSize: 14,
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

  Widget _buildEventsList(BuildContext context, List<Event> events) {
    // Filter events based on current filter
    List<Event> filteredEvents = events;
    if (_currentFilter == 'Urgent') {
      filteredEvents = events.where((event) => event.date.difference(DateTime.now()).inDays <= 3).toList();
    } else if (_currentFilter == 'Today') {
      filteredEvents = events.where((event) => event.date.day == DateTime.now().day && event.date.month == DateTime.now().month && event.date.year == DateTime.now().year).toList();
    }

    if (filteredEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No ${_currentFilter.toLowerCase()} events',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      itemCount: filteredEvents.length,
      itemBuilder: (context, index) {
        final event = filteredEvents[index];
        final daysLeft = event.date.difference(DateTime.now()).inDays;
        final isUrgent = daysLeft <= 3;

        return Column(
          children: [
            _EventCard(
              event: event, 
              isUrgent: isUrgent, 
              daysLeft: daysLeft,
              onApprove: () => _approveEvent(event.id),
              onReject: () => _rejectEvent(event.id),
            ),
            if (index < filteredEvents.length - 1) const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Future<void> _approveEvent(String eventId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await EventService.approveEvent(eventId, user.email!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event approved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to approve event: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectEvent(String eventId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await EventService.rejectEvent(eventId, user.email!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event rejected'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reject event: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _EventCard extends StatelessWidget {
  final Event event;
  final bool isUrgent;
  final int daysLeft;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _EventCard({
    required this.event,
    required this.isUrgent,
    required this.daysLeft,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with urgent badge
          if (isUrgent) _buildUrgentHeader(context),
          
          // Event Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Title and Date
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onBackground,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_formatDate(event.date)}${_hasTimeInfo() ? ' • ${_formatTimeRange()}' : ''}',
                            style: TextStyle(
                              color: colorScheme.onBackground.withOpacity(0.6),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        'New',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Divider
                Container(
                  height: 1,
                  color: colorScheme.outline.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                
                // Event Details
                _buildDetailRow(context, 'Event Manager', event.managerEmail.split('@')[0]),
                const SizedBox(height: 12),
                
                // Only show capacity if it exists
                if (event.capacity != null && event.capacity! > 0)
                  _buildDetailRow(context, 'Capacity', '${event.capacity} attendees'),
                if (event.capacity != null && event.capacity! > 0)
                  const SizedBox(height: 12),
                
                _buildDetailRow(context, 'Submitted', _formatSubmittedTime(event.submittedAt)),
                const SizedBox(height: 20),
                
                // Days Left Warning - only show if date is in future
                if (daysLeft > 0)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.watch_later_rounded,
                          color: colorScheme.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Event starts in $daysLeft days',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (daysLeft > 0) const SizedBox(height: 20),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onApprove,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary.withOpacity(0.06),
                          foregroundColor: colorScheme.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: colorScheme.primary.withOpacity(0.2)),
                          ),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Approve',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onReject,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.error.withOpacity(0.06),
                          foregroundColor: colorScheme.error,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: colorScheme.error.withOpacity(0.2)),
                          ),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cancel_rounded,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Reject',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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

  Widget _buildUrgentHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.error.withOpacity(0.06),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border.all(color: colorScheme.error.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: colorScheme.error,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            'URGENT',
            style: TextStyle(
              color: colorScheme.error,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Must review today',
              style: TextStyle(
                color: colorScheme.error,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              color: colorScheme.onBackground.withOpacity(0.6),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: colorScheme.onBackground,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    // Simple date formatting without intl package
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  String _formatSubmittedTime(DateTime submittedAt) {
    final now = DateTime.now();
    final difference = now.difference(submittedAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // Helper methods
  bool _hasTimeInfo() {
    return event.startTime != null && event.endTime != null;
  }

  String _formatTimeRange() {
    if (!_hasTimeInfo()) return '';
    return '${_formatTime(event.startTime!)} - ${_formatTime(event.endTime!)}';
  }
}