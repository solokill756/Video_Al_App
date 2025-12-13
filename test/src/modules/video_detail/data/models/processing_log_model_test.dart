import 'package:flutter_test/flutter_test.dart';
import 'package:dmvgenie/src/modules/video_detail/data/models/processing_log_model.dart';

void main() {
  group('ProcessingLogEvent', () {
    group('fromJson', () {
      test('should create ProcessingLogEvent from valid JSON', () {
        // Arrange
        final json = {
          'id': 1,
          'videoId': 'video-123',
          'timestamp': '2025-01-15T10:30:00.000Z',
          'step': 'Video Uploaded to S3',
          'details': 'Video successfully uploaded to S3 bucket',
        };

        // Act
        final result = ProcessingLogEvent.fromJson(json);

        // Assert
        expect(result.id, 1);
        expect(result.videoId, 'video-123');
        expect(result.timestamp, '2025-01-15T10:30:00.000Z');
        expect(result.step, 'Video Uploaded to S3');
        expect(result.details, 'Video successfully uploaded to S3 bucket');
      });

      test('should handle JSON with all required fields', () {
        // Arrange
        final json = {
          'id': 42,
          'videoId': 'test-video-456',
          'timestamp': '2025-12-31T23:59:59.999Z',
          'step': 'Clip Embedding',
          'details': 'Video clips embedded successfully',
        };

        // Act
        final result = ProcessingLogEvent.fromJson(json);

        // Assert
        expect(result.id, 42);
        expect(result.videoId, 'test-video-456');
        expect(result.timestamp, '2025-12-31T23:59:59.999Z');
        expect(result.step, 'Clip Embedding');
        expect(result.details, 'Video clips embedded successfully');
      });

      test('should handle empty strings in fields', () {
        // Arrange
        final json = {
          'id': 0,
          'videoId': '',
          'timestamp': '',
          'step': '',
          'details': '',
        };

        // Act
        final result = ProcessingLogEvent.fromJson(json);

        // Assert
        expect(result.id, 0);
        expect(result.videoId, '');
        expect(result.timestamp, '');
        expect(result.step, '');
        expect(result.details, '');
      });

      test('should handle special characters in strings', () {
        // Arrange
        final json = {
          'id': 1,
          'videoId': 'video-with-special-chars-@#\$%',
          'timestamp': '2025-01-15T10:30:00.000Z',
          'step': 'Step with "quotes" and \'apostrophes\'',
          'details': 'Details with \n newlines and \t tabs',
        };

        // Act
        final result = ProcessingLogEvent.fromJson(json);

        // Assert
        expect(result.videoId, contains('special-chars'));
        expect(result.step, contains('quotes'));
        expect(result.details, contains('newlines'));
      });
    });

    group('toJson', () {
      test('should convert ProcessingLogEvent to JSON', () {
        // Arrange
        const event = ProcessingLogEvent(
          id: 1,
          videoId: 'video-123',
          timestamp: '2025-01-15T10:30:00.000Z',
          step: 'Video Uploaded to S3',
          details: 'Video successfully uploaded to S3 bucket',
        );

        // Act
        final json = event.toJson();

        // Assert
        expect(json['id'], 1);
        expect(json['videoId'], 'video-123');
        expect(json['timestamp'], '2025-01-15T10:30:00.000Z');
        expect(json['step'], 'Video Uploaded to S3');
        expect(json['details'], 'Video successfully uploaded to S3 bucket');
      });

      test('should produce JSON that can be deserialized back', () {
        // Arrange
        const original = ProcessingLogEvent(
          id: 99,
          videoId: 'roundtrip-test',
          timestamp: '2025-06-15T12:00:00.000Z',
          step: 'Status Updated',
          details: 'Processing completed',
        );

        // Act
        final json = original.toJson();
        final deserialized = ProcessingLogEvent.fromJson(json);

        // Assert
        expect(deserialized.id, original.id);
        expect(deserialized.videoId, original.videoId);
        expect(deserialized.timestamp, original.timestamp);
        expect(deserialized.step, original.step);
        expect(deserialized.details, original.details);
      });
    });

    group('equality', () {
      test('should be equal when all fields are the same', () {
        // Arrange
        const event1 = ProcessingLogEvent(
          id: 1,
          videoId: 'video-123',
          timestamp: '2025-01-15T10:30:00.000Z',
          step: 'Shot Detection',
          details: 'Shots detected',
        );

        const event2 = ProcessingLogEvent(
          id: 1,
          videoId: 'video-123',
          timestamp: '2025-01-15T10:30:00.000Z',
          step: 'Shot Detection',
          details: 'Shots detected',
        );

        // Assert
        expect(event1, equals(event2));
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('should not be equal when any field differs', () {
        // Arrange
        const event1 = ProcessingLogEvent(
          id: 1,
          videoId: 'video-123',
          timestamp: '2025-01-15T10:30:00.000Z',
          step: 'Shot Detection',
          details: 'Shots detected',
        );

        const event2 = ProcessingLogEvent(
          id: 2, // Different id
          videoId: 'video-123',
          timestamp: '2025-01-15T10:30:00.000Z',
          step: 'Shot Detection',
          details: 'Shots detected',
        );

        // Assert
        expect(event1, isNot(equals(event2)));
      });
    });

    group('copyWith', () {
      test('should create a copy with modified fields', () {
        // Arrange
        const original = ProcessingLogEvent(
          id: 1,
          videoId: 'video-123',
          timestamp: '2025-01-15T10:30:00.000Z',
          step: 'Shot Detection',
          details: 'Original details',
        );

        // Act
        final modified = original.copyWith(details: 'Modified details');

        // Assert
        expect(modified.id, original.id);
        expect(modified.videoId, original.videoId);
        expect(modified.timestamp, original.timestamp);
        expect(modified.step, original.step);
        expect(modified.details, 'Modified details');
      });

      test('should not modify original when using copyWith', () {
        // Arrange
        const original = ProcessingLogEvent(
          id: 1,
          videoId: 'video-123',
          timestamp: '2025-01-15T10:30:00.000Z',
          step: 'Shot Detection',
          details: 'Original details',
        );

        // Act
        final modified = original.copyWith(step: 'New Step');

        // Assert
        expect(original.step, 'Shot Detection');
        expect(modified.step, 'New Step');
      });
    });
  });

  group('ProcessingLogsResponse', () {
    group('fromJson', () {
      test('should create ProcessingLogsResponse from valid JSON with multiple events', () {
        // Arrange
        final json = {
          'data': [
            {
              'id': 1,
              'videoId': 'video-123',
              'timestamp': '2025-01-15T10:30:00.000Z',
              'step': 'Video Uploaded to S3',
              'details': 'Upload complete',
            },
            {
              'id': 2,
              'videoId': 'video-123',
              'timestamp': '2025-01-15T10:31:00.000Z',
              'step': 'Shot Detection',
              'details': 'Detection complete',
            },
          ],
        };

        // Act
        final result = ProcessingLogsResponse.fromJson(json);

        // Assert
        expect(result.data, hasLength(2));
        expect(result.data[0].id, 1);
        expect(result.data[0].step, 'Video Uploaded to S3');
        expect(result.data[1].id, 2);
        expect(result.data[1].step, 'Shot Detection');
      });

      test('should create ProcessingLogsResponse with empty list', () {
        // Arrange
        final json = {
          'data': <Map<String, dynamic>>[],
        };

        // Act
        final result = ProcessingLogsResponse.fromJson(json);

        // Assert
        expect(result.data, isEmpty);
      });

      test('should handle large number of events', () {
        // Arrange
        final events = List.generate(
          100,
          (i) => {
            'id': i,
            'videoId': 'video-large-test',
            'timestamp': '2025-01-15T10:30:00.000Z',
            'step': 'Step $i',
            'details': 'Details for step $i',
          },
        );
        final json = {'data': events};

        // Act
        final result = ProcessingLogsResponse.fromJson(json);

        // Assert
        expect(result.data, hasLength(100));
        expect(result.data.first.id, 0);
        expect(result.data.last.id, 99);
      });

      test('should handle events with varying timestamps', () {
        // Arrange
        final json = {
          'data': [
            {
              'id': 1,
              'videoId': 'video-123',
              'timestamp': '2025-01-15T10:00:00.000Z',
              'step': 'Start',
              'details': 'Started',
            },
            {
              'id': 2,
              'videoId': 'video-123',
              'timestamp': '2025-01-15T11:30:45.123Z',
              'step': 'Middle',
              'details': 'In progress',
            },
            {
              'id': 3,
              'videoId': 'video-123',
              'timestamp': '2025-01-15T12:59:59.999Z',
              'step': 'End',
              'details': 'Completed',
            },
          ],
        };

        // Act
        final result = ProcessingLogsResponse.fromJson(json);

        // Assert
        expect(result.data, hasLength(3));
        expect(result.data[0].timestamp, '2025-01-15T10:00:00.000Z');
        expect(result.data[1].timestamp, '2025-01-15T11:30:45.123Z');
        expect(result.data[2].timestamp, '2025-01-15T12:59:59.999Z');
      });
    });

    group('toJson', () {
      test('should convert ProcessingLogsResponse to JSON', () {
        // Arrange
        const response = ProcessingLogsResponse(
          data: [
            ProcessingLogEvent(
              id: 1,
              videoId: 'video-123',
              timestamp: '2025-01-15T10:30:00.000Z',
              step: 'Video Uploaded to S3',
              details: 'Upload complete',
            ),
            ProcessingLogEvent(
              id: 2,
              videoId: 'video-123',
              timestamp: '2025-01-15T10:31:00.000Z',
              step: 'Shot Detection',
              details: 'Detection complete',
            ),
          ],
        );

        // Act
        final json = response.toJson();

        // Assert
        expect(json['data'], isList);
        expect(json['data'], hasLength(2));
        expect(json['data'][0]['id'], 1);
        expect(json['data'][1]['id'], 2);
      });

      test('should produce JSON that can be deserialized back', () {
        // Arrange
        const original = ProcessingLogsResponse(
          data: [
            ProcessingLogEvent(
              id: 1,
              videoId: 'roundtrip-test',
              timestamp: '2025-01-15T10:30:00.000Z',
              step: 'Test Step',
              details: 'Test details',
            ),
          ],
        );

        // Act
        final json = original.toJson();
        final deserialized = ProcessingLogsResponse.fromJson(json);

        // Assert
        expect(deserialized.data.length, original.data.length);
        expect(deserialized.data.first.id, original.data.first.id);
        expect(deserialized.data.first.videoId, original.data.first.videoId);
      });

      test('should handle empty data list', () {
        // Arrange
        const response = ProcessingLogsResponse(data: []);

        // Act
        final json = response.toJson();

        // Assert
        expect(json['data'], isEmpty);
      });
    });

    group('equality', () {
      test('should be equal when data lists are identical', () {
        // Arrange
        const response1 = ProcessingLogsResponse(
          data: [
            ProcessingLogEvent(
              id: 1,
              videoId: 'video-123',
              timestamp: '2025-01-15T10:30:00.000Z',
              step: 'Shot Detection',
              details: 'Details',
            ),
          ],
        );

        const response2 = ProcessingLogsResponse(
          data: [
            ProcessingLogEvent(
              id: 1,
              videoId: 'video-123',
              timestamp: '2025-01-15T10:30:00.000Z',
              step: 'Shot Detection',
              details: 'Details',
            ),
          ],
        );

        // Assert
        expect(response1, equals(response2));
      });

      test('should not be equal when data lists differ', () {
        // Arrange
        const response1 = ProcessingLogsResponse(
          data: [
            ProcessingLogEvent(
              id: 1,
              videoId: 'video-123',
              timestamp: '2025-01-15T10:30:00.000Z',
              step: 'Shot Detection',
              details: 'Details',
            ),
          ],
        );

        const response2 = ProcessingLogsResponse(
          data: [
            ProcessingLogEvent(
              id: 2, // Different
              videoId: 'video-123',
              timestamp: '2025-01-15T10:30:00.000Z',
              step: 'Shot Detection',
              details: 'Details',
            ),
          ],
        );

        // Assert
        expect(response1, isNot(equals(response2)));
      });

      test('should not be equal when list lengths differ', () {
        // Arrange
        const response1 = ProcessingLogsResponse(data: []);

        const response2 = ProcessingLogsResponse(
          data: [
            ProcessingLogEvent(
              id: 1,
              videoId: 'video-123',
              timestamp: '2025-01-15T10:30:00.000Z',
              step: 'Shot Detection',
              details: 'Details',
            ),
          ],
        );

        // Assert
        expect(response1, isNot(equals(response2)));
      });
    });

    group('copyWith', () {
      test('should create a copy with modified data list', () {
        // Arrange
        const original = ProcessingLogsResponse(
          data: [
            ProcessingLogEvent(
              id: 1,
              videoId: 'video-123',
              timestamp: '2025-01-15T10:30:00.000Z',
              step: 'Original',
              details: 'Original details',
            ),
          ],
        );

        const newData = [
          ProcessingLogEvent(
            id: 2,
            videoId: 'video-456',
            timestamp: '2025-01-16T10:30:00.000Z',
            step: 'Modified',
            details: 'Modified details',
          ),
        ];

        // Act
        final modified = original.copyWith(data: newData);

        // Assert
        expect(modified.data, hasLength(1));
        expect(modified.data.first.id, 2);
        expect(original.data.first.id, 1); // Original unchanged
      });
    });
  });
}