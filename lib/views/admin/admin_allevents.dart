import 'package:flutter/material.dart';
import 'package:event_manager_application_finalproject/theme.dart';
import 'package:event_manager_application_finalproject/event_service.dart';
import 'package:event_manager_application_finalproject/models/event.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class AllEventsDesign extends StatefulWidget {
  const AllEventsDesign({super.key});

  @override
  State<AllEventsDesign> createState() => _AllEventsDesignState();
}

class _AllEventsDesignState extends State<AllEventsDesign> {
  String _currentFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _searchDebounceTimer;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    // Add listener to the text controller
    _searchController.addListener(() {
      _onSearchChanged();
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _searchController.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    // Cancel any previous timer
    _searchDebounceTimer?.cancel();
    
    // Create a new timer
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!_isDisposed) {
        setState(() {
          _searchQuery = _searchController.text.trim().toLowerCase();
          print('Search query updated: "$_searchQuery"');
        });
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _searchDebounceTimer?.cancel(); // Cancel any pending timer
    if (!_isDisposed) {
      setState(() {
        _searchQuery = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'All Events',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onBackground,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: colorScheme.onBackground,
      ),
      body: StreamBuilder<List<Event>>(
        stream: EventService.getAllEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final events = snapshot.data ?? [];
          
          return Column(
            children: [
              // Filter button row placed below AppBar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Filter Button
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
                            width: 70,
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
              
              // Search Bar
              _buildSearchBar(context),
              
              // Events List
              Expanded(
                child: _buildEventsList(context, events),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterDropdown(List<Event> events) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Apply search filter first, then count
    final filteredEvents = _filterEvents(events, _searchQuery);
    final totalCount = filteredEvents.length;
    final activeCount = filteredEvents.where((event) => event.status == EventStatus.approved && event.date.isAfter(DateTime.now())).length;
    final pendingCount = filteredEvents.where((event) => event.status == EventStatus.pending).length;
    final completedCount = filteredEvents.where((event) => event.status == EventStatus.approved && event.date.isBefore(DateTime.now())).length;
    final cancelledCount = filteredEvents.where((event) => event.status == EventStatus.cancelled).length;

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

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      color: theme.scaffoldBackgroundColor,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search events by title, manager, category, venue, or description...',
            prefixIcon: Icon(
              Icons.search_rounded, 
              color: colorScheme.onBackground.withOpacity(0.6)
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      color: colorScheme.onBackground.withOpacity(0.6),
                    ),
                    onPressed: _clearSearch,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ),
    );
  }

Widget _buildEventsList(BuildContext context, List<Event> events) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  
  // Apply search filter
  List<Event> filteredEvents = _filterEvents(events, _searchQuery);
  
  // Filter events based on current filter
  if (_currentFilter == 'Active') {
    filteredEvents = filteredEvents.where((event) => 
      event.status == EventStatus.approved && 
      event.date.isAfter(DateTime.now())
    ).toList();
  } else if (_currentFilter == 'Pending') {
    filteredEvents = filteredEvents.where((event) => event.status == EventStatus.pending).toList();
  } else if (_currentFilter == 'Completed') {
    filteredEvents = filteredEvents.where((event) => 
      event.status == EventStatus.approved && 
      event.date.isBefore(DateTime.now())
    ).toList();
  } else if (_currentFilter == 'Cancelled') {
    filteredEvents = filteredEvents.where((event) => event.status == EventStatus.cancelled).toList();
  }
  
  if (filteredEvents.isEmpty) {
    String message;
    if (_searchQuery.isNotEmpty) {
      message = _currentFilter != 'All' 
          ? 'No ${_currentFilter.toLowerCase()} events found for "$_searchQuery"'
          : 'No events found for "$_searchQuery"';
    } else {
      message = 'No ${_currentFilter.toLowerCase()} events';
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.filter_list_off,
            size: 64,
            color: theme.colorScheme.onBackground.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: theme.colorScheme.onBackground.withOpacity(0.6),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: TextButton(
                onPressed: _clearSearch,
                child: Text('Clear search'),
              ),
            ),
        ],
      ),
    );
  }
  
  // Create header if search query is not empty
  Widget? header;
  if (_searchQuery.isNotEmpty) {
    header = Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Text(
        'Found ${filteredEvents.length} ${filteredEvents.length == 1 ? 'event' : 'events'} for "$_searchQuery"',
        style: TextStyle(
          color: colorScheme.onBackground.withOpacity(0.6),
          fontSize: 14,
        ),
      ),
    );
  }
  
  // Return a ListView that includes both header and event cards
  return ListView(
    children: [
      if (header != null) header,
      ...filteredEvents.map((event) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: event == filteredEvents.last ? 20 : 16,
          ),
          child: _EventCardStream(
            event: event,
          ),
        );
      }).toList(),
    ],
  );
}
  // Helper method to filter events by search query
  List<Event> _filterEvents(List<Event> events, String query) {
    if (query.isEmpty) return events;

    final filtered = events.where((event) {
      final title = event.title.toLowerCase();
      final managerEmail = event.managerEmail.toLowerCase();
      final category = event.category.toLowerCase();
      final description = event.description?.toLowerCase() ?? '';
      final venue = event.venue?.toLowerCase() ?? '';

      final matches = title.contains(query) ||
             managerEmail.contains(query) ||
             category.contains(query) ||
             description.contains(query) ||
             venue.contains(query);

      return matches;
    }).toList();

    return filtered;
  }
}

