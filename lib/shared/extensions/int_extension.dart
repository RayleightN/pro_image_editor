import 'dart:math';

extension IntFormatter on int {
  String toBytesString([int decimals = 2]) {
    if (this <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = (log(this) / log(1024)).floor();
    var size = this / pow(1024, i);
    return '${size.toStringAsFixed(decimals)} ${suffixes[i]}';
  }
}
