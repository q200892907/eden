extension NumExtension on num {
  String get formatString {
    if (this < 1000) {
      if (this % 1 == 0) {
        return toStringAsFixed(0);
      }
      return toStringAsFixed(2);
    } else if (this >= 1000 && this < 1000000) {
      num temp = this / 1000;
      return '${temp.toStringAsFixed(2)}K';
    } else if (this >= 1000000 && this < 1000000000) {
      num temp = this / 1000000;
      return '${temp.toStringAsFixed(2)}M';
    } else if (this >= 1000000000 && this < 1000000000000) {
      num temp = this / 1000000000;
      return '${temp.toStringAsFixed(2)}B';
    } else {
      num temp = this / 1000000000000;
      return '${temp.toStringAsFixed(2)}T';
    }
  }
}
