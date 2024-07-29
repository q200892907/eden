import 'dart:io';

class EdenFileUtil {
  static bool isAudio(String path) {
    List<String> audioExtensions = ['.mp3'];
    String extension = path.split('.').last.toLowerCase();
    return audioExtensions.contains('.$extension');
  }

  static String fileName(String path) {
    return Uri.parse(path).pathSegments.last;
  }

  static String filePath(String path) {
    File file = File(path);
    if (file.existsSync()) {
      // 文件已存在，处理重命名逻辑
      int count = 1;
      String filename = fileName(path);
      String basePath =
          file.path.substring(0, file.path.length - filename.length);
      String newFileName = filename;
      while (file.existsSync()) {
        newFileName =
            '$basePath${filename.split('.').first}($count).${filename.split('.').last}';
        file = File(newFileName);
        count++;
      }
      return file.path;
    }
    return file.path;
  }
}

extension StringExtension on String {
  String get fileName => EdenFileUtil.fileName(this);
}
