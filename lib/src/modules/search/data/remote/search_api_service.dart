import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../model/search_model.dart';

part 'search_api_service.g.dart';

@injectable
@RestApi()
abstract class SearchApiService {
  @factoryMethod
  factory SearchApiService(Dio dio, {@Named('searchApiUrl') String? baseUrl}) =
      _SearchApiService;

  // Text search
  @POST('/search/text')
  Future<SearchResponse> searchByText({
    @Body() required TextSearchRequest request,
  });

  // Image search
  @POST('/search/image-url')
  Future<SearchResponse> searchByImage({
    @Body() required ImageSearchRequest request,
  });
}
