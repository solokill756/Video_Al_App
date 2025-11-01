import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../common/dialogs/app_dialogs.dart';
import '../../../../common/widgets/loading_widget.dart';
import '../../data/model/user_profile_model.dart';
import '../application/cubit/settings_cubit.dart';

@RoutePage()
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileView();
  }
}

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  UserProfileModel? _user;
  bool _isEditing = false;
  File? _selectedImage;

  void _handleUpdateProfile() async {
    final name = _nameController.text.trim();
    final phoneNumber = _phoneController.text.trim();

    if (name.isEmpty) {
      AppDialogs.showSnackBar(
        message: 'Name cannot be empty',
        backgroundColor: Colors.redAccent,
      );
      return;
    }

    if (phoneNumber.isNotEmpty &&
        !RegExp(r'^\+?[0-9]{7,15}$').hasMatch(phoneNumber)) {
      AppDialogs.showSnackBar(
        message: 'Invalid phone number format',
        backgroundColor: Colors.redAccent,
      );
      return;
    }

    context.read<SettingsCubit>().updateProfile(
          name: name,
          phoneNumber: phoneNumber,
        );
  }

  @override
  void initState() {
    super.initState();
    context.read<SettingsCubit>().loadSettings();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _populateFields(UserProfileModel? user) {
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber;
      _user = user;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: BlocListener<SettingsCubit, SettingsState>(
        listener: (context, state) {
          state.maybeWhen(
              loaded: (isNotificationEnabled, isAutoPlay, user, twoFaLink) {
                _populateFields(user);
              },
              error: (message) {
                AppDialogs.showSnackBar(
                  message: message,
                  backgroundColor: Colors.redAccent,
                );
              },
              uploadAvatarSuccess: (message) {
                context.hideLoadingDialog();
                AppDialogs.showSnackBar(
                  message: message,
                  backgroundColor: Colors.green,
                );
              },
              uploadingAvatar: () {
                context.showLoadingDialog(
                    message: 'Uploading avatar...', type: LoadingType.dots);
              },
              uploadAvatarFailure: (message) {
                context.hideLoadingDialog();
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

              // Profile Content
              Expanded(
                child: BlocBuilder<SettingsCubit, SettingsState>(
                  builder: (context, state) {
                    return state.maybeWhen(
                      initial: () => _buildProfileContent(),
                      loading: () =>
                          const Center(child: LoadingWidget.medium()),
                      loaded: (_, __, user, ___) {
                        _populateFields(user);
                        return _buildProfileContent();
                      },
                      error: (message) => _buildErrorContent(message),
                      orElse: () => _buildProfileContent(),
                    );
                  },
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
            'Profile',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              if (_isEditing) {
                _handleUpdateProfile();
              }
              setState(() {
                _isEditing = !_isEditing;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _isEditing
                    ? const Color(0xFF0D9488)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _isEditing ? 'Save' : 'Edit',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _isEditing ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar Section
            _buildAvatarSection(),

            const SizedBox(height: 32),

            // Profile Info Section
            _buildProfileInfoSection(),

            const SizedBox(height: 24),

            // Statistics Section
            _buildStatisticsSection(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Container(
      padding: const EdgeInsets.all(24),
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
          Stack(
            children: [
              // Avatar Container
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: _buildAvatarImage(),
                ),
              ),

              // Camera button
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showImageSourceDialog();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D9488),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _user?.name ?? 'User Name',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _user?.email ?? 'user@example.com',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0D9488).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _user?.plan?.planType == 'FREE'
                  ? 'Free Customer'
                  : 'Premium Customer',
              style: TextStyle(
                fontSize: 12,
                color: _user?.plan?.planType == 'Premium Plan'
                    ? const Color(0xFFFFA500)
                    : const Color(0xFF0D9488),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoSection() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 20),

          // Name Field
          _buildInfoField(
            label: 'Full Name',
            controller: _nameController,
            icon: Icons.person_outline,
            enabled: _isEditing,
          ),

          const SizedBox(height: 16),

          // Email Field
          _buildInfoField(
            label: 'Email',
            controller: _emailController,
            icon: Icons.email_outlined,
            enabled: false, // Email không cho phép edit
          ),

          const SizedBox(height: 16),

          // Phone Field
          _buildInfoField(
            label: 'Phone Number',
            controller: _phoneController,
            icon: Icons.phone_outlined,
            enabled: _isEditing,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool enabled,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color:
                  enabled ? const Color(0xFF0D9488) : const Color(0xFF9CA3AF),
              size: 20,
            ),
            filled: true,
            fillColor: enabled ? Colors.white : const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color:
                    enabled ? const Color(0xFFD1D5DB) : const Color(0xFFE5E7EB),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF0D9488), width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
          ),
          style: TextStyle(
            fontSize: 16,
            color: enabled ? const Color(0xFF1F2937) : const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsSection() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activity Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.video_library_outlined,
                  title: 'Videos Watched',
                  value: '142',
                  color: const Color(0xFF0D9488),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.access_time,
                  title: 'Watch Time',
                  value: '24h',
                  color: const Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.favorite_outline,
                  title: 'Favorites',
                  value: '38',
                  color: const Color(0xFFEF4444),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.download_outlined,
                  title: 'Downloads',
                  value: '12',
                  color: const Color(0xFF059669),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContent(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Color(0xFFEF4444),
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading profile',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<SettingsCubit>().loadSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
            ),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarImage() {
    if (_user?.avatar != null && _user!.avatar!.isNotEmpty) {
      // Check if it's a network URL or local file path
      if (_user!.avatar!.startsWith('http')) {
        return Image.network(
          _user!.avatar!,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultAvatar();
          },
        );
      } else {
        // Local file path
        return Image.file(
          File(_user!.avatar!),
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultAvatar();
          },
        );
      }
    }

    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 100,
      height: 100,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D9488), Color(0xFF059669)],
        ),
      ),
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 48,
      ),
    );
  }

  // Image handling methods
  Future<void> _checkPermissions() async {
    final cameraStatus = await Permission.camera.status;
    final photosStatus = await Permission.photos.status;

    if (cameraStatus.isDenied) {
      await Permission.camera.request();
    }

    if (photosStatus.isDenied) {
      await Permission.photos.request();
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      await _checkPermissions();

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        await _uploadImage();
      }
    } catch (e) {
      AppDialogs.showSnackBar(
        message: 'Error accessing camera: ${e.toString()}',
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      await _checkPermissions();

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        await _uploadImage();
      }
    } catch (e) {
      AppDialogs.showSnackBar(
        message: 'Error accessing gallery: ${e.toString()}',
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _uploadImage() async {
    await context
        .read<SettingsCubit>()
        .uploadAvatar(filePath: _selectedImage!.path);
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: const Text(
                'Change Profile Picture',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
            const Divider(height: 1),
            _buildImageSourceOption(
              icon: Icons.camera_alt,
              title: 'Take Photo',
              subtitle: 'Use camera to take a new photo',
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            const Divider(height: 1),
            _buildImageSourceOption(
              icon: Icons.photo_library,
              title: 'Choose from Gallery',
              subtitle: 'Select from your photo library',
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            if (_selectedImage != null ||
                (_user?.avatar != null && _user!.avatar!.isNotEmpty)) ...[
              const Divider(height: 1),
              _buildImageSourceOption(
                icon: Icons.delete_outline,
                title: 'Remove Photo',
                subtitle: 'Remove current profile picture',
                onTap: () {
                  Navigator.pop(context);
                  _removeProfilePicture();
                },
                isDestructive: true,
              ),
            ],
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: (isDestructive ? Colors.red : const Color(0xFF0D9488))
              .withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red : const Color(0xFF0D9488),
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDestructive ? Colors.red : const Color(0xFF1F2937),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: isDestructive
              ? Colors.red.withOpacity(0.7)
              : const Color(0xFF6B7280),
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: isDestructive
            ? Colors.red.withOpacity(0.5)
            : const Color(0xFF9CA3AF),
      ),
    );
  }

  void _removeProfilePicture() {
    context.read<SettingsCubit>().removeAvatar();
  }
}
