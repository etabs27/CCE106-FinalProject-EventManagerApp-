import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  Stream<List<Event>>? _pendingEventsStream;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _initializeStream();
  }

  void _initializeStream() {
    try {
      _pendingEventsStream = EventService.getPendingEvents();
    } catch (e) {
      // Handle initialization error
      print('Error initializing stream: $e');
      // Create an empty stream to prevent errors
      _pendingEventsStream = Stream.value([]);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // AppBar fade effect: from white → scaffold background
    const double scrollThreshold = 50.0;
    const double maxScroll = 150.0;

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
        // Adds subtle shadow when scrolled (like in AllEvents page)
        scrolledUnderElevation: 4.0,
        shadowColor: colorScheme.onSurface.withOpacity(0.1),
      ),
      body: _pendingEventsStream == null
          ? _buildLoadingState(context)
          : StreamBuilder<List<Event>>(
              stream: _pendingEventsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState(context);
                }

                if (snapshot.hasError) {
                  return _buildErrorState(context, snapshot.error.toString());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildNoPendingEventsState(context);
                }

                // Events are already pending from the stream
                final pendingEvents = snapshot.data!;

                return Column(
                  children: [
                    // Filter button row - Fixed position at top
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      color: theme.scaffoldBackgroundColor,
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
                                  child: _buildFilterDropdown(pendingEvents),
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

                    // Header with stats - Fixed position below filter
                    _buildHeaderStats(context, pendingEvents),

                    // Scrollable events list - ALWAYS SCROLLABLE
                    Expanded(
                      child: _buildScrollableEventsList(context, pendingEvents),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildScrollableEventsList(BuildContext context, List<Event> pendingEvents) {
    return Scrollbar(
      controller: _scrollController,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final filteredEvents = _getFilteredEvents(pendingEvents);
                
                if (filteredEvents.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 80),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 64, color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text('No ${_currentFilter.toLowerCase()} events',
                            style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6))),
                      ],
                    ),
                  );
                }
                
                final event = filteredEvents[index];
                final daysLeft = event.date.difference(DateTime.now()).inDays;
                final isUrgent = daysLeft <= 3;

                return Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: index == filteredEvents.length - 1 ? 20 : 16,
                  ),
                  child: _EventCard(
                    event: event,
                    isUrgent: isUrgent,
                    daysLeft: daysLeft,
                    onApprove: () => _approveEvent(event.id),
                    onReject: () => _rejectEvent(event.id),
                  ),
                );
              },
              childCount: _getFilteredEvents(pendingEvents).isEmpty ? 1 : _getFilteredEvents(pendingEvents).length,
            ),
          ),
        ],
      ),
    );
  }

  List<Event> _getFilteredEvents(List<Event> events) {
    List<Event> filteredEvents = events;
    if (_currentFilter == 'Urgent') {
      filteredEvents = events.where((e) => e.date.difference(DateTime.now()).inDays <= 3).toList();
    } else if (_currentFilter == 'Today') {
      final now = DateTime.now();
      filteredEvents = events.where((e) => e.date.day == now.day && e.date.month == now.month && e.date.year == now.year).toList();
    }
    return filteredEvents;
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 20),
            const Text('Error Loading Events', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(error, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _initializeStream();
                });
              }, 
              child: const Text('Retry')
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return const Center(
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

  Widget _buildNoPendingEventsState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available_rounded, 
                size: 64, 
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text('No pending events',
                style: TextStyle(
                  fontSize: 18, 
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6)
                )),
            const SizedBox(height: 8),
            Text('All events have been reviewed',
                style: TextStyle(
                  fontSize: 14, 
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5)
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(List<Event> events) {
    final colorScheme = Theme.of(context).colorScheme;

    final allCount = events.length;
    final urgentCount = events.where((e) => e.date.difference(DateTime.now()).inDays <= 3).length;
    final todayCount = events.where((e) =>
        e.date.day == DateTime.now().day &&
        e.date.month == DateTime.now().month &&
        e.date.year == DateTime.now().year).length;

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _currentFilter,
        icon: const SizedBox.shrink(),
        isDense: true,
        isExpanded: true,
        style: TextStyle(color: colorScheme.primary, fontSize: 12, fontWeight: FontWeight.w600),
        dropdownColor: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        items: [
          DropdownMenuItem(
            value: 'All', 
            child: Text('All ($allCount)', style: TextStyle(color: colorScheme.primary, fontSize: 12, fontWeight: FontWeight.w600))
          ),
          DropdownMenuItem(
            value: 'Urgent', 
            child: Text('Urgent ($urgentCount)', style: TextStyle(color: colorScheme.primary, fontSize: 12, fontWeight: FontWeight.w600))
          ),
          DropdownMenuItem(
            value: 'Today', 
            child: Text('Today ($todayCount)', style: TextStyle(color: colorScheme.primary, fontSize: 12, fontWeight: FontWeight.w600))
          ),
        ],
        onChanged: (value) {
          if (value != null) setState(() => _currentFilter = value);
        },
      ),
    );
  }

  Widget _buildHeaderStats(BuildContext context, List<Event> events) {
    final colorScheme = Theme.of(context).colorScheme;
    final pendingCount = events.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.05), 
            blurRadius: 8, 
            offset: const Offset(0, 2)
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review pending events',
              style: TextStyle(fontSize: 16, color: colorScheme.onBackground.withOpacity(0.6), fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(color: colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.pending_actions_rounded, color: colorScheme.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$pendingCount Pending',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: colorScheme.primary)),
                    Text('Events awaiting review',
                        style: TextStyle(color: colorScheme.primary.withOpacity(0.8), fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _approveEvent(String eventId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await EventService.approveEvent(eventId, user.email!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event approved successfully'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to approve event: $e'), backgroundColor: Colors.red),
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
          const SnackBar(content: Text('Event rejected'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reject event: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

// _EventCard and its helper methods remain 100% unchanged below
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
          if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                color: colorScheme.primary.withOpacity(0.1),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                child: Image.network(
                  event.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(child: Icon(Icons.image_not_supported, size: 48, color: colorScheme.primary.withOpacity(0.5))),
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Center(child: CircularProgressIndicator(color: colorScheme.primary));
                  },
                ),
              ),
            ),

          if (isUrgent) _buildUrgentHeader(context),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(event.title,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: colorScheme.onBackground)),
                          const SizedBox(height: 4),
                          Text('${_formatDate(event.date)}${_hasTimeInfo() ? ' • ${_formatTimeRange()}' : ''}',
                              style: TextStyle(color: colorScheme.onBackground.withOpacity(0.6), fontSize: 14)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
                      ),
                      child: Text('New',
                          style: TextStyle(color: colorScheme.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(height: 1, color: colorScheme.outline.withOpacity(0.3)),
                const SizedBox(height: 16),
                _buildDetailRow(context, 'Event Manager', event.managerEmail.split('@')[0]),
                const SizedBox(height: 12),
                if (event.capacity != null && event.capacity! > 0)
                  _buildDetailRow(context, 'Capacity', '${event.capacity} attendees'),
                if (event.capacity != null && event.capacity! > 0) const SizedBox(height: 12),
                _buildDetailRow(context, 'Submitted', _formatSubmittedTime(event.submittedAt)),
                const SizedBox(height: 20),

                if (daysLeft > 0)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.watch_later_rounded, color: colorScheme.primary, size: 18),
                        const SizedBox(width: 8),
                        Text('Event starts in $daysLeft days',
                            style: TextStyle(color: colorScheme.primary, fontSize: 14, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                if (daysLeft > 0) const SizedBox(height: 20),

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
                            Icon(Icons.check_circle_rounded, size: 20),
                            SizedBox(width: 8),
                            Text('Approve', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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
                            Icon(Icons.cancel_rounded, size: 20),
                            SizedBox(width: 8),
                            Text('Reject', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.error.withOpacity(0.06),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        border: Border.all(color: colorScheme.error.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: colorScheme.error, size: 18),
          const SizedBox(width: 8),
          Text('URGENT', style: TextStyle(color: colorScheme.error, fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          Expanded(
            child: Text('Must review today',
                style: TextStyle(color: colorScheme.error, fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(label,
              style: TextStyle(color: colorScheme.onBackground.withOpacity(0.6), fontSize: 14, fontWeight: FontWeight.w500)),
        ),
        Text(value, style: TextStyle(color: colorScheme.onBackground, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  String _formatSubmittedTime(DateTime submittedAt) {
    final difference = DateTime.now().difference(submittedAt);
    if (difference.inDays > 0) return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    if (difference.inHours > 0) return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    return 'Just now';
  }

  bool _hasTimeInfo() => event.startTime != null && event.endTime != null;

  String _formatTimeRange() => '${_formatTime(event.startTime!)} - ${_formatTime(event.endTime!)}';
}