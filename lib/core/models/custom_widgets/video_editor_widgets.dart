import 'package:flutter/widgets.dart';
import 'package:pro_image_editor/core/models/video/trim_duration_span_model.dart';

class VideoEditorWidgets {
  const VideoEditorWidgets({
    this.playIndicator,
    this.pauseIndicator,
    this.muteButton,
    this.trimBar,
    this.infoBanner,
    this.headerToolbar,
    this.trimDurationInfo,
  });

  final Widget? playIndicator;
  final Widget? pauseIndicator;
  final Widget Function(Function(bool isMuted) setMute)? muteButton;
  final Widget Function(TrimDurationSpan durationSpan)? trimDurationInfo;
  final Widget Function(TrimDurationSpan durationSpan)? infoBanner;
  final Widget? trimBar;

  final Widget? headerToolbar;

  /// TODO: write copyWith method
}
