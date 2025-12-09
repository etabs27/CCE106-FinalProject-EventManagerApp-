import 'package:flutter/material.dart';
import 'package:event_manager_application_finalproject/theme.dart';

class ManagersDesign extends StatefulWidget {
  const ManagersDesign({super.key});

  @override
  State<ManagersDesign> createState() => _ManagersDesignState();
}

class _ManagersDesignState extends State<ManagersDesign> {
  String _currentFilter = 'All (24)';
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
          'Managers',
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
            // Filter button row placed below AppBar - RIGHT ALIGNED
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
            
            // Search Bar
            _buildSearchBar(context),
            
            // Managers List
            Expanded(
              child: _buildManagersList(context),
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
            value: 'All (24)',
            child: Text(
              'All (24)',
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          DropdownMenuItem<String>(
            value: 'Active (22)',
            child: Text(
              'Active (22)',
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          DropdownMenuItem<String>(
            value: 'Restricted (2)',
            child: Text(
              'Restricted (2)',
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
          decoration: InputDecoration(
            hintText: 'Search...',
            prefixIcon: Icon(
              Icons.search_rounded,
              color: colorScheme.onBackground.withOpacity(0.6),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildManagersList(BuildContext context) {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        _ManagerCard(
          name: 'Sarah Johnson',
          email: 'sarahj@eventhub.com',
          status: 'Active',
          eventsCount: '15 events',
          isRestricted: false,
        ),
        const SizedBox(height: 12),
        _ManagerCard(
          name: 'Mike Chen',
          email: 'mike.c@eventhub.com',
          status: 'Active',
          eventsCount: '8 events',
          isRestricted: false,
        ),
        const SizedBox(height: 12),
        _ManagerCard(
          name: 'Lisa Rodriguez',
          email: 'lisa.r@eventhub.com',
          status: 'Restricted',
          eventsCount: '3 events',
          isRestricted: true,
        ),
        // Add more items for scrolling
        _ManagerCard(
          name: 'David Wilson',
          email: 'david.w@eventhub.com',
          status: 'Active',
          eventsCount: '10 events',
          isRestricted: false,
        ),
        const SizedBox(height: 12),
        _ManagerCard(
          name: 'Emily Brown',
          email: 'emily.b@eventhub.com',
          status: 'Active',
          eventsCount: '6 events',
          isRestricted: false,
        ),
        const SizedBox(height: 12),
        _ManagerCard(
          name: 'John Smith',
          email: 'john.s@eventhub.com',
          status: 'Restricted',
          eventsCount: '2 events',
          isRestricted: true,
        ),
      ],
    );
  }
}

class _ManagerCard extends StatelessWidget {
  final String name;
  final String email;
  final String status;
  final String eventsCount;
  final bool isRestricted;

  const _ManagerCard({
    required this.name,
    required this.email,
    required this.status,
    required this.eventsCount,
    required this.isRestricted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Manager Info Row
            Row(
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getStatusColor(colorScheme).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: _getStatusColor(colorScheme),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Manager Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onBackground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(
                          color: colorScheme.onBackground.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(colorScheme).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: _getStatusColor(colorScheme),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            eventsCount,
                            style: TextStyle(
                              color: colorScheme.onBackground.withOpacity(0.6),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Action Buttons (only for active managers)
            if (!isRestricted) ...[
              const SizedBox(height: 16),
              Container(
                height: 1,
                color: colorScheme.outline.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildActionButton('View', Icons.visibility_rounded, colorScheme),
                  const SizedBox(width: 12),
                  _buildActionButton('Edit', Icons.edit_rounded, colorScheme),
                  const SizedBox(width: 12),
                  _buildActionButton('Suspend', Icons.pause_circle_rounded, colorScheme),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, ColorScheme colorScheme) {
    return Expanded(
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: colorScheme.primary,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ColorScheme colorScheme) {
    if (isRestricted) {
      return colorScheme.error;
    }
    return colorScheme.primary;
  }
}