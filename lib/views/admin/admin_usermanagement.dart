import 'package:flutter/material.dart';
import 'package:event_manager_application_finalproject/theme.dart';
import 'package:event_manager_application_finalproject/user_service.dart';
import 'package:event_manager_application_finalproject/event_service.dart';
import 'package:event_manager_application_finalproject/models/event.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserManagementDesign extends StatefulWidget {
  const UserManagementDesign({super.key});

  @override
  State<UserManagementDesign> createState() => _UserManagementDesignState();
}

class _UserManagementDesignState extends State<UserManagementDesign> {
  String _currentFilter = 'All Users';
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
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
          'User Management',
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
                  // Filter Button
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: UserService.getAllUsers(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container();
                      }
                      
                      final users = snapshot.data!;
                      final totalCount = users.length;
                      final activeCount = users.where((user) => !(user['isSuspended'] as bool? ?? false)).length;
                      final suspendedCount = users.where((user) => user['isSuspended'] as bool? ?? false).length;
                      
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
                              width: 70,
                              child: _buildUserFilterDropdown(totalCount, activeCount, suspendedCount),
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
            
            // Search Section
            _buildSearchSection(context),
            
            // Users List
            Expanded(
              child: _buildUsersList(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserFilterDropdown(int totalCount, int activeCount, int suspendedCount) {
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
            value: 'All Users',
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
            value: 'Active Users',
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
            value: 'Suspended Users',
            child: Text(
              'Suspended ($suspendedCount)',
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

  Widget _buildSearchSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      color: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users by name or email...',
                prefixIcon: Icon(
                  Icons.search_rounded, 
                  color: colorScheme.onBackground.withOpacity(0.6)
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded, color: colorScheme.onBackground.withOpacity(0.6)),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: UserService.getAllUsers(),
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
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No users found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          );
        }
        
        final users = snapshot.data!;
        
        // Filter users based on current filter
        List<Map<String, dynamic>> filteredUsers = users;
        if (_currentFilter == 'Active Users') {
          filteredUsers = users.where((user) => !(user['isSuspended'] as bool? ?? false)).toList();
        } else if (_currentFilter == 'Suspended Users') {
          filteredUsers = users.where((user) => user['isSuspended'] as bool? ?? false).toList();
        }
        
        // Apply search filter
        if (_searchQuery.isNotEmpty) {
          filteredUsers = filteredUsers.where((user) {
            final name = (user['name'] ?? '').toString().toLowerCase();
            final firstName = (user['firstName'] ?? '').toString().toLowerCase();
            final lastName = (user['lastName'] ?? '').toString().toLowerCase();
            final fullName = (user['fullName'] ?? '').toString().toLowerCase();
            final email = (user['email'] ?? '').toString().toLowerCase();
            
            // Search in all name fields and email
            return name.contains(_searchQuery.toLowerCase()) || 
                   firstName.contains(_searchQuery.toLowerCase()) ||
                   lastName.contains(_searchQuery.toLowerCase()) ||
                   fullName.contains(_searchQuery.toLowerCase()) ||
                   email.contains(_searchQuery.toLowerCase());
          }).toList();
        }
        
        if (filteredUsers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _searchQuery.isNotEmpty ? Icons.search_off_rounded : Icons.filter_list_off,
                  size: 64,
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isNotEmpty 
                    ? 'No users found for "$_searchQuery"'
                    : 'No ${_currentFilter.toLowerCase()}',
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
                if (_searchQuery.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                    child: Text('Clear search'),
                  ),
                ],
              ],
            ),
          );
        }
        
        return ListView.builder(
          controller: _scrollController,
          shrinkWrap: true,
          physics: AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            final user = filteredUsers[index];
            return Column(
              children: [
                _UserCard(
                  userData: user,
                  onUserUpdated: () {
                    // Refresh the UI when user is updated
                    setState(() {});
                  },
                ),
                if (index < filteredUsers.length - 1) const SizedBox(height: 12),
              ],
            );
          },
        );
      },
    );
  }
}

