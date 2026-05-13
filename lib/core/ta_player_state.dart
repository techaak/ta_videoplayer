enum TaPlayerStatus {
  initial,
  loading,
  ready,
  playing,
  paused,
  buffering,
  completed,
  error
}

class TaPlayerState {
  final TaPlayerStatus status;
  final Duration position;
  final Duration duration;
  final Duration buffered;
  final double volume;
  final double speed;
  final bool isMuted;
  final bool isFullscreen;
  final String? errorMessage;

  TaPlayerState({
    this.status = TaPlayerStatus.initial,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.buffered = Duration.zero,
    this.volume = 1.0,
    this.speed = 1.0,
    this.isMuted = false,
    this.isFullscreen = false,
    this.errorMessage,
  });

  TaPlayerState copyWith({
    TaPlayerStatus? status,
    Duration? position,
    Duration? duration,
    Duration? buffered,
    double? volume,
    double? speed,
    bool? isMuted,
    bool? isFullscreen,
    String? errorMessage,
  }) {
    return TaPlayerState(
      status: status ?? this.status,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      buffered: buffered ?? this.buffered,
      volume: volume ?? this.volume,
      speed: speed ?? this.speed,
      isMuted: isMuted ?? this.isMuted,
      isFullscreen: isFullscreen ?? this.isFullscreen,
      errorMessage: errorMessage,
    );
  }
}
