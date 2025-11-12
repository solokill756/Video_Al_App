import 'package:injectable/injectable.dart';
import 'package:dmvgenie/src/modules/upload/data/model/video_model.dart';
import 'package:dmvgenie/src/modules/upload/data/remote/video_api_service.dart';
import 'package:dmvgenie/src/modules/video_list/domain/repository/video_list_repository.dart';

@Injectable(as: VideoListRepository)
class VideoListRepositoryImpl implements VideoListRepository {
  final VideoApiService _videoApiService;

  VideoListRepositoryImpl({required VideoApiService videoApiService})
      : _videoApiService = videoApiService;

  @override
  Future<VideoListResponse> getUserVideos({
    required int pageIndex,
    required int pageSize,
  }) async {
    final response = await _videoApiService.getUserVideos(
      pageIndex: pageIndex,
      pageSize: pageSize,
    );
    return response;
  }
}
