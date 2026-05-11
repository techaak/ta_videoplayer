import 'package:flutter/foundation.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class TaPlayerService {
  static final TaPlayerService _instance = TaPlayerService._internal();
  factory TaPlayerService() => _instance;
  
  final VolumeController _volumeController = VolumeController();
  final ValueNotifier<double> volumeNotifier = ValueNotifier<double>(0.5);

  TaPlayerService._internal() {
    _init();
  }

  Future<void> _init() async {
    double vol = await getVolume();
    volumeNotifier.value = vol;
    _volumeController.listener((volume) {
      volumeNotifier.value = volume;
    });
  }

  Future<void> setVolume(double volume) async {
    _volumeController.setVolume(volume);
    volumeNotifier.value = volume;
  }

  Future<double> getVolume() async {
    return await _volumeController.getVolume();
  }

  /// Exposes the volume notifier so controllers can add/remove listeners directly
  void addVolumeListener(VoidCallback listener) {
    volumeNotifier.addListener(listener);
  }

  void removeVolumeListener(VoidCallback listener) {
    volumeNotifier.removeListener(listener);
  }

  Future<void> setBrightness(double brightness) async {
    try {
      await ScreenBrightness.instance.setScreenBrightness(brightness);
    } catch (e) {
      debugPrint('Brightness error: $e');
    }
  }

  Future<void> resetBrightness() async {
    try {
      await ScreenBrightness.instance.resetScreenBrightness();
    } catch (e) {
      debugPrint('Brightness reset error: $e');
    }
  }

  Future<void> setWakelock(bool enabled) async {
    try {
      if (enabled) {
        await WakelockPlus.enable();
      } else {
        await WakelockPlus.disable();
      }
    } catch (e) {
      debugPrint('Wakelock error: $e');
    }
  }
}
