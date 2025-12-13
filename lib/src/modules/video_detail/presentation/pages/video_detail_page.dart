import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:dmvgenie/src/common/dialogs/app_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dmvgenie/src/modules/video_detail/presentation/application/cubit/video_detail_cubit.dart';
import 'package:dmvgenie/src/modules/video_detail/presentation/application/cubit/video_detail_state.dart';
import 'package:dmvgenie/src/modules/video_detail/presentation/widgets/improved_video_player.dart';
import 'package:dmvgenie/src/modules/video_detail/presentation/application/cubit/private_search_cubit.dart';
import 'package:dmvgenie/src/modules/video_detail/presentation/application/cubit/private_search_state.dart';
import 'package:dmvgenie/src/modules/video_detail/presentation/application/cubit/processing_logs_cubit.dart';
import 'package:dmvgenie/src/modules/video_detail/presentation/application/cubit/processing_logs_state.dart';
import 'package:dmvgenie/src/modules/video_detail/presentation/widgets/processing_logs_timeline.dart';
import 'package:dmvgenie/src/modules/video_detail/data/models/private_search_model.dart';
import 'package:dmvgenie/src/modules/upload/data/remote/video_api_service.dart';
import 'package:dmvgenie/src/modules/upload/data/remote/s3_upload_service.dart';
import 'package:dmvgenie/src/common/utils/getit_utils.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../common/widgets/loading_widget.dart';

@RoutePage()
class VideoDetailPage extends StatelessWidget {
  final String videoId;

  const VideoDetailPage({
    super.key,
    required this.videoId,
  });

  @override
  Widget build(BuildContext context) {
    return VideoDetailView(videoId: videoId);
  }
}

class VideoDetailView extends StatefulWidget {
  final String videoId;

  const VideoDetailView({
    super.key,
    required this.videoId,
  });

  @override
  State<VideoDetailView> createState() => _VideoDetailViewState();
}

class _VideoDetailViewState extends State<VideoDetailView> {
  final GlobalKey _playerKey = GlobalKey();
  final GlobalKey _videoPlayerKey = GlobalKey();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _sessionId;
  bool _isImageSearch = false;
  XFile? _selectedImage;
  PrivateSearchCubit? _privateSearchCubit;
  late final ImagePicker _imagePicker;
  bool _isPickingImage = false;

  @override
  void initState() {
    super.initState();
    _imagePicker = ImagePicker();
    context.read<VideoDetailCubit>().getVideoDetail(widget.videoId);
    // Load processing logs for the video
    context.read<ProcessingLogsCubit>().getProcessingLogs(
          videoId: widget.videoId,
        );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Save reference to cubit for safe access in dispose
    _privateSearchCubit ??= context.read<PrivateSearchCubit>();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    // Unload session when leaving page (using saved reference)
    if (_sessionId != null && _privateSearchCubit != null) {
      _privateSearchCubit!.unloadSession();
    }
    super.dispose();
  }

  /// Extract video ID from URL
  String? _extractVideoIdFromUrl(String url) {
    final match = RegExp(
      r'([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})\.mp4',
      caseSensitive: false,
    ).firstMatch(url);
    return match?.group(1);
  }

  /// Get current session ID from state
  String? _getCurrentSessionId() {
    final state = context.read<PrivateSearchCubit>().state;
    return state.whenOrNull(
      sessionLoaded: (sessionId, _) => sessionId,
      searchResults: (results, totalIndexed, tookMs, sessionId) => sessionId,
    );
  }

