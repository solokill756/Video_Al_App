import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:dmvgenie/src/modules/upload/data/model/video_model.dart';
import 'package:dmvgenie/src/modules/video_detail/domain/repository/video_detail_repository.dart';

import 'video_detail_state.dart';

@injectable
class VideoDetailCubit extends Cubit<VideoDetailState> {
  final VideoDetailRepository videoDetailRepository;

  VideoDetailCubit({required this.videoDetailRepository})
      : super(const VideoDetailState.initial());

  /// Get video detail
  Future<Video?> getVideoDetail(String videoId) async {
    try {
      emit(const VideoDetailState.loadingDetail());
      final video =
          await videoDetailRepository.getVideoDetail(videoId: videoId);
      emit(VideoDetailState.detailLoaded(video: video));
      return video;
    } catch (e) {
      emit(VideoDetailState.error(message: 'Error loading video details: $e'));
      return null;
    }
  }

  /// Update video
  Future<void> updateVideo({
    required String videoId,
    required String title,
    required String description,
  }) async {
    try {
      emit(const VideoDetailState.updating());
      await videoDetailRepository.updateVideo(
        videoId: videoId,
        title: title,
        description: description,
      );
      emit(const VideoDetailState.updateSuccess());
      // Reload detail
      await getVideoDetail(videoId);
    } catch (e) {
      emit(VideoDetailState.error(message: 'Error updating video: $e'));
    }
  }

  /// Delete video
  Future<void> deleteVideo(String videoId) async {
    try {
      emit(const VideoDetailState.deleting());
      await videoDetailRepository.deleteVideo(videoId: videoId);
      emit(const VideoDetailState.deleteSuccess());
    } catch (e) {
      emit(VideoDetailState.error(message: 'Error deleting video: $e'));
    }
  }

  /// Reset state
  void reset() {
    emit(const VideoDetailState.initial());
  }
}
