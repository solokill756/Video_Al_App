import '../../data/models/processing_log_model.dart';

abstract class VideoProcessingRepository {
  /// Get processing logs for a video
  Future<ProcessingLogsResponse> getProcessingLogs({required String videoId});
}
