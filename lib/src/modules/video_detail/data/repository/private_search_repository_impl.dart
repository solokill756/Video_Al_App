import 'package:injectable/injectable.dart';

import '../../domain/repository/private_search_repository.dart';
import '../models/private_search_model.dart';
import '../remote/private_search_api_service.dart';

@Injectable(as: PrivateSearchRepository)
class PrivateSearchRepositoryImpl implements PrivateSearchRepository {
  final PrivateSearchApiService _apiService;

  PrivateSearchRepositoryImpl(this._apiService);

  @override
  Future<LoadDataResponse> loadData(List<String> videoIds) async {
    final response = await _apiService.loadData(
      body: {'video_ids': videoIds},
    );
    return response;
  }

  @override
  Future<PrivateSearchResponse> searchByText({
    required String sessionId,
    required String query,
    int topK = 20,
  }) async {
    final response = await _apiService.searchByText(
      body: {
        'session_id': sessionId,
        'query': query,
        'top_k': topK,
      },
    );
    return response;
  }

  @override
  Future<PrivateSearchResponse> searchByImageUrl({
    required String sessionId,
    required String imageUrl,
    int topK = 20,
  }) async {
    final response = await _apiService.searchByImageUrl(
      body: {
        'session_id': sessionId,
        'image_url': imageUrl,
        'top_k': topK,
      },
    );
    return response;
  }

  @override
  Future<void> unloadSession(String sessionId) async {
    await _apiService.unloadSession(sessionId: sessionId);
  }
}

