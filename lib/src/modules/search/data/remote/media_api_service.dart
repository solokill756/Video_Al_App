import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../upload/data/model/video_model.dart';

part 'media_api_service.g.dart';

@injectable
@RestApi()
abstract class MediaApiService {
  @factoryMethod
  factory MediaApiService(Dio dio, {@Named('baseUrl') String? baseUrl}) =
      _MediaApiService;

  // Get presigned URL for image upload
  @POST('/media/presigned-url')
  Future<PresignedUrlResponse> getPresignedUrl({
    @Body() required Map<String, String> body,
  });
}
