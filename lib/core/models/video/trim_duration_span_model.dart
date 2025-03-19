class TrimDurationSpan {
  const TrimDurationSpan({
    required this.start,
    required this.end,
  });
  final Duration start;
  final Duration end;

  Duration get duration {
    return end - start;
  }
}
