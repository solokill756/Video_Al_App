import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../common/utils/app_environment.dart';
import '../models/mastra_response_model.dart';
import '../models/video_result_model.dart';

@injectable
class MastraApiService {
  static final String _mastraBaseUrl = AppEnvironment.mastraApiUrl;
  static final String _agentId = 'aiTutorAgent';
  static final String _videoServer = AppEnvironment.videoServer;
  static final String? _apiKey = AppEnvironment.googleGenerativeAiApiKey;

  MastraApiService();

  /// Send message to AI agent with conversation history
  Future<MastraResponseModel> sendMessageToAgent(
    String message,
    List<ConversationMessage> conversationHistory, {
    CancelToken? cancelToken,
  }) async {
    // Validate API key
    if (_apiKey == null) {
      throw Exception('GOOGLE_GENERATIVE_AI_API_KEY is not set in .env file');
    }

    // Validate base URL
    if (_mastraBaseUrl.isEmpty) {
      throw Exception(
          'MASTRA_API_URL is not set in .env file. Current value: "$_mastraBaseUrl"');
    }

    print('MastraApiService: Base URL = $_mastraBaseUrl');
    print('MastraApiService: API Key = ${_apiKey!.substring(0, 10)}...');

    // Build messages array: history + new message
    final messages = [
      ...conversationHistory.map((msg) => {
            'role': msg.role,
            'content': msg.content,
          }),
      {
        'role': 'user',
        'content': message,
      },
    ];

    try {
      // Validate base URL
      if (_mastraBaseUrl.isEmpty) {
        throw Exception('MASTRA_API_URL is not set in .env file');
      }

      // Use a separate Dio instance for Mastra API (no auth interceptor)
      final mastraDio = Dio(
        BaseOptions(
          baseUrl: _mastraBaseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      print(
          'MastraApiService: Calling ${_mastraBaseUrl}/api/agents/$_agentId/generate');

      final response = await mastraDio.post(
        '/api/agents/$_agentId/generate',
        data: {
          'messages': messages,
          'apiKey': _apiKey,
        },
        cancelToken: cancelToken,
      );

      return MastraResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        throw Exception('Request was cancelled');
      }

      // Better error message for connection errors
      if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Cannot connect to Mastra API at $_mastraBaseUrl. Please check if the server is running and accessible.',
        );
      }

      throw Exception(
        e.response?.data?['message'] ??
            e.message ??
            'Failed to get AI response: ${e.type}',
      );
    }
  }

  /// Clean text for display by removing video URLs and formatting Markdown
  String cleanTextForDisplay(String text) {
    if (text.isEmpty) return text;

    String cleaned = text;

    // Remove video URLs (they will be shown as video cards)
    final urlPattern = RegExp(
      r'(?:\[([^\]]+)\]\()?(https?://[^\s\n\)]+/api/video/[^\s\n\)]+\.mp4(?:#t=(\d+\.?\d*))?)(?:\))?',
      caseSensitive: false,
    );

    // Remove URLs and their surrounding Markdown patterns
    cleaned = cleaned.replaceAll(urlPattern, '');

    // Remove bullet points that only contain video URLs
    // Pattern: *   **Video:** [empty after URL removal]
    cleaned = cleaned.replaceAll(
      RegExp(r'[*•]\s*\*\*Video:\*\*\s*\n?', caseSensitive: false),
      '',
    );

    // Remove empty bullet points
    cleaned =
        cleaned.replaceAll(RegExp(r'[*•]\s*\n', caseSensitive: false), '');

    // Clean up Markdown formatting for better display
    // Keep structure but make it readable
    cleaned = _formatMarkdownForDisplay(cleaned);

    // Clean up extra whitespace and newlines
    cleaned = cleaned
        .replaceAll(RegExp(r'\n{3,}'), '\n\n') // Max 2 newlines
        .replaceAll(RegExp(r'[ \t]+'), ' ') // Multiple spaces to single
        .trim();

    return cleaned;
  }

  /// Format Markdown for better display (simplified formatting)
  String _formatMarkdownForDisplay(String text) {
    if (text.isEmpty) return text;

    String formatted = text;

    // Convert **bold** to readable text (keep bold but readable)
    formatted = formatted.replaceAllMapped(
      RegExp(r'\*\*([^*]+)\*\*'),
      (match) => match.group(1) ?? '',
    );

    // Convert *italic* to readable text
    formatted = formatted.replaceAllMapped(
      RegExp(r'(?<!\*)\*([^*]+)\*(?!\*)'),
      (match) => match.group(1) ?? '',
    );

    // Convert headings to readable text
    formatted = formatted.replaceAllMapped(
      RegExp(r'^#{1,6}\s+(.+)$', multiLine: true),
      (match) => '${match.group(1) ?? ''}\n',
    );

    // Convert bullet points to readable format
    formatted =
        formatted.replaceAll(RegExp(r'^[*•]\s+', multiLine: true), '• ');

    // Convert numbered lists
    formatted = formatted.replaceAll(RegExp(r'^\d+\.\s+', multiLine: true), '');

    return formatted;
  }

  /// Parse AI response to extract text and videos
  List<VideoResultModel> parseVideoResults(MastraResponseModel response) {
    final videos = <VideoResultModel>[];
    int index = 0;

    // First, try to parse videos from text response (if AI returns URLs in text)
    final text = response.text ?? '';
    if (text.isNotEmpty) {
      videos.addAll(_parseVideosFromText(text, index));
      index = videos.length;
    }

    // Extract from formattedResults (if available)
    if (response.toolOutput?.formattedResults != null) {
      for (final result in response.toolOutput!.formattedResults!) {
        final timestamp = result.ptsTime;
        final videoPath = result.videoPath;

        if (videoPath.isNotEmpty) {
          videos.add(
            VideoResultModel(
              id: 'formatted-$index',
              title: result.title ?? 'Video Lecture',
              videoUrl: '$_videoServer/$videoPath.mp4#t=${timestamp.toInt()}',
              timestamp: timestamp,
              videoPath: videoPath,
              transcript: result.transcript,
            ),
          );
          index++;
        }
      }
    }

    // Extract from searchResults (if available)
    if (response.toolOutput?.searchResults != null) {
      final searchResults = response.toolOutput!.searchResults!;
      final videoPaths = searchResults.videoPaths ?? [];
      final ptsTimes = searchResults.ptsTimes ?? [];
      final scores = searchResults.scores ?? [];

      for (int i = 0; i < videoPaths.length; i++) {
        final videoPath = videoPaths[i];
        final timestamp = i < ptsTimes.length ? ptsTimes[i] : 0.0;
        final score = i < scores.length ? scores[i] : null;

        videos.add(
          VideoResultModel(
            id: 'search-$index',
            title: 'Video Result ${index + 1}',
            videoUrl: '$_videoServer/$videoPath.mp4#t=${timestamp.toInt()}',
            timestamp: timestamp,
            videoPath: videoPath,
            score: score,
          ),
        );
        index++;
      }
    }

    return videos;
  }

  /// Parse video URLs from Markdown text response
  /// Supports Markdown formats like:
  /// - **Video:** [title] URL [description]
  /// - * [description] URL
  /// - [text](url) or plain URLs
  /// Extracts URLs like: http://100.79.229.28:8865/api/video/04_03_2025%20Basic%20Style%20Transfer.mp4#t=1578.88
  List<VideoResultModel> _parseVideosFromText(String text, int startIndex) {
    final videos = <VideoResultModel>[];
    int index = startIndex;

    // Regex pattern to match video URLs with timestamp
    // Matches: http://.../api/video/...mp4#t=123.45 or http://.../api/video/...mp4
    // Also matches Markdown links: [text](http://.../api/video/...mp4#t=123.45)
    final urlPattern = RegExp(
      r'(?:\[([^\]]+)\]\()?(https?://[^\s\n\)]+/api/video/[^\s\n\)]+\.mp4(?:#t=(\d+\.?\d*))?)(?:\))?',
      caseSensitive: false,
    );

    // Find all matches
    final matches = urlPattern.allMatches(text);

    for (final match in matches) {
      final linkText = match.group(1); // Text from [text](url) if Markdown link
      final fullUrl = match.group(2)!;
      final timestampStr = match.group(3);

      // Extract timestamp
      double? timestamp;
      if (timestampStr != null) {
        timestamp = double.tryParse(timestampStr);
      }

      // Extract video path from URL
      // Example: http://100.79.229.28:8865/api/video/04_03_2025%20Basic%20Style%20Transfer.mp4#t=1578.88
      // Extract: 04_03_2025 Basic Style Transfer (decoded)
      String? videoPath;
      try {
        final uri = Uri.parse(fullUrl);
        final pathSegments = uri.pathSegments;
        if (pathSegments.isNotEmpty) {
          // Get the last segment (filename)
          final videoFileName = pathSegments.last;
          // Decode URL encoding (%20 -> space)
          videoPath = Uri.decodeComponent(videoFileName);
          // Remove .mp4 extension for videoPath
          if (videoPath.endsWith('.mp4')) {
            videoPath = videoPath.substring(0, videoPath.length - 4);
          }
        }
      } catch (e) {
        print('Error parsing video URL: $fullUrl - $e');
      }

      // Extract title and description from surrounding Markdown text
      String? title;
      String? description;
      final matchStart = match.start;
      final matchEnd = match.end;

      // Look for text before and after the URL (wider context for Markdown)
      final contextStart = matchStart > 150 ? matchStart - 150 : 0;
      final contextEnd =
          matchEnd + 400 < text.length ? matchEnd + 400 : text.length;
      final contextText = text.substring(contextStart, contextEnd);
      final urlIndexInContext = matchStart - contextStart;

      // If it's a Markdown link [text](url), use the link text as title
      if (linkText != null && linkText.isNotEmpty) {
        title = _stripMarkdown(linkText);
      }

      // Try to find title/description patterns in Markdown format
      // Pattern 1: **Video:** [title] URL [description]
      final videoHeaderPattern = RegExp(
        r'\*\*Video:\*\*\s*([^\n*]+?)(?:\s*(?:http|\[))',
        caseSensitive: false,
        dotAll: true,
      );

      // Pattern 2: ### Heading or ## Heading before URL
      final headingPattern = RegExp(
        r'^#{1,6}\s+([^\n]+)$',
        caseSensitive: false,
        multiLine: true,
      );

      // Try to find title from patterns before URL
      if (title == null) {
        final beforeUrl = contextText.substring(0, urlIndexInContext);

        // Check for **Video:** pattern
        final videoMatch = videoHeaderPattern.firstMatch(beforeUrl);
        if (videoMatch != null) {
          title = _stripMarkdown(videoMatch.group(1)?.trim() ?? '');
        } else {
          // Check for headings
          final headingMatches = headingPattern.allMatches(beforeUrl);
          if (headingMatches.isNotEmpty) {
            final lastHeading = headingMatches.last;
            title = _stripMarkdown(lastHeading.group(1)?.trim() ?? '');
          }
        }
      }

      // Extract description from text after URL
      if (matchEnd < text.length) {
        final afterText = text.substring(
          matchEnd,
          matchEnd + 300 < text.length ? matchEnd + 300 : text.length,
        );

        // Look for description patterns in Markdown format
        final descPatterns = [
          // Pattern: * This video segment discusses...
          RegExp(
              r'[*•]\s*This (?:video|clip|segment) (?:discusses|explains|introduces|delves into)[\s:]+([^\n*]+)',
              caseSensitive: false),
          // Pattern: * [description]
          RegExp(r'[*•]\s*([^\n]+)', caseSensitive: false),
          // Pattern: - [description]
          RegExp(r'-\s*([^\n]+)', caseSensitive: false),
          // Pattern: This video/clip/segment discusses...
          RegExp(
              r'This (?:video|clip|segment) (?:discusses|explains|introduces|delves into)[\s:]+([^\n*]+)',
              caseSensitive: false),
        ];

        for (final pattern in descPatterns) {
          final descMatch = pattern.firstMatch(afterText);
          if (descMatch != null) {
            description = _stripMarkdown(descMatch.group(1)?.trim() ?? '');
            // Clean up description
            description = description.replaceAll(
                RegExp(r'^(This video|This clip|This segment)[\s:]+',
                    caseSensitive: false),
                '');
            if (description.isNotEmpty) {
              break;
            }
          }
        }
      }

      // Use video filename as fallback title if no title found
      final finalTitle = title ??
          (videoPath != null ? _formatVideoTitle(videoPath) : null) ??
          'Video ${index + 1}';

      videos.add(
        VideoResultModel(
          id: 'text-$index',
          title: finalTitle,
          videoUrl: fullUrl,
          timestamp: timestamp,
          videoPath: videoPath,
          transcript: description,
        ),
      );
      index++;
    }

    return videos;
  }

  /// Strip Markdown formatting from text
  /// Removes: **bold**, *italic*, `code`, [links](url), # headings, etc.
  String _stripMarkdown(String text) {
    if (text.isEmpty) return text;

    String result = text;

    // Remove bold: **text** or __text__
    result = result.replaceAllMapped(
      RegExp(r'\*\*([^*]+)\*\*'),
      (match) => match.group(1) ?? '',
    );
    result = result.replaceAllMapped(
      RegExp(r'__([^_]+)__'),
      (match) => match.group(1) ?? '',
    );

    // Remove italic: *text* or _text_ (but not if it's part of **text**)
    result = result.replaceAllMapped(
      RegExp(r'(?<!\*)\*([^*]+)\*(?!\*)'),
      (match) => match.group(1) ?? '',
    );
    result = result.replaceAllMapped(
      RegExp(r'(?<!_)_([^_]+)_(?!_)'),
      (match) => match.group(1) ?? '',
    );

    // Remove inline code: `code`
    result = result.replaceAllMapped(
      RegExp(r'`([^`]+)`'),
      (match) => match.group(1) ?? '',
    );

    // Remove links: [text](url) -> text
    result = result.replaceAllMapped(
      RegExp(r'\[([^\]]+)\]\([^\)]+\)'),
      (match) => match.group(1) ?? '',
    );

    // Remove headings: # Heading -> Heading
    result = result.replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '');

    // Remove strikethrough: ~~text~~
    result = result.replaceAllMapped(
      RegExp(r'~~([^~]+)~~'),
      (match) => match.group(1) ?? '',
    );

    // Clean up extra whitespace
    result = result.trim().replaceAll(RegExp(r'\s+'), ' ');

    return result;
  }

  /// Format video filename to a readable title
  String _formatVideoTitle(String videoPath) {
    // Remove common prefixes and format
    String title = videoPath;

    // Replace underscores and dashes with spaces
    title = title.replaceAll(RegExp(r'[_-]'), ' ');

    // Capitalize first letter of each word
    final words = title.split(' ');
    title = words.map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');

    return title;
  }
}
