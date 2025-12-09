import 'package:flutter/material.dart';
import 'package:event_manager_application_finalproject/theme.dart';

class ManagerSettingsPage extends StatefulWidget {
  const ManagerSettingsPage({super.key});

  @override
  State<ManagerSettingsPage> createState() => _ManagerSettingsPageState();
}

class _ManagerSettingsPageState extends State<ManagerSettingsPage> {
  // Settings states
  bool beepSound = true;
  bool autoFlash = false;
  bool vibrateOnScan = true;
  bool checkinAlerts = true;
  bool dailySummary = false;
  
  TextEditingController nameController = TextEditingController(text: 'John Doe');
  TextEditingController emailController = TextEditingController(text: 'john@eventmanager.com');

  @override
  void initState() {
    super.initState();
    // Load saved settings here
  }

  void _saveSettings() {
    // Save settings to shared preferences or backend
    print('Settings saved');
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

                // QR Scanner Settings
                _buildSectionTitle('QR Scanner'),
                _buildSettingToggle(
                  icon: Icons.volume_up_rounded,
                  title: 'Beep Sound',
                  subtitle: 'Play sound on successful scan',
                  value: beepSound,
                  onChanged: (value) => setState(() => beepSound = value),
                ),
                _buildSettingToggle(
                  icon: Icons.flash_on_rounded,
                  title: 'Auto-flash',
                  subtitle: 'Automatically use flash in low light',
                  value: autoFlash,
                  onChanged: (value) => setState(() => autoFlash = value),
                ),
                _buildSettingToggle(
                  icon: Icons.vibration_rounded,
                  title: 'Vibrate',
                  subtitle: 'Vibrate on successful scan',
                  value: vibrateOnScan,
                  onChanged: (value) => setState(() => vibrateOnScan = value),
                ),
                const SizedBox(height: 24),

                // Notifications
                _buildSectionTitle('Notifications'),
                _buildSettingToggle(
                  icon: Icons.check_circle_rounded,
                  title: 'Check-in Alerts',
                  subtitle: 'Real-time notifications for check-ins',
                  value: checkinAlerts,
                  onChanged: (value) => setState(() => checkinAlerts = value),
                ),
                _buildSettingToggle(
                  icon: Icons.summarize_rounded,
                  title: 'Daily Summary',
                  subtitle: 'Receive daily check-in report',
                  value: dailySummary,
                  onChanged: (value) => setState(() => dailySummary = value),
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