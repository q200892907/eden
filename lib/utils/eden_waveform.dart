import 'dart:io';

import 'package:eden_logger/eden_logger.dart';
import 'package:just_waveform/just_waveform.dart';

class EdenWaveform {
  static String _getWaveFilePath(String path) {
    return '$path.wave';
  }

  /// 是否存在
  static bool existsSync(String path) {
    File waveFile = File(_getWaveFilePath(path));
    return waveFile.existsSync();
  }

  /// 解析
  static Future<Waveform> parse(String path) async {
    File waveFile = File(_getWaveFilePath(path));
    // 解析波形文件
    Stopwatch stopwatch = Stopwatch();
    stopwatch.start();
    return JustWaveform.parse(waveFile).then((waveForm) {
      stopwatch.stop();
      EdenLogger.d("解析波形文件耗时(ms)：${stopwatch.elapsed.inMilliseconds}");
      return waveForm;
    });
  }

  /// 生成
  static Future<bool> extract(String filePath) async {
    // 创建并生成波形文件
    try {
      String wavePath = _getWaveFilePath(filePath);
      File waveFile = File.fromUri(Uri.file(wavePath));
      Stream<WaveformProgress> stream = JustWaveform.extract(
        audioInFile: File(filePath),
        waveOutFile: waveFile,
      );
      double progress = 0;
      await for (WaveformProgress data in stream) {
        progress = data.progress;
        EdenLogger.d('波形转换进度:$progress');
      }
      if (progress != 1) {
        EdenLogger.e('转换波形文件失败');
        File file = File(filePath);
        file.deleteSync();
        return false;
      }
      return true;
    } catch (e) {
      // 转换波形文件失败，删除波形文件和音频文件，并返回失败
      EdenLogger.e('转换波形文件失败:$e');
      File file = File(filePath);
      file.deleteSync();
      return false;
    }
  }
}
