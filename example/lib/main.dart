import 'package:flutter/material.dart';
import 'package:ta_videoplayer/ta_videoplayer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ta Video Player Reels',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const ReelsExample(),
    );
  }
}

class ReelsExample extends StatefulWidget {
  const ReelsExample({super.key});

  @override
  State<ReelsExample> createState() => _ReelsExampleState();
}

class _ReelsExampleState extends State<ReelsExample> {
  late TaPlaylistController _playlistController;

  @override
  void initState() {
    super.initState();
    _playlistController = TaPlaylistController(
      sources: [
        TaVideoSource.youtubeId('dQw4w9WgXcQ'),
        TaVideoSource.youtubeId('pB392viOfNE'),
        TaVideoSource.youtubeId('gwbbzxQ_L-o'),
        TaVideoSource.youtubeId('6w2xzRoEucU'),
        TaVideoSource.youtubeId('j_yK8yPLhv0'),
        TaVideoSource.youtubeId('GO_tWkBUXG4'),
        TaVideoSource.youtubeId('hO88Xc6Icso'),
        TaVideoSource.youtubeId('kHreiZfT2U0'),
        TaVideoSource.youtubeId('Jtydd3tCD1c'),
      ],
    );
  }

  @override
  void dispose() {
    _playlistController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: TaReelsViewer(
        controller: _playlistController,
        autoScrollNext: true,
      ),
    );
  }
}
