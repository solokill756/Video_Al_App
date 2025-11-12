import 'package:dmvgenie/src/modules/upload/data/model/video_model.dart';

abstract class VideoDetailRepository {
  /// Get video detail by ID
  Future<Video> getVideoDetail({required String videoId});

  /// Update video details
  Future<void> updateVideo({
    required String videoId,
    required String title,
    required String description,
  });

  /// Delete video
  Future<void> deleteVideo({required String videoId});
}
