extension intExt on int {
  String formatBytes() {
    const int KB = 1024;
    const int MB = 1024 * KB;
    const int GB = 1024 * MB;

    if (this >= GB) {
      return '${(this / GB).toStringAsFixed(2)} GB';
    } else if (this >= MB) {
      return '${(this / MB).toStringAsFixed(2)} MB';
    } else if (this >= KB) {
      return '${(this / KB).toStringAsFixed(2)} KB';
    } else {
      return '$this B';
    }
  }
}
