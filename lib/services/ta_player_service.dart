import 'package:flutter/foundation.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class TaPlayerService {
  static final TaPlayerService _instance = TaPlayerService._internal();

  factory TaPlayerService() => _instance;

  final ValueNotifier<double> volumeNotifier = ValueNotifier<double>(0.5);

  TaPlayerService._internal() {
    _init();
  }

  Future<void> _init() async {
    final vol = await getVolume();

    volumeNotifier.value = vol;

    VolumeController.instance.addListener((volume) {
      volumeNotifier.value = volume;
    });
  }

  Future<void> setVolume(double volume) async {
    await VolumeController.instance.setVolume(volume);

    volumeNotifier.value = volume;
  }

  Future<double> getVolume() async {
    return await VolumeController.instance.getVolume();
  }

  void addVolumeListener(VoidCallback listener) {
    volumeNotifier.addListener(listener);
  }

  void removeVolumeListener(VoidCallback listener) {
    volumeNotifier.removeListener(listener);
  }

  Future<void> setBrightness(double brightness) async {
    try {
      await ScreenBrightness.instance.setApplicationScreenBrightness(brightness);
    } catch (e) {
      debugPrint('Brightness error: $e');
    }
  }

  Future<void> resetBrightness() async {
    try {
      await ScreenBrightness.instance.resetApplicationScreenBrightness();
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
