import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mime/mime.dart';
import 'package:result_dart/result_dart.dart';

import '../../../../core/data/remote/base/api_error.dart';
import '../../../../core/data/remote/services/api_service.dart';
import '../model/search_model.dart';
import '../remote/media_api_service.dart';
import '../remote/search_api_service.dart';
import '../../domain/repository/search_repository.dart';

@Injectable(as: SearchRepository)
class SearchRepositoryImpl implements SearchRepository {
  final SearchApiService _searchApiService;
  final MediaApiService _mediaApiService;

  SearchRepositoryImpl({
    required SearchApiService searchApiService,
    required MediaApiService mediaApiService,
  })  : _searchApiService = searchApiService,
        _mediaApiService = mediaApiService;

  @override
  Future<Result<SearchResponse, ApiError>> searchByText({
    required String query,
    required int topK,
  }) async {
    try {
      final request = TextSearchRequest(query: query, topK: topK);
      final response = await _searchApiService.searchByText(request: request);
      return Success(response);
    } on DioException catch (e) {
      return Failure(e.toApiError());
    } catch (e, stackTrace) {
      print('SearchRepositoryImpl.searchByText error: $e');
      print('Stack trace: $stackTrace');
      return Failure(ApiError.unexpected());
    }
  }

  @override
  Future<Result<SearchResponse, ApiError>> searchByImage({
    required String imageUrl,
    required int topK,
  }) async {
    try {
      final request = ImageSearchRequest(imageUrl: imageUrl, topK: topK);
      final response = await _searchApiService.searchByImage(request: request);
      return Success(response);
    } on DioException catch (e) {
      return Failure(e.toApiError());
    } catch (e, stackTrace) {
      print('SearchRepositoryImpl.searchByImage error: $e');
      print('Stack trace: $stackTrace');
      return Failure(ApiError.unexpected());
    }
  }

  @override
  Future<Result<String, ApiError>> uploadImage({
    required String filePath,
  }) async {
    try {
      // Get presigned URL
      final fileName = filePath.split('/').last;
      final presignedUrlResponse = await _mediaApiService.getPresignedUrl(
        body: {
          'fileName': fileName,
          'type': 'upload',
        },
      );
      final uploadUrl = presignedUrlResponse.url;

      // Upload file to S3
      final file = File(filePath);
      final fileBytes = await file.readAsBytes();
      final mimeType = lookupMimeType(filePath) ?? 'image/jpeg';

      final uploadDio = Dio();
      await uploadDio.put(
        uploadUrl,
        data: fileBytes,
        options: Options(
          headers: {
            'Content-Type': mimeType,
            'Content-Length': fileBytes.length,
          },
          receiveTimeout: null,
          sendTimeout: null,
        ),
      );

      // Return the image URL without query parameters
      final imageUrl = uploadUrl.split('?').first;
      return Success(imageUrl);
    } on DioException catch (e) {
      return Failure(e.toApiError());
    } catch (e) {
      return Failure(ApiError.unexpected());
    }
  }
}

