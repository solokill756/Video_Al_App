import 'package:auto_route/auto_route.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/dialogs/app_dialogs.dart';
import '../../../../common/dialogs/custom_alert_dialog.dart';
import '../../../app/app_router.dart';
import '../../data/model/user_profile_model.dart';
import '../application/cubit/settings_cubit.dart';
import '../components/change_password_dialog.dart';
import '../components/disable_2fa_dialog.dart';
import '../components/enable_2fa_dialog.dart';
import '../../../payment/presentation/components/payment_modal.dart';
import '../../../payment/presentation/application/cubit/payment_cubit.dart';
import '../../../payment/presentation/application/cubit/payment_state.dart';
import '../../../plan/presentation/application/cubit/plan_cubit.dart';
import '../../../plan/presentation/application/cubit/plan_state.dart';
import '../../../upload/data/model/plan_model.dart';

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
  bool _twoFactorAuth = false;
  String? _avatarUrl;
  String _selectedPlanName = '';
  String _paymentLink = '';

  @override
  void initState() {
    super.initState();
    context.read<SettingsCubit>().loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: BlocListener<PaymentCubit, PaymentState>(
        listener: (context, paymentState) {
          paymentState.maybeWhen(
            paymentLinkReceived: (registrationLink, planId, planName) {
              setState(() {
                _paymentLink = registrationLink;
                _selectedPlanName = planName;
              });
              Navigator.of(context).pop();
              _showPaymentModal(context);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
            paymentError: (error, errorCode) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              AppDialogs.showSnackBar(
                message: error,
                backgroundColor: Colors.redAccent,
              );
            },
            orElse: () {},
          );
        },
        child: BlocListener<SettingsCubit, SettingsState>(
          listener: (context, state) {
            state.maybeWhen(
                loaded: (isNotificationEnabled, isAutoPlay, user, twoFaLink) {
                  setState(() {
                    _notifications = isNotificationEnabled;
                    _autoPlay = isAutoPlay;
                    _twoFactorAuth = user.isEnable2FA;
                    _avatarUrl = user.avatar;
                  });
                },
                error: (message) {
                  AppDialogs.showSnackBar(
                    message: message,
                    backgroundColor: Colors.redAccent,
                  );
                },
                orElse: () {});
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
                          BlocBuilder<SettingsCubit, SettingsState>(
                            builder: (context, state) {
                              return state.maybeWhen(
                                loaded: (isNotificationEnabled, isAutoPlay,
                                    user, twoFaLink) {
                                  return _buildProfileSection(user);
                                },
                                loading: () => const Center(
                                    child: CircularProgressIndicator()),
                                orElse: () => _buildProfileSection(null),
                              );
                            },
                          ),

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
                              return state.maybeWhen(
                                initial: () => _buildLogoutButton(),
                                loading: () => const Center(
                                    child: CircularProgressIndicator()),
                                loaded: (isNotificationEnabled, isAutoPlay,
                                        user, twoFaLink) =>
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
                                orElse: () => _buildLogoutButton(),
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

  Widget _buildProfileSection(UserProfileModel? user) {
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
      child: Column(
        children: [
          Row(
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
                child: _avatarUrl != null
                    ? ClipOval(
                        child: Image.network(
                          _avatarUrl!,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(
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
                    Text(
                      user?.name ?? 'User Name',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? 'user@example.com',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D9488).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user?.plan?.planType == 'FREE'
                            ? 'Free Customer'
                            : 'Premium Customer',
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

              // View Profile Button
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.router.push(const ProfileRoute());
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF64748B),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

          // Upgrade Button (show only for FREE users)
          if (user?.plan?.planType == 'FREE') ...[
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFFE2E8F0),
                  ),
                ),
              ),
              child: const SizedBox(height: 16),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showUpgradePlanOptions(context),
                icon: const Icon(Icons.upgrade, size: 18),
                label: const Text(
                  'Upgrade to Premium',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showUpgradePlanOptions(BuildContext context) {
    // Load plans when modal opens
    context.read<PlanCubit>().loadPlans(pageSize: 100);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext modalContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle Bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  'Choose Your Plan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 16),

                // Load Plans Dynamically
                BlocBuilder<PlanCubit, PlanState>(
                  builder: (context, state) {
                    return state.maybeWhen(
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      plansLoaded: (plans) {
                        // Filter out FREE plans - only show paid plans
                        final paidPlans =
                            plans.where((p) => p.planType != 'FREE').toList();

                        final children = <Widget>[];
                        for (int i = 0; i < paidPlans.length; i++) {
                          children.add(
                            Column(
                              children: [
                                _buildUpgradePlanOption(
                                  context: context,
                                  plan: paidPlans[i],
                                ),
                                if (i < paidPlans.length - 1)
                                  const SizedBox(height: 12),
                              ],
                            ),
                          );
                        }
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: children,
                        );
                      },
                      error: (message) => Center(
                        child: Text(
                          message,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      orElse: () => const SizedBox.shrink(),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUpgradePlanOption({
    required BuildContext context,
    required Plan plan,
  }) {
    // Extract features from plan.features map
    final List<String> features = [];
    plan.features.forEach((key, value) {
      if (value == true || (value is String && value.isNotEmpty)) {
        // Use the key as feature text (assumes backend provides readable keys)
        features.add(key.toString());
      }
    });

    // Format price with comma separator
    final priceFormatted = '${plan.price.toStringAsFixed(0)} VND';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                plan.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0D9488),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  priceFormatted,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (plan.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                plan.description,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF0D9488),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        f,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _onUpgradePressed(context, plan.id, plan.name);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Choose Plan',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onUpgradePressed(BuildContext context, int planId, String planName) {
    print('✅ Upgrade pressed: $planName (ID: $planId)');

    // Show loading
    AppDialogs.showSnackBar(
      message: 'Getting payment information...',
      backgroundColor: const Color(0xFF0D9488),
    );

    // Call PaymentCubit to get payment link
    context.read<PaymentCubit>().getPaymentLink(
          planId: planId,
          planName: planName,
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
          icon: Icons.security,
          title: 'Two-Factor Authentication',
          subtitle: 'Add extra security to your account',
          value: _twoFactorAuth,
          onChanged: (value) {
            _handle2FAToggle(
              value,
            );
          },
        ),
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
          icon: Icons.lock_outline,
          title: 'Change Password',
          subtitle: 'Update your account password',
          onTap: () => _showChangePasswordDialog(),
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

  void _handle2FAToggle(
    bool enable,
  ) {
    // Lấy cubit từ context
    final settingsCubit = context.read<SettingsCubit>();

    if (enable) {
      // Kích hoạt 2FA
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) =>
            // Cung cấp cubit cho dialog
            BlocProvider.value(
          value: settingsCubit,
          child: const Enable2FADialog(),
        ),
      ).then((success) {
        if (success != true) {
          setState(() {
            _twoFactorAuth = false;
          });
        }
      });
    } else {
      // Vô hiệu hóa 2FA
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => BlocProvider.value(
          value: settingsCubit,
          child: const Disable2FADialog(),
        ),
      ).then((success) {
        if (success != true) {
          setState(() {
            _twoFactorAuth = true;
          });
        }
      });
    }
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ChangePasswordDialog(),
    );
  }

  void _showPaymentModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: context.read<PaymentCubit>(),
          child: PaymentModal(
            isOpen: true,
            onClose: () {
              Navigator.of(dialogContext).pop();
            },
            planName: _selectedPlanName,
            registrationLink: _paymentLink,
          ),
        );
      },
    );
  }
}
