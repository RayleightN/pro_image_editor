import 'package:flutter/material.dart';
import '/shared/controllers/video_controller.dart';
import '/shared/extensions/duration_extension.dart';
import '/shared/extensions/int_extension.dart';
import '/shared/widgets/video/video_editor_configurable.dart';

class VideoEditorInfoBanner extends StatelessWidget {
  const VideoEditorInfoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    var player = VideoEditorConfigurable.of(context);
    ProVideoController controller = player.controller;

    return ValueListenableBuilder(
        valueListenable: controller.trimDurationSpanNotifier,
        builder: (_, durationSpan, __) {
          if (player.configs.widgets.infoBanner != null) {
            return player.configs.widgets.infoBanner!(durationSpan);
          }

          int estimatedFileSize = (controller.fileSize /
                  controller.videoDuration.inSeconds *
                  durationSpan.duration.inSeconds)
              .round();

          return IgnorePointer(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: player.style.infoBannerBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${durationSpan.duration.toTimeString()} | '
                '${estimatedFileSize.toBytesString(1)}',
                style: player.style.infoBannerTextStyle ??
                    TextStyle(
                      fontSize: 14,
                      color: player.style.infoBannerTextColor,
                    ),
              ),
            ),
          );
        });
  }
}
