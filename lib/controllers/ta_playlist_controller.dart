import 'package:flutter/foundation.dart';
import '../models/ta_video_source.dart';
import 'ta_video_controller.dart';

class TaPlaylistController extends ChangeNotifier {
  final List<TaVideoSource> sources;
  final int preloadCount;
  
  int _currentIndex = 0;
  final Map<int, TaVideoController> _controllers = {};

  TaPlaylistController({
    required this.sources,
    this.preloadCount = 2,
  });

  int get currentIndex => _currentIndex;
  
  TaVideoController? get currentController => _controllers[_currentIndex];

  void initialize() {
    _updateControllers();
  }

  void next() {
    if (_currentIndex < sources.length - 1) {
      _currentIndex++;
      _updateControllers();
      notifyListeners();
    }
  }

  void previous() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _updateControllers();
      notifyListeners();
    }
  }

  void jumpTo(int index) {
    if (index >= 0 && index < sources.length) {
      _currentIndex = index;
      _updateControllers();
      notifyListeners();
    }
  }

  void _updateControllers() {
    // Keep controllers for currentIndex and preloadCount ahead/behind
    final Set<int> activeIndices = {
      _currentIndex,
      for (int i = 1; i <= preloadCount; i++) ...[
        if (_currentIndex + i < sources.length) _currentIndex + i,
        if (_currentIndex - i >= 0) _currentIndex - i,
      ]
    };

    // Dispose controllers no longer needed
    final List<int> toRemove = [];
    _controllers.forEach((index, controller) {
      if (!activeIndices.contains(index)) {
        toRemove.add(index);
      }
    });

    for (var index in toRemove) {
      _controllers[index]?.dispose();
      _controllers.remove(index);
    }

    // Initialize new controllers
    for (var index in activeIndices) {
      if (!_controllers.containsKey(index)) {
        final controller = TaVideoController(source: sources[index]);
        _controllers[index] = controller;
        controller.initialize();
      }
    }
    
    // Auto-play current, pause others
    _controllers.forEach((index, controller) {
      if (index == _currentIndex) {
        controller.play();
      } else {
        controller.pause();
      }
    });
  }

  TaVideoController? getControllerAt(int index) {
    return _controllers[index];
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    super.dispose();
  }
}
