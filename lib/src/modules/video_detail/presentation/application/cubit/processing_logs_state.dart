import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../data/models/processing_log_model.dart';

part 'processing_logs_state.freezed.dart';

@freezed
class ProcessingLogsState with _$ProcessingLogsState {
  const factory ProcessingLogsState.initial() = Initial;

  const factory ProcessingLogsState.loading() = Loading;
  const factory ProcessingLogsState.loaded(
      {required ProcessingLogsResponse logs}) = Loaded;

  const factory ProcessingLogsState.error({required String message}) = Error;
}
