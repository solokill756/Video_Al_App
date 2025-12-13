import 'package:freezed_annotation/freezed_annotation.dart';

part 'processing_log_model.freezed.dart';
part 'processing_log_model.g.dart';

@freezed
class ProcessingLogEvent with _$ProcessingLogEvent {
  const factory ProcessingLogEvent({
    required int id,
    required String videoId,
    required String timestamp,
    required String step,
    required String details,
  }) = _ProcessingLogEvent;

  factory ProcessingLogEvent.fromJson(Map<String, dynamic> json) =>
      _$ProcessingLogEventFromJson(json);
}

@freezed
class ProcessingLogsResponse with _$ProcessingLogsResponse {
  const factory ProcessingLogsResponse({
    required List<ProcessingLogEvent> data,
  }) = _ProcessingLogsResponse;

  factory ProcessingLogsResponse.fromJson(Map<String, dynamic> json) =>
      _$ProcessingLogsResponseFromJson(json);
}
