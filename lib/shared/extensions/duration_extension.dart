extension DurationFormatter on Duration {
  String toTimeString() {
    int totalSeconds = inSeconds;
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
}
