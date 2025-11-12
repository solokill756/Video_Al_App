import 'package:injectable/injectable.dart';
import 'package:dmvgenie/src/modules/upload/data/model/video_model.dart';
import 'package:dmvgenie/src/modules/upload/data/remote/video_api_service.dart';
import 'package:dmvgenie/src/modules/video_detail/domain/repository/video_detail_repository.dart';

@Injectable(as: VideoDetailRepository)
class VideoDetailRepositoryImpl implements VideoDetailRepository {
  final VideoApiService _videoApiService;

  VideoDetailRepositoryImpl({required VideoApiService videoApiService})
      : _videoApiService = videoApiService;

  @override
  Future<Video> getVideoDetail({required String videoId}) async {
    final response = await _videoApiService.getVideoDetail(videoId: videoId);
    return response;
  }

  @override
  Future<void> updateVideo({
    required String videoId,
    required String title,
    required String description,
  }) async {
    final body = {
      'title': title,
      'description': description,
    };
    await _videoApiService.updateVideo(
      videoId: videoId,
      body: body,
    );
  }

  @override
  Future<void> deleteVideo({required String videoId}) async {
    await _videoApiService.deleteVideo(videoId: videoId);
  }
}
