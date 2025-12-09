import 'package:flutter/material.dart';
import 'package:event_manager_application_finalproject/theme.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  // Settings states
  bool approvalNotifications = true;
  bool managerNotifications = true;
  bool eventNotifications = true;
  bool weeklyReport = false;
  
  TextEditingController nameController = TextEditingController(text: 'Admin');
  TextEditingController emailController = TextEditingController(text: 'admin@eventmanager.com');

  void _saveSettings() {
    // Save settings to shared preferences or backend
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Settings saved',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        automaticallyImplyLeading: true,
        title: Text(
          'Settings',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onBackground,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _saveSettings,
            icon: Icon(Icons.save_rounded, color: colorScheme.primary),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Section
                _buildSectionTitle('Profile'),
                _buildTextField('Name', nameController),
                const SizedBox(height: 12),
                _buildTextField('Email', emailController),
                const SizedBox(height: 24),

                // Admin Notifications
                _buildSectionTitle('Notifications'),
                _buildSettingToggle(
                  icon: Icons.approval_rounded,
                  title: 'Event Approvals',
                  subtitle: 'Get notified when managers create new events',
                  value: approvalNotifications,
                  onChanged: (value) => setState(() => approvalNotifications = value),
                ),
                _buildSettingToggle(
                  icon: Icons.person_add_rounded,
                  title: 'New Managers',
                  subtitle: 'Notifications for new manager registrations',
                  value: managerNotifications,
                  onChanged: (value) => setState(() => managerNotifications = value),
                ),
                _buildSettingToggle(
                  icon: Icons.event_rounded,
                  title: 'Event Updates',
                  subtitle: 'Notifications for completed/active events',
                  value: eventNotifications,
                  onChanged: (value) => setState(() => eventNotifications = value),
                ),
                _buildSettingToggle(
                  icon: Icons.analytics_rounded,
                  title: 'Weekly Report',
                  subtitle: 'Receive weekly admin report every Monday',
                  value: weeklyReport,
                  onChanged: (value) => setState(() => weeklyReport = value),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onBackground.withOpacity(0.6),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onBackground,
        ),
      ),
    );
  }

  Widget _buildSettingToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onBackground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: colorScheme.primary,
          ),
        ],
      ),
    );
  }
}