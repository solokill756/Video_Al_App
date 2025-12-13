import 'package:result_dart/result_dart.dart';

import '../../../../core/data/remote/base/api_error.dart';
import '../../data/model/search_model.dart';

abstract class SearchRepository {
  Future<Result<SearchResponse, ApiError>> searchByText({
    required String query,
    required int topK,
  });

  Future<Result<SearchResponse, ApiError>> searchByImage({
    required String imageUrl,
    required int topK,
  });

  Future<Result<String, ApiError>> uploadImage({
    required String filePath,
  });
}

