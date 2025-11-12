import 'package:dmvgenie/src/common/dialogs/app_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../application/cubit/upload_cubit.dart';
import '../application/cubit/upload_state.dart';
import 'video_metadata_form.dart';

class VideoUploadWidget extends StatefulWidget {
  const VideoUploadWidget({super.key});

  @override
  State<VideoUploadWidget> createState() => _VideoUploadWidgetState();
}

class _VideoUploadWidgetState extends State<VideoUploadWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isHovering = false;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _selectedFileName;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleFileSelect() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Select Video Source',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.video_library,
                  color: Color(0xFF0D9488),
                ),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideoFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.video_camera_back,
                  color: Color(0xFF7C3AED),
                ),
                title: const Text('Record Video'),
                onTap: () {
                  Navigator.pop(context);
                  _recordVideo();
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickVideoFromGallery() async {
    try {
      final XFile? video = await ImagePicker().pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 30),
      );

      if (video != null) {
        _processVideo(video);
      }
    } catch (e) {
      AppDialogs.showSnackBar(
        message: 'Error picking video: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _recordVideo() async {
    try {
      final XFile? video = await ImagePicker().pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 30),
      );

      if (video != null) {
        _processVideo(video);
      }
    } catch (e) {
      AppDialogs.showSnackBar(
        message: 'Error recording video: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  void _processVideo(XFile video) {
    // Extract filename
    final fileName = video.name;

    setState(() {
      _selectedFileName = fileName;
      _isUploading = false; // Show form before uploading
    });

    // Show metadata form in a bottom sheet
    _showMetadataForm(video);
  }

  void _showMetadataForm(XFile video) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: VideoMetadataForm(
                onFormSubmitted: (title, description, thumbnail) {
                  Navigator.pop(context);
                  _startUpload(title, description, thumbnail, video);
                },
              ),
            ),
          ),
        ),
      ),
    ).then((_) {
      // When dialog closes (user tapped back or outside), reset if no upload started
      if (!_isUploading) {
        setState(() {
          _selectedFileName = null;
        });
      }
    });
  }

  void _startUpload(
      String title, String description, XFile? thumbnail, XFile videoFile) {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    // Emit upload event to cubit
    context.read<UploadCubit>().uploadVideo(
          title: title,
          description: description,
          videoFile: videoFile,
          thumbnailFile: thumbnail,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UploadCubit, UploadState>(
      listener: (context, state) {
        state.whenOrNull(
          uploadingToS3: (progress, fileName) {
            setState(() {
              _uploadProgress = progress;
            });
          },
          uploadSuccess: (video) {
            setState(() {
              _isUploading = false;
            });
            AppDialogs.showSnackBar(
              message: 'Upload completed successfully!',
              backgroundColor: Colors.green,
            );
          },
          limitExceeded: (message) {
            setState(() {
              _isUploading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
          error: (message) {
            setState(() {
              _isUploading = false;
            });
            AppDialogs.showSnackBar(
              message: 'Upload failed: $message',
              backgroundColor: Colors.red,
            );
          },
        );
      },
      child: GestureDetector(
        onTap: _isUploading ? null : _handleFileSelect,
        onLongPress: () {
          setState(() => _isHovering = true);
        },
        onLongPressEnd: (_) {
          setState(() => _isHovering = false);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: _isHovering
                ? const Color(0xFF0D9488).withOpacity(0.05)
                : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isHovering
                  ? const Color(0xFF0D9488)
                  : const Color(0xFFE2E8F0),
              width: _isHovering ? 2 : 1.5,
              style: BorderStyle.solid,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isHovering ? 0.08 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isUploading && _selectedFileName == null) ...[
                // Upload Icon with Animation
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (0.1 * _animationController.value).abs(),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D9488).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.cloud_upload_outlined,
                          color: const Color(0xFF0D9488),
                          size: 40,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Drag and drop your video here',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'or tap to select from your device',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'MP4, MOV, AVI, MKV • Max 500MB',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF0D9488),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ] else if (_isUploading) ...[
                // // Uploading State
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(
                          value: _uploadProgress / 100,
                          strokeWidth: 4,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF0D9488),
                          ),
                        ),
                      ),
                      Text(
                        '${_uploadProgress.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D9488),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _selectedFileName ?? 'Uploading...',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please keep the app open',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ] else ...[
                // Upload Complete
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _selectedFileName ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Upload completed successfully',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF059669),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedFileName = null;
                      _uploadProgress = 0.0;
                    });
                    // Reset cubit state
                    context.read<UploadCubit>().reset();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Upload Another'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
