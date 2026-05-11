# ta_videoplayer

A high-performance Flutter video player package for Android & iOS with support for:

- YouTube videos
- Network videos
- Asset videos
- Reels/shorts style player
- Smart preloading
- Customizable controls
- Fullscreen playback
- Playlist support
- Optimized scrolling performance

---

## ✨ Features

✅ YouTube video playback using:
- Video IDs
- Video URLs
- Playlists

✅ Network video support:
- MP4
- HLS (.m3u8)
- Streaming URLs

✅ Local video playback:
- Assets
- File videos

✅ Playlist support
- Single video
- Multiple videos
- Mixed video sources

✅ Smart preloading
- Preload next videos
- Smooth transitions
- Faster playback startup

✅ Reels / Shorts mode
- Vertical scrolling
- Auto play next video
- Feed optimized player

✅ Customizable controls
- Seekbar
- Play/Pause
- Fullscreen
- Mute/Unmute
- Playback controls

✅ Volume control
- Mute/unmute
- Volume control APIs
- System audio handling

✅ Optimized performance
- Faster initialization
- Reduced buffering
- Better scrolling experience
- Resource management

---

# 📦 Installation

Add dependency:

```yaml
dependencies:
  ta_videoplayer: latest_version
```

---

# 🚀 Usage

## Network Video

```dart
TaVideoPlayer(
  source: TaVideoSource.network(
    "https://example.com/video.mp4",
  ),
)
```

---

## YouTube Video

```dart
TaVideoPlayer(
  source: TaVideoSource.youtubeId(
    "VIDEO_ID",
  ),
)
```

---

## Asset Video

```dart
TaVideoPlayer(
  source: TaVideoSource.asset(
    "assets/videos/sample.mp4",
  ),
)
```

---

# 🎬 Playlist Example

```dart
TaVideoPlayer(
  playlist: [
    TaVideoSource.youtubeId("abc123"),
    TaVideoSource.network("https://example.com/video.mp4"),
  ],
)
```

---

# 📱 Reels / Shorts Example

```dart
TaReelsPlayer(
  videos: videos,
  autoPlayNext: true,
  autoScrollToNext: true,
)
```

---

# 🎛️ Custom Controls

```dart
TaVideoPlayer(
  seekBarPosition: SeekBarPosition.top,
  showFullscreenButton: true,
  showMuteButton: true,
)
```

---

# 🔊 Volume Controls

```dart
controller.mute();

controller.unmute();

controller.setVolume(0.8);
```

---

# ⚡ Performance Optimizations

- Smart preloading
- Controller reuse
- Smooth scrolling
- Reduced buffering
- Efficient memory handling
- Video lifecycle management
- Feed optimized playback

---

# 🛠️ Platform Support

| Platform | Supported |
|----------|------------|
| Android | ✅ |
| iOS | ✅ |

---

# 📌 Roadmap

## Upcoming Features
- Picture in Picture (PiP)
- Playback speed controls
- Gesture controls
- Brightness controls
- Quality selector
- Background playback
- Advanced caching
- Subtitle support

---

# 🤝 Contributing

Contributions are welcome.

Please open issues and pull requests.

---

# 📄 License

This project is licensed under the MIT License.

---

# 👨‍💻 Author

Developed by Techaak.
