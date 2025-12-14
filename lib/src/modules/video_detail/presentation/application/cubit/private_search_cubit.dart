import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/repository/private_search_repository.dart';
import 'private_search_state.dart';

@injectable
class PrivateSearchCubit extends Cubit<PrivateSearchState> {
  final PrivateSearchRepository _repository;

  PrivateSearchCubit(this._repository)
      : super(const PrivateSearchState.initial());

  /// Load session với video IDs
  Future<void> loadSession(List<String> videoIds) async {
    try {
      emit(const PrivateSearchState.loadingSession());
      final response = await _repository.loadData(videoIds);
      emit(PrivateSearchState.sessionLoaded(
        sessionId: response.sessionId,
        totalVectors: response.totalVectors,
      ));
    } catch (e) {
      // Format error message to be more user-friendly
      String errorMessage = 'Failed to load session';
      if (e.toString().contains('404')) {
        errorMessage =
            'Search service not available (404). Please check configuration.';
      } else if (e.toString().contains('Connection refused') ||
          e.toString().contains('connection error')) {
        errorMessage =
            'Cannot connect to search service. Please check your connection.';
      } else {
        errorMessage = 'Failed to load session: ${e.toString()}';
      }
      emit(PrivateSearchState.error(errorMessage));
    }
  }

  /// Search by text
  Future<void> searchByText(String query, {int topK = 20}) async {
    try {
      final currentState = state;
      String? _sessionId;

      currentState.whenOrNull(
        sessionLoaded: (id, _) => _sessionId = id,
        searchResults: (results, totalIndexed, tookMs, sessionId) =>
            _sessionId = sessionId,
        permissionDenied: (message, sessionId) => _sessionId = sessionId,
      );

      if (_sessionId == null) {
        emit(const PrivateSearchState.error('Session not loaded'));
        return;
      }

      emit(const PrivateSearchState.searching());
      final response = await _repository.searchByText(
        sessionId: _sessionId!,
        query: query,
        topK: topK,
      );
      emit(PrivateSearchState.searchResults(
        results: response.results,
        totalIndexed: response.totalIndexed,
        tookMs: response.tookMs,
        sessionId: _sessionId!,
      ));
    } catch (e) {
      emit(PrivateSearchState.error('Search failed: $e'));
    }
  }

  /// Search by image URL
  Future<void> searchByImageUrl(String imageUrl, {int topK = 20}) async {
    try {
      final currentState = state;
      String? _sessionId;

      currentState.whenOrNull(
        sessionLoaded: (id, _) => _sessionId = id,
        searchResults: (results, totalIndexed, tookMs, sessionId) =>
            _sessionId = sessionId,
        permissionDenied: (message, sessionId) => _sessionId = sessionId,
      );

      if (_sessionId == null) {
        emit(const PrivateSearchState.error('Session not loaded'));
        return;
      }

      emit(const PrivateSearchState.searching());
      final checkPermission = await checkCanSearchByImage(_sessionId!);
      if (checkPermission == false) {
        return;
      }
      final response = await _repository.searchByImageUrl(
        sessionId: _sessionId!,
        imageUrl: imageUrl,
        topK: topK,
      );
      emit(PrivateSearchState.searchResults(
        results: response.results,
        totalIndexed: response.totalIndexed,
        tookMs: response.tookMs,
        sessionId: _sessionId!,
      ));
    } catch (e) {
      emit(PrivateSearchState.error('Search failed: $e'));
    }
  }

  /// Unload session
  Future<void> unloadSession() async {
    try {
      final currentState = state;
      String? sessionId;

      currentState.whenOrNull(
        sessionLoaded: (id, _) => sessionId = id,
        searchResults: (results, totalIndexed, tookMs, sessionId) =>
            sessionId = sessionId,
        permissionDenied: (message, sessionId) => sessionId = sessionId,
      );

      if (sessionId != null) {
        await _repository.unloadSession(sessionId!);
      }
      emit(const PrivateSearchState.initial());
    } catch (e) {
      print('Failed to unload session: $e');
    }
  }

  /// Reset state
  void reset() {
    emit(const PrivateSearchState.initial());
  }

  /// Check if can search by image
  Future<bool> checkCanSearchByImage(String sessionId) async {
    try {
      await _repository.checkCanSearchByImage();
      return true;
    } catch (e) {
      emit(PrivateSearchState.permissionDenied(
        'You do not have permission to search by image.',
        sessionId,
      ));
      return false;
    }
  }
}
