import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../domain/repository/upload_repository.dart';
import 'upload_state.dart';

class UploadCubit extends Cubit<UploadState> {
  final UploadRepository uploadRepository;

  UploadCubit({required this.uploadRepository})
      : super(const UploadState.initial());

  /// Kiểm tra xem user có thể upload video hay không
  Future<void> checkUploadLimit() async {
    try {
      emit(const UploadState.checkingLimit());
      await uploadRepository.checkUploadLimit();
      emit(const UploadState.limitChecked());
    } catch (e) {
      if (e.toString().contains('limit') || e.toString().contains('exceeded')) {
        emit(const UploadState.limitExceeded(
          message:
              'You have reached your upload limit. Please upgrade your plan.',
        ));
      } else {
        emit(UploadState.error(message: 'Error checking upload limit: $e'));
      }
    }
  }

  /// Thực hiện toàn bộ quy trình upload video
  Future<void> uploadVideo({
    required String title,
    required String description,
    required XFile videoFile,
    XFile? thumbnailFile,
  }) async {
    try {
      // Bước 1: Kiểm tra giới hạn upload
      emit(const UploadState.checkingLimit());
      await uploadRepository.checkUploadLimit();
      emit(const UploadState.limitChecked());

      // Bước 2: Lấy presigned URL cho video
      emit(const UploadState.gettingPresignedUrl());
      final videoFileName =
          'videos/${DateTime.now().millisecondsSinceEpoch}_${videoFile.name}';
      final presignedUrlResponse = await uploadRepository
          .getPresignedUrlForVideo(fileName: videoFileName);
      final presignedUrl = presignedUrlResponse.url;

      emit(UploadState.presignedUrlObtained(url: presignedUrl));

      // Bước 3: Upload video lên S3
      emit(UploadState.uploadingToS3(progress: 0, fileName: videoFile.name));
      final videoFile0 = File(videoFile.path);
      await uploadRepository.uploadVideoToS3(
        presignedUrl: presignedUrl,
        videoFile: videoFile0,
        onProgress: (progress) {
          emit(UploadState.uploadingToS3(
              progress: progress, fileName: videoFile.name));
        },
      );
      emit(UploadState.uploadingToS3(progress: 100, fileName: videoFile.name));

      // Bước 4: Upload thumbnail nếu có
      String? thumbnailUrl;
      if (thumbnailFile != null) {
        try {
          final thumbFileName =
              'thumbnails/${DateTime.now().millisecondsSinceEpoch}_${thumbnailFile.name}';
          final thumbPresignedResponse = await uploadRepository
              .getPresignedUrlForThumbnail(fileName: thumbFileName);
          final thumbPresignedUrl = thumbPresignedResponse.url;

          final thumbFile = File(thumbnailFile.path);
          await uploadRepository.uploadThumbnailToS3(
            presignedUrl: thumbPresignedUrl,
            thumbnailFile: thumbFile,
            onProgress: (progress) {
              emit(UploadState.uploadingToS3(
                progress: progress,
                fileName: '${thumbnailFile.name} (thumbnail)',
              ));
            },
          );
          thumbnailUrl = thumbPresignedUrl.split('?').first;
        } catch (e) {
          print('Warning: Upload thumbnail failed: $e');
        }
      }

      // Step 5: Create video record in database
      emit(const UploadState.creatingVideoRecord());
      final videoUrl = presignedUrl.split('?').first;
      final video = await uploadRepository.createVideo(
        title: title,
        description: description,
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
      );
      emit(UploadState.uploadSuccess(video: video));
    } catch (e) {
      if (e.toString().contains('limit') || e.toString().contains('exceeded')) {
        emit(const UploadState.limitExceeded(
          message:
              'You have reached your upload limit. Please upgrade your plan.',
        ));
      } else {
        emit(UploadState.error(message: 'Lỗi upload video: $e'));
      }
    }
  }

  /// Reset state về initial
  void reset() {
    emit(const UploadState.initial());
  }
}
