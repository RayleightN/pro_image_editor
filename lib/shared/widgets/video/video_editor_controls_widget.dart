import 'package:flutter/material.dart';
import 'package:pro_image_editor/shared/widgets/video/toolbar/video_editor_trim_info_widget.dart';

import '/core/models/editor_configs/video_editor_configs.dart';
import 'toolbar/video_editor_mute_button.dart';
import '/shared/widgets/video/video_editor_state_widget.dart';
import 'video_editor_configurable.dart';
import 'toolbar/video_editor_info_banner.dart';
import 'trimmer/video_editor_trim_bar.dart';

class VideoEditorControlsWidget extends StatelessWidget {
  const VideoEditorControlsWidget();

  @override
  Widget build(BuildContext context) {
    var player = VideoEditorConfigurable.of(context);

    bool alignTop =
        player.configs.controlsPosition == VideoEditorControlPosition.top;

    return Stack(
      children: [
        player.widgets.headerToolbar ??
            Column(
              spacing: 10,
              verticalDirection:
                  alignTop ? VerticalDirection.down : VerticalDirection.up,
              children: [
                const VideoEditorTrimBar(),
                Padding(
                  padding: player.contentPadding,
                  child: const Row(
                    spacing: 12,
                    children: [
                      VideoEditorMuteButton(),
                      VideoEditorInfoBanner(),
                      Spacer(),
                      VideoEditorTrimInfoWidget()
                    ],
                  ),
                ),
              ],
            ),
        const VideoEditorStateWidget(),
      ],
    );
  }
}
