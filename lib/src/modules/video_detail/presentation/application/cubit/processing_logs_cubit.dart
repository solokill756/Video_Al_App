import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/repository/video_processing_repository.dart';
import 'processing_logs_state.dart';

@injectable
class ProcessingLogsCubit extends Cubit<ProcessingLogsState> {
  final VideoProcessingRepository videoProcessingRepository;

  ProcessingLogsCubit({required this.videoProcessingRepository})
      : super(const ProcessingLogsState.initial());

  /// Get processing logs for a video
  Future<void> getProcessingLogs({required String videoId}) async {
    try {
      emit(const ProcessingLogsState.loading());
      final logs =
          await videoProcessingRepository.getProcessingLogs(videoId: videoId);
      emit(ProcessingLogsState.loaded(logs: logs));
    } catch (e) {
      emit(ProcessingLogsState.error(
          message: 'Error loading processing logs: $e'));
    }
  }

  /// Reset state
  void reset() {
    emit(const ProcessingLogsState.initial());
  }
}
