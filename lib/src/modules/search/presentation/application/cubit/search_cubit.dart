import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../common/mixin/cancelable_base_bloc.dart';
import '../../../data/model/search_model.dart';
import '../../../domain/repository/search_repository.dart';
import 'search_state.dart';

@injectable
class SearchCubit extends Cubit<SearchState> with CancelableBaseBloc {
  final SearchRepository _repository;

  SearchCubit(this._repository) : super(const SearchState.initial());

  static const int maxTopK = 1500;
  static const int itemsPerPage = 20;

  List<SearchResult> _allResults = [];
  List<SearchResult> _currentDisplayedResults = [];
  int _currentPage = 1;

  Future<void> searchByText(String query, {int topK = maxTopK}) async {
    if (query.trim().isEmpty) {
      emit(const SearchState.error(message: 'Please enter a search query'));
      return;
    }

    if (topK > maxTopK) {
      topK = maxTopK;
    }

    _currentPage = 1;
    _allResults = [];

    emit(const SearchState.loading());

    final result = await _repository.searchByText(
      query: query,
      topK: topK,
    );

    result.fold(
      (response) {
        _allResults = response.results;
        _updateState();
      },
      (error) {
        emit(SearchState.error(message: error.message));
      },
    );
  }

  Future<void> searchByImage(String imageUrl, {int topK = maxTopK}) async {
    if (imageUrl.isEmpty) {
      emit(const SearchState.error(message: 'Image URL is required'));
      return;
    }

    if (topK > maxTopK) {
      topK = maxTopK;
    }

    _currentPage = 1;
    _allResults = [];

    emit(const SearchState.loading());

    final result = await _repository.searchByImage(
      imageUrl: imageUrl,
      topK: topK,
    );

    result.fold(
      (response) {
        _allResults = response.results;
        _updateState();
      },
      (error) {
        emit(SearchState.error(message: error.message));
      },
    );
  }

  void loadMore() {
    state.maybeWhen(
      resultsLoaded: (results, totalResults, hasMorePages, currentPage, itemsPerPage) {
        if (!hasMorePages) return;
        _currentPage++;
        // Emit loadingMore with current results still visible
        emit(SearchState.loadingMore());
        // Update state after a brief delay to show loading indicator
        Future.microtask(() => _updateState());
      },
      orElse: () {},
    );
  }

  void _updateState() {
    final totalResults = _allResults.length;
    final endIndex = (_currentPage * itemsPerPage).clamp(0, totalResults);
    _currentDisplayedResults = _allResults.sublist(0, endIndex);
    final hasMorePages = endIndex < totalResults;

    emit(SearchState.resultsLoaded(
      results: _currentDisplayedResults,
      totalResults: totalResults,
      hasMorePages: hasMorePages,
      currentPage: _currentPage,
      itemsPerPage: itemsPerPage,
    ));
  }

  void reset() {
    _allResults = [];
    _currentDisplayedResults = [];
    _currentPage = 1;
    emit(const SearchState.initial());
  }
}