  /// Perform image search: upload image to S3 then search
  Future<void> _performImageSearch() async {
    if (_selectedImage == null) return;

    final sessionId = _getCurrentSessionId();
    if (sessionId == null) {
      AppDialogs.showSnackBar(
        message: 'Session not loaded yet',
        backgroundColor: Colors.orange,
      );
      return;
    }

    try {
      // Show loading
      context.showLoadingDialog(
          message: 'Uploading image for search...', type: LoadingType.dots);

      // Step 1: Get presigned URL for image
      final imageFileName =
          'search-images/${DateTime.now().millisecondsSinceEpoch}_${_selectedImage!.name}';

      // Use VideoApiService to get presigned URL (reuse thumbnail endpoint for images)
      final videoApiService = getIt<VideoApiService>();
      final presignedUrlResponse =
          await videoApiService.getPresignedUrlForThumbnail(
        body: {
          'fileName': imageFileName,
          'type': 'upload',
        },
      );

      // Step 2: Upload image to S3
      final s3UploadService = getIt<S3UploadService>();
      final imageFile = File(_selectedImage!.path);
      await s3UploadService.uploadFile(
        presignedUrl: presignedUrlResponse.url,
        filePath: imageFile.path,
        contentType: 'image/jpeg',
      );

      // Step 3: Get image URL (remove query params from presigned URL)
      final imageUrl = presignedUrlResponse.url.split('?').first;

      context.hideLoadingDialog();

      // Step 4: Search with image URL
      context.read<PrivateSearchCubit>().searchByImageUrl(imageUrl);

      context.showLoadingDialog(
        message: 'Searching...',
        type: LoadingType.dots,
      );
    } catch (e) {
      context.hideLoadingDialog();
      AppDialogs.showSnackBar(
        message: 'Failed to search image: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  /// Load session when video is COMPLETED
  void _loadSessionIfNeeded(dynamic video) {
    if (video.status == 'COMPLETED' && _sessionId == null) {
      final videoId = _extractVideoIdFromUrl(video.url);
      if (videoId != null) {
        context.read<PrivateSearchCubit>().loadSession([videoId]);
      } else {
        print('⚠️ Could not extract video ID from URL: ${video.url}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () {
            context.router.maybePop();
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF1F2937),
              size: 18,
            ),
          ),
        ),
        title: const Text(
          'Video Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        centerTitle: true,
      ),
      body: MultiBlocListener(
        listeners: [
          // Listen to video detail state to load session when COMPLETED
          BlocListener<VideoDetailCubit, VideoDetailState>(
            listener: (context, state) {
              state.whenOrNull(
                detailLoaded: (video) {
                  _loadSessionIfNeeded(video);
                },
              );
            },
          ),
          // Listen to private search state to update session ID
          BlocListener<PrivateSearchCubit, PrivateSearchState>(
            listener: (context, state) {
              state.whenOrNull(
                sessionLoaded: (sessionId, totalVectors) {
                  setState(() {
                    _sessionId = sessionId;
                  });
                  AppDialogs.showSnackBar(
                    message: 'Session loaded! Start to Searching',
                    backgroundColor: Colors.green,
                  );
                },
                searchResults: (results, totalIndexed, tookMs, sessionId) {
                  context.hideLoadingDialog();
                  AppDialogs.showSnackBar(
                    message: 'Searching completed!',
                    backgroundColor: Colors.green,
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
          ),
        ],
        child: BlocBuilder<VideoDetailCubit, VideoDetailState>(
          builder: (context, state) {
            return state.whenOrNull(
                  loadingDetail: () => const _LoadingWidget(),
                  detailLoaded: (video) => _buildVideoDetail(video),
                  error: (message) => _buildErrorWidget(message),
                ) ??
                const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildVideoDetail(dynamic video) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Improved Video Player
          Container(
            key: _videoPlayerKey,
            color: Colors.black,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: ImprovedVideoPlayer(
                key: _playerKey,
                videoUrl: video.url,
                videoTitle: video.title,
              ),
            ),
          ),

          // Video Info Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Status in Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        video.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(video.status).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getStatusColor(video.status),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(video.status),
                            size: 14,
                            color: _getStatusColor(video.status),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            video.status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(video.status),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Description and Info in Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description Card
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.description_outlined,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Description',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              video.description ?? 'No description provided',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                                height: 1.5,
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Info Grid
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              icon: Icons.calendar_today_outlined,
                              label: 'Uploaded',
                              value: _formatDateTime(video.createdAt),
                            ),
                            const SizedBox(height: 14),
                            const Divider(height: 1, thickness: 1),
                            const SizedBox(height: 14),
                            _buildInfoRow(
                              icon: Icons.update_outlined,
                              label: 'Updated',
                              value: _formatDateTime(video.updatedAt),
                            ),
                            const SizedBox(height: 14),
                            const Divider(height: 1, thickness: 1),
                            const SizedBox(height: 14),
                            _buildInfoRow(
                              icon: Icons.link_outlined,
                              label: 'Video URL',
                              value: video.url,
                              isCopyable: true,
                              isUrl: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showEditDialog(video),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0D9488),
                          side: const BorderSide(
                            color: Color(0xFF0D9488),
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showDeleteDialog(video),
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text(
                          'Delete',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade500,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Processing Logs Timeline
          Container(
            margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: BlocBuilder<ProcessingLogsCubit, ProcessingLogsState>(
              builder: (context, state) {
                return state.whenOrNull(
                      loaded: (logs) => ProcessingLogsTimeline(
                        processingLog: logs,
                      ),
                      loading: () => Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (message) => Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFEF4444).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Color(0xFFEF4444),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                message,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFFEF4444),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ) ??
                    const SizedBox.shrink();
              },
            ),
          ),

          // Search Panel (Below video info)
          _buildSearchPanel(video),
        ],
      ),
    );
  }

  Widget _buildSearchPanel(dynamic video) {
    return Container(
      margin: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search Header
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0D9488).withOpacity(0.1),
                  const Color(0xFF14B8A6).withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              border: const Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search,
                  color: Color(0xFF0D9488),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Search in Video',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                // Status indicator
                if (video.status == 'COMPLETED')
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Ready',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else if (video.status == 'PROCESSING')
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Processing',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Search Content
          video.status == 'COMPLETED'
              ? _buildSearchContent()
              : SizedBox(
                  height: 300,
                  child: _buildProcessingMessage(video.status),
                ),
        ],
      ),
    );
  }

  Widget _buildProcessingMessage(String status) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == 'PENDING'
                  ? Icons.hourglass_bottom
                  : Icons.error_outline,
              size: 48,
              color: status == 'PENDING' ? Colors.orange : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              status == 'PENDING'
                  ? 'Video is being processed'
                  : 'Video processing failed',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              status == 'PENDING'
                  ? 'Please wait for processing to complete before searching'
                  : 'Please try uploading the video again',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchContent() {
    return BlocBuilder<PrivateSearchCubit, PrivateSearchState>(
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search Mode Toggle
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isImageSearch = false;
                          _selectedImage = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !_isImageSearch
                              ? const Color(0xFF0D9488)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.text_fields_rounded,
                              size: 16,
                              color: !_isImageSearch
                                  ? Colors.white
                                  : Colors.grey[600],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Text',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: !_isImageSearch
                                    ? Colors.white
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isImageSearch = true;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _isImageSearch
                              ? const Color(0xFF0D9488)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_rounded,
                              size: 16,
                              color: _isImageSearch
                                  ? Colors.white
                                  : Colors.grey[600],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Image',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _isImageSearch
                                    ? Colors.white
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Search Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _isImageSearch
                  ? _buildImageSearchInput()
                  : _buildTextSearchInput(),
            ),
            const SizedBox(height: 12),
            // Search Results
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 400,
              ),
              child: state.whenOrNull(
                    searching: () => const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
                      ),
                    ),
                    searchResults: (results, totalIndexed, tookMs, sessionId) =>
                        _buildSearchResults(results),
                    error: (message) => SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.red.shade200,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                color: Colors.red.shade700,
                                size: 40,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _formatErrorMessage(message),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                                softWrap: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    sessionLoaded: (sessionId, totalVectors) =>
                        _buildEmptyState(),
                  ) ??
                  _buildEmptyState(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextSearchInput() {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Enter search query...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF0D9488),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              final sessionId = _getCurrentSessionId();
              if (sessionId != null) {
                context.read<PrivateSearchCubit>().searchByText(value.trim());
              } else {
                AppDialogs.showSnackBar(
                  message: 'Session not loaded yet',
                  backgroundColor: Colors.orange,
                );
              }
            }
          },
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (_searchController.text.trim().isNotEmpty) {
                final sessionId = _getCurrentSessionId();
                if (sessionId != null) {
                  context
                      .read<PrivateSearchCubit>()
                      .searchByText(_searchController.text.trim());
                } else {
                  AppDialogs.showSnackBar(
                    message: 'Session not loaded yet',
                    backgroundColor: Colors.orange,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Search'),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSearchInput() {
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            // Prevent multiple simultaneous picks
            if (_isPickingImage) return;

            _isPickingImage = true;
            try {
              final XFile? image = await _imagePicker.pickImage(
                source: ImageSource.gallery,
              );
              if (image != null && mounted) {
                setState(() {
                  _selectedImage = image;
                });
              }
            } catch (e) {
              if (mounted) {
                AppDialogs.showSnackBar(
                  message: 'Error picking image: $e',
                  backgroundColor: Colors.red,
                );
              }
            } finally {
              _isPickingImage = false;
            }
          },
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 2,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.file(
                      File(_selectedImage!.path),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.broken_image),
                        );
                      },
                    ),
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_outlined,
                          size: 32,
                          color: Color(0xFF9CA3AF),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap to select image',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              if (_selectedImage != null) {
                await _performImageSearch();
              } else {
                AppDialogs.showSnackBar(
                  message: 'Please select an image',
                  backgroundColor: Colors.orange,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Search'),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_rounded,
                size: 48,
                color: Color(0xFF0D9488),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No search results yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter a query to search within this video',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(List<PrivateSearchResult> results) {
    if (results.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'No results found',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        final timeInSeconds = result.ptsTime.toInt();
        final minutes = timeInSeconds ~/ 60;
        final seconds = timeInSeconds % 60;

        return GestureDetector(
          onTap: () {
            // Jump to timestamp in video player
            final playerState = _playerKey.currentState;
            if (playerState != null) {
              // Call seekTo method via dynamic call (since _ImprovedVideoPlayerState is private)
              try {
                (playerState as dynamic)
                    .seekTo(Duration(seconds: timeInSeconds));

                // Scroll to video player
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_videoPlayerKey.currentContext != null) {
                    Scrollable.ensureVisible(
                      _videoPlayerKey.currentContext!,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  }
                });
              } catch (e) {
                print('Error seeking video: $e');
              }
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Timestamp
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Score
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Frame ${result.frameIdx}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${(result.score * 100).toStringAsFixed(1)}% match',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                // Jump icon
                const Icon(
                  Icons.play_arrow,
                  color: Color(0xFF0D9488),
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isCopyable = false,
    bool isUrl = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF0D9488).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF0D9488)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isUrl ? _shortenUrl(value) : value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color:
                      isUrl ? const Color(0xFF0D9488) : const Color(0xFF1F2937),
                ),
                maxLines: isUrl ? 2 : 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (isCopyable)
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              AppDialogs.showSnackBar(
                message: 'Copied to clipboard!',
                backgroundColor: Colors.green,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.copy_outlined,
                size: 16,
                color: Color(0xFF0D9488),
              ),
            ),
          ),
      ],
    );
  }

  void _showEditDialog(dynamic video) {
    final titleController = TextEditingController(text: video.title);
    final descriptionController =
        TextEditingController(text: video.description ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Edit Video',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Video Title',
                  hintText: 'Enter video title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF0D9488),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter video description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF0D9488),
                      width: 2,
                    ),
                  ),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              context.read<VideoDetailCubit>().updateVideo(
                    videoId: video.id,
                    title: titleController.text,
                    description: descriptionController.text,
                  );
              Navigator.pop(context);
              AppDialogs.showSnackBar(
                message: 'Video updated successfully!',
                backgroundColor: Colors.green,
              );
            },
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(dynamic video) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Delete Video',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${video.title}"?\n\nThis action cannot be undone.',
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7280),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              context.read<VideoDetailCubit>().deleteVideo(video.id);
              Navigator.pop(context);
              AppDialogs.showSnackBar(
                message: 'Video deleted successfully!',
                backgroundColor: Colors.red,
              );
            },
            child: const Text(
              'Delete',
              style:
                  TextStyle(color: Colors.white, backgroundColor: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          const Text(
            'Error loading video',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              context.read<VideoDetailCubit>().getVideoDetail(widget.videoId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PROCESSING':
        return Colors.orange;
      case 'COMPLETED':
        return Colors.green;
      case 'FAILED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'PROCESSING':
        return Icons.hourglass_bottom;
      case 'COMPLETED':
        return Icons.check_circle;
      case 'FAILED':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _shortenUrl(String url) {
    if (url.length > 50) {
      final start = url.substring(0, 25);
      final end = url.substring(url.length - 20);
      return '$start...$end';
    }
    return url;
  }

  /// Format error message to be shorter and more user-friendly
  String _formatErrorMessage(String message) {
    // Extract key information from DioException
    if (message.contains('404')) {
      return 'Session endpoint not found (404).\nPlease check if the private search service is running.';
    }
    if (message.contains('DioException')) {
      // Extract status code if available
      final statusMatch = RegExp(r'status code of (\d+)').firstMatch(message);
      if (statusMatch != null) {
        final statusCode = statusMatch.group(1);
        return 'Request failed with status $statusCode.\nPlease try again later.';
      }
      // Extract connection error
      if (message.contains('connection error') ||
          message.contains('Connection refused')) {
        return 'Cannot connect to search service.\nPlease check your connection.';
      }
      // Generic DioException
      return 'Network error occurred.\nPlease try again later.';
    }
    // If message is too long, truncate it
    if (message.length > 150) {
      return '${message.substring(0, 147)}...';
    }
    return message;
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          Color(0xFF0D9488),
        ),
      ),
    );
  }
}
