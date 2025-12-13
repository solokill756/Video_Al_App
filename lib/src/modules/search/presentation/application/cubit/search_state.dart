import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../data/model/search_model.dart';

part 'search_state.freezed.dart';

@freezed
class SearchState with _$SearchState {
  const factory SearchState.initial() = _Initial;
  const factory SearchState.loading() = _Loading;
  const factory SearchState.loadingMore() = _LoadingMore;
  const factory SearchState.resultsLoaded({
    required List<SearchResult> results,
    required int totalResults,
    required bool hasMorePages,
    required int currentPage,
    required int itemsPerPage,
  }) = _ResultsLoaded;
  const factory SearchState.error({required String message}) = _Error;
}

