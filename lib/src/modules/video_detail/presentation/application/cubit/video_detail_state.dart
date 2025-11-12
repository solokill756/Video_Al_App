import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:dmvgenie/src/modules/upload/data/model/video_model.dart';

part 'video_detail_state.freezed.dart';

@freezed
class VideoDetailState with _$VideoDetailState {
  const factory VideoDetailState.initial() = Initial;

  const factory VideoDetailState.loadingDetail() = LoadingDetail;
  const factory VideoDetailState.detailLoaded({required Video video}) =
      DetailLoaded;

  const factory VideoDetailState.updating() = Updating;
  const factory VideoDetailState.updateSuccess() = UpdateSuccess;

  const factory VideoDetailState.deleting() = Deleting;
  const factory VideoDetailState.deleteSuccess() = DeleteSuccess;

  const factory VideoDetailState.error({required String message}) = Error;
}
