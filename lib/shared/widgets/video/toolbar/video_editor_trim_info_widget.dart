import 'package:flutter/widgets.dart';
import 'package:pro_image_editor/shared/extensions/duration_extension.dart';

import '../video_editor_configurable.dart';

class VideoEditorTrimInfoWidget extends StatelessWidget {
  const VideoEditorTrimInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var player = VideoEditorConfigurable.of(context);
    return ValueListenableBuilder(
      valueListenable: player.controller.trimDurationSpanNotifier,
      builder: (_, value, __) {
        if (player.configs.widgets.trimDurationInfo != null) {
          return player.configs.widgets.trimDurationInfo!(value);
        }

        return IgnorePointer(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: player.style.trimDurationBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${value.start.toTimeString()} - '
              '${(value.end.toTimeString())}',
              style: player.style.trimDurationTextStyle ??
                  TextStyle(
                    fontSize: 14,
                    color: player.style.trimDurationTextColor,
                  ),
            ),
          ),
        );
      },
    );
  }
}
