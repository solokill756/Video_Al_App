import 'dart:io';

import 'package:injectable/injectable.dart';

import '../../domain/repository/upload_repository.dart';
import '../model/video_model.dart' as video_m;
import '../remote/s3_upload_service.dart';
import '../remote/video_api_service.dart';

@Injectable(as: UploadRepository)
class UploadRepositoryImpl implements UploadRepository {
  final VideoApiService _videoApiService;
  final S3UploadService _s3UploadService;

  UploadRepositoryImpl(
    this._videoApiService,
    this._s3UploadService,
  );

  // ==================== Video Upload ====================

  @override
  Future<void> checkUploadLimit() async {
    await _videoApiService.checkUploadLimit();
  }

  @override
  Future<video_m.PresignedUrlResponse> getPresignedUrlForVideo({
    required String fileName,
  }) async {
    return await _videoApiService.getPresignedUrlForVideo(
      body: {
        'fileName': fileName,
        'type': 'upload',
      },
    );
  }

  @override
  Future<void> uploadVideoToS3({
    required String presignedUrl,
    required File videoFile,
    void Function(double)? onProgress,
  }) async {
    await _s3UploadService.uploadFile(
      presignedUrl: presignedUrl,
      filePath: videoFile.path,
      contentType: 'video/mp4',
      onProgress: onProgress,
    );
  }

  @override
  Future<video_m.PresignedUrlResponse> getPresignedUrlForThumbnail({
    required String fileName,
  }) async {
    return await _videoApiService.getPresignedUrlForThumbnail(
      body: {
        'fileName': fileName,
        'type': 'upload',
      },
    );
  }

  @override
  Future<void> uploadThumbnailToS3({
    required String presignedUrl,
    required File thumbnailFile,
    void Function(double)? onProgress,
  }) async {
    await _s3UploadService.uploadFile(
      presignedUrl: presignedUrl,
      filePath: thumbnailFile.path,
      contentType: 'image/jpeg',
      onProgress: onProgress,
    );
  }

  @override
  Future<video_m.Video> createVideo({
    required String title,
    required String description,
    required String videoUrl,
    String? thumbnailUrl,
  }) async {
    return await _videoApiService.createVideo(
      body: {
        'title': title,
        'description': description,
        'url': videoUrl,
        if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      },
    );
  }
}
