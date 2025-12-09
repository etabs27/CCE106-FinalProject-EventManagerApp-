import 'package:flutter/material.dart';
import 'package:event_manager_application_finalproject/theme.dart';

class AllEventsDesign extends StatefulWidget {
  const AllEventsDesign({super.key});

  @override
  State<AllEventsDesign> createState() => _AllEventsDesignState();
}

class _AllEventsDesignState extends State<AllEventsDesign> {
  String _currentFilter = 'All (150)';
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
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
          'All Events',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onBackground,
          ),
        ),
        backgroundColor: appBarColor,
        elevation: 0,
        foregroundColor: colorScheme.onBackground,
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
        child: Column(
          children: [
            // Filter button row placed below AppBar
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
                          width: 70,
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
            
            // Search Bar
            _buildSearchBar(context),
            
            // Events List
            Expanded(
              child: _buildEventsList(context),
            ),
          ],
        ),
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
            value: 'All (150)',
            child: Text(
              'All (150)',
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          DropdownMenuItem<String>(
            value: 'Active (82)',
            child: Text(
              'Active (82)',
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          DropdownMenuItem<String>(
            value: 'Pending (7)',
            child: Text(
              'Pending (7)',
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
              'Completed',
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
      padding: const EdgeInsets.all(20),
      color: theme.scaffoldBackgroundColor,
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

  Widget _buildEventsList(BuildContext context) {
    return ListView(
      controller: _scrollController,
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
        // Add more items for scrolling
        _EventCard(
          status: 'Active',
          category: 'Art',
          title: 'Art Exhibition',
          date: 'Dec 28, 2024 - 10:00 AM',
          managerName: 'Lisa Rodriguez',
          registeredCount: '500',
          totalCapacity: '800',
          checkedInCount: '320',
          isPending: false,
        ),
        const SizedBox(height: 16),
        _EventCard(
          status: 'Completed',
          category: 'Food',
          title: 'Food Festival',
          date: 'Nov 15, 2024 - 11:00 AM',
          managerName: 'Alex Chen',
          registeredCount: '1,200',
          totalCapacity: '1,500',
          checkedInCount: '1,150',
          isPending: false,
        ),
        const SizedBox(height: 16),
        _EventCard(
          status: 'Pending',
          category: 'Education',
          title: 'Tech Workshop',
          date: 'Jan 10, 2025 - 2:00 PM',
          managerName: 'David Kim',
          registeredCount: '150',
          totalCapacity: '300',
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
    );
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