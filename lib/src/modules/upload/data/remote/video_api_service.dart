import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/data/remote/base/api_response.dart';
import '../model/video_model.dart';

part 'video_api_service.g.dart';

@injectable
@RestApi()
abstract class VideoApiService {
  @factoryMethod
  factory VideoApiService(Dio dio, {@Named('baseUrl') String? baseUrl}) =
      _VideoApiService;

  // Check Upload Limit
  @POST('/videos/check-limit-upload-video')
  Future<StatusApiResponse> checkUploadLimit();

  // Get Presigned URL for Video
  @POST('/videos/presigned-url-upload-video')
  Future<PresignedUrlResponse> getPresignedUrlForVideo({
    @Body() required Map<String, String> body,
  });

  // Get Presigned URL for Thumbnail
  @POST('/videos/presigned-url-upload-video-thumbnail')
  Future<PresignedUrlResponse> getPresignedUrlForThumbnail({
    @Body() required Map<String, String> body,
  });

  // Create Video Record
  @POST('/videos')
  Future<Video> createVideo({
    @Body() required Map<String, dynamic> body,
  });

  // Get User Videos
  @GET('/videos/user')
  Future<VideoListResponse> getUserVideos({
    @Query('pageIndex') required int pageIndex,
    @Query('pageSize') required int pageSize,
  });

  // Get Video Detail
  @GET('/videos/{videoId}')
  Future<Video> getVideoDetail({
    @Path('videoId') required String videoId,
  });

  // Update Video
  @PUT('/videos/{videoId}')
  Future<Video> updateVideo({
    @Path('videoId') required String videoId,
    @Body() required Map<String, dynamic> body,
  });

  // Delete Video
  @DELETE('/videos/{videoId}')
  Future<StatusApiResponse> deleteVideo({
    @Path('videoId') required String videoId,
  });
}
