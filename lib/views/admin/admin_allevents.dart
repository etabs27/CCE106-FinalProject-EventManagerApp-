import 'package:flutter/material.dart';
import 'package:event_manager_application_finalproject/theme.dart';

class AllEventsDesign extends StatelessWidget {
  const AllEventsDesign({super.key});

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
        backgroundColor: colorScheme.surface,
        elevation: 0,
        foregroundColor: colorScheme.onBackground,
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list_rounded, 
              color: colorScheme.onBackground.withOpacity(0.6)
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(context),
          
          // Filter Tabs
          _buildFilterTabs(context),
          
          // Events List
          Expanded(
            child: _buildEventsList(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: colorScheme.primary,
        child: Icon(
          Icons.add_rounded, 
          color: colorScheme.onPrimary, 
          size: 24
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      color: colorScheme.surface,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search events...',
            prefixIcon: Icon(
              Icons.search_rounded, 
              color: colorScheme.onBackground.withOpacity(0.6)
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: colorScheme.surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterTab(context, 'All (150)', true),
            const SizedBox(width: 12),
            _buildFilterTab(context, 'Active (82)', false),
            const SizedBox(width: 12),
            _buildFilterTab(context, 'Pending (7)', false),
            const SizedBox(width: 12),
            _buildFilterTab(context, 'Completed', false),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(BuildContext context, String label, bool active) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: active ? colorScheme.primary.withOpacity(0.06) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? colorScheme.primary.withOpacity(0.2) : colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? colorScheme.primary : colorScheme.onBackground.withOpacity(0.7),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEventsList(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Active Event
        _EventCard(
          status: 'Active',
          category: 'Music',
          title: 'Summer Music Festival',
          date: 'Dec 20, 2024 - 6:00 PM',
          managerName: 'Sarah Johnson',
          registeredCount: '1,234',
          totalCapacity: '2,000',
          checkedInCount: '856',
          isPending: false,
        ),
        const SizedBox(height: 16),
        
        // Pending Event
        _EventCard(
          status: 'Pending',
          category: 'Tech',
          title: 'Tech Conference 2024',
          date: 'Dec 25, 2024 - 9:00 AM',
          managerName: 'Mike Chen',
          registeredCount: '850',
          totalCapacity: '1,000',
          checkedInCount: null,
          isPending: true,
        ),
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  final String status;
  final String category;
  final String title;
  final String date;
  final String managerName;
  final String registeredCount;
  final String totalCapacity;
  final String? checkedInCount;
  final bool isPending;

  const _EventCard({
    required this.status,
    required this.category,
    required this.title,
    required this.date,
    required this.managerName,
    required this.registeredCount,
    required this.totalCapacity,
    this.checkedInCount,
    required this.isPending,
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
          // Status Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
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
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: colorScheme.onPrimary,
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
                      color: colorScheme.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: colorScheme.primary,
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
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: TextStyle(
                        color: colorScheme.onBackground.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manager: $managerName',
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
                      ? _buildPendingStats(colorScheme)
                      : _buildActiveStats(colorScheme),
                ),
                
                const SizedBox(height: 20),
                
                // Action Button
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isPending ? Icons.reviews_rounded : Icons.visibility_rounded,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isPending ? 'Review Event' : 'View Details',
                        style: TextStyle(
                          color: colorScheme.primary,
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
    ); // ← ADDED THIS CLOSING BRACE
  }

  Widget _buildActiveStats(ColorScheme colorScheme) {
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
              '$registeredCount / $totalCapacity',
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
          child: Row(
            children: [
              Expanded(
                flex: int.parse(registeredCount.replaceAll(',', '')),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              Expanded(
                flex: int.parse(totalCapacity.replaceAll(',', '')) - 
                      int.parse(registeredCount.replaceAll(',', '')),
                child: const SizedBox(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPendingStats(ColorScheme colorScheme) {
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
              '$registeredCount / $totalCapacity',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colorScheme.onBackground,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
              ),
              child: Text(
                'Awaiting Approval',
                style: TextStyle(
                  color: colorScheme.primary,
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