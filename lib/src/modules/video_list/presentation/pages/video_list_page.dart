import 'package:auto_route/auto_route.dart';
import 'package:dmvgenie/src/common/dialogs/app_dialogs.dart';
import 'package:dmvgenie/src/common/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dmvgenie/src/modules/app/app_router.dart';
import '../application/cubit/video_cubit.dart';
import '../application/cubit/video_state.dart';

@RoutePage()
class VideoListPage extends StatelessWidget {
  const VideoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const VideoListView();
  }
}

class VideoListView extends StatefulWidget {
  const VideoListView({super.key});

  @override
  State<VideoListView> createState() => _VideoListViewState();
}

class _VideoListViewState extends State<VideoListView> {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Load videos on init
    context.read<VideoCubit>().loadUserVideos(refresh: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Only load more when at bottom and not already loading
    if (!_isLoadingMore &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 500) {
      _isLoadingMore = true;
      context.read<VideoCubit>().loadMoreVideos().then((_) {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => context.router.back(),
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
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF1F2937),
              size: 20,
            ),
          ),
        ),
        title: const Text(
          'My Videos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        centerTitle: true,
      ),
      body: BlocListener<VideoCubit, VideoState>(
        listener: (context, state) {
          state.maybeWhen(
            updating: () {
              context.showLoadingDialog(
                message: 'Updating video...',
                barrierDismissible: false,
                type: LoadingType.circular,
              );
            },
            updateSuccess: () {
              context.hideLoadingDialog();
              AppDialogs.showSnackBar(
                message: 'Video updated successfully!',
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              );
              // Reload videos after update
              context.read<VideoCubit>().loadUserVideos(refresh: true);
            },
            orElse: () {},
          );
        },
        child: BlocBuilder<VideoCubit, VideoState>(
          builder: (context, state) {
            return state.whenOrNull(
                  initial: () => const _LoadingWidget(),
                  loading: () => const _LoadingWidget(),
                  videosLoaded: (videos, hasMorePages, currentPage) =>
                      _buildVideoList(videos, hasMorePages),
                  loadingMore: () => const _LoadingWidget(),
                  error: (message) => _buildErrorWidget(message),
                ) ??
                const _LoadingWidget();
          },
        ),
      ),
    );
  }

  Widget _buildVideoList(List<dynamic> videos, bool hasMorePages) {
    if (videos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library,
              size: 64,
              color: Color(0xFFCBD5E1),
            ),
            SizedBox(height: 16),
            Text(
              'No videos yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF94A3B8),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Start uploading your first video',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFFCBD5E1),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<VideoCubit>().loadUserVideos(refresh: true);
      },
      child: Stack(
        children: [
          ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: videos.length + (hasMorePages ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == videos.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF0D9488),
                    ),
                  ),
                );
              }

              final video = videos[index];
              return _buildVideoCard(video);
            },
          ),
          // Pagination controls at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: hasMorePages
                        ? () {
                            context.read<VideoCubit>().loadMoreVideos();
                          }
                        : null,
                    icon: const Icon(Icons.navigate_next),
                    label: const Text('Load More'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      disabledBackgroundColor: const Color(0xFFCBD5E1),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  if (!hasMorePages)
                    const Text(
                      'No more videos',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(dynamic video) {
    return GestureDetector(
      onTap: () {
        // Navigate to video detail
        context.router.push(VideoDetailRoute(videoId: video.id));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: video.thumbnailUrl != null
                  ? Image.network(
                      video.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const _ThumbnailPlaceholder(),
                    )
                  : const _ThumbnailPlaceholder(),
            ),
            // Video Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    video.description ?? 'No description',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status: ${video.status}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Uploaded on ${_formatDate(video.createdAt)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
            'Error',
            style: TextStyle(
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
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<VideoCubit>().loadUserVideos(refresh: true);
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

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
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

class _ThumbnailPlaceholder extends StatelessWidget {
  const _ThumbnailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.video_library,
          size: 48,
          color: Color(0xFFCBD5E1),
        ),
      ),
    );
  }
}
