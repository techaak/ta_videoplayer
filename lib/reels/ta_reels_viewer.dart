import 'dart:async';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../controllers/ta_playlist_controller.dart';
import '../controllers/ta_video_controller.dart';
import '../ui/ta_video_player.dart';
import '../core/ta_player_state.dart';
import '../services/ta_player_service.dart';

class TaReelsViewer extends StatefulWidget {
  final TaPlaylistController controller;
  final bool autoScrollNext;

  const TaReelsViewer({
    Key? key,
    required this.controller,
    this.autoScrollNext = true,
  }) : super(key: key);

  @override
  State<TaReelsViewer> createState() => _TaReelsViewerState();
}

class _TaReelsViewerState extends State<TaReelsViewer> with TickerProviderStateMixin {
  late PageController _pageController;
  final TaPlayerService _playerService = TaPlayerService();
  
  // Feedback Animations
  bool _showCenterIcon = false;
  bool _showVolumeIndicator = false;
  Timer? _iconTimer;
  Timer? _volumeTimer;
  
  IconData _centerIcon = Icons.play_arrow;
  double _currentVolume = 0.5;
  bool _isLongPressing = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.controller.currentIndex);
    widget.controller.initialize();
    _initVolume();
    
    // Listen to global mute changes to sync local UI state
    TaVideoController.globalMute.addListener(_onGlobalMuteChanged);
  }

  void _onGlobalMuteChanged() {
    if (mounted) {
      setState(() {
        _showVolumeOverlay();
      });
    }
  }

  void _onVolumeChanged() {
    if (mounted) {
      setState(() {
        _currentVolume = _playerService.volumeNotifier.value;
        _showVolumeOverlay();
      });
    }
  }

  Future<void> _initVolume() async {
    _currentVolume = await _playerService.getVolume();
    _playerService.addVolumeListener(_onVolumeChanged);
  }

  void _showVolumeOverlay() {
    if (!mounted) return;
    setState(() => _showVolumeIndicator = true);
    _volumeTimer?.cancel();
    _volumeTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showVolumeIndicator = false);
    });
  }

  void _showCenterIconAnimation(IconData icon) {
    if (!mounted) return;
    setState(() {
      _centerIcon = icon;
      _showCenterIcon = true;
    });
    _iconTimer?.cancel();
    _iconTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _showCenterIcon = false);
    });
  }

  @override
  void dispose() {
    TaVideoController.globalMute.removeListener(_onGlobalMuteChanged);
    _pageController.dispose();
    _iconTimer?.cancel();
    _volumeTimer?.cancel();
    _playerService.removeVolumeListener(_onVolumeChanged);
    super.dispose();
  }

  void _onVideoStateChanged(TaPlayerState state, int index) {
    if (widget.autoScrollNext && 
        state.status == TaPlayerStatus.completed && 
        index == widget.controller.currentIndex && 
        !_isLongPressing) {
      _scrollToNext();
    }
  }

  void _scrollToNext() {
    if (widget.controller.currentIndex < widget.controller.sources.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutQuart,
      );
    }
  }

  /// Toggle Mute/Unmute (Instagram Single Tap behavior)
  void _handleTap() {
    final controller = widget.controller.currentController;
    if (controller == null) return;

    controller.toggleMute();
    
    // Show center icon feedback
    _showCenterIconAnimation(
      TaVideoController.globalMute.value ? Icons.volume_off : Icons.volume_up,
    );
    _showVolumeOverlay();
  }

  /// Instagram: Long Press to Pause, release to resume
  void _handleLongPressStart(LongPressStartDetails details) {
    final controller = widget.controller.currentController;
    if (controller == null) return;

    _isLongPressing = true;
    controller.pause();
    _showCenterIconAnimation(Icons.pause);
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    final controller = widget.controller.currentController;
    if (controller == null) return;

    _isLongPressing = false;
    controller.play();
    _showCenterIconAnimation(Icons.play_arrow);
  }

  /// Vertical swipe on right side to control volume
  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (details.localPosition.dx > screenWidth / 2) {
      double delta = details.primaryDelta! / -250;
      _currentVolume = (_currentVolume + delta).clamp(0.0, 1.0);
      widget.controller.currentController?.setVolume(_currentVolume);
      _showVolumeOverlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main Video Feed
          GestureDetector(
            onTap: _handleTap,
            onLongPressStart: _handleLongPressStart,
            onLongPressEnd: _handleLongPressEnd,
            onVerticalDragUpdate: _handleVerticalDragUpdate,
            child: PageView.builder(
              scrollDirection: Axis.vertical,
              controller: _pageController,
              itemCount: widget.controller.sources.length,
              onPageChanged: (index) {
                widget.controller.jumpTo(index);
              },
              itemBuilder: (context, index) {
                final controller = widget.controller.getControllerAt(index);
                if (controller == null) return const Center(child: CircularProgressIndicator(color: Colors.white));

                return VisibilityDetector(
                  key: Key('reel_$index'),
                  onVisibilityChanged: (info) {
                    if (info.visibleFraction > 0.8) {
                      controller.play();
                    } else {
                      controller.pause();
                    }
                  },
                  child: ValueListenableBuilder<TaPlayerState>(
                    valueListenable: controller,
                    builder: (context, state, child) {
                      _onVideoStateChanged(state, index);
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          TaVideoPlayer(
                            controller: controller,
                            showControls: false,
                          ),
                          
                          // Instagram-like bottom shadow gradient
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 180,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.6),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Progress bar at the very bottom
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: _InstagramProgressLine(state: state),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
          
          // Center Animation Feedback (Scale & Fade)
          Center(
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 200),
              tween: Tween(begin: 0.0, end: _showCenterIcon ? 1.0 : 0.0),
              builder: (context, opacity, child) {
                return Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: 0.8 + (opacity * 0.2),
                    child: Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_centerIcon, size: 45, color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),

          // Side Volume Bar (Instagram Style)
          Positioned(
            right: 15,
            top: MediaQuery.of(context).size.height * 0.3,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _showVolumeIndicator ? 1.0 : 0.0,
              child: _InstagramVolumeBar(
                volume: TaVideoController.globalMute.value ? 0.0 : _currentVolume,
              ),
            ),
          ),

          // Mute/Unmute Toggle Button (Bottom Right)
          Positioned(
            right: 15,
            bottom: 80,
            child: ValueListenableBuilder<bool>(
              valueListenable: TaVideoController.globalMute,
              builder: (context, isMuted, child) {
                return GestureDetector(
                  onTap: _handleTap,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                    child: Icon(
                      isMuted ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _InstagramProgressLine extends StatelessWidget {
  final TaPlayerState state;
  const _InstagramProgressLine({required this.state});

  @override
  Widget build(BuildContext context) {
    double progress = 0.0;
    if (state.duration.inMilliseconds > 0) {
      progress = state.position.inMilliseconds / state.duration.inMilliseconds;
    }

    return Container(
      height: 2.0,
      width: double.infinity,
      color: Colors.white12,
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(color: Colors.white),
      ),
    );
  }
}

class _InstagramVolumeBar extends StatelessWidget {
  final double volume;
  const _InstagramVolumeBar({required this.volume});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: 4,
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: 140 * volume,
            width: 4,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
