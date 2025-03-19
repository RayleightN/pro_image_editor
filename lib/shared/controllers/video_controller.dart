import 'package:flutter/widgets.dart';

import '/core/models/editor_callbacks/video_editor_callbacks.dart';
import '/core/models/editor_configs/video_editor_configs.dart';

class ProVideoController {
  ProVideoController({
    required this.videoPlayer,
    required this.initialSize,
  });

  final Widget videoPlayer;
  final Size initialSize;

  late VideoEditorCallbacks Function() _callbacksFunction;
  late VideoEditorConfigs Function() _configsFunction;

  VideoEditorCallbacks get callbacks => _callbacksFunction();
  VideoEditorConfigs get configs => _configsFunction();

  late final isPlayingNotifier = ValueNotifier<bool>(configs.initialPlay);
  late final isMutedNotifier = ValueNotifier<bool>(configs.initialMuted);

  initialize({
    required VideoEditorCallbacks Function() callbacksFunction,
    required VideoEditorConfigs Function() configsFunction,
  }) {
    _callbacksFunction = callbacksFunction;
    _configsFunction = configsFunction;
  }

  void togglePlayState() {
    isPlayingNotifier.value = !isPlayingNotifier.value;

    if (isPlayingNotifier.value) {
      callbacks.onPlay?.call();
    } else {
      callbacks.onPause?.call();
    }
  }

  void setMuteState(bool isMuted) {
    isMutedNotifier.value = isMuted;

    callbacks.onMuteToggle?.call(isMuted);
  }
}
