import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/utils/app_environment.dart';
import '../../../app/app_router.dart';
import '../../data/model/search_model.dart';
import '../application/cubit/search_cubit.dart';
import '../application/cubit/search_state.dart';

@RoutePage()
class SearchResultsPage extends StatefulWidget {
  final String? query;
  final String? imageUrl;
  final bool isImageSearch;

  const SearchResultsPage({
    super.key,
    this.query,
    this.imageUrl,
    this.isImageSearch = false,
  });

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    // Trigger search when page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _performSearch();
    });
  }

  @override
  void didUpdateWidget(SearchResultsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If query or imageUrl changed, perform new search
    if (oldWidget.query != widget.query ||
        oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.isImageSearch != widget.isImageSearch) {
      _hasSearched = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch();
      });
    }
  }

  void _performSearch() {
    if (_hasSearched) return;

    final searchCubit = context.read<SearchCubit>();

    // Reset state before new search
    searchCubit.reset();

    if (widget.isImageSearch &&
        widget.imageUrl != null &&
        widget.imageUrl!.isNotEmpty) {
      searchCubit.searchByImage(widget.imageUrl!);
      _hasSearched = true;
    } else if (widget.query != null && widget.query!.isNotEmpty) {
      searchCubit.searchByText(widget.query!);
      _hasSearched = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => context.router.maybePop(),
        ),
        title: Text(
          widget.isImageSearch ? 'Image Search Results' : 'Search Results',
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
              ),
            ),
            loadingMore: () {
              // When loading more, we need to get previous results
              // Since freezed doesn't preserve previous state in loadingMore,
              // we'll use a BlocBuilder to get the latest state
              return BlocBuilder<SearchCubit, SearchState>(
                builder: (context, currentState) {
                  return currentState.when(
                    initial: () => const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
                      ),
                    ),
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
                      ),
                    ),
                    loadingMore: () => const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
                      ),
                    ),
                    resultsLoaded: (results, totalResults, hasMorePages,
                        currentPage, itemsPerPage) {
                      return _buildResultsList(
                        context,
                        results,
                        totalResults,
                        hasMorePages,
                        isLoadingMore: true,
                      );
                    },
                    error: (message) => Center(
                      child: Text(message),
                    ),
                  );
                },
              );
            },
            resultsLoaded: (results, totalResults, hasMorePages, currentPage,
                itemsPerPage) {
              return _buildResultsList(
                context,
                results,
                totalResults,
                hasMorePages,
                isLoadingMore: false,
              );
            },
            error: (message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Color(0xFFEF4444),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.router.maybePop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Group results by videoPath and sort by highest score
  Map<String, List<SearchResult>> _groupResultsByVideo(
      List<SearchResult> results) {
    final grouped = <String, List<SearchResult>>{};

    for (final result in results) {
      if (!grouped.containsKey(result.videoPath)) {
        grouped[result.videoPath] = [];
      }
      grouped[result.videoPath]!.add(result);
    }

    // Sort frames within each group by score (descending)
    for (final key in grouped.keys) {
      grouped[key]!.sort((a, b) => b.score.compareTo(a.score));
    }

    // Sort groups by highest score in group (descending)
    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) {
        final maxScoreA =
            a.value.map((r) => r.score).reduce((a, b) => a > b ? a : b);
        final maxScoreB =
            b.value.map((r) => r.score).reduce((a, b) => a > b ? a : b);
        return maxScoreB.compareTo(maxScoreA);
      });

    return Map.fromEntries(sortedEntries);
  }

  Widget _buildResultsList(
    BuildContext context,
    List<SearchResult> results,
    int totalResults,
    bool hasMorePages, {
    required bool isLoadingMore,
  }) {
    if (results.isEmpty && !isLoadingMore) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 16),
            const Text(
              'No results found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try a different search query',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      );
    }

    // Group results by videoPath
    final groupedResults = _groupResultsByVideo(results);
    final videoGroups = groupedResults.entries.toList();

    return Column(
      children: [
        // Results count
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          color: Colors.white,
          child: Row(
            children: [
              Text(
                '$totalResults result${totalResults != 1 ? 's' : ''} found in ${videoGroups.length} video${videoGroups.length != 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        // Results list grouped by video
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: videoGroups.length + (isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == videoGroups.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
                    ),
                  ),
                );
              }

              final videoGroup = videoGroups[index];
              final videoPath = videoGroup.key;
              final frames = videoGroup.value;
              final maxScore =
                  frames.map((r) => r.score).reduce((a, b) => a > b ? a : b);

              return _buildVideoGroup(context, videoPath, frames, maxScore);
            },
          ),
        ),
        // Load more button
        if (hasMorePages && !isLoadingMore)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.read<SearchCubit>().loadMore(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Load More',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVideoGroup(
    BuildContext context,
    String videoPath,
    List<SearchResult> frames,
    double maxScore,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video group header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0D9488).withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.video_library,
                            size: 18,
                            color: Color(0xFF0D9488),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              videoPath,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D9488),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${frames.length} frame${frames.length != 1 ? 's' : ''}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D9488).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Best: ${(maxScore * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0D9488),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Frames grid
          Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: frames.length,
              itemBuilder: (context, index) {
                return _buildResultCard(context, frames[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, SearchResult result) {
    final imageUrl = '${AppEnvironment.imageBaseUrl}/${result.imagePath}';
    final videoUrl = '${AppEnvironment.videoBaseUrl}/${result.videoPath}';
    final timeInSeconds = result.ptsTime.toInt();
    final minutes = timeInSeconds ~/ 60;
    final seconds = timeInSeconds % 60;

    return GestureDetector(
      onTap: () {
        // Navigate to video player with pts_time
        context.router.push(
          VideoPlayerRoute(
            videoUrl: videoUrl,
            videoTitle: result.videoPath,
            initialPosition: Duration(seconds: timeInSeconds),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Container(
                    color: const Color(0xFFF3F4F6),
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: const Color(0xFFF3F4F6),
                    child: const Icon(
                      Icons.broken_image,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.videoPath,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${minutes}m ${seconds}s',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D9488).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${(result.score * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0D9488),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
