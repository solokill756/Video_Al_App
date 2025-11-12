import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mime/mime.dart';

@injectable
class S3UploadService {
  S3UploadService();

  /// Create a separate Dio instance optimized for large file uploads to S3
  Dio _createS3Dio() {
    return Dio(
      BaseOptions(
        // Extended timeouts for large file uploads
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(minutes: 10),
        sendTimeout: const Duration(minutes: 10),
        // Disable compression for binary files
        contentType: 'application/octet-stream',
      ),
    );
  }

  Future<void> uploadFile({
    required String presignedUrl,
    required String filePath,
    required String contentType,
    void Function(double)? onProgress,
  }) async {
    try {
      final file = File(filePath);
      final fileBytes = await file.readAsBytes();
      final mimeType = lookupMimeType(filePath) ?? 'application/octet-stream';

      // Use dedicated S3 Dio instance with extended timeouts
      final s3Dio = _createS3Dio();

      await s3Dio.put(
        presignedUrl,
        data: fileBytes,
        onSendProgress: (sent, total) {
          if (total > 0) {
            final progress = (sent / total) * 100;
            onProgress?.call(progress);
          }
        },
        options: Options(
          contentType: mimeType,
          headers: {
            'Content-Type': mimeType,
            'Content-Length': fileBytes.length,
          },
          validateStatus: (status) {
            // Accept 2xx status codes
            return status != null && status >= 200 && status < 300;
          },
        ),
      );
    } catch (e) {
      print('S3 Upload Error: $e');
      throw Exception('Failed to upload to S3: $e');
    }
  }
}
