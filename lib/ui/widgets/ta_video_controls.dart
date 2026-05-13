import 'package:flutter/material.dart';
import '../../controllers/ta_video_controller.dart';
import '../../core/ta_player_state.dart';

class TaVideoControls extends StatelessWidget {
  final TaVideoController controller;

  const TaVideoControls({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TaPlayerState>(
      valueListenable: controller,
      builder: (context, state, child) {
        return Stack(
          children: [
            // Center Play/Pause & Loading
            GestureDetector(
              onTap: () => state.status == TaPlayerStatus.playing
                  ? controller.pause()
                  : controller.play(),
              child: Container(
                color: Colors.transparent,
                child: Center(
                  child: _buildCenterUI(state),
                ),
              ),
            ),

            // Bottom Controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomBar(state),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCenterUI(TaPlayerState state) {
    if (state.status == TaPlayerStatus.loading ||
        state.status == TaPlayerStatus.buffering) {
      return const CircularProgressIndicator(color: Colors.white);
    }
    if (state.status == TaPlayerStatus.paused ||
        state.status == TaPlayerStatus.ready) {
      return const Icon(Icons.play_arrow, size: 80, color: Colors.white70);
    }
    return const SizedBox.shrink();
  }

  Widget _buildBottomBar(TaPlayerState state) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildProgressBar(state),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  state.status == TaPlayerStatus.playing
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: () => state.status == TaPlayerStatus.playing
                    ? controller.pause()
                    : controller.play(),
              ),
              Text(
                '${_formatDuration(state.position)} / ${_formatDuration(state.duration)}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              const Spacer(),
              _buildVolumeControl(state),
              IconButton(
                icon: const Icon(Icons.fullscreen, color: Colors.white),
                onPressed: () {
                  // TODO: Implement Fullscreen
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeControl(TaPlayerState state) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            state.isMuted ? Icons.volume_off : Icons.volume_up,
            color: Colors.white,
          ),
          onPressed: () =>
              state.isMuted ? controller.unmute() : controller.mute(),
        ),
        SizedBox(
          width: 80,
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white24,
              thumbColor: Colors.white,
            ),
            child: Slider(
              value: state.volume,
              onChanged: (val) => controller.setVolume(val),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(TaPlayerState state) {
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
        activeTrackColor: Colors.red,
        inactiveTrackColor: Colors.white24,
        thumbColor: Colors.red,
      ),
      child: Slider(
        value: state.position.inMilliseconds.toDouble(),
        min: 0,
        max: state.duration.inMilliseconds
            .toDouble()
            .clamp(0.0, double.infinity),
        onChanged: (val) {
          controller.seekTo(Duration(milliseconds: val.toInt()));
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
