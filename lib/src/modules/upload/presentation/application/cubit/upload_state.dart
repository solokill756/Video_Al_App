import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../upload/data/model/video_model.dart';

part 'upload_state.freezed.dart';

@freezed
class UploadState with _$UploadState {
  const factory UploadState.initial() = Initial;

  const factory UploadState.checkingLimit() = CheckingLimit;
  const factory UploadState.limitChecked() = LimitChecked;
  const factory UploadState.limitExceeded({required String message}) =
      LimitExceeded;

  const factory UploadState.gettingPresignedUrl() = GettingPresignedUrl;
  const factory UploadState.presignedUrlObtained({required String url}) =
      PresignedUrlObtained;

  const factory UploadState.uploadingToS3({
    required double progress,
    required String fileName,
  }) = UploadingToS3;

  const factory UploadState.creatingVideoRecord() = CreatingVideoRecord;
  const factory UploadState.uploadSuccess({required Video video}) =
      UploadSuccess;

  const factory UploadState.error({required String message}) = Error;
}
