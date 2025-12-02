import 'package:flutter/material.dart';
import 'package:event_manager_application_finalproject/theme.dart';
import 'package:provider/provider.dart';
import 'package:event_manager_application_finalproject/main.dart';
import 'package:event_manager_application_finalproject/views/user/user_homepage.dart';
import 'package:event_manager_application_finalproject/views/user/user_explorepage.dart';
import 'package:event_manager_application_finalproject/views/user/user_favoritepage.dart';
import 'package:event_manager_application_finalproject/views/user/user_ticketpage.dart';
import 'package:event_manager_application_finalproject/auth/login.dart';

// Theme Provider for managing theme state


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 4; // Profile is the 5th item (index 4)

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    
    // Check if we're in dark mode
    final bool isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        automaticallyImplyLeading: false,
        title: Text(
          'Profile',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onBackground,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.onSurface.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Profile Picture
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primary.withOpacity(0.12),
                      ),
                      child: Icon(
                        Icons.person_rounded, 
                        color: colorScheme.primary, 
                        size: 40
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Name and Email
                    Text(
                      'Alex Johnson', 
                      style: textTheme.titleLarge?.copyWith(
                        color: colorScheme.onBackground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'alexjohnson@gmail.com', 
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onBackground.withOpacity(0.65), 
                        fontSize: 14
                      ),
                    ),
                    SizedBox(height: 20),
                    
                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('45', 'Likes'),
                        _buildStatItem('8', 'Tickets'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Menu Options
            _buildMenuOption(
              'Edit Profile',
              'Update your personal information',
              Icons.edit_rounded,
            ),
            _buildMenuOption(
              'My Bookings',
              'View your event bookings',
              Icons.book_online_rounded,
            ),
            _buildMenuOption(
              'Payment Methods',
              'Manage your payment options',
              Icons.payment_rounded,
            ),
            _buildMenuOption(
              'Notifications',
              'Manage your notifications',
              Icons.notifications_rounded,
            ),

            // Theme Switch
            Container(
              margin: EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.onSurface.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
                title: Text(
                  'Theme', 
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 16, 
                    fontWeight: FontWeight.w500, 
                    color: colorScheme.onBackground
                  ),
                ),
                subtitle: Text(
                  isDarkMode ? 'Dark Mode' : 'Light Mode', 
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onBackground.withOpacity(0.65), 
                    fontSize: 12
                  ),
                ),
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: (value) {
                    _toggleTheme(value);
                  },
                  activeColor: colorScheme.primary,
                ),
              ),
            ),

            // Log Out Button
            Container(
              margin: EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.onSurface.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                onTap: _showLogoutConfirmation,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.error.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: colorScheme.error,
                    size: 20,
                  ),
                ),
                title: Text(
                  'Sign Out', 
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 16, 
                    fontWeight: FontWeight.w500, 
                    color: colorScheme.error
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: colorScheme.outline.withOpacity(0.5),
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withOpacity(0.08), 
              blurRadius: 10, 
              offset: Offset(0, -2)
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_rounded, 'Home', 0),
            _buildNavItem(Icons.explore_rounded, 'Explore', 1),
            _buildNavItem(Icons.favorite_border_rounded, 'Like', 2),
            _buildNavItem(Icons.confirmation_number_rounded, 'Tickets', 3),
            _buildNavItem(Icons.person_outline_rounded, 'Profile', 4),
          ],
        ),
      ),
    );
  }

  void _toggleTheme(bool isDarkMode) {
    // This function would typically use a ThemeProvider
    // For now, we'll use a simple approach with a custom theme
    // In a real app, you would use Provider, Riverpod, or another state management solution
    
    // You can implement theme switching logic here
    // For example, using a shared preferences to save theme preference
    
    // Toggle the shared ThemeProvider so the whole app switches themes
    // (ThemeProvider is defined in main.dart and exposed at the app root)
    try {
      // Use Provider to flip the app theme
      Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
    } catch (_) {
      // If provider is not available, proceed to show the snack (demo fallback)
    }

    // Show a message for user feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isDarkMode ? 'Dark theme enabled' : 'Light theme enabled'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    // Note: Theme switching is performed with the top-level ThemeProvider.
  }

  void _navigateToIndex(int index) {
    if (_currentIndex == index) return;
    
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UserHomePageWidget()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ExplorePage()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const FavoritesPage()));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TicketsPage()));
        break;
      case 4:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
        break;
    }
  }

  void _showLogoutConfirmation() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Capture parent/page context so we can navigate after closing the dialog.
    final pageContext = context;

    showDialog(
      context: pageContext,
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
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            onPressed: () {
              // Close the dialog first, using the dialog's context
              Navigator.pop(dialogContext);

              // Show success message on the page context
              ScaffoldMessenger.of(pageContext).showSnackBar(
                SnackBar(
                  content: Text(
                    'Signed out successfully',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onError,
                    ),
                  ),
                  backgroundColor: colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
              
              // Navigate to login page immediately (remove previous routes)
              Navigator.of(pageContext).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false, // Remove all previous routes
              );
            },
            child: Text(
              'Sign Out',
              style: textTheme.bodyMedium?.copyWith(
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

  Widget _buildNavItem(IconData icon, String label, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _navigateToIndex(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? colorScheme.primary : colorScheme.onBackground.withOpacity(0.65),
            size: 24,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? colorScheme.primary : colorScheme.onBackground.withOpacity(0.65),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      children: [
        Text(
          value, 
          style: textTheme.titleLarge?.copyWith(
            fontSize: 20, 
            fontWeight: FontWeight.bold, 
            color: colorScheme.onBackground
          ),
        ),
        SizedBox(height: 4),
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

  Widget _buildMenuOption(String title, String subtitle, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.05), 
            blurRadius: 8, 
            offset: Offset(0, 2)
          ),
        ],
      ),
      child: ListTile(
        onTap: () {
          // Add navigation logic for each menu option here
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title feature coming soon!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1), 
            borderRadius: BorderRadius.circular(10)
          ),
          child: Icon(
            icon, 
            color: colorScheme.primary, 
            size: 20
          ),
        ),
        title: Text(
          title, 
          style: textTheme.bodyMedium?.copyWith(
            fontSize: 16, 
            fontWeight: FontWeight.w500, 
            color: colorScheme.onBackground
          ),
        ),
        subtitle: Text(
          subtitle, 
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onBackground.withOpacity(0.65), 
            fontSize: 12
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded, 
          color: colorScheme.outline.withOpacity(0.5), 
          size: 16
        ),
      ),
    );
  }
}

