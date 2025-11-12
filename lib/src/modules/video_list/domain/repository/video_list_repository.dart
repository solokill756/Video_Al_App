import 'package:dmvgenie/src/modules/upload/data/model/video_model.dart';

abstract class VideoListRepository {
  /// Get user's video list
  Future<VideoListResponse> getUserVideos({
    required int pageIndex,
    required int pageSize,
  });
}
