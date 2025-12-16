import 'package:flutter/material.dart';
import 'package:event_manager_application_finalproject/theme.dart';
import 'package:event_manager_application_finalproject/user_service.dart';
import 'package:event_manager_application_finalproject/event_service.dart';
import 'package:event_manager_application_finalproject/models/event.dart';

class ManagersDesign extends StatefulWidget {
  const ManagersDesign({super.key});

  @override
  State<ManagersDesign> createState() => _ManagersDesignState();
}

class _ManagersDesignState extends State<ManagersDesign> {
  String _currentFilter = 'All';
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.hasClients 
          ? _scrollController.offset 
          : 0.0;
    });
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
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
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: UserService.getAllManagers(),
                    builder: (context, snapshot) {
                      final managers = snapshot.data ?? [];
                      
                      // Apply search filter first, then count
                      final filteredManagers = _filterManagers(managers, _searchQuery);
                      final totalCount = filteredManagers.length;
                      final activeCount = filteredManagers.where((m) => !(m['isRestricted'] as bool? ?? false)).length;
                      final restrictedCount = filteredManagers.where((m) => m['isRestricted'] as bool? ?? false).length;
                      
                      return Container(
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
                              child: _buildFilterDropdown(totalCount, activeCount, restrictedCount),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons.arrow_drop_down_rounded,
                              color: colorScheme.primary,
                              size: 16,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            // Search Bar
            _buildSearchBar(context, colorScheme, theme),
            
            // Managers List
            Expanded(
              child: _buildManagersList(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(int totalCount, int activeCount, int restrictedCount) {
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
            value: 'Restricted',
            child: Text(
              'Restricted ($restrictedCount)',
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

  Widget _buildSearchBar(BuildContext context, ColorScheme colorScheme, ThemeData theme) {
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
            hintText: 'Search by name or email...',
            prefixIcon: Icon(
              Icons.search_rounded,
              color: colorScheme.onBackground.withOpacity(0.6),
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

  Widget _buildManagersList(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: UserService.getAllManagers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: theme.colorScheme.onBackground.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No managers found',
                  style: TextStyle(
                    fontSize: 18,
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          );
        }
        
        List<Map<String, dynamic>> managers = snapshot.data!;
        
        // Apply search filter
        managers = _filterManagers(managers, _searchQuery);
        
        // Filter managers based on current filter
        if (_currentFilter == 'Active') {
          managers = managers.where((manager) => !(manager['isRestricted'] as bool? ?? false)).toList();
        } else if (_currentFilter == 'Restricted') {
          managers = managers.where((manager) => manager['isRestricted'] as bool? ?? false).toList();
        }
        
        if (managers.isEmpty) {
          String message;
          if (_searchQuery.isNotEmpty) {
            message = _currentFilter != 'All' 
                ? 'No ${_currentFilter.toLowerCase()} managers found for "$_searchQuery"'
                : 'No managers found for "$_searchQuery"';
          } else {
            message = 'No ${_currentFilter.toLowerCase()} managers';
          }
          
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off_rounded,
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
        
        // Show search results count
        Widget? header;
        if (_searchQuery.isNotEmpty) {
          header = Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Text(
              'Found ${managers.length} ${managers.length == 1 ? 'manager' : 'managers'} for "$_searchQuery"',
              style: TextStyle(
                color: colorScheme.onBackground.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          );
        }
        
        return Column(
          children: [
            if (header != null) header,
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemCount: managers.length,
                itemBuilder: (context, index) {
                  final manager = managers[index];
                  return Column(
                    children: [
                      _ManagerCardStream(
                        managerData: manager,
                        onViewPressed: () => _viewManagerDetails(manager),
                        onEditPressed: () => _editManager(manager),
                        onSuspendPressed: () => _suspendManager(manager),
                      ),
                      if (index < managers.length - 1) const SizedBox(height: 12),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper method to filter managers by search query
  List<Map<String, dynamic>> _filterManagers(List<Map<String, dynamic>> managers, String query) {
    if (query.isEmpty) return managers;
    
    return managers.where((manager) {
      final name = (manager['name'] as String? ?? '').toLowerCase();
      final email = (manager['email'] as String? ?? '').toLowerCase();
      
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  // VIEW MANAGER DETAILS FUNCTION
  void _viewManagerDetails(Map<String, dynamic> manager) async {
    final managerEmail = manager['email'] as String? ?? '';
    final managerName = manager['name'] as String? ?? 'No Name';
    final isRestricted = manager['isRestricted'] as bool? ?? false;
    
    // Get manager's events
    final events = await EventService.getEventsByManager(managerEmail).first;
    
    // Show dialog with manager details
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Manager Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Name'),
                  subtitle: Text(managerName),
                ),
                ListTile(
                  leading: Icon(Icons.email),
                  title: Text('Email'),
                  subtitle: Text(managerEmail),
                ),
                ListTile(
                  leading: Icon(Icons.circle, color: isRestricted ? Colors.red : Colors.green),
                  title: Text('Status'),
                  subtitle: Text(isRestricted ? 'Restricted' : 'Active'),
                ),
                ListTile(
                  leading: Icon(Icons.event),
                  title: Text('Total Events'),
                  subtitle: Text('${events.length} events'),
                ),
                if (events.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Text('Recent Events:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  ...events.take(3).map((event) => ListTile(
                    leading: Icon(Icons.circle, size: 8),
                    title: Text(event.title),
                    subtitle: Text('Status: ${event.status.toString().split('.').last}'),
                  )).toList(),
                  if (events.length > 3)
                    Text('... and ${events.length - 3} more', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // EDIT MANAGER FUNCTION
  void _editManager(Map<String, dynamic> manager) {
    final managerEmail = manager['email'] as String? ?? '';
    final managerName = manager['name'] as String? ?? '';
    
    TextEditingController nameController = TextEditingController(text: managerName);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Manager'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Manager Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Email: $managerEmail',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  try {
                    // Update manager in database
                    await UserService.updateManagerName(managerEmail, newName);
                    
                    Navigator.pop(context);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Manager updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update manager: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Name cannot be empty'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // SUSPEND/RESTRICT MANAGER FUNCTION
  void _suspendManager(Map<String, dynamic> manager) {
    final managerEmail = manager['email'] as String? ?? '';
    final managerName = manager['name'] as String? ?? 'No Name';
    final isCurrentlyRestricted = manager['isRestricted'] as bool? ?? false;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isCurrentlyRestricted ? 'Activate Manager' : 'Restrict Manager'),
          content: Text(
            isCurrentlyRestricted
                ? 'Are you sure you want to activate $managerName? They will be able to create and manage events again.'
                : 'Are you sure you want to restrict $managerName? They will not be able to create new events.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Toggle restriction status
                  await UserService.toggleManagerRestriction(managerEmail, !isCurrentlyRestricted);
                  
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isCurrentlyRestricted
                            ? 'Manager activated successfully'
                            : 'Manager restricted successfully',
                      ),
                      backgroundColor: isCurrentlyRestricted ? Colors.green : Colors.orange,
                    ),
                  );
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update manager: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isCurrentlyRestricted ? Colors.green : Colors.orange,
              ),
              child: Text(isCurrentlyRestricted ? 'Activate' : 'Restrict'),
            ),
          ],
        );
      },
    );
  }
}

class _ManagerCardStream extends StatelessWidget {
  final Map<String, dynamic> managerData;
  final VoidCallback? onViewPressed;
  final VoidCallback? onEditPressed;
  final VoidCallback? onSuspendPressed;

  const _ManagerCardStream({
    required this.managerData,
    this.onViewPressed,
    this.onEditPressed,
    this.onSuspendPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isRestricted = managerData['isRestricted'] as bool? ?? false;
    final managerEmail = managerData['email'] as String? ?? '';

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
                    color: _getStatusColor(colorScheme, isRestricted).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: _getStatusColor(colorScheme, isRestricted),
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
                        managerData['name'] ?? 'No Name',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onBackground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        managerEmail,
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
                              color: _getStatusColor(colorScheme, isRestricted).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isRestricted ? 'Restricted' : 'Active',
                              style: TextStyle(
                                color: _getStatusColor(colorScheme, isRestricted),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Events count with real data
                          StreamBuilder<List<Event>>(
                            stream: EventService.getEventsByManager(managerEmail),
                            builder: (context, snapshot) {
                              final eventsCount = snapshot.data?.length ?? 0;
                              return Text(
                                '$eventsCount ${eventsCount == 1 ? 'event' : 'events'}',
                                style: TextStyle(
                                  color: colorScheme.onBackground.withOpacity(0.6),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
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
                  _buildActionButton(
                    'View',
                    Icons.visibility_rounded,
                    colorScheme,
                    onPressed: onViewPressed,
                  ),
                  const SizedBox(width: 12),
                  _buildActionButton(
                    'Edit',
                    Icons.edit_rounded,
                    colorScheme,
                    onPressed: onEditPressed,
                  ),
                  const SizedBox(width: 12),
                  _buildActionButton(
                    'Suspend',
                    Icons.pause_circle_rounded,
                    colorScheme,
                    onPressed: onSuspendPressed,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, ColorScheme colorScheme, {VoidCallback? onPressed}) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
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
                size: 16,
                color: colorScheme.primary,
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
      ),
    );
  }

  Color _getStatusColor(ColorScheme colorScheme, bool isRestricted) {
    return isRestricted ? colorScheme.error : colorScheme.primary;
  }
}