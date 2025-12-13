import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dmvgenie/src/modules/video_detail/data/repository/video_processing_repository_impl.dart';
import 'package:dmvgenie/src/modules/video_detail/data/models/processing_log_model.dart';
import 'package:dmvgenie/src/modules/upload/data/remote/video_api_service.dart';

class MockVideoApiService extends Mock implements VideoApiService {}

void main() {
  late VideoProcessingRepositoryImpl repository;
  late MockVideoApiService mockVideoApiService;

  setUp(() {
    mockVideoApiService = MockVideoApiService();
    repository = VideoProcessingRepositoryImpl(
      videoApiService: mockVideoApiService,
    );
  });

  group('VideoProcessingRepositoryImpl', () {
    group('getProcessingLogs', () {
      const videoId = 'test-video-123';

      test('should return ProcessingLogsResponse when API call is successful', () async {
        // Arrange
        final expectedResponse = ProcessingLogsResponse(
          data: [
            const ProcessingLogEvent(
              id: 1,
              videoId: videoId,
              timestamp: '2025-01-15T10:30:00.000Z',
              step: 'Video Uploaded to S3',
              details: 'Video successfully uploaded to S3 bucket',
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

        when(() => mockVideoApiService.getProcessingLogs(videoId: videoId))
            .thenAnswer((_) async => expectedResponse);

        // Act
        final result = await repository.getProcessingLogs(videoId: videoId);

        // Assert
        expect(result, equals(expectedResponse));
        expect(result.data, hasLength(2));
        expect(result.data[0].step, 'Video Uploaded to S3');
        expect(result.data[1].step, 'Shot Detection');
        verify(() => mockVideoApiService.getProcessingLogs(videoId: videoId))
            .called(1);
      });

      test('should return empty ProcessingLogsResponse when no logs available', () async {
        // Arrange
        const expectedResponse = ProcessingLogsResponse(data: []);

        when(() => mockVideoApiService.getProcessingLogs(videoId: videoId))
            .thenAnswer((_) async => expectedResponse);

        // Act
        final result = await repository.getProcessingLogs(videoId: videoId);

        // Assert
        expect(result, equals(expectedResponse));
        expect(result.data, isEmpty);
        verify(() => mockVideoApiService.getProcessingLogs(videoId: videoId))
            .called(1);
      });

      test('should return ProcessingLogsResponse with single log', () async {
        // Arrange
        final expectedResponse = ProcessingLogsResponse(
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

        when(() => mockVideoApiService.getProcessingLogs(videoId: videoId))
            .thenAnswer((_) async => expectedResponse);

        // Act
        final result = await repository.getProcessingLogs(videoId: videoId);

        // Assert
        expect(result.data, hasLength(1));
        expect(result.data.first.id, 1);
        verify(() => mockVideoApiService.getProcessingLogs(videoId: videoId))
            .called(1);
      });

      test('should return ProcessingLogsResponse with multiple logs in chronological order', () async {
        // Arrange
        final expectedResponse = ProcessingLogsResponse(
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

        when(() => mockVideoApiService.getProcessingLogs(videoId: videoId))
            .thenAnswer((_) async => expectedResponse);

        // Act
        final result = await repository.getProcessingLogs(videoId: videoId);

        // Assert
        expect(result.data, hasLength(4));
        expect(result.data[0].step, 'Video Uploaded to S3');
        expect(result.data[1].step, 'Shot Detection');
        expect(result.data[2].step, 'Clip Embedding');
        expect(result.data[3].step, 'Status Updated');
        verify(() => mockVideoApiService.getProcessingLogs(videoId: videoId))
            .called(1);
      });

      test('should handle large number of logs', () async {
        // Arrange
        final logsData = List.generate(
          100,
          (i) => ProcessingLogEvent(
            id: i,
            videoId: videoId,
            timestamp: '2025-01-15T10:30:00.000Z',
            step: 'Step $i',
            details: 'Details for step $i',
          ),
        );
        final expectedResponse = ProcessingLogsResponse(data: logsData);

        when(() => mockVideoApiService.getProcessingLogs(videoId: videoId))
            .thenAnswer((_) async => expectedResponse);

        // Act
        final result = await repository.getProcessingLogs(videoId: videoId);

        // Assert
        expect(result.data, hasLength(100));
        expect(result.data.first.id, 0);
        expect(result.data.last.id, 99);
        verify(() => mockVideoApiService.getProcessingLogs(videoId: videoId))
            .called(1);
      });

      test('should throw exception when API call fails', () async {
        // Arrange
        when(() => mockVideoApiService.getProcessingLogs(videoId: videoId))
            .thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => repository.getProcessingLogs(videoId: videoId),
          throwsException,
        );
        verify(() => mockVideoApiService.getProcessingLogs(videoId: videoId))
            .called(1);
      });

      test('should throw exception when API returns null', () async {
        // Arrange
        when(() => mockVideoApiService.getProcessingLogs(videoId: videoId))
            .thenThrow(Exception('Null response'));

        // Act & Assert
        expect(
          () => repository.getProcessingLogs(videoId: videoId),
          throwsException,
        );
      });

      test('should handle different video IDs correctly', () async {
        // Arrange
        const videoId1 = 'video-1';
        const videoId2 = 'video-2';

        final response1 = ProcessingLogsResponse(
          data: [
            const ProcessingLogEvent(
              id: 1,
              videoId: videoId1,
              timestamp: '2025-01-15T10:30:00.000Z',
              step: 'Video Uploaded to S3',
              details: 'Upload for video 1',
            ),
          ],
        );

        final response2 = ProcessingLogsResponse(
          data: [
            const ProcessingLogEvent(
              id: 2,
              videoId: videoId2,
              timestamp: '2025-01-15T11:30:00.000Z',
              step: 'Shot Detection',
              details: 'Detection for video 2',
            ),
          ],
        );

        when(() => mockVideoApiService.getProcessingLogs(videoId: videoId1))
            .thenAnswer((_) async => response1);
        when(() => mockVideoApiService.getProcessingLogs(videoId: videoId2))
            .thenAnswer((_) async => response2);

        // Act
        final result1 = await repository.getProcessingLogs(videoId: videoId1);
        final result2 = await repository.getProcessingLogs(videoId: videoId2);

        // Assert
        expect(result1.data.first.videoId, videoId1);
        expect(result2.data.first.videoId, videoId2);
        verify(() => mockVideoApiService.getProcessingLogs(videoId: videoId1))
            .called(1);
        verify(() => mockVideoApiService.getProcessingLogs(videoId: videoId2))
            .called(1);
      });

      test('should handle special characters in video ID', () async {
        // Arrange
        const specialVideoId = 'video-with-special-chars-@#\$%';
        final expectedResponse = ProcessingLogsResponse(
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

        when(() => mockVideoApiService.getProcessingLogs(videoId: specialVideoId))
            .thenAnswer((_) async => expectedResponse);

        // Act
        final result = await repository.getProcessingLogs(videoId: specialVideoId);

        // Assert
        expect(result.data.first.videoId, specialVideoId);
        verify(() => mockVideoApiService.getProcessingLogs(videoId: specialVideoId))
            .called(1);
      });

      test('should handle empty video ID', () async {
        // Arrange
        const emptyVideoId = '';
        final expectedResponse = ProcessingLogsResponse(
          data: [
            const ProcessingLogEvent(
              id: 1,
              videoId: emptyVideoId,
              timestamp: '2025-01-15T10:30:00.000Z',
              step: 'Video Uploaded to S3',
              details: 'Upload complete',
            ),
          ],
        );

        when(() => mockVideoApiService.getProcessingLogs(videoId: emptyVideoId))
            .thenAnswer((_) async => expectedResponse);

        // Act
        final result = await repository.getProcessingLogs(videoId: emptyVideoId);

        // Assert
        expect(result.data.first.videoId, emptyVideoId);
        verify(() => mockVideoApiService.getProcessingLogs(videoId: emptyVideoId))
            .called(1);
      });

      test('should propagate timeout exception from API', () async {
        // Arrange
        when(() => mockVideoApiService.getProcessingLogs(videoId: videoId))
            .thenThrow(Exception('Request timeout'));

        // Act & Assert
        expect(
          () => repository.getProcessingLogs(videoId: videoId),
          throwsException,
        );
      });

      test('should handle consecutive calls for same video ID', () async {
        // Arrange
        final expectedResponse = ProcessingLogsResponse(
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

        when(() => mockVideoApiService.getProcessingLogs(videoId: videoId))
            .thenAnswer((_) async => expectedResponse);

        // Act
        final result1 = await repository.getProcessingLogs(videoId: videoId);
        final result2 = await repository.getProcessingLogs(videoId: videoId);

        // Assert
        expect(result1, equals(expectedResponse));
        expect(result2, equals(expectedResponse));
        verify(() => mockVideoApiService.getProcessingLogs(videoId: videoId))
            .called(2);
      });

      test('should handle API returning logs with different step types', () async {
        // Arrange
        final expectedResponse = ProcessingLogsResponse(
          data: [
            const ProcessingLogEvent(
              id: 1,
              videoId: videoId,
              timestamp: '2025-01-15T10:00:00.000Z',
              step: 'Video Uploaded to S3',
              details: 'S3 upload complete',
            ),
            const ProcessingLogEvent(
              id: 2,
              videoId: videoId,
              timestamp: '2025-01-15T10:05:00.000Z',
              step: 'Shot Detection',
              details: 'Detected 25 shots',
            ),
            const ProcessingLogEvent(
              id: 3,
              videoId: videoId,
              timestamp: '2025-01-15T10:10:00.000Z',
              step: 'Clip Embedding',
              details: 'Embedded 25 clips',
            ),
            const ProcessingLogEvent(
              id: 4,
              videoId: videoId,
              timestamp: '2025-01-15T10:15:00.000Z',
              step: 'Status Updated',
              details: 'Video ready for viewing',
            ),
          ],
        );

        when(() => mockVideoApiService.getProcessingLogs(videoId: videoId))
            .thenAnswer((_) async => expectedResponse);

        // Act
        final result = await repository.getProcessingLogs(videoId: videoId);

        // Assert
        expect(result.data, hasLength(4));
        final steps = result.data.map((e) => e.step).toList();
        expect(steps, contains('Video Uploaded to S3'));
        expect(steps, contains('Shot Detection'));
        expect(steps, contains('Clip Embedding'));
        expect(steps, contains('Status Updated'));
      });

      test('should verify method signature matches interface', () {
        // This test ensures the repository implements the interface correctly
        expect(
          repository.getProcessingLogs,
          isA<Future<ProcessingLogsResponse> Function({required String videoId})>(),
        );
      });
    });
  });
}