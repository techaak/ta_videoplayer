import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../controllers/ta_video_controller.dart';
import '../core/ta_player_state.dart';
import 'widgets/ta_video_controls.dart';

class TaVideoPlayer extends StatefulWidget {
  final TaVideoController controller;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool showControls;

  const TaVideoPlayer({
    super.key,
    required this.controller,
    this.placeholder,
    this.errorWidget,
    this.showControls = true,
  });

  @override
  State<TaVideoPlayer> createState() => _TaVideoPlayerState();
}

class _TaVideoPlayerState extends State<TaVideoPlayer> {
  @override
  void initState() {
    super.initState();
    if (widget.controller.value.status == TaPlayerStatus.initial) {
      widget.controller.initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TaPlayerState>(
      valueListenable: widget.controller,
      builder: (context, state, child) {
        return Container(
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildPlayer(state),
              if (widget.showControls)
                TaVideoControls(controller: widget.controller),
              if (state.status == TaPlayerStatus.error)
                widget.errorWidget ??
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          state.errorMessage ?? 'Error loading video',
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlayer(TaPlayerState state) {
    final videoController = widget.controller.videoPlayerController;
    if (videoController != null && videoController.value.isInitialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: videoController.value.aspectRatio,
          child: VideoPlayer(videoController),
        ),
      );
    }
    return widget.placeholder ??
        const Center(child: CircularProgressIndicator(color: Colors.white));
  }
}
