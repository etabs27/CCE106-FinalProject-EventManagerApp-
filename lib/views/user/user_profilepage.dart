import 'package:flutter/material.dart';
import 'package:event_manager_application_finalproject/theme.dart';
import 'package:provider/provider.dart';
import 'package:event_manager_application_finalproject/main.dart';
import 'package:event_manager_application_finalproject/views/user/user_homepage.dart';
import 'package:event_manager_application_finalproject/views/user/user_explorepage.dart';
import 'package:event_manager_application_finalproject/views/user/user_favoritepage.dart';
import 'package:event_manager_application_finalproject/views/user/user_ticketpage.dart';
import 'package:event_manager_application_finalproject/auth/login.dart';
import 'package:event_manager_application_finalproject/views/user/user_homepagenotification.dart';
import 'package:event_manager_application_finalproject/views/user/user_profilepageeditprofile.dart'; 
import 'package:event_manager_application_finalproject/views/user/user_profilepagepayment.dart';

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
              onTap: () {
                // Navigate to Edit Profile Page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserProfilePageEditProfile()),
                );
              },
            ),
            _buildMenuOption(
              'My Bookings',
              'View your event bookings',
              Icons.book_online_rounded,
              onTap: () {
                // Navigate to Tickets Page (which shows bookings)
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TicketsPage()),
                );
              },
            ),
            _buildMenuOption(
              'Payment Methods',
              'Manage your payment options',
              Icons.payment_rounded,
              onTap: () {
                // Navigate to Payment Methods Page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserProfilePagePayment()),
                );
              },
            ),
            _buildMenuOption(
              'Notifications',
              'Manage your notifications',
              Icons.notifications_rounded,
              onTap: () {
                // Navigate to UserHomePageNotification
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserHomePageNotification()),
                );
              },
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

            // Log Out Button - Changed to use primary color (brown)
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
                    color: colorScheme.primary.withOpacity(0.1), // Changed to primary color
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: colorScheme.primary, // Changed to primary color
                    size: 20,
                  ),
                ),
                title: Text(
                  'Sign Out', 
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 16, 
                    fontWeight: FontWeight.w500, 
                    color: colorScheme.primary // Changed to primary color (brown)
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
    // Toggle the shared ThemeProvider so the whole app switches themes
    try {
      // Use Provider to flip the app theme
      Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
    } catch (_) {
      // If provider is not available, silently handle the theme change
      // No snackbar message will be shown
    }
    
    // Note: Theme switching is performed with the top-level ThemeProvider.
    // No success message will be shown when theme is changed.
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
              backgroundColor: colorScheme.primary, // Changed to primary color (brown)
              foregroundColor: Colors.white, // White text for contrast
            ),
            onPressed: () {
              // Close the dialog first
              Navigator.pop(dialogContext);
              
              // Navigate to login page immediately without showing success message
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: Text(
              'Sign Out',
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.white, // White text for contrast
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

  Widget _buildMenuOption(String title, String subtitle, IconData icon, {VoidCallback? onTap}) {
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
        onTap: onTap ?? () {
          // Default behavior if no onTap provided
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