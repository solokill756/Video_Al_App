# Unit Tests for Processing Logs Feature

This directory contains comprehensive unit tests for the processing logs feature added to the Video AI App.

## Test Coverage

### 1. Model Tests (`data/models/processing_log_model_test.dart`)
Tests for `ProcessingLogEvent` and `ProcessingLogsResponse` Freezed models:
- JSON serialization/deserialization
- Equality and hash code
- CopyWith functionality
- Edge cases (empty strings, special characters, large datasets)

### 2. Repository Tests (`data/repository/video_processing_repository_impl_test.dart`)
Tests for `VideoProcessingRepositoryImpl`:
- Successful API calls
- Error handling
- Empty response handling
- Different video IDs
- Special characters in parameters
- Consecutive calls

### 3. Cubit Tests (`presentation/application/cubit/processing_logs_cubit_test.dart`)
Tests for `ProcessingLogsCubit` using `bloc_test`:
- State transitions (Initial → Loading → Loaded)
- Error state handling
- Reset functionality
- Multiple consecutive calls
- Edge cases (empty video ID, special characters)
- Various error types (Exception, FormatException, string errors)

### 4. Widget Tests (`presentation/widgets/processing_logs_timeline_test.dart`)
Tests for `ProcessingLogsTimeline` UI component:
- Empty state rendering
- Timeline event display
- Step icons and colors for different step types
- Timeline visual structure
- Header and step count display
- Edge cases (long text, special characters, many events)

## Running the Tests

### Run all tests:
```bash
flutter test
```

### Run specific test file:
```bash
flutter test test/src/modules/video_detail/data/models/processing_log_model_test.dart
```

### Run with coverage:
```bash
flutter test --coverage
```

### Generate coverage report:
```bash
# Install lcov first if not already installed
# On macOS: brew install lcov
# On Linux: sudo apt-get install lcov

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open in browser
open coverage/html/index.html
```

## Test Structure

All tests follow the Arrange-Act-Assert (AAA) pattern:
1. **Arrange**: Set up test data and mock dependencies
2. **Act**: Execute the code being tested
3. **Assert**: Verify the results

## Dependencies

The tests use the following packages (already in `pubspec.yaml`):
- `flutter_test`: Core Flutter testing framework
- `mocktail`: Mocking library
- `bloc_test`: Testing utilities for BLoC/Cubit

## Best Practices

- Tests are isolated and do not depend on each other
- Each test has a clear, descriptive name
- Mocks are used for external dependencies
- Edge cases and error conditions are thoroughly tested
- Widget tests verify both functionality and visual structure

## Coverage Goals

The test suite aims for:
- 100% coverage of model serialization/deserialization
- 100% coverage of repository implementation
- 100% coverage of Cubit state management logic
- Comprehensive coverage of widget rendering and interactions