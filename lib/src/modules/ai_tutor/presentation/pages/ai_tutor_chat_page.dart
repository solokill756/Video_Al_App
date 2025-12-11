import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../application/cubit/ai_tutor_cubit.dart';
import '../application/cubit/ai_tutor_state.dart';
import '../../../app/app_router.dart';
import '../../data/models/video_result_model.dart';

@RoutePage()
class AITutorChatPageNew extends StatefulWidget {
  const AITutorChatPageNew({super.key});

  @override
  State<AITutorChatPageNew> createState() => _AITutorChatPageNewState();
}

class _AITutorChatPageNewState extends State<AITutorChatPageNew> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Listen to text changes to rebuild send button
    _messageController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AITutorCubit, AITutorState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: _buildAppBar(context, state),
          body: Column(
            children: [
              // Chat Messages
              Expanded(
                child: _buildChatMessages(state),
              ),
              // Input Area
              _buildInputArea(context, state),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AITutorState state) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: const Color(0xFF0D9488).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.smart_toy_rounded,
              color: const Color(0xFF0D9488),
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.activeConversation?.name ?? 'AI Tutor',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                Text(
                  'Ask AI and watch lecture videos',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.history, color: Color(0xFF1F2937)),
          onPressed: () => _showConversationHistory(context, state),
        ),
      ],
    );
  }

  Widget _buildChatMessages(AITutorState state) {
    if (state.isLoadingMessages) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
        ),
      );
    }

    if (state.messages.isEmpty) {
      return _buildWelcomeMessage();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      itemCount: state.messages.length + (state.isAILoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.messages.length) {
          // Loading indicator for AI response
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    Icons.smart_toy_rounded,
                    color: const Color(0xFF0D9488),
                    size: 18.sp,
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFF0D9488),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return _buildMessageBubble(state.messages[index]);
      },
    );
  }

  Widget _buildWelcomeMessage() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.all(24.w),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Icon(
                Icons.smart_toy_rounded,
                color: const Color(0xFF0D9488),
                size: 40.sp,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              '👋 Hello! I\'m your AI Tutor',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
            ),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Text(
                'Ask me a question and I\'ll help you find relevant lecture videos!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: const Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    Icons.smart_toy_rounded,
                    color: const Color(0xFF0D9488),
                    size: 18.sp,
                  ),
                ),
                SizedBox(width: 8.w),
              ],
              Flexible(
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isUser ? const Color(0xFF0D9488) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                      bottomLeft: Radius.circular(isUser ? 16.r : 4.r),
                      bottomRight: Radius.circular(isUser ? 4.r : 16.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // For bot messages, parse and display text with videos interspersed
                      if (!isUser && message.videos.isNotEmpty)
                        ..._buildMessageWithVideos(message)
                      else
                        Text(
                          message.content,
                          style: TextStyle(
                            fontSize: 15.sp,
                            color:
                                isUser ? Colors.white : const Color(0xFF1F2937),
                            height: 1.4,
                          ),
                        ),
                      // Show videos at end for user messages or if parsing failed
                      if (isUser && message.videos.isNotEmpty) ...[
                        SizedBox(height: 12.h),
                        ...message.videos
                            .map((video) => _buildVideoCard(video)),
                      ],
                      if (message.isError)
                        Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: Text(
                            'Failed to save message',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.red[300],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (isUser) ...[
                SizedBox(width: 8.w),
                Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    Icons.person,
                    color: const Color(0xFF0D9488),
                    size: 18.sp,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// Build message content with videos interspersed in text (similar to React version)
  List<Widget> _buildMessageWithVideos(ChatMessage message) {
    final widgets = <Widget>[];

    // Get raw text if available (for parsing video positions)
    final rawText = message.rawResponse?['rawText'] as String?;
    if (rawText == null || message.videos.isEmpty) {
      // Fallback: show formatted text then all videos
      return [
        _buildFormattedText(message.content),
        SizedBox(height: 12.h),
        ...message.videos.map((video) => _buildVideoCard(video)),
      ];
    }

    // Parse raw text to find video URLs and their positions
    final urlPattern = RegExp(
      r'(?:\[([^\]]+)\]\()?(https?://[^\s\n\)]+/api/video/[^\s\n\)]+\.mp4(?:#t=(\d+\.?\d*))?)(?:\))?',
      caseSensitive: false,
    );

    final matches = urlPattern.allMatches(rawText);
    final videoPositions = <({int position, VideoResultModel video})>[];

    // Match videos with their positions in raw text
    for (final video in message.videos) {
      for (final match in matches) {
        final matchUrl = match.group(2);
        if (matchUrl != null && matchUrl == video.videoUrl) {
          videoPositions.add((
            position: match.start,
            video: video,
          ));
          break;
        }
      }
    }

    // Sort by position
    videoPositions.sort((a, b) => a.position.compareTo(b.position));

    // Simple approach: split cleaned text evenly and insert videos
    // Remove transcript text from segments to avoid duplication
    final cleanedText = message.content;
    final videoCount = videoPositions.length;

    if (videoCount == 0) {
      return [
        _buildFormattedText(cleanedText),
      ];
    }

    // Split text into segments (one before each video, plus one after last)
    final segmentLength = cleanedText.length ~/ (videoCount + 1);
    int currentIndex = 0;

    for (int i = 0; i < videoCount; i++) {
      // Calculate end position for this segment
      final segmentEnd = (i + 1) * segmentLength;

      // Extract text segment
      String textSegment = cleanedText
          .substring(
            currentIndex.clamp(0, cleanedText.length),
            segmentEnd.clamp(0, cleanedText.length),
          )
          .trim();

      // Remove transcript from text segment if it exists in video card
      final video = videoPositions[i].video;
      if (video.transcript != null && video.transcript!.isNotEmpty) {
        textSegment = _removeTranscriptFromText(textSegment, video.transcript!);

        // Also check if text segment contains similar description patterns
        // Remove any text that looks like it's describing the video
        textSegment = _removeVideoDescriptionPatterns(textSegment);
      }

      // Add text segment if not empty after removing transcript
      if (textSegment.isNotEmpty) {
        widgets.add(_buildFormattedText(textSegment));
        widgets.add(SizedBox(height: 12.h));
      }

      // Add video card
      widgets.add(_buildVideoCard(video));
      widgets.add(SizedBox(height: 12.h));

      currentIndex = segmentEnd;
    }

    // Add remaining text after last video
    if (currentIndex < cleanedText.length) {
      String remaining = cleanedText.substring(currentIndex).trim();

      // Remove transcript from remaining text if last video has transcript
      if (videoCount > 0) {
        final lastVideo = videoPositions[videoCount - 1].video;
        if (lastVideo.transcript != null && lastVideo.transcript!.isNotEmpty) {
          remaining =
              _removeTranscriptFromText(remaining, lastVideo.transcript!);
        }
      }
      // Also remove video description patterns
      remaining = _removeVideoDescriptionPatterns(remaining);

      if (remaining.isNotEmpty) {
        widgets.add(_buildFormattedText(remaining));
      }
    }

    return widgets.isEmpty
        ? [
            _buildFormattedText(message.content),
            SizedBox(height: 12.h),
            ...message.videos.map((video) => _buildVideoCard(video)),
          ]
        : widgets;
  }

  /// Remove transcript text from segment to avoid duplication
  String _removeTranscriptFromText(String text, String transcript) {
    if (text.isEmpty || transcript.isEmpty) return text;

    // Normalize both texts for comparison
    final normalizedText = text.toLowerCase().trim();
    final normalizedTranscript = transcript.toLowerCase().trim();

    // If transcript is very long, try to find a shorter unique part
    String searchText = normalizedTranscript;
    if (normalizedTranscript.length > 100) {
      // Try first 50-100 characters
      searchText = normalizedTranscript.substring(0, 100);
    }

    // Try to find and remove transcript from text
    final transcriptIndex = normalizedText.indexOf(searchText);
    if (transcriptIndex != -1) {
      // Found transcript in text, remove it
      final beforeTranscript = text.substring(0, transcriptIndex).trim();
      final afterTranscript =
          text.substring(transcriptIndex + transcript.length).trim();

      // Combine and clean up
      final result = [beforeTranscript, afterTranscript]
          .where((s) => s.isNotEmpty)
          .join(' ')
          .trim();

      // Clean up extra spaces and punctuation
      return result
          .replaceAll(RegExp(r'\s+'), ' ')
          .replaceAll(RegExp(r'[.,;:]\s*[.,;:]'), '.')
          .trim();
    }

    // If exact match not found, try to remove similar phrases
    // Remove common patterns like "Video này giải thích về..." or "This video explains..."
    final patterns = [
      RegExp(
          r'Video này (?:giải thích|thảo luận|đề cập|discusses|explains)[^.]*\.',
          caseSensitive: false),
      RegExp(
          r'This (?:video|clip|segment) (?:discusses|explains|introduces|delves into)[^.]*\.',
          caseSensitive: false),
    ];

    String result = text;
    for (final pattern in patterns) {
      result = result.replaceAll(pattern, '').trim();
    }

    return result.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Remove common video description patterns from text
  String _removeVideoDescriptionPatterns(String text) {
    if (text.isEmpty) return text;

    String result = text;

    // Remove patterns that describe videos (these will be in video cards)
    final patterns = [
      // Vietnamese: "Video này giải thích về...", "Video này thảo luận về..."
      RegExp(
          r'Video này (?:giải thích|thảo luận|đề cập|discusses|explains|introduces|delves into|đi sâu vào)[^.]{0,300}\.?',
          caseSensitive: false),
      RegExp(r'Clip này (?:giải thích|thảo luận|đề cập)[^.]{0,300}\.?',
          caseSensitive: false),
      RegExp(r'Segment này (?:giải thích|thảo luận|đề cập)[^.]{0,300}\.?',
          caseSensitive: false),
      // English: "This video explains...", "This clip discusses..."
      RegExp(
          r'This (?:video|clip|segment) (?:discusses|explains|introduces|delves into|seems? to|appears? to)[^.]{0,300}\.?',
          caseSensitive: false),
      // Patterns starting with "It" or "This"
      RegExp(
          r'[Ii]t (?:discusses|explains|introduces|delves into|seems? to|appears? to)[^.]{0,300}\.?',
          caseSensitive: false),
      // Patterns with "thảo luận về", "giải thích về"
      RegExp(
          r'(?:thảo luận|giải thích|đề cập|discusses|explains) về[^.]{0,200}\.?',
          caseSensitive: false),
    ];

    for (final pattern in patterns) {
      result = result.replaceAll(pattern, '').trim();
    }

    // Clean up: remove duplicate spaces, fix punctuation
    result = result
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[.,;:]\s*[.,;:]'), '.')
        .replaceAll(RegExp(r'\.\s*\.'), '.')
        .trim();

    return result;
  }

  /// Build formatted text with Markdown support
  Widget _buildFormattedText(String text) {
    if (text.isEmpty) return const SizedBox.shrink();

    // Parse Markdown-like formatting
    final textSpans = <TextSpan>[];
    final buffer = StringBuffer();
    int i = 0;

    while (i < text.length) {
      // Check for **bold**
      if (i < text.length - 2 &&
          text[i] == '*' &&
          text[i + 1] == '*' &&
          text[i + 2] != '*') {
        // Found start of bold
        if (buffer.isNotEmpty) {
          textSpans.add(TextSpan(text: buffer.toString()));
          buffer.clear();
        }
        i += 2; // Skip **
        final boldStart = i;
        // Find end of bold
        while (i < text.length - 1) {
          if (text[i] == '*' && text[i + 1] == '*') {
            final boldText = text.substring(boldStart, i);
            textSpans.add(
              TextSpan(
                text: boldText,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
            i += 2; // Skip **
            break;
          }
          i++;
        }
        if (i >= text.length - 1) {
          // No closing **, add as normal text
          textSpans.add(TextSpan(text: text.substring(boldStart - 2)));
          break;
        }
      } else {
        buffer.write(text[i]);
        i++;
      }
    }

    if (buffer.isNotEmpty) {
      textSpans.add(TextSpan(text: buffer.toString()));
    }

    return textSpans.isEmpty
        ? Text(
            text,
            style: TextStyle(
              fontSize: 15.sp,
              color: const Color(0xFF1F2937),
              height: 1.4,
            ),
          )
        : Text.rich(
            TextSpan(
              children: textSpans,
              style: TextStyle(
                fontSize: 15.sp,
                color: const Color(0xFF1F2937),
                height: 1.4,
              ),
            ),
          );
  }

  Widget _buildVideoCard(VideoResultModel video) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF0F9FF),
            Color(0xFFE0F2FE),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFF0D9488),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D9488).withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Row
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.play_circle_outline,
                  color: const Color(0xFF0D9488),
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  video.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0C4A6E),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Video Path (if different from title)
          if (video.videoPath != null &&
              video.videoPath != video.title &&
              !video.title.contains(video.videoPath!))
            Padding(
              padding: EdgeInsets.only(bottom: 4.h),
              child: Row(
                children: [
                  Icon(
                    Icons.folder_outlined,
                    size: 12.sp,
                    color: const Color(0xFF6B7280),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      video.videoPath!,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: const Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          // Timestamp
          if (video.timestamp != null)
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 12.sp,
                    color: const Color(0xFF0369A1),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Thời điểm: ${_formatTimestamp(video.timestamp!)}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF0369A1),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '(${video.timestamp!.toStringAsFixed(2)}s)',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),

          // Transcript/Description
          if (video.transcript != null && video.transcript!.isNotEmpty)
            Container(
              padding: EdgeInsets.all(8.w),
              margin: EdgeInsets.only(bottom: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 12.sp,
                        color: const Color(0xFF6B7280),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Nội dung:',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    video.transcript!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF374151),
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

          // Play Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                context.router.push(
                  VideoPlayerRoute(
                    videoUrl: video.videoUrl,
                    videoTitle: video.title,
                    initialPosition: Duration(
                      seconds: video.timestamp?.toInt() ?? 0,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow, size: 18),
              label: const Text('Watch Video'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(double seconds) {
    final minutes = (seconds / 60).floor();
    final secs = (seconds % 60).floor();
    return '${minutes}m ${secs}s';
  }

  Widget _buildInputArea(BuildContext context, AITutorState state) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  focusNode: _focusNode,
                  enabled: !state.isAILoading,
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: const Color(0xFF1F2937),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter your question...',
                    hintStyle: TextStyle(
                      fontSize: 15.sp,
                      color: const Color(0xFF9CA3AF),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty && !state.isAILoading) {
                      _handleSendMessage(context, value.trim());
                    }
                  },
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: state.isAILoading
                    ? Colors.grey[300]
                    : const Color(0xFF0D9488),
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D9488).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    final text = _messageController.text.trim();
                    print(
                        'Send button tapped. Text: "$text", isLoading: ${state.isAILoading}');
                    if (text.isNotEmpty && !state.isAILoading) {
                      print('Calling _handleSendMessage');
                      _handleSendMessage(context, text);
                    } else {
                      print('Text is empty');
                    }
                  },
                  borderRadius: BorderRadius.circular(24.r),
                  child: Icon(
                    Icons.send_rounded,
                    color: state.isAILoading ||
                            _messageController.text.trim().isEmpty
                        ? Colors.white.withOpacity(0.5)
                        : Colors.white,
                    size: 24.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSendMessage(BuildContext context, String message) {
    if (message.trim().isEmpty) return;

    print('_handleSendMessage called with: "$message"');
    try {
      final cubit = context.read<AITutorCubit>();
      print('AITutorCubit found, calling sendMessage');
      cubit.sendMessage(message);
      _messageController.clear();
      _focusNode.unfocus();

      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      // Show error if cubit is not available
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showConversationHistory(
    BuildContext context,
    AITutorState state,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: BlocBuilder<AITutorCubit, AITutorState>(
          builder: (context, modalState) {
            return Column(
              children: [
                // Handle bar
                Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                // Title
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    children: [
                      Text(
                        'Conversation History',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // New Conversation Button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0xFF14B8A6),
                          Color(0xFF0D9488),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          context.read<AITutorCubit>().createConversation();
                        },
                        borderRadius: BorderRadius.circular(12.r),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'New Conversation',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                // Conversations List
                Expanded(
                  child: modalState.isLoadingConversations
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF0D9488),
                            ),
                          ),
                        )
                      : modalState.conversations.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline,
                                    size: 64.sp,
                                    color: const Color(0xFF9CA3AF),
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    'No conversations yet',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'Start a conversation to see history',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: const Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              itemCount: modalState.conversations.length,
                              itemBuilder: (context, index) {
                                final conversation =
                                    modalState.conversations[index];
                                final isActive =
                                    modalState.activeConversation?.id ==
                                        conversation.id;

                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: isActive
                                        ? const Color(0xFF0D9488)
                                        : const Color(0xFF0D9488)
                                            .withOpacity(0.1),
                                    child: Icon(
                                      Icons.chat_bubble_outline,
                                      color: isActive
                                          ? Colors.white
                                          : const Color(0xFF0D9488),
                                      size: 20.sp,
                                    ),
                                  ),
                                  title: Text(
                                    conversation.name,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: isActive
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: const Color(0xFF1F2937),
                                    ),
                                  ),
                                  subtitle: Text(
                                    _formatTime(conversation.updatedAt),
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: const Color(0xFF9CA3AF),
                                    ),
                                  ),
                                  trailing: isActive
                                      ? const Icon(
                                          Icons.check_circle,
                                          color: Color(0xFF0D9488),
                                        )
                                      : IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Color(0xFFEF4444),
                                          ),
                                          onPressed: () {
                                            context
                                                .read<AITutorCubit>()
                                                .deleteConversation(
                                                  conversation.id,
                                                );
                                          },
                                        ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    context
                                        .read<AITutorCubit>()
                                        .selectConversation(conversation.id);
                                  },
                                );
                              },
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
