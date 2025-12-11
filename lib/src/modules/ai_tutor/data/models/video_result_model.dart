import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_result_model.freezed.dart';
part 'video_result_model.g.dart';

@freezed
class VideoResultModel with _$VideoResultModel {
  const factory VideoResultModel({
    required String id,
    required String title,
    required String videoUrl,
    double? timestamp,
    String? thumbnailUrl,
    String? transcript,
    String? videoPath,
    double? score,
  }) = _VideoResultModel;

  factory VideoResultModel.fromJson(Map<String, dynamic> json) =>
      _$VideoResultModelFromJson(json);
}
