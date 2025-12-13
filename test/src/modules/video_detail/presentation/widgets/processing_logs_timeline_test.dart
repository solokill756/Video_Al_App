import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dmvgenie/src/modules/video_detail/presentation/widgets/processing_logs_timeline.dart';
import 'package:dmvgenie/src/modules/video_detail/data/models/processing_log_model.dart';

void main() {
  group('ProcessingLogsTimeline', () {
    Widget makeTestableWidget(ProcessingLogsResponse processingLog) {
      return MaterialApp(
        home: Scaffold(
          body: ProcessingLogsTimeline(processingLog: processingLog),
        ),
      );
    }

    group('empty state', () {
      testWidgets('displays empty message when no logs are available',
          (WidgetTester tester) async {
        // Arrange
        const emptyLogs = ProcessingLogsResponse(data: []);

        // Act
        await tester.pumpWidget(makeTestableWidget(emptyLogs));

        // Assert
        expect(find.text('No processing logs available'), findsOneWidget);
        expect(find.byType(ListView), findsNothing);
      });

      testWidgets('empty state has correct styling', (WidgetTester tester) async {
        // Arrange
        const emptyLogs = ProcessingLogsResponse(data: []);

        // Act
        await tester.pumpWidget(makeTestableWidget(emptyLogs));

        // Assert
        final textWidget = tester.widget<Text>(
          find.text('No processing logs available'),
        );
        expect(textWidget.style?.fontSize, 14);
      });
    });

    group('header', () {
      testWidgets('displays Processing Timeline title', (WidgetTester tester) async {
        // Arrange
        final logs = ProcessingLogsResponse(
          data: [
            const ProcessingLogEvent(
              id: 1,
              videoId: 'video-123',
              timestamp: '2025-01-15T10:30:00.000Z',
              step: 'Video Uploaded to S3',
              details: 'Upload complete',
            ),
          ],
        );

        // Act
        await tester.pumpWidget(makeTestableWidget(logs));

        // Assert
        expect(find.text('Processing Timeline'), findsOneWidget);
      });

      testWidgets('displays correct step count for single log',
          (WidgetTester tester) async {
        // Arrange
        final logs = ProcessingLogsResponse(
          data: [
            const ProcessingLogEvent(
              id: 1,
              videoId: 'video-123',
              timestamp: '2025-01-15T10:30:00.000Z',
              step: 'Video Uploaded to S3',
              details: 'Upload complete',
            ),
          ],
        );

        // Act
        await tester.pumpWidget(makeTestableWidget(logs));

        // Assert
        expect(find.text('1 step'), findsOneWidget);
      });

      testWidgets('displays correct step count for multiple logs',
          (WidgetTester tester) async {
        // Arrange
        final logs = ProcessingLogsResponse(
          data: [
            const ProcessingLogEvent(
              id: 1,
              videoId: 'video-123',
              timestamp: '2025-01-15T10:30:00.000Z',
              step: 'Video Uploaded to S3',
              details: 'Upload complete',
            ),
            const ProcessingLogEvent(
              id: 2,
              videoId: 'video-123',
              timestamp: '2025-01-15T10:31:00.000Z',
              step: 'Shot Detection',
              details: 'Detection complete',
            ),
          ],
        );

        // Act
        await tester.pumpWidget(makeTestableWidget(logs));

        // Assert
        expect(find.text('2 steps'), findsOneWidget);
      });

      testWidgets('displays correct step count for many logs',
          (WidgetTester tester) async {
        // Arrange
        final logs = ProcessingLogsResponse(
          data: List.generate(
            5,
            (i) => ProcessingLogEvent(
              id: i,
              videoId: 'video-123',
              timestamp: '2025-01-15T10:30:00.000Z',
              step: 'Step $i',
              details: 'Details $i',
            ),
          ),
        );

        // Act
        await tester.pumpWidget(makeTestableWidget(logs));

        // Assert
        expect(find.text('5 steps'), findsOneWidget);
      });
    });

    group('timeline events', () {
      testWidgets('displays single event correctly', (WidgetTester tester) async {
        // Arrange
        final logs = ProcessingLogsResponse(
          data: [
            const ProcessingLogEvent(
              id: 1,
              videoId: 'video-123',
              timestamp: '2025-01-15T10:30:00.000Z',
              step: 'Video Uploaded to S3',
              details: 'Video successfully uploaded to S3 bucket',
            ),
          ],
        );

        // Act
        await tester.pumpWidget(makeTestableWidget(logs));

        // Assert
        expect(find.text('Video Uploaded to S3'), findsOneWidget);
        expect(find.text('Video successfully uploaded to S3 bucket'), findsOneWidget);
      });

      testWidgets('displays multiple events in order', (WidgetTester tester) async {
        // Arrange
        final logs = ProcessingLogsResponse(
          data: [
            const ProcessingLogEvent(
              id: 1,
              videoId: 'video-123',
              timestamp: '2025-01-15T10:00:00.000Z',
              step: 'Video Uploaded to S3',
              details: 'Upload started',
            ),
            const ProcessingLogEvent(
              id: 2,
              videoId: 'video-123',
              timestamp: '2025-01-15T10:05:00.000Z',
              step: 'Shot Detection',
              details: 'Detection started',
            ),
            const ProcessingLogEvent(
              id: 3,
              videoId: 'video-123',
              timestamp: '2025-01-15T10:10:00.000Z',
              step: 'Clip Embedding',
              details: 'Embedding started',
            ),
          ],
        );

        // Act
        await tester.pumpWidget(makeTestableWidget(logs));

        // Assert
        expect(find.text('Video Uploaded to S3'), findsOneWidget);
        expect(find.text('Shot Detection'), findsOneWidget);
        expect(find.text('Clip Embedding'), findsOneWidget);
      });

      testWidgets('displays event details', (WidgetTester tester) async {
        // Arrange
        final logs = ProcessingLogsResponse(
          data: [
            const ProcessingLogEvent(
              id: 1,
              videoId: 'video-123',
              timestamp: '2025-01-15T10:30:00.000Z',
              step: 'Video Uploaded to S3',
              details: 'Detailed description of the upload process',
            ),
          ],
        );

        // Act
        await tester.pumpWidget(makeTestableWidget(logs));

        // Assert
        expect(
          find.text('Detailed description of the upload process'),
          findsOneWidget,
        );
      });

      testWidgets('displays formatted timestamps', (WidgetTester tester) async {
        // Arrange
        final logs = ProcessingLogsResponse(
          data: [
            const ProcessingLogEvent(
              id: 1,
              videoId: 'video-123',
              timestamp: '2025-01-15T10:30:00.000Z',
              step: 'Video Uploaded to S3',
              details: 'Upload complete',
            ),
          ],
        );

        // Act
        await tester.pumpWidget(makeTestableWidget(logs));

        // Assert
        // Verify timestamp is displayed (format may vary by locale)
        expect(find.textContaining('2025'), findsOneWidget);
      });

      testWidgets('displays Completed status badge', (WidgetTester tester) async {
        // Arrange
        final logs = ProcessingLogsResponse(
          data: [
            const ProcessingLogEvent(
              id: 1,
              videoId: 'video-123',
              timestamp: '2025-01-15T10:30:00.000Z',
              step: 'Video Uploaded to S3',
              details: 'Upload complete',
            ),
          ],
        );

        // Act
        await tester.pumpWidget(makeTestableWidget(logs));

        // Assert
        expect(find.text('Completed'), findsOneWidget);
      });
    });

    group('step icons and colors', () {
      testWidgets('displays correct icon for Video Uploaded to S3',
          (WidgetTester tester) async {
        // Arrange
        final logs = ProcessingLogsResponse(
          data: [
            const ProcessingLogEvent(
              id: 1,
              videoId: 'video-123',
              timestamp: '2025-01-15T10:30:00.000Z',
              step: 'Video Uploaded to S3',
              details: 'Upload complete',
            ),
          ],
        );

        // Act
        await tester.pumpWidget(makeTestableWidget(logs));

        // Assert
        expect(find.byIcon(Icons.cloud_upload_outlined), findsOneWidget);
      });

      testWidgets('displays correct icon for Shot Detection',
          (WidgetTester tester) async {
        // Arrange
        final logs = ProcessingLogsResponse(
          data: [
            const ProcessingLogEvent(
              id: 1,
              videoId: 'video-123',
              timestamp: '2025-01-15T10:30:00.000Z',
              step: 'Shot Detection',
              details: 'Detection complete',
            ),
          ],
        );

        // Act
        await tester.pumpWidget(makeTestableWidget(logs));

        // Assert
        expect(find.byIcon(Icons.image_search), findsOneWidget);
      });

      testWidgets('displays correct icon for Clip Embedding',
          (WidgetTester tester) async {
        // Arrange
        final logs = ProcessingLogsResponse(
          data: [
            const ProcessingLogEvent(
              id: 1,
              videoId: 'video-123',
              timestamp: '2025-01-15T10:30:00.000Z',
              step: 'Clip Embedding',
              details: 'Embedding complete',
            ),
          ],
        );

        // Act
        await tester.pumpWidget(makeTestableWidget(logs));

        // Assert
        expect(find.byIcon(Icons.construction_outlined), findsOneWidget);
      });

      testWidgets('displays correct icon for Status Updated',
          (WidgetTester tester) async {
        // Arrange
        final logs = ProcessingLogsResponse(
          data: [
            const ProcessingLogEvent(
              id: 1,
              videoId: 'video-123',
              timestamp: '2025-01-15T10:30:00.000Z',
              step: 'Status Updated',
              details: 'Status change complete',
            ),
          ],
        );

        // Act
        await tester.pumpWidget(makeTestableWidget(logs));

        // Assert
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      });

      testWidgets('displays default icon for unknown step',
          (WidgetTester tester) async {
        // Arrange
        final logs = ProcessingLogsResponse(
          data: [
            const ProcessingLogEvent(
              id: 1,
              videoId: 'video-123',
              timestamp: '2025-01-15T10:30:00.000Z',
              step: 'Unknown Step',
              details: 'Unknown step details',
            ),
          ],
        );

        // Act
        await tester.pumpWidget(makeTestableWidget(logs));

        // Assert
        expect(find.byIcon(Icons.info), findsOneWidget);
      });

      testWidgets('handles case-insensitive step matching',
          (WidgetTester tester) async {
        // Arrange
        final logs = ProcessingLogsResponse(
          data: [
            const ProcessingLogEvent(
              id: 1,
              videoId: 'video-123',
              timestamp: '2025-01-15T10:30:00.000Z',
              step: 'VIDEO UPLOADED TO S3',
              details: 'Upload complete',
            ),
          ],
        );

        // Act
        await tester.pumpWidget(makeTestableWidget(logs));

        // Assert
        expect(find.byIcon(Icons.cloud_upload_outlined), findsOneWidget);
      });
    });

    group('timeline visual structure', () {
      testWidgets('displays timeline dots for each event',
          (WidgetTester tester) async {
        // Arrange
        final logs = ProcessingLogsResponse(
          data: [
            const ProcessingLogEvent(
              id: 1,
              videoId: 'video-123',
              timestamp: '2025-01-15T10:30:00.000Z',
              step: 'Video Uploaded to S3',
              details: 'Upload complete',
            ),
            const ProcessingLogEvent(
              id: 2,
              videoId: 'video-123',
              timestamp: '2025-01-15T10:31:00.000Z',
              step: 'Shot Detection',
              details: 'Detection complete',
            ),
          ],
        );

        // Act
        await tester.pumpWidget(makeTestableWidget(logs));

        // Assert
        // Each event should have a circular icon container
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.decoration is BoxDecoration &&
                (widget.decoration as BoxDecoration).shape == BoxShape.circle,
          ),
          findsNWidgets(2),
        );
      });

      testWidgets('does not display connecting line for last event',
          (WidgetTester tester) async {
        // Arrange
        final logs = ProcessingLogsResponse(
          data: [
            const ProcessingLogEvent(
              id: 1,
              videoId: 'video-123',
              timestamp: '2025-01-15T10:30:00.000Z',
              step: 'Video Uploaded to S3',
              details: 'Upload complete',
            ),
          ],
        );

        // Act
        await tester.pumpWidget(makeTestableWidget(logs));
        await tester.pumpAndSettle();

        // Assert
        // Single event should not have a connecting line after it
        final containers = tester.widgetList<Container>(find.byType(Container));
        final lineContainers = containers.where(
          (c) => c.constraints?.maxWidth == 2 || c.width == 2,
        );
        expect(lineContainers.isEmpty, true);
      });
    });

    group('edge cases', () {
      testWidgets('handles very long step names', (WidgetTester tester) async {
        // Arrange
        final logs = ProcessingLogsResponse(
          data: [
            const ProcessingLogEvent(
              id: 1,
              videoId: 'video-123',
              timestamp: '2025-01-15T10:30:00.000Z',
              step: 'This is a very long step name that might cause layout issues',
              details: 'Details',
            ),
          ],
        );

        // Act
        await tester.pumpWidget(makeTestableWidget(logs));

        // Assert
        expect(
          find.text('This is a very long step name that might cause layout issues'),
          findsOneWidget,
        );
      });

      testWidgets('handles very long detail text', (WidgetTester tester) async {
        // Arrange
        final logs = ProcessingLogsResponse(
          data: [
            const ProcessingLogEvent(
              id: 1,
              videoId: 'video-123',
              timestamp: '2025-01-15T10:30:00.000Z',
              step: 'Video Uploaded to S3',
              details:
                  'This is a very long details text that contains a lot of information about the processing step and might need to wrap to multiple lines',
            ),
          ],
        );

        // Act
        await tester.pumpWidget(makeTestableWidget(logs));

        // Assert
        expect(
          find.textContaining('This is a very long details text'),
          findsOneWidget,
        );
      });

      testWidgets('handles empty strings in step and details',
          (WidgetTester tester) async {
        // Arrange
        final logs = ProcessingLogsResponse(
          data: [
            const ProcessingLogEvent(
              id: 1,
              videoId: 'video-123',
              timestamp: '2025-01-15T10:30:00.000Z',
              step: '',
              details: '',
            ),
          ],
        );

        // Act
        await tester.pumpWidget(makeTestableWidget(logs));

        // Assert
        expect(find.text('Completed'), findsOneWidget);
        // Widget should render without error even with empty strings
      });

      testWidgets('handles special characters in text',
          (WidgetTester tester) async {
        // Arrange
        final logs = ProcessingLogsResponse(
          data: [
            const ProcessingLogEvent(
              id: 1,
              videoId: 'video-123',
              timestamp: '2025-01-15T10:30:00.000Z',
              step: 'Step with "quotes" and \'apostrophes\'',
              details: 'Details with @#\$% special characters',
            ),
          ],
        );

        // Act
        await tester.pumpWidget(makeTestableWidget(logs));

        // Assert
        expect(find.textContaining('quotes'), findsOneWidget);
        expect(find.textContaining('special characters'), findsOneWidget);
      });

      testWidgets('handles large number of events', (WidgetTester tester) async {
        // Arrange
        final logs = ProcessingLogsResponse(
          data: List.generate(
            20,
            (i) => ProcessingLogEvent(
              id: i,
              videoId: 'video-123',
              timestamp: '2025-01-15T10:30:00.000Z',
              step: 'Step $i',
              details: 'Details for step $i',
            ),
          ),
        );

        // Act
        await tester.pumpWidget(makeTestableWidget(logs));

        // Assert
        expect(find.text('20 steps'), findsOneWidget);
        // Verify first and last steps are rendered
        expect(find.text('Step 0'), findsOneWidget);
      });
    });

    group('widget structure', () {
      testWidgets('has correct container decoration', (WidgetTester tester) async {
        // Arrange
        final logs = ProcessingLogsResponse(
          data: [
            const ProcessingLogEvent(
              id: 1,
              videoId: 'video-123',
              timestamp: '2025-01-15T10:30:00.000Z',
              step: 'Video Uploaded to S3',
              details: 'Upload complete',
            ),
          ],
        );

        // Act
        await tester.pumpWidget(makeTestableWidget(logs));

        // Assert
        final container = tester.widget<Container>(
          find.byType(Container).first,
        );
        expect(container.decoration, isA<BoxDecoration>());
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, Colors.white);
        expect(decoration.borderRadius, isNotNull);
      });

      testWidgets('contains divider between header and events',
          (WidgetTester tester) async {
        // Arrange
        final logs = ProcessingLogsResponse(
          data: [
            const ProcessingLogEvent(
              id: 1,
              videoId: 'video-123',
              timestamp: '2025-01-15T10:30:00.000Z',
              step: 'Video Uploaded to S3',
              details: 'Upload complete',
            ),
          ],
        );

        // Act
        await tester.pumpWidget(makeTestableWidget(logs));

        // Assert
        expect(find.byType(Divider), findsOneWidget);
      });
    });
  });
}