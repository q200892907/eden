import 'package:vibration/vibration.dart';

class VibrationUtils {
  static bool _isVibrate = false;

  static void vibrate({int amplitude = -1, int duration = 500}) {
    if (_isVibrate) {
      return;
    }
    _isVibrate = true;
    Vibration.vibrate(amplitude: amplitude, duration: duration).then((value) {
      _isVibrate = false;
    });
  }

  static void cancel() {
    Vibration.cancel();
  }
}
