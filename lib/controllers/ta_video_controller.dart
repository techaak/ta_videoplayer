import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/ta_video_source.dart';
import '../core/ta_player_state.dart';
import '../services/ta_player_service.dart';

class TaVideoController extends ValueNotifier<TaPlayerState> {
  final TaVideoSource source;
  VideoPlayerController? _controller;
  final YoutubeExplode _yt = YoutubeExplode();
  final TaPlayerService _playerService = TaPlayerService();
  
  // Global mute state shared across all Reel instances
  static final ValueNotifier<bool> globalMute = ValueNotifier<bool>(false);
  static double _lastNonZeroVolume = 0.5;
  
  bool _isDisposed = false;

  TaVideoController({required this.source}) : super(TaPlayerState());

  VideoPlayerController? get videoPlayerController => _controller;

  Future<void> initialize() async {
    if (_isDisposed) return;
    value = value.copyWith(status: TaPlayerStatus.loading);
    
    try {
      String? resolvedUrl;
      if (source.type == TaVideoSourceType.youtube) {
        resolvedUrl = await _resolveYoutubeUrl(source.id ?? source.url);
      } else {
        resolvedUrl = source.url;
      }

      if (resolvedUrl == null) throw Exception("Could not resolve video URL");

      switch (source.type) {
        case TaVideoSourceType.network:
        case TaVideoSourceType.youtube:
          _controller = VideoPlayerController.networkUrl(Uri.parse(resolvedUrl), httpHeaders: source.headers ?? {});
          break;
        case TaVideoSourceType.asset:
          _controller = VideoPlayerController.asset(resolvedUrl);
          break;
        case TaVideoSourceType.file:
          _controller = VideoPlayerController.file(File(resolvedUrl));
          break;
      }

      await _controller?.initialize();
      if (_isDisposed) return;

      _controller?.addListener(_listener);
      
      // Force initial volume sync
      _applyVolumeState();
      
      // Listen to global changes
      globalMute.addListener(_applyVolumeState);
      _playerService.addVolumeListener(_onSystemVolumeChanged);

      value = value.copyWith(
        status: TaPlayerStatus.ready,
        duration: _controller?.value.duration ?? Duration.zero,
      );
    } catch (e) {
      if (!_isDisposed) {
        value = value.copyWith(status: TaPlayerStatus.error, errorMessage: e.toString());
      }
    }
  }

  void _onSystemVolumeChanged() {
    if (_isDisposed) return;
    double volume = _playerService.volumeNotifier.value;
    if (volume > 0.001) {
      _lastNonZeroVolume = volume;
      if (globalMute.value) {
        globalMute.value = false; // Unmute if hardware volume button pressed up
      }
    } else {
      if (!globalMute.value) {
        globalMute.value = true;
      }
    }
    _applyVolumeState();
  }

  void _applyVolumeState() {
    if (_isDisposed || _controller == null || !_controller!.value.isInitialized) return;
    
    double targetVolume;
    if (globalMute.value) {
      targetVolume = 0.0;
    } else {
      targetVolume = _playerService.volumeNotifier.value;
      if (targetVolume <= 0.001) targetVolume = _lastNonZeroVolume;
    }
    
    _controller?.setVolume(targetVolume);
    value = value.copyWith(volume: targetVolume, isMuted: globalMute.value);
  }

  void _listener() {
    if (_isDisposed || _controller == null) return;
    final val = _controller!.value;
    
    TaPlayerStatus status = value.status;
    if (val.hasError) {
      status = TaPlayerStatus.error;
    } else if (val.isBuffering) {
      status = TaPlayerStatus.buffering;
    } else if (val.isInitialized) {
      if (val.isPlaying) {
        status = TaPlayerStatus.playing;
        // Defensive: ensure volume is correct when playing starts
        if (val.volume != (globalMute.value ? 0.0 : _playerService.volumeNotifier.value)) {
           _applyVolumeState();
        }
      } else if (val.position >= val.duration && val.duration != Duration.zero) {
        status = TaPlayerStatus.completed;
      } else {
        status = TaPlayerStatus.paused;
      }
    }

    value = value.copyWith(
      status: status,
      position: val.position,
      duration: val.duration,
      buffered: val.buffered.isNotEmpty ? val.buffered.last.end : Duration.zero,
      errorMessage: val.errorDescription,
    );
  }

  Future<String?> _resolveYoutubeUrl(String idOrUrl) async {
    try {
      var videoId = VideoId.parseVideoId(idOrUrl);
      if (videoId == null) return null;
      var manifest = await _yt.videos.streamsClient.getManifest(videoId);
      var streamInfo = manifest.muxed.withHighestBitrate();
      return streamInfo.url.toString();
    } catch (e) {
      return null;
    }
  }

  Future<void> play() async {
    if (_controller == null) return;
    _applyVolumeState(); // Sync volume exactly before play starts
    await _controller?.play();
  }

  Future<void> pause() async => await _controller?.pause();
  Future<void> seekTo(Duration position) async => await _controller?.seekTo(position);

  Future<void> mute() async {
    globalMute.value = true;
  }

  Future<void> unmute() async {
    globalMute.value = false;
  }

  Future<void> toggleMute() async {
    globalMute.value = !globalMute.value;
  }

  Future<void> setVolume(double volume, {bool syncWithSystem = true}) async {
    if (volume > 0.001) {
      _lastNonZeroVolume = volume;
      if (globalMute.value) globalMute.value = false;
    } else {
      globalMute.value = true;
    }
    
    if (syncWithSystem) {
      await _playerService.setVolume(volume);
    }
    _applyVolumeState();
  }

  @override
  void dispose() {
    _isDisposed = true;
    globalMute.removeListener(_applyVolumeState);
    _playerService.removeVolumeListener(_onSystemVolumeChanged);
    _controller?.removeListener(_listener);
    _controller?.dispose();
    _yt.close();
    super.dispose();
  }
}
