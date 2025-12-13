import '../../data/models/private_search_model.dart';

abstract class PrivateSearchRepository {
  /// Load data và tạo session
  Future<LoadDataResponse> loadData(List<String> videoIds);

  /// Search by text
  Future<PrivateSearchResponse> searchByText({
    required String sessionId,
    required String query,
    int topK = 20,
  });

  /// Search by image URL
  Future<PrivateSearchResponse> searchByImageUrl({
    required String sessionId,
    required String imageUrl,
    int topK = 20,
  });

  /// Unload session
  Future<void> unloadSession(String sessionId);
}
