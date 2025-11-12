import 'package:auto_route/auto_route.dart';
import 'package:dmvgenie/src/common/dialogs/app_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/app_router.dart';
import '../components/video_upload_widget.dart';
import '../application/cubit/upload_cubit.dart';
import '../application/cubit/upload_state.dart';

@RoutePage()
class UploadVideoPage extends StatelessWidget {
  const UploadVideoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const UploadVideoView();
  }
}

class UploadVideoView extends StatefulWidget {
  const UploadVideoView({super.key});

  @override
  State<UploadVideoView> createState() => _UploadVideoViewState();
}

class _UploadVideoViewState extends State<UploadVideoView> {
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
    return BlocListener<UploadCubit, UploadState>(
      listener: (context, state) {
        state.whenOrNull(
          uploadSuccess: (video) {
            AppDialogs.showSnackBar(
              message: 'Video uploaded successfully: ${video.title}',
              backgroundColor: Colors.green,
            );
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) context.router.back();
            });
          },
          limitExceeded: (message) {
            AppDialogs.showSnackBar(
              message: message,
              backgroundColor: Colors.red,
            );
          },
          error: (message) {
            AppDialogs.showSnackBar(
              message: message,
              backgroundColor: Colors.red,
            );
          },
        );
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: const Text(
            'Upload Video',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          centerTitle: true,
          actions: [
            GestureDetector(
              onTap: () {
                // Navigate to VideoListRoute using the full route
                context.router.push(const VideoListRoute());
              },
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.video_library,
                  color: Color(0xFF64748B),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        body: BlocBuilder<UploadCubit, UploadState>(
          builder: (context, state) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Video Upload Widget
                    const VideoUploadWidget(),
                    const SizedBox(height: 32),
                    // Show upload progress
                    state.whenOrNull(
                          creatingVideoRecord: () =>
                              _buildCreatingVideoRecord(),
                        ) ??
                        _buildUploadDetailsSection(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUploadDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload Guidelines',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        _buildGuidelineItem(
          icon: Icons.video_file_outlined,
          title: 'Supported Formats',
          content: 'MP4, MOV, AVI, MKV, WebM (max 500MB)',
        ),
        const SizedBox(height: 12),
        _buildGuidelineItem(
          icon: Icons.info_outline,
          title: 'Video Duration',
          content: '5 seconds to 30 minutes recommended',
        ),
        const SizedBox(height: 12),
        _buildGuidelineItem(
          icon: Icons.check_circle_outline,
          title: 'Quality',
          content: '720p or higher recommended for best results',
        ),
        const SizedBox(height: 12),
        _buildGuidelineItem(
          icon: Icons.shield_outlined,
          title: 'Privacy',
          content: 'Your videos are encrypted and private',
        ),
      ],
    );
  }

  Widget _buildCreatingVideoRecord() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(0xFF0D9488),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Creating video record...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Please wait while we process your video',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF0D9488).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.video_file_outlined,
              color: Color(0xFF0D9488),
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
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
    );
  }
}
