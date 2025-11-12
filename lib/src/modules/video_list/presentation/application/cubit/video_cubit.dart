import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:dmvgenie/src/modules/upload/data/model/video_model.dart';
import 'package:dmvgenie/src/modules/video_list/domain/repository/video_list_repository.dart';

import 'video_state.dart';

@injectable
class VideoCubit extends Cubit<VideoState> {
  final VideoListRepository videoListRepository;

  VideoCubit({required this.videoListRepository})
      : super(const VideoState.initial());

  int _currentPage = 1;
  final int _pageSize = 10;
  bool _hasMorePages = true;
  List<Video> _cachedVideos = [];
  bool _isLoadingMore = false;

  /// Load user videos
  Future<void> loadUserVideos({bool refresh = false}) async {
    try {
      if (refresh) {
        _currentPage = 1;
        _hasMorePages = true;
        _cachedVideos = [];
        _isLoadingMore = false;
        emit(const VideoState.loading());
      } else if (_cachedVideos.isEmpty) {
        // First load - show loading
        emit(const VideoState.loading());
      } else {
        // Subsequent loads - show cached data first
        emit(VideoState.videosLoaded(
          videos: _cachedVideos,
          hasMorePages: _hasMorePages,
          currentPage: _currentPage,
        ));
        // Don't fetch new data if not refreshing and have cache
        return;
      }

      final videoListResponse = await videoListRepository.getUserVideos(
        pageIndex: _currentPage,
        pageSize: _pageSize,
      );

      final videos = videoListResponse.data;
      _cachedVideos = videos;
      _hasMorePages = _currentPage < videoListResponse.pagination.totalPages;

      emit(VideoState.videosLoaded(
        videos: videos,
        hasMorePages: _hasMorePages,
        currentPage: _currentPage,
      ));

      _currentPage++;
    } catch (e) {
      emit(VideoState.error(message: 'Error loading videos: $e'));
    }
  }

  /// Load more videos (pagination)
  Future<void> loadMoreVideos() async {
    if (!_hasMorePages || _isLoadingMore) return;

    _isLoadingMore = true;
    try {
      emit(const VideoState.loadingMore());
      final videoListResponse = await videoListRepository.getUserVideos(
        pageIndex: _currentPage,
        pageSize: _pageSize,
      );

      final newVideos = videoListResponse.data;
      // Merge new videos with cached videos
      _cachedVideos.addAll(newVideos);

      _hasMorePages = _currentPage < videoListResponse.pagination.totalPages;

      emit(VideoState.videosLoaded(
        videos: _cachedVideos,
        hasMorePages: _hasMorePages,
        currentPage: _currentPage,
      ));

      _currentPage++;
    } catch (e) {
      emit(VideoState.error(message: 'Error loading more videos: $e'));
    } finally {
      _isLoadingMore = false;
    }
  }

  /// Reset state
  void reset() {
    _currentPage = 1;
    _hasMorePages = true;
    emit(const VideoState.initial());
  }

  /// Restore list state (used when going back from detail)
  void restoreListState() {
    if (_cachedVideos.isNotEmpty) {
      emit(VideoState.videosLoaded(
        videos: _cachedVideos,
        hasMorePages: _hasMorePages,
        currentPage: _currentPage,
      ));
    } else {
      emit(const VideoState.initial());
    }
  }
}
