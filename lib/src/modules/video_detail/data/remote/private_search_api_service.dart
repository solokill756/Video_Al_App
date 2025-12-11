import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../models/private_search_model.dart';

part 'private_search_api_service.g.dart';

@injectable
@RestApi()
abstract class PrivateSearchApiService {
  @factoryMethod
  factory PrivateSearchApiService(
    Dio dio, {
    @Named('privateSearchApiUrl') String? baseUrl,
  }) = _PrivateSearchApiService;

  /// Load data và tạo session
  @POST('/load')
  Future<LoadDataResponse> loadData({
    @Body() required Map<String, dynamic> body,
  });

  /// Search by text
  @POST('/search/text')
  Future<PrivateSearchResponse> searchByText({
    @Body() required Map<String, dynamic> body,
  });

  /// Search by image URL
  @POST('/search/image-url')
  Future<PrivateSearchResponse> searchByImageUrl({
    @Body() required Map<String, dynamic> body,
  });

  /// Unload session
  @DELETE('/unload/{sessionId}')
  Future<void> unloadSession({
    @Path('sessionId') required String sessionId,
  });
}