class _UserCard extends StatelessWidget {
  final Map<String, dynamic> userData;
  final VoidCallback? onUserUpdated;

  const _UserCard({
    required this.userData,
    this.onUserUpdated,
  });

  void _showActionMenu(BuildContext context, String userId, String userEmail, bool isSuspended) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'User Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onBackground,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Action Items
                _buildActionItem(
                  context,
                  icon: Icons.visibility_rounded,
                  title: 'View Profile',
                  subtitle: 'See detailed information',
                  color: colorScheme.primary,
                  onTap: () {
                    Navigator.pop(context);
                    _viewUserProfile(context, userEmail);
                  },
                ),
                
                // User specific actions
                _buildActionItem(
                  context,
                  icon: isSuspended ? Icons.play_circle_outline_rounded : Icons.pause_circle_outline_rounded,
                  title: isSuspended ? 'Activate User' : 'Suspend User',
                  subtitle: isSuspended ? 'Allow user to access the app' : 'Temporarily block user access',
                  color: isSuspended ? Colors.green : Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    _toggleUserSuspension(context, userId, userEmail, isSuspended);
                  },
                ),
                
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: colorScheme.onBackground.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: colorScheme.onBackground,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: colorScheme.onBackground.withOpacity(0.6),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: colorScheme.onBackground.withOpacity(0.3),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    );
  }

  Future<void> _toggleUserSuspension(BuildContext context, String userId, String userEmail, bool isSuspended) async {
    final shouldSuspend = !isSuspended;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          shouldSuspend ? 'Suspend User' : 'Activate User',
          style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
        ),
        content: Text(
          shouldSuspend
              ? 'Are you sure you want to suspend $userEmail? They will not be able to access the app until activated.'
              : 'Are you sure you want to activate $userEmail? They will regain access to the app.',
          style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                // Update user suspension status using UserService
                await UserService.updateUserSuspension(userId, shouldSuspend);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      shouldSuspend 
                        ? 'User suspended successfully' 
                        : 'User activated successfully',
                    ),
                    backgroundColor: shouldSuspend ? Colors.orange : Colors.green,
                  ),
                );
                onUserUpdated?.call();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to update user: $e'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: shouldSuspend ? Colors.orange : Colors.green,
            ),
            child: Text(shouldSuspend ? 'Suspend' : 'Activate'),
          ),
        ],
      ),
    );
  }

  void _viewUserProfile(BuildContext context, String userEmail) {
    final role = userData['role'] as String? ?? 'user';
    final isSuspended = userData['isSuspended'] as bool? ?? false;
    
    // Get name details
    final firstName = userData['firstName'] as String? ?? '';
    final lastName = userData['lastName'] as String? ?? '';
    final middleName = userData['middleName'] as String?;
    
    // Build display name
    String displayName = 'No Name';
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      if (middleName != null && middleName.isNotEmpty) {
        displayName = '$firstName $middleName $lastName';
      } else {
        displayName = '$firstName $lastName';
      }
    } else {
      displayName = userData['name'] as String? ?? 'No Name';
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Profile', style: TextStyle(color: Theme.of(context).colorScheme.onBackground)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Full Name: $displayName', style: TextStyle(color: Theme.of(context).colorScheme.onBackground)),
              const SizedBox(height: 8),
              if (firstName.isNotEmpty) 
                Text('First Name: $firstName', style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.8))),
              if (lastName.isNotEmpty) 
                Text('Last Name: $lastName', style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.8))),
              if (middleName != null && middleName.isNotEmpty) 
                Text('Middle Name: $middleName', style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.8))),
              const SizedBox(height: 8),
              Text('Email: $userEmail', style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.8))),
              Text('Role: ${role.toUpperCase()}', style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.8))),
              Text('Status: ${isSuspended ? 'Suspended' : 'Active'}', style: TextStyle(
                color: isSuspended ? Theme.of(context).colorScheme.error : Colors.green,
              )),
              if (userData['createdAt'] != null) 
                Text('Joined: ${DateFormat('MMM dd, yyyy').format(userData['createdAt'].toDate())}', 
                     style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.8))),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final userEmail = userData['email'] as String? ?? '';
    final userId = userData['id'] as String? ?? '';
    final createdAt = userData['createdAt'];
    final lastActive = userData['lastActive'];
    final userRole = userData['role'] as String? ?? 'user';
    final isSuspended = userData['isSuspended'] as bool? ?? false;
    
    // Get name details
    final firstName = userData['firstName'] as String? ?? '';
    final lastName = userData['lastName'] as String? ?? '';
    final middleName = userData['middleName'] as String?;
    
    // Build display name
    String displayName = 'No Name';
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      if (middleName != null && middleName.isNotEmpty) {
        displayName = '$firstName $middleName $lastName';
      } else {
        displayName = '$firstName $lastName';
      }
    } else {
      // Fallback to legacy 'name' field or 'fullName'
      displayName = userData['name'] as String? ?? 
                   userData['fullName'] as String? ?? 
                   'No Name';
    }
    
    // Format dates
    String joinDate = 'Unknown';
    if (createdAt != null) {
      try {
        final date = createdAt.toDate();
        joinDate = DateFormat('MMM dd, yyyy').format(date);
      } catch (e) {
        joinDate = 'Unknown';
      }
    }
    
    String lastActiveText = 'Never';
    if (lastActive != null) {
      try {
        final date = lastActive.toDate();
        final now = DateTime.now();
        final difference = now.difference(date);
        
        if (difference.inDays > 0) {
          lastActiveText = '${difference.inDays}d ago';
        } else if (difference.inHours > 0) {
          lastActiveText = '${difference.inHours}h ago';
        } else if (difference.inMinutes > 0) {
          lastActiveText = '${difference.inMinutes}m ago';
        } else {
          lastActiveText = 'Just now';
        }
      } catch (e) {
        lastActiveText = 'Unknown';
      }
    }

    final status = isSuspended ? 'Suspended' : 'Active';

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
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // User Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getRoleColor(colorScheme, userRole).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getRoleIcon(userRole),
                color: _getRoleColor(colorScheme, userRole),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          displayName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onBackground,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: _getStatusColor(colorScheme, status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: _getStatusColor(colorScheme, status),
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    userEmail,
                    style: TextStyle(
                      color: colorScheme.onBackground.withOpacity(0.6),
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: _getRoleColor(colorScheme, userRole).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          userRole.toUpperCase(),
                          style: TextStyle(
                            color: _getRoleColor(colorScheme, userRole),
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '•',
                        style: TextStyle(
                          color: colorScheme.onBackground.withOpacity(0.2),
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Joined $joinDate',
                          style: TextStyle(
                            color: colorScheme.onBackground.withOpacity(0.5),
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Last active $lastActiveText',
                    style: TextStyle(
                      color: colorScheme.onBackground.withOpacity(0.5),
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Actions Menu
            IconButton(
              iconSize: 20,
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.more_vert_rounded, 
                color: colorScheme.onBackground.withOpacity(0.4)
              ),
              onPressed: () => _showActionMenu(context, userId, userEmail, isSuspended),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ColorScheme colorScheme, String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return colorScheme.primary;
      case 'suspended':
        return colorScheme.error;
      default:
        return colorScheme.primary;
    }
  }

  Color _getRoleColor(ColorScheme colorScheme, String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.purple;
      case 'manager':
        return Colors.orange;
      case 'user':
        return colorScheme.primary;
      default:
        return colorScheme.primary;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Icons.security_rounded;
      case 'manager':
        return Icons.manage_accounts_rounded;
      case 'user':
        return Icons.person_rounded;
      default:
        return Icons.person_rounded;
    }
  }
}