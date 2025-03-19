import 'package:flutter/material.dart';

import '/core/models/editor_callbacks/video_editor_callbacks.dart';
import '/core/models/editor_configs/video_editor_configs.dart';
import '../../controllers/video_controller.dart';

class VideoEditorConfigurable extends InheritedWidget {
  const VideoEditorConfigurable({
    super.key,
    required super.child,
    required this.videoManager,
  });

  final ProVideoController videoManager;

  VideoEditorConfigs get configs => videoManager.configs;
  VideoEditorCallbacks get callbacks => videoManager.callbacks;

  ValueNotifier<bool> get isPlayingNotifier => videoManager.isPlayingNotifier;
  ValueNotifier<bool> get isMutedNotifier => videoManager.isMutedNotifier;

  VideoEditorIcons get icons => configs.icons;
  VideoEditorStyle get style => configs.style;
  VideoEditorWidgets get widgets => configs.widgets;

  static VideoEditorConfigurable of(BuildContext context) {
    final config = maybeOf(context);
    assert(config != null, 'No VideoEditorConfigurable found in context');
    return config!;
  }

  static VideoEditorConfigurable? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<VideoEditorConfigurable>();
  }

  @override
  bool updateShouldNotify(covariant VideoEditorConfigurable oldWidget) {
    return true;
  }
}
