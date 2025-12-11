import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/app_router.dart';
import '../application/cubit/ai_tutor_cubit.dart';
import '../application/cubit/ai_tutor_state.dart';

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
          floatingActionButton: state.messages.isNotEmpty
              ? FloatingActionButton(
                  onPressed: () => _showConversationHistory(context, state),
                  backgroundColor: const Color(0xFF0D9488),
                  mini: true,
                  child: const Icon(Icons.history, color: Colors.white),
                )
              : null,
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
        if (state.isAILoading)
          Padding(
            padding: EdgeInsets.all(16.w),
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
                      Text(
                        message.content,
                        style: TextStyle(
                          fontSize: 15.sp,
                          color:
                              isUser ? Colors.white : const Color(0xFF1F2937),
                          height: 1.4,
                        ),
                      ),
                      if (message.videos.isNotEmpty) ...[
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

  Widget _buildVideoCard(video) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(Icons.play_circle_outline, color: const Color(0xFF0D9488)),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                if (video.timestamp != null)
                  Text(
                    'At ${_formatTimestamp(video.timestamp!)}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.play_arrow, color: Color(0xFF0D9488)),
            onPressed: () {
              // Navigate to video player
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
                  onTap: state.isAILoading ||
                          _messageController.text.trim().isEmpty
                      ? null
                      : () {
                          _handleSendMessage(
                            context,
                            _messageController.text.trim(),
                          );
                        },
                  borderRadius: BorderRadius.circular(24.r),
                  child: Icon(
                    Icons.send_rounded,
                    color: Colors.white,
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

    context.read<AITutorCubit>().sendMessage(message);
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
          builder: (context, state) {
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
                  child: state.isLoadingConversations
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF0D9488),
                            ),
                          ),
                        )
                      : state.conversations.isEmpty
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
                              itemCount: state.conversations.length,
                              itemBuilder: (context, index) {
                                final conversation = state.conversations[index];
                                final isActive = state.activeConversation?.id ==
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
