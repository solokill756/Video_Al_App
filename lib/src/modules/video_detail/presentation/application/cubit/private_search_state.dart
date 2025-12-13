import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../data/models/private_search_model.dart';

part 'private_search_state.freezed.dart';

@freezed
class PrivateSearchState with _$PrivateSearchState {
  const factory PrivateSearchState.initial() = _Initial;
  const factory PrivateSearchState.loadingSession() = _LoadingSession;
  const factory PrivateSearchState.sessionLoaded({
    required String sessionId,
    required int totalVectors,
  }) = _SessionLoaded;
  const factory PrivateSearchState.searching() = _Searching;
  const factory PrivateSearchState.searchResults({
    required List<PrivateSearchResult> results,
    required int totalIndexed,
    required int tookMs,
    required String sessionId,
  }) = _SearchResults;
  const factory PrivateSearchState.error(String message) = _Error;
}
