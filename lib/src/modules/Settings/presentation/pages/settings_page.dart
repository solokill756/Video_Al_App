import 'package:auto_route/auto_route.dart';
import 'package:dmvgenie/src/common/dialogs/app_dialogs.dart';
import 'package:dmvgenie/src/modules/app/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/dialogs/custom_alert_dialog.dart';
import '../application/settings_cubit/settings_cubit.dart';

@RoutePage()
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsView();
  }
}

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _notifications = true;
  bool _autoPlay = true;
  bool _saveSearchHistory = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: BlocListener<SettingsCubit, SettingsState>(
        listener: (context, state) {
          state.when(
            initial: () {},
            loading: () {},
            loaded: (isNotificationEnabled, isAutoPlay) {
              setState(() {
                _notifications = isNotificationEnabled;
                _autoPlay = isAutoPlay;
              });
            },
            error: (message) {
              AppDialogs.showSnackBar(
                message: message,
                backgroundColor: Colors.redAccent,
              );
            },
          );
        },
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Settings Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),

                        // Profile Section
                        _buildProfileSection(),

                        const SizedBox(height: 32),

                        // App Settings
                        _buildAppSettings(),

                        const SizedBox(height: 24),

                        // Video Settings
                        _buildVideoSettings(),

                        const SizedBox(height: 24),

                        // Privacy & Security
                        _buildPrivacySettings(),

                        const SizedBox(height: 24),

                        // About & Support
                        _buildAboutSettings(),

                        const SizedBox(height: 32),

                        // Logout Button
                        BlocBuilder<SettingsCubit, SettingsState>(
                          builder: (context, state) {
                            return state.when(
                              initial: () => _buildLogoutButton(),
                              loading: () => const Center(
                                  child: CircularProgressIndicator()),
                              loaded: (isNotificationEnabled, isAutoPlay) =>
                                  _buildLogoutButton(),
                              error: (message) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  AppDialogs.showSnackBar(
                                    message: message,
                                    backgroundColor: Colors.redAccent,
                                  );
                                });
                                return _buildLogoutButton();
                              },
                            );
                          },
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_back_ios,
                color: Color(0xFF64748B),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Cài đặt',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D9488), Color(0xFF059669)],
              ),
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Icon(
              // bool _highQuality = false;
              // bool _saveSearchHistory = true;
              // bool _biometricAuth = false;
              Icons.person,
              color: Colors.white,
              size: 32,
            ),
          ),

          const SizedBox(width: 16),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'John Doe',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'user@example.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Premium',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF0D9488),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Edit Button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _showEditProfile();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.edit,
                color: Color(0xFF64748B),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettings() {
    return _buildSettingsSection(
      title: 'App Settings',
      children: [
        _buildSwitchTile(
          icon: Icons.notifications,
          title: 'Notifications',
          subtitle: 'Receive notifications about new videos',
          value: _notifications,
          onChanged: (value) {
            setState(() {
              _notifications = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildVideoSettings() {
    return _buildSettingsSection(
      title: 'Video Settings',
      children: [
        _buildSwitchTile(
          icon: Icons.play_arrow,
          title: 'Auto Play',
          subtitle: 'Automatically play the next video',
          value: _autoPlay,
          onChanged: (value) {
            setState(() {
              _autoPlay = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPrivacySettings() {
    return _buildSettingsSection(
      title: 'Privacy & Security',
      children: [
        _buildSwitchTile(
          icon: Icons.history,
          title: 'Save Search History',
          subtitle: 'Remember searched keywords',
          value: _saveSearchHistory,
          onChanged: (value) {
            setState(() {
              _saveSearchHistory = value;
            });
          },
        ),
        _buildActionTile(
          icon: Icons.delete_outline,
          title: 'Clear Data',
          subtitle: 'Delete history and cache',
          onTap: () => _showClearDataDialog(),
        ),
      ],
    );
  }

  Widget _buildAboutSettings() {
    return _buildSettingsSection(
      title: 'About',
      children: [
        _buildActionTile(
          icon: Icons.help_outline,
          title: 'Help',
          subtitle: 'FAQs and guides',
          onTap: () => _showHelp(),
        ),
        _buildActionTile(
          icon: Icons.feedback,
          title: 'Feedback',
          subtitle: 'Send your feedback',
          onTap: () => _showFeedback(),
        ),
        _buildActionTile(
          icon: Icons.star_outline,
          title: 'Rate the App',
          subtitle: 'Give us 5 stars on the Store',
          onTap: () => _rateApp(),
        ),
        _buildActionTile(
          icon: Icons.info_outline,
          title: 'Version Info',
          subtitle: 'VideoSearch v1.0.0',
          onTap: () => _showAbout(),
        ),
      ],
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF0D9488).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF0D9488),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF0D9488),
            activeTrackColor: const Color(0xFF0D9488).withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF0D9488),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF9CA3AF),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF6B7280).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF6B7280),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF9CA3AF),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF0D9488),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF0D9488),
              inactiveTrackColor: const Color(0xFF0D9488).withOpacity(0.3),
              thumbColor: const Color(0xFF0D9488),
              overlayColor: const Color(0xFF0D9488).withOpacity(0.2),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          _showLogoutDialog();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEF4444),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          'Log Out',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showEditProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Edit Profile'),
        content: const Text(
            'The edit profile feature will be available in the next version.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Clear Data'),
        content: const Text(
          'Are you sure you want to delete all search history and cached data? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              AppDialogs.showSnackBar(
                message: 'Data cleared successfully',
                backgroundColor: Colors.green,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    final router = context.router;
    final settingsCubit = context.read<SettingsCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => CustomAlertDialog(
        titleWidget: const Text(
          'Log Out',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        contentWidget: const Text(
          'Are you sure you want to log out of your account?',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF6B7280),
          ),
        ),
        hasCloseButton: true,
        hasOKButton: true,
        closeButtonText: 'Cancel',
        okButtonText: 'Log Out',
        okButtonColor: const Color(0xFFEF4444),
        onOKButtonPressed: () async {
          // Close dialog using dialogContext
          Navigator.of(dialogContext).pop();

          try {
            await settingsCubit.logout();
            // Navigate to login and clear stack
            router.replaceAll([const LoginRoute()]);
            AppDialogs.showSnackBar(
              message: 'Logged out successfully',
              backgroundColor: Colors.green,
            );
          } catch (e) {
            AppDialogs.showSnackBar(
              message: 'Logout error: ${e.toString()}',
              backgroundColor: Colors.redAccent,
            );
          }
        },
      ),
    );
  }

  void _showHelp() {
    AppDialogs.showSnackBar(
      message: 'Opening help page...',
      backgroundColor: Colors.blueAccent,
    );
  }

  void _showFeedback() {
    AppDialogs.showSnackBar(
      message: 'Opening feedback form...',
      backgroundColor: Colors.blueAccent,
    );
  }

  void _rateApp() {
    AppDialogs.showSnackBar(
      message: 'Redirecting to Store...',
      backgroundColor: Colors.blueAccent,
    );
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('VideoSearch'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('Developed by: VideoAI Team'),
            SizedBox(height: 8),
            Text('© 2024 VideoSearch. All rights reserved.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
