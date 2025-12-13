import 'package:injectable/injectable.dart';
import '../../domain/repository/video_processing_repository.dart';
import '../../../../modules/upload/data/remote/video_api_service.dart';
import '../models/processing_log_model.dart';

@Injectable(as: VideoProcessingRepository)
class VideoProcessingRepositoryImpl implements VideoProcessingRepository {
  final VideoApiService _videoApiService;

  VideoProcessingRepositoryImpl({required VideoApiService videoApiService})
      : _videoApiService = videoApiService;

  @override
  Future<ProcessingLogsResponse> getProcessingLogs(
      {required String videoId}) async {
    return await _videoApiService.getProcessingLogs(videoId: videoId);
  }
}
