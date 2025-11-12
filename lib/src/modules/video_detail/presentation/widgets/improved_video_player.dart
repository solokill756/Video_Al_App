import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

/// Cải thiện video player với fullscreen thực sự và controls điều chỉnh thời gian
class ImprovedVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String videoTitle;

  const ImprovedVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.videoTitle,
  });

  @override
  State<ImprovedVideoPlayer> createState() => _ImprovedVideoPlayerState();
}

class _ImprovedVideoPlayerState extends State<ImprovedVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _showControls = true;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() {
    try {
      if (widget.videoUrl.isEmpty) {
        setState(() => _hasError = true);
        return;
      }

      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
        ..initialize().then((_) {
          setState(() => _isInitialized = true);
          _controller.play();
          // Add listener to update UI
          _controller.addListener(() {
            setState(() {});
          });
        }).catchError((error) {
          print('Video error: $error');
          setState(() => _hasError = true);
        });
    } catch (e) {
      print('Error: $e');
      setState(() => _hasError = true);
    }
  }

  void _togglePlayPause() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  void _skipForward() {
    final newPosition =
        _controller.value.position + const Duration(seconds: 10);
    final duration = _controller.value.duration;
    _controller.seekTo(
      newPosition > duration ? duration : newPosition,
    );
  }

  void _skipBackward() {
    final newPosition =
        _controller.value.position - const Duration(seconds: 10);
    _controller.seekTo(
      newPosition.isNegative ? Duration.zero : newPosition,
    );
  }

  void _toggleControlsVisibility() {
    setState(() => _showControls = !_showControls);
  }

  void _toggleFullScreen() {
    if (_isFullScreen) {
      // Exit fullscreen
      Navigator.of(context).pop();
      setState(() => _isFullScreen = false);
    } else {
      // Enter fullscreen - show full screen modal
      setState(() => _isFullScreen = true);
      Navigator.of(context).push(
        PageRouteBuilder(
          opaque: true,
          barrierDismissible: false,
          pageBuilder: (context, animation, secondaryAnimation) {
            return _FullScreenVideoPlayer(
              controller: _controller,
              videoTitle: widget.videoTitle,
              onExit: () {
                setState(() => _isFullScreen = false);
              },
            );
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    // Reset orientation to portrait when disposing
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: _hasError
          ? _buildErrorWidget()
          : _isInitialized
              ? _buildVideoPlayer()
              : _buildLoadingWidget(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Error loading video',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() => _hasError = false);
              _initializeVideoPlayer();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return GestureDetector(
      onTap: _toggleControlsVisibility,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Video
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),

          // Play icon overlay when paused
          if (!_controller.value.isPlaying)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.6),
              ),
              padding: const EdgeInsets.all(16),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 56,
              ),
            ),

          // Controls (Bottom bar)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Progress bar
                    SizedBox(
                      height: 4,
                      child: VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                        colors: VideoProgressColors(
                          playedColor: const Color(0xFF0D9488),
                          bufferedColor: Colors.grey.shade600,
                          backgroundColor: Colors.grey.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Control buttons
                    Row(
                      children: [
                        // Skip backward 10s
                        IconButton(
                          icon: const Icon(
                            Icons.replay_10,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: _skipBackward,
                        ),
                        // Play/Pause
                        IconButton(
                          icon: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: _togglePlayPause,
                        ),
                        // Skip forward 10s
                        IconButton(
                          icon: const Icon(
                            Icons.forward_10,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: _skipForward,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              _formatDuration(_controller.value.position),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          _formatDuration(_controller.value.duration),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.fullscreen,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: _toggleFullScreen,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Widget fullscreen thực sự hiển thị video ở toàn màn hình
class _FullScreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final String videoTitle;
  final VoidCallback onExit;

  const _FullScreenVideoPlayer({
    required this.controller,
    required this.videoTitle,
    required this.onExit,
  });

  @override
  State<_FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<_FullScreenVideoPlayer> {
  late bool _showControls = true;

  @override
  void initState() {
    super.initState();
    // Set landscape orientation for fullscreen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // Hide status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    // Add listener to update UI when video plays
    widget.controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    // Restore portrait orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // Show status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _skipForward() {
    final newPosition =
        widget.controller.value.position + const Duration(seconds: 10);
    final duration = widget.controller.value.duration;
    widget.controller.seekTo(
      newPosition > duration ? duration : newPosition,
    );
  }

  void _skipBackward() {
    final newPosition =
        widget.controller.value.position - const Duration(seconds: 10);
    widget.controller.seekTo(
      newPosition.isNegative ? Duration.zero : newPosition,
    );
  }

  void _togglePlayPause() {
    setState(() {
      widget.controller.value.isPlaying
          ? widget.controller.pause()
          : widget.controller.play();
    });
  }

  void _toggleControlsVisibility() {
    setState(() => _showControls = !_showControls);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControlsVisibility,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Video
            Center(
              child: AspectRatio(
                aspectRatio: widget.controller.value.aspectRatio,
                child: VideoPlayer(widget.controller),
              ),
            ),

            // Play icon overlay when paused
            if (!widget.controller.value.isPlaying)
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.6),
                ),
                padding: const EdgeInsets.all(16),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 80,
                ),
              ),

            // Top bar with title and close button
            if (_showControls)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  opacity: _showControls ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.videoTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.fullscreen_exit,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () {
                            widget.onExit();
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Bottom controls bar
            if (_showControls)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  opacity: _showControls ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Progress bar
                        SizedBox(
                          height: 4,
                          child: VideoProgressIndicator(
                            widget.controller,
                            allowScrubbing: true,
                            colors: VideoProgressColors(
                              playedColor: const Color(0xFF0D9488),
                              bufferedColor: Colors.grey.shade600,
                              backgroundColor: Colors.grey.shade800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Control buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Skip backward 10s
                            IconButton(
                              icon: const Icon(
                                Icons.replay_10,
                                color: Colors.white,
                                size: 28,
                              ),
                              onPressed: _skipBackward,
                            ),
                            const SizedBox(width: 16),
                            // Play/Pause
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF0D9488),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  widget.controller.value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 36,
                                ),
                                onPressed: _togglePlayPause,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Skip forward 10s
                            IconButton(
                              icon: const Icon(
                                Icons.forward_10,
                                color: Colors.white,
                                size: 28,
                              ),
                              onPressed: _skipForward,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Time display
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _formatDuration(widget.controller.value.position),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const Text(
                              ' / ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              _formatDuration(widget.controller.value.duration),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
