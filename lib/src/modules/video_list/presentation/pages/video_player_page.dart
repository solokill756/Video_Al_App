import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:dio/dio.dart';
import '../../../../core/data/local/storage.dart';

@RoutePage()
class VideoPlayerPage extends StatelessWidget {
  final String videoUrl;
  final String videoTitle;
  final Duration? initialPosition;

  const VideoPlayerPage({
    super.key,
    required this.videoUrl,
    required this.videoTitle,
    this.initialPosition,
  });

  @override
  Widget build(BuildContext context) {
    return VideoPlayerView(
      videoUrl: videoUrl,
      videoTitle: videoTitle,
      initialPosition: initialPosition,
    );
  }
}

class VideoPlayerView extends StatefulWidget {
  final String videoUrl;
  final String videoTitle;
  final Duration? initialPosition;

  const VideoPlayerView({
    super.key,
    required this.videoUrl,
    required this.videoTitle,
    this.initialPosition,
  });

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';
  VoidCallback? _errorListener;
  VoidCallback? _videoListener;
  bool _hasSeeked = false; // Track if we've already seeked
  bool _showControls = true; // Show/hide controls
  bool _isFullScreen = false; // Fullscreen state
  DateTime? _lastTapTime; // For double tap detection
  Offset? _lastTapPosition; // For double tap position

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
    // Auto-hide controls after 3 seconds
    _startControlsTimer();
  }

  void _startControlsTimer() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _controller != null && _controller!.value.isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startControlsTimer();
    }
  }

  void _initializeVideoPlayer() {
    // Call async function
    _initializeVideoPlayerAsync();
  }

  Future<void> _initializeVideoPlayerAsync() async {
    try {
      // Validate URL
      if (widget.videoUrl.isEmpty) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Video URL is empty';
        });
        return;
      }

      final uri = Uri.tryParse(widget.videoUrl);
      if (uri == null || !uri.hasScheme) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Invalid video URL format';
        });
        return;
      }

      // Log video URL for debugging
      print('🎥 Initializing video player with URL: ${widget.videoUrl}');
      print('🎥 URI: $uri');

      // Get access token for authentication
      final accessToken = await Storage.accessToken;
      print(
          '🎥 Has access token: ${accessToken != null && accessToken.isNotEmpty}');

      // Test the URL first with a HEAD request to check if it's accessible
      try {
        final dio = Dio();
        if (accessToken != null && accessToken.isNotEmpty) {
          dio.options.headers['Authorization'] = 'Bearer $accessToken';
        }
        dio.options.headers['User-Agent'] =
            'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36';

        final response = await dio.head(
          widget.videoUrl,
          options: Options(
            followRedirects: true,
            validateStatus: (status) => status! < 500,
          ),
        );

        print('🎥 HEAD request status: ${response.statusCode}');
        print('🎥 Content-Type: ${response.headers.value('content-type')}');
        print('🎥 Accept-Ranges: ${response.headers.value('accept-ranges')}');
        print('🎥 Content-Length: ${response.headers.value('content-length')}');

        if (response.statusCode != null && response.statusCode! >= 400) {
          throw Exception('Server returned ${response.statusCode}');
        }
      } catch (e) {
        print('⚠️ HEAD request failed: $e');
        // Continue anyway, might still work
      }

      // Build headers similar to browser request
      final headers = <String, String>{
        'User-Agent':
            'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36',
        'Accept':
            'video/webm,video/ogg,video/*;q=0.9,application/ogg;q=0.7,audio/*;q=0.6,*/*;q=0.5',
        'Accept-Language': 'en-US,en;q=0.9',
        'Accept-Encoding': 'identity', // Don't compress, ExoPlayer handles it
        'Connection': 'keep-alive',
      };

      // Add authorization if available
      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
        print('🎥 Added Authorization header');
      }

      print('🎥 Headers: $headers');

      // Try with headers - API endpoints often need authentication
      _controller = VideoPlayerController.networkUrl(
        uri,
        httpHeaders: headers,
      )..initialize().then((_) {
          print('✅ Video player initialized successfully');
          if (mounted && _controller != null) {
            setState(() {
              _isInitialized = true;
            });

            // Add listener to update UI when video state changes
            _videoListener = () {
              if (mounted) {
                setState(() {
                  // Auto-hide controls when playing
                  if (_controller!.value.isPlaying && _showControls) {
                    _startControlsTimer();
                  }
                });
              }
            };
            _controller!.addListener(_videoListener!);

            // Start playing first, then seek to position after video starts
            // This prevents lag when seeking immediately after initialization
            if (widget.initialPosition != null) {
              print(
                  '🎥 Has initial position: ${widget.initialPosition}, will seek after playback starts');
              // Start playing from beginning first to avoid lag
              _controller!.play();

              // Wait for video to start playing and buffer a bit, then seek
              // Use a one-time check instead of adding/removing listener
              Future.delayed(const Duration(milliseconds: 500), () {
                if (!mounted ||
                    _controller == null ||
                    !_controller!.value.isInitialized ||
                    _hasSeeked) {
                  return;
                }

                // Check if video is playing and has buffered some data
                if (_controller!.value.isPlaying ||
                    _controller!.value.position.inMilliseconds > 0) {
                  _hasSeeked = true;
                  print('🎥 Seeking to position: ${widget.initialPosition}');
                  _controller!
                      .seekTo(widget.initialPosition!)
                      .catchError((error) {
                    print('⚠️ Seek error: $error');
                    _hasSeeked = false; // Allow retry
                  });
                } else {
                  // If still not playing, try again after a bit more delay
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (mounted &&
                        _controller != null &&
                        _controller!.value.isInitialized &&
                        !_hasSeeked) {
                      _hasSeeked = true;
                      print(
                          '🎥 Delayed seek to position: ${widget.initialPosition}');
                      _controller!
                          .seekTo(widget.initialPosition!)
                          .catchError((error) {
                        print('⚠️ Seek error: $error');
                        _hasSeeked = false;
                      });
                    }
                  });
                }
              });
            } else {
              // Play immediately if no initial position
              print('🎥 No initial position, playing immediately');
              _controller!.play();
            }
          }
        }).catchError((error) {
          print('❌ Video player initialization error: $error');
          if (mounted) {
            setState(() {
              _hasError = true;
              // Parse error message to be more user-friendly
              final errorStr = error.toString();
              print('Error string: $errorStr');
              if (errorStr.contains('Source error') ||
                  errorStr.contains('ExoPlaybackException')) {
                _errorMessage =
                    'Cannot load video. The video format may not be supported or the server is not responding.';
              } else if (errorStr.contains('404') ||
                  errorStr.contains('Not Found')) {
                _errorMessage =
                    'Video not found. The video may have been removed.';
              } else if (errorStr.contains('timeout') ||
                  errorStr.contains('Timeout')) {
                _errorMessage =
                    'Connection timeout. Please check your internet connection.';
              } else {
                _errorMessage =
                    'Failed to load video: ${errorStr.length > 100 ? errorStr.substring(0, 100) : errorStr}';
              }
            });
          }
        });

      // Add error listener for better error handling
      _errorListener = () {
        if (_controller != null && _controller!.value.hasError && mounted) {
          setState(() {
            _hasError = true;
            final error =
                _controller!.value.errorDescription ?? 'Unknown error';
            if (error.contains('Source error') ||
                error.contains('ExoPlaybackException')) {
              _errorMessage =
                  'Cannot load video. Please check your internet connection or try again later.';
            } else {
              _errorMessage = 'Video player error: $error';
            }
          });
        }
      };
      _controller?.addListener(_errorListener!);
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Error initializing video player: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    // Exit fullscreen if active (without setState to avoid errors)
    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    if (_controller != null) {
      if (_errorListener != null) {
        _controller!.removeListener(_errorListener!);
      }
      if (_videoListener != null) {
        _controller!.removeListener(_videoListener!);
      }
      _controller!.dispose();
    }
    super.dispose();
  }

  void _enterFullScreen() async {
    if (!mounted) return;

    // Set orientation first
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Wait a bit for orientation change
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    if (mounted) {
      setState(() {
        _isFullScreen = true;
      });
    }
  }

  void _exitFullScreen() async {
    if (!mounted) return;

    // Restore system UI first
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Restore orientation
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Wait a bit for orientation change
    await Future.delayed(const Duration(milliseconds: 100));

    if (mounted) {
      setState(() {
        _isFullScreen = false;
      });
    }
  }

  void _toggleFullScreen() {
    if (!mounted) return;

    if (_isFullScreen) {
      _exitFullScreen();
    } else {
      _enterFullScreen();
    }
  }

  Duration _clampDuration(Duration value, Duration min, Duration max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  void _handleDoubleTap(Offset position, BuildContext context) {
    if (_controller == null) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final tapX = position.dx;
    final currentPosition = _controller!.value.position;
    final duration = _controller!.value.duration;

    // Seek forward 10 seconds if tap on right side, backward 10 seconds if left side
    final seekDuration = tapX > screenWidth / 2 ? 10 : -10;
    final newPosition = _clampDuration(
      currentPosition + Duration(seconds: seekDuration),
      Duration.zero,
      duration,
    );

    _controller!.seekTo(newPosition);

    // Show feedback
    _showSeekFeedback(context, seekDuration > 0);
  }

  void _showSeekFeedback(BuildContext context, bool forward) {
    // Show visual feedback for seek
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                forward ? Icons.fast_forward : Icons.fast_rewind,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                '${forward ? '+' : ''}10s',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(milliseconds: 800), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _hasError
            ? _buildErrorWidget()
            : _isInitialized
                ? _buildVideoPlayer()
                : const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF0D9488),
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_controller == null) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        // Handle double tap for seeking
        final now = DateTime.now();
        if (_lastTapTime != null &&
            now.difference(_lastTapTime!) < const Duration(milliseconds: 300)) {
          // Double tap detected
          _handleDoubleTap(
            _lastTapPosition ?? Offset.zero,
            context,
          );
          _lastTapTime = null;
        } else {
          // Single tap - toggle controls
          _lastTapTime = now;
          _lastTapPosition = null; // Will be set by onTapDown
          _toggleControls();
        }
      },
      onTapDown: (details) {
        _lastTapPosition = details.localPosition;
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video Player - Full screen
          Center(
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            ),
          ),

          // Top Controls Bar
          if (_showControls)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildTopControls(),
            ),

          // Center Play/Pause Button
          if (_showControls || !_controller!.value.isPlaying)
            Center(
              child: GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Icon(
                    _controller!.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                    size: 56,
                  ),
                ),
              ),
            ),

          // Bottom Controls Bar
          if (_showControls)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomControls(),
            ),
        ],
      ),
    );
  }

  Widget _buildTopControls() {
    return Container(
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        child: Row(
          children: [
            // Back Button
            GestureDetector(
              onTap: () => context.router.back(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Video Title
            Expanded(
              child: Text(
                widget.videoTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    if (_controller == null) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.transparent,
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress Bar with better seek handling
            GestureDetector(
              onHorizontalDragStart: (details) {
                // Show controls when user starts seeking
                setState(() {
                  _showControls = true;
                });
                _startControlsTimer();
              },
              onHorizontalDragUpdate: (details) {
                if (_controller == null) return;
                final RenderBox? box = context.findRenderObject() as RenderBox?;
                if (box == null) return;

                final tapPosition = details.localPosition;
                final progressBarWidth = box.size.width;
                final relativePosition = tapPosition.dx / progressBarWidth;
                final duration = _controller!.value.duration;
                final newPosition = _clampDuration(
                  Duration(
                    milliseconds:
                        (relativePosition * duration.inMilliseconds).round(),
                  ),
                  Duration.zero,
                  duration,
                );

                _controller!.seekTo(newPosition);
              },
              child: Container(
                height: 40, // Larger touch target
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: VideoProgressIndicator(
                  _controller!,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: Color(0xFF0D9488),
                    bufferedColor: Color(0xFF4A5568),
                    backgroundColor: Color(0xFF2D3748),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Controls Row
            Row(
              children: [
                // Play/Pause Button
                GestureDetector(
                  onTap: _togglePlayPause,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _controller!.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Time Display
                Text(
                  '${_formatDuration(_controller!.value.position)} / ${_formatDuration(_controller!.value.duration)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                // Skip Backward Button
                GestureDetector(
                  onTap: () {
                    if (_controller == null) return;
                    final currentPosition = _controller!.value.position;
                    final duration = _controller!.value.duration;
                    final newPosition = _clampDuration(
                      currentPosition - const Duration(seconds: 10),
                      Duration.zero,
                      duration,
                    );
                    _controller!.seekTo(newPosition);
                    _showSeekFeedback(context, false);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.replay_10,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Skip Forward Button
                GestureDetector(
                  onTap: () {
                    if (_controller == null) return;
                    final currentPosition = _controller!.value.position;
                    final duration = _controller!.value.duration;
                    final newPosition = _clampDuration(
                      currentPosition + const Duration(seconds: 10),
                      Duration.zero,
                      duration,
                    );
                    _controller!.seekTo(newPosition);
                    _showSeekFeedback(context, true);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.forward_10,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Fullscreen Button
                GestureDetector(
                  onTap: _toggleFullScreen,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.error_outline,
          size: 64,
          color: Colors.red,
        ),
        const SizedBox(height: 16),
        const Text(
          'Error Loading Video',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _hasError = false;
              _isInitialized = false;
            });
            _initializeVideoPlayer();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D9488),
          ),
          child: const Text('Retry'),
        ),
      ],
    );
  }

  void _togglePlayPause() {
    if (_controller == null) return;

    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    });
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }
}