class _EventCardStream extends StatelessWidget {
  final Event event;

  const _EventCardStream({
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Determine status text and color
    String statusText;
    Color statusColor;
    bool isPending = false;
    
    switch (event.status) {
      case EventStatus.pending:
        statusText = 'Pending';
        statusColor = Colors.orange;
        isPending = true;
        break;
      case EventStatus.approved:
        statusText = event.date.isBefore(DateTime.now()) ? 'Completed' : 'Active';
        statusColor = event.date.isBefore(DateTime.now()) ? Colors.green : colorScheme.primary;
        break;
      case EventStatus.rejected:
        statusText = 'Rejected';
        statusColor = Colors.red;
        break;
      case EventStatus.cancelled:
        statusText = 'Cancelled';
        statusColor = Colors.grey;
        break;
      default:
        statusText = 'Unknown';
        statusColor = Colors.grey;
    }

    final dateFormat = DateFormat('MMM dd, yyyy - hh:mm a');
    final formattedDate = dateFormat.format(DateTime(
      event.date.year,
      event.date.month,
      event.date.day,
      event.startTime?.hour ?? 0,
      event.startTime?.minute ?? 0,
    ));

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
          // Status Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: statusColor.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    event.category,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Event Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Title and Date
                Column(
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
                      formattedDate,
                      style: TextStyle(
                        color: colorScheme.onBackground.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manager: ${event.managerEmail}',
                      style: TextStyle(
                        color: colorScheme.onBackground.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Stats
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  child: isPending 
                      ? _buildPendingStats(context, event)
                      : _buildActiveStats(context, event),
                ),
                
                const SizedBox(height: 20),
                
                // Action Button
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusColor.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isPending ? Icons.reviews_rounded : Icons.visibility_rounded,
                        color: statusColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isPending ? 'Review Event' : 'View Details',
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveStats(BuildContext context, Event event) {
    final colorScheme = Theme.of(context).colorScheme;
    final registeredCount = event.registeredAttendees ?? 0;
    final checkedInCount = event.checkedInAttendees ?? 0;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Registered',
              style: TextStyle(
                color: colorScheme.onBackground.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
            Text(
              'Checked In',
              style: TextStyle(
                color: colorScheme.onBackground.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$registeredCount / ${event.capacity}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colorScheme.onBackground,
              ),
            ),
            Text(
              '$checkedInCount checked in',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colorScheme.onBackground,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Progress Bar
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
            color: colorScheme.outline.withOpacity(0.3),
            borderRadius: BorderRadius.circular(3),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final percentage = event.capacity > 0 ? registeredCount / event.capacity : 0;
              final filledWidth = constraints.maxWidth * percentage;
              return Stack(
                children: [
                  Container(
                    width: filledWidth,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPendingStats(BuildContext context, Event event) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Capacity',
              style: TextStyle(
                color: colorScheme.onBackground.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
            Text(
              'Status',
              style: TextStyle(
                color: colorScheme.onBackground.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${event.capacity} max capacity',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colorScheme.onBackground,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Text(
                'Awaiting Approval',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}