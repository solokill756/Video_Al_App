import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:dmvgenie/src/modules/upload/data/model/video_model.dart';

part 'video_state.freezed.dart';

@freezed
class VideoState with _$VideoState {
  const factory VideoState.initial() = Initial;

  const factory VideoState.loading() = Loading;
  const factory VideoState.loadingMore() = LoadingMore;
  const factory VideoState.videosLoaded({
    required List<Video> videos,
    required bool hasMorePages,
    required int currentPage,
  }) = VideosLoaded;

  const factory VideoState.loadingDetail() = LoadingDetail;
  const factory VideoState.detailLoaded({required Video video}) = DetailLoaded;

  const factory VideoState.updating() = Updating;
  const factory VideoState.updateSuccess() = UpdateSuccess;

  const factory VideoState.deleting() = Deleting;
  const factory VideoState.deleteSuccess() = DeleteSuccess;

  const factory VideoState.error({required String message}) = Error;
}
