import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dmvgenie/src/modules/video_detail/presentation/application/cubit/processing_logs_cubit.dart';
import 'package:dmvgenie/src/modules/video_detail/presentation/application/cubit/processing_logs_state.dart';
import 'package:dmvgenie/src/modules/video_detail/domain/repository/video_processing_repository.dart';
import 'package:dmvgenie/src/modules/video_detail/data/models/processing_log_model.dart';

class MockVideoProcessingRepository extends Mock implements VideoProcessingRepository {}

void main() {
  late ProcessingLogsCubit cubit;
  late MockVideoProcessingRepository mockRepository;

  setUp(() {
    mockRepository = MockVideoProcessingRepository();
    cubit = ProcessingLogsCubit(videoProcessingRepository: mockRepository);
  });

  tearDown(() {
    cubit.close();
  });

  group('ProcessingLogsCubit', () {
    const videoId = 'test-video-123';

    test('initial state should be Initial', () {
      expect(cubit.state, equals(const ProcessingLogsState.initial()));
    });

    group('getProcessingLogs', () {
      final mockLogsResponse = ProcessingLogsResponse(
        data: [
          const ProcessingLogEvent(
            id: 1,
            videoId: videoId,
            timestamp: '2025-01-15T10:30:00.000Z',
            step: 'Video Uploaded to S3',
            details: 'Video successfully uploaded',
          ),
          const ProcessingLogEvent(
            id: 2,
            videoId: videoId,
            timestamp: '2025-01-15T10:31:00.000Z',
            step: 'Shot Detection',
            details: 'Shot detection completed',
          ),
        ],
      );

      blocTest<ProcessingLogsCubit, ProcessingLogsState>(
        'emits [Loading, Loaded] when getProcessingLogs succeeds',
        build: () {
          when(() => mockRepository.getProcessingLogs(videoId: videoId))
              .thenAnswer((_) async => mockLogsResponse);
          return cubit;
        },
        act: (cubit) => cubit.getProcessingLogs(videoId: videoId),
        expect: () => [
          const ProcessingLogsState.loading(),
          ProcessingLogsState.loaded(logs: mockLogsResponse),
        ],
        verify: (_) {
          verify(() => mockRepository.getProcessingLogs(videoId: videoId))
              .called(1);
        },
      );

      blocTest<ProcessingLogsCubit, ProcessingLogsState>(
        'emits [Loading, Loaded] with empty logs when no logs available',
        build: () {
          const emptyResponse = ProcessingLogsResponse(data: []);
          when(() => mockRepository.getProcessingLogs(videoId: videoId))
              .thenAnswer((_) async => emptyResponse);
          return cubit;
        },
        act: (cubit) => cubit.getProcessingLogs(videoId: videoId),
        expect: () => [
          const ProcessingLogsState.loading(),
          const ProcessingLogsState.loaded(logs: ProcessingLogsResponse(data: [])),
        ],
        verify: (_) {
          verify(() => mockRepository.getProcessingLogs(videoId: videoId))
              .called(1);
        },
      );

      blocTest<ProcessingLogsCubit, ProcessingLogsState>(
        'emits [Loading, Error] when getProcessingLogs fails with exception',
        build: () {
          when(() => mockRepository.getProcessingLogs(videoId: videoId))
              .thenThrow(Exception('Network error'));
          return cubit;
        },
        act: (cubit) => cubit.getProcessingLogs(videoId: videoId),
        expect: () => [
          const ProcessingLogsState.loading(),
          const ProcessingLogsState.error(
            message: 'Error loading processing logs: Exception: Network error',
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.getProcessingLogs(videoId: videoId))
              .called(1);
        },
      );

      blocTest<ProcessingLogsCubit, ProcessingLogsState>(
        'emits [Loading, Error] when getProcessingLogs fails with timeout',
        build: () {
          when(() => mockRepository.getProcessingLogs(videoId: videoId))
              .thenThrow(Exception('Request timeout'));
          return cubit;
        },
        act: (cubit) => cubit.getProcessingLogs(videoId: videoId),
        expect: () => [
          const ProcessingLogsState.loading(),
          const ProcessingLogsState.error(
            message: 'Error loading processing logs: Exception: Request timeout',
          ),
        ],
      );

      blocTest<ProcessingLogsCubit, ProcessingLogsState>(
        'emits [Loading, Loaded] with single log event',
        build: () {
          final singleLogResponse = ProcessingLogsResponse(
            data: [
              const ProcessingLogEvent(
                id: 1,
                videoId: videoId,
                timestamp: '2025-01-15T10:30:00.000Z',
                step: 'Video Uploaded to S3',
                details: 'Upload complete',
              ),
            ],
          );
          when(() => mockRepository.getProcessingLogs(videoId: videoId))
              .thenAnswer((_) async => singleLogResponse);
          return cubit;
        },
        act: (cubit) => cubit.getProcessingLogs(videoId: videoId),
        expect: () => [
          const ProcessingLogsState.loading(),
          ProcessingLogsState.loaded(
            logs: ProcessingLogsResponse(
              data: [
                const ProcessingLogEvent(
                  id: 1,
                  videoId: videoId,
                  timestamp: '2025-01-15T10:30:00.000Z',
                  step: 'Video Uploaded to S3',
                  details: 'Upload complete',
                ),
              ],
            ),
          ),
        ],
      );

      blocTest<ProcessingLogsCubit, ProcessingLogsState>(
        'emits [Loading, Loaded] with multiple log events in correct order',
        build: () {
          final multipleLogsResponse = ProcessingLogsResponse(
            data: [
              const ProcessingLogEvent(
                id: 1,
                videoId: videoId,
                timestamp: '2025-01-15T10:00:00.000Z',
                step: 'Video Uploaded to S3',
                details: 'Upload started',
              ),
              const ProcessingLogEvent(
                id: 2,
                videoId: videoId,
                timestamp: '2025-01-15T10:05:00.000Z',
                step: 'Shot Detection',
                details: 'Detection started',
              ),
              const ProcessingLogEvent(
                id: 3,
                videoId: videoId,
                timestamp: '2025-01-15T10:10:00.000Z',
                step: 'Clip Embedding',
                details: 'Embedding started',
              ),
              const ProcessingLogEvent(
                id: 4,
                videoId: videoId,
                timestamp: '2025-01-15T10:15:00.000Z',
                step: 'Status Updated',
                details: 'Processing complete',
              ),
            ],
          );
          when(() => mockRepository.getProcessingLogs(videoId: videoId))
              .thenAnswer((_) async => multipleLogsResponse);
          return cubit;
        },
        act: (cubit) => cubit.getProcessingLogs(videoId: videoId),
        expect: () => [
          const ProcessingLogsState.loading(),
          ProcessingLogsState.loaded(logs: multipleLogsResponse),
        ],
        verify: (_) {
          final state = cubit.state;
          expect(state, isA<Loaded>());
          final loadedState = state as Loaded;
          expect(loadedState.logs.data, hasLength(4));
          expect(loadedState.logs.data[0].step, 'Video Uploaded to S3');
          expect(loadedState.logs.data[3].step, 'Status Updated');
        },
      );

      blocTest<ProcessingLogsCubit, ProcessingLogsState>(
        'handles consecutive calls for different video IDs',
        build: () {
          final logs1 = ProcessingLogsResponse(
            data: [
              const ProcessingLogEvent(
                id: 1,
                videoId: 'video-1',
                timestamp: '2025-01-15T10:30:00.000Z',
                step: 'Video Uploaded to S3',
                details: 'Upload for video 1',
              ),
            ],
          );
          final logs2 = ProcessingLogsResponse(
            data: [
              const ProcessingLogEvent(
                id: 2,
                videoId: 'video-2',
                timestamp: '2025-01-15T11:30:00.000Z',
                step: 'Shot Detection',
                details: 'Detection for video 2',
              ),
            ],
          );
          when(() => mockRepository.getProcessingLogs(videoId: 'video-1'))
              .thenAnswer((_) async => logs1);
          when(() => mockRepository.getProcessingLogs(videoId: 'video-2'))
              .thenAnswer((_) async => logs2);
          return cubit;
        },
        act: (cubit) async {
          await cubit.getProcessingLogs(videoId: 'video-1');
          await cubit.getProcessingLogs(videoId: 'video-2');
        },
        expect: () => [
          const ProcessingLogsState.loading(),
          ProcessingLogsState.loaded(
            logs: ProcessingLogsResponse(
              data: [
                const ProcessingLogEvent(
                  id: 1,
                  videoId: 'video-1',
                  timestamp: '2025-01-15T10:30:00.000Z',
                  step: 'Video Uploaded to S3',
                  details: 'Upload for video 1',
                ),
              ],
            ),
          ),
          const ProcessingLogsState.loading(),
          ProcessingLogsState.loaded(
            logs: ProcessingLogsResponse(
              data: [
                const ProcessingLogEvent(
                  id: 2,
                  videoId: 'video-2',
                  timestamp: '2025-01-15T11:30:00.000Z',
                  step: 'Shot Detection',
                  details: 'Detection for video 2',
                ),
              ],
            ),
          ),
        ],
      );

      blocTest<ProcessingLogsCubit, ProcessingLogsState>(
        'emits error with descriptive message on API failure',
        build: () {
          when(() => mockRepository.getProcessingLogs(videoId: videoId))
              .thenThrow(Exception('API returned 404'));
          return cubit;
        },
        act: (cubit) => cubit.getProcessingLogs(videoId: videoId),
        expect: () => [
          const ProcessingLogsState.loading(),
          const ProcessingLogsState.error(
            message: 'Error loading processing logs: Exception: API returned 404',
          ),
        ],
      );

      blocTest<ProcessingLogsCubit, ProcessingLogsState>(
        'handles large number of logs',
        build: () {
          final largeLogsList = List.generate(
            100,
            (i) => ProcessingLogEvent(
              id: i,
              videoId: videoId,
              timestamp: '2025-01-15T10:30:00.000Z',
              step: 'Step $i',
              details: 'Details for step $i',
            ),
          );
          final largeLogsResponse = ProcessingLogsResponse(data: largeLogsList);
          when(() => mockRepository.getProcessingLogs(videoId: videoId))
              .thenAnswer((_) async => largeLogsResponse);
          return cubit;
        },
        act: (cubit) => cubit.getProcessingLogs(videoId: videoId),
        expect: () => [
          const ProcessingLogsState.loading(),
          ProcessingLogsState.loaded(logs: largeLogsResponse),
        ],
        verify: (_) {
          final state = cubit.state;
          expect(state, isA<Loaded>());
          final loadedState = state as Loaded;
          expect(loadedState.logs.data, hasLength(100));
        },
      );

      blocTest<ProcessingLogsCubit, ProcessingLogsState>(
        'handles empty video ID',
        build: () {
          const emptyResponse = ProcessingLogsResponse(data: []);
          when(() => mockRepository.getProcessingLogs(videoId: ''))
              .thenAnswer((_) async => emptyResponse);
          return cubit;
        },
        act: (cubit) => cubit.getProcessingLogs(videoId: ''),
        expect: () => [
          const ProcessingLogsState.loading(),
          const ProcessingLogsState.loaded(logs: ProcessingLogsResponse(data: [])),
        ],
      );

      blocTest<ProcessingLogsCubit, ProcessingLogsState>(
        'handles special characters in video ID',
        build: () {
          const specialVideoId = 'video-@#\$%-special';
          final response = ProcessingLogsResponse(
            data: [
              const ProcessingLogEvent(
                id: 1,
                videoId: specialVideoId,
                timestamp: '2025-01-15T10:30:00.000Z',
                step: 'Video Uploaded to S3',
                details: 'Upload complete',
              ),
            ],
          );
          when(() => mockRepository.getProcessingLogs(videoId: specialVideoId))
              .thenAnswer((_) async => response);
          return cubit;
        },
        act: (cubit) => cubit.getProcessingLogs(videoId: 'video-@#\$%-special'),
        expect: () => [
          const ProcessingLogsState.loading(),
          ProcessingLogsState.loaded(logs: response),
        ],
      );
    });

    group('reset', () {
      blocTest<ProcessingLogsCubit, ProcessingLogsState>(
        'resets to initial state from loaded state',
        build: () {
          final mockResponse = ProcessingLogsResponse(
            data: [
              const ProcessingLogEvent(
                id: 1,
                videoId: videoId,
                timestamp: '2025-01-15T10:30:00.000Z',
                step: 'Video Uploaded to S3',
                details: 'Upload complete',
              ),
            ],
          );
          when(() => mockRepository.getProcessingLogs(videoId: videoId))
              .thenAnswer((_) async => mockResponse);
          return cubit;
        },
        act: (cubit) async {
          await cubit.getProcessingLogs(videoId: videoId);
          cubit.reset();
        },
        expect: () => [
          const ProcessingLogsState.loading(),
          ProcessingLogsState.loaded(
            logs: ProcessingLogsResponse(
              data: [
                const ProcessingLogEvent(
                  id: 1,
                  videoId: videoId,
                  timestamp: '2025-01-15T10:30:00.000Z',
                  step: 'Video Uploaded to S3',
                  details: 'Upload complete',
                ),
              ],
            ),
          ),
          const ProcessingLogsState.initial(),
        ],
      );

      blocTest<ProcessingLogsCubit, ProcessingLogsState>(
        'resets to initial state from error state',
        build: () {
          when(() => mockRepository.getProcessingLogs(videoId: videoId))
              .thenThrow(Exception('Error'));
          return cubit;
        },
        act: (cubit) async {
          await cubit.getProcessingLogs(videoId: videoId);
          cubit.reset();
        },
        expect: () => [
          const ProcessingLogsState.loading(),
          const ProcessingLogsState.error(
            message: 'Error loading processing logs: Exception: Error',
          ),
          const ProcessingLogsState.initial(),
        ],
      );

      blocTest<ProcessingLogsCubit, ProcessingLogsState>(
        'resets to initial state from loading state',
        build: () {
          when(() => mockRepository.getProcessingLogs(videoId: videoId))
              .thenAnswer((_) async {
            await Future.delayed(const Duration(seconds: 1));
            return const ProcessingLogsResponse(data: []);
          });
          return cubit;
        },
        act: (cubit) {
          cubit.getProcessingLogs(videoId: videoId);
          cubit.reset();
        },
        expect: () => [
          const ProcessingLogsState.loading(),
          const ProcessingLogsState.initial(),
        ],
      );

      blocTest<ProcessingLogsCubit, ProcessingLogsState>(
        'can call reset multiple times',
        build: () => cubit,
        act: (cubit) {
          cubit.reset();
          cubit.reset();
          cubit.reset();
        },
        expect: () => [
          const ProcessingLogsState.initial(),
          const ProcessingLogsState.initial(),
          const ProcessingLogsState.initial(),
        ],
      );

      blocTest<ProcessingLogsCubit, ProcessingLogsState>(
        'reset does not affect subsequent getProcessingLogs calls',
        build: () {
          final mockResponse = ProcessingLogsResponse(
            data: [
              const ProcessingLogEvent(
                id: 1,
                videoId: videoId,
                timestamp: '2025-01-15T10:30:00.000Z',
                step: 'Video Uploaded to S3',
                details: 'Upload complete',
              ),
            ],
          );
          when(() => mockRepository.getProcessingLogs(videoId: videoId))
              .thenAnswer((_) async => mockResponse);
          return cubit;
        },
        act: (cubit) async {
          await cubit.getProcessingLogs(videoId: videoId);
          cubit.reset();
          await cubit.getProcessingLogs(videoId: videoId);
        },
        expect: () => [
          const ProcessingLogsState.loading(),
          ProcessingLogsState.loaded(logs: mockResponse),
          const ProcessingLogsState.initial(),
          const ProcessingLogsState.loading(),
          ProcessingLogsState.loaded(logs: mockResponse),
        ],
      );
    });

    group('error handling', () {
      blocTest<ProcessingLogsCubit, ProcessingLogsState>(
        'handles generic exceptions',
        build: () {
          when(() => mockRepository.getProcessingLogs(videoId: videoId))
              .thenThrow(Exception('Generic error'));
          return cubit;
        },
        act: (cubit) => cubit.getProcessingLogs(videoId: videoId),
        expect: () => [
          const ProcessingLogsState.loading(),
          const ProcessingLogsState.error(
            message: 'Error loading processing logs: Exception: Generic error',
          ),
        ],
      );

      blocTest<ProcessingLogsCubit, ProcessingLogsState>(
        'handles FormatException',
        build: () {
          when(() => mockRepository.getProcessingLogs(videoId: videoId))
              .thenThrow(const FormatException('Invalid format'));
          return cubit;
        },
        act: (cubit) => cubit.getProcessingLogs(videoId: videoId),
        expect: () => [
          const ProcessingLogsState.loading(),
          const ProcessingLogsState.error(
            message: 'Error loading processing logs: FormatException: Invalid format',
          ),
        ],
      );

      blocTest<ProcessingLogsCubit, ProcessingLogsState>(
        'handles string errors',
        build: () {
          when(() => mockRepository.getProcessingLogs(videoId: videoId))
              .thenThrow('String error message');
          return cubit;
        },
        act: (cubit) => cubit.getProcessingLogs(videoId: videoId),
        expect: () => [
          const ProcessingLogsState.loading(),
          const ProcessingLogsState.error(
            message: 'Error loading processing logs: String error message',
          ),
        ],
      );
    });
  });
}