import 'dart:io';
import '../../../upload/data/model/video_model.dart';

abstract class UploadRepository {
  // Video Upload - Only for the upload process
  Future<void> checkUploadLimit();

  Future<PresignedUrlResponse> getPresignedUrlForVideo({
    required String fileName,
  });

  Future<void> uploadVideoToS3({
    required String presignedUrl,
    required File videoFile,
    void Function(double)? onProgress,
  });

  Future<PresignedUrlResponse> getPresignedUrlForThumbnail({
    required String fileName,
  });

  Future<void> uploadThumbnailToS3({
    required String presignedUrl,
    required File thumbnailFile,
    void Function(double)? onProgress,
  });

  Future<Video> createVideo({
    required String title,
    required String description,
    required String videoUrl,
    String? thumbnailUrl,
  });
}
