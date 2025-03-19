import 'package:flutter/material.dart';
import 'package:pro_image_editor/features/main_editor/main_editor.dart';

class VideoEditorRemoveArea extends StatelessWidget {
  const VideoEditorRemoveArea({
    super.key,
    required this.removeAreaKey,
    required this.editor,
    required this.rebuildStream,
  });

  final GlobalKey removeAreaKey;
  final ProImageEditorState editor;
  final Stream<void> rebuildStream;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: StreamBuilder(
            stream: rebuildStream,
            builder: (context, snapshot) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  key: removeAreaKey,
                  height: kToolbarHeight,
                  width: kToolbarHeight,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF44336).withAlpha(
                        editor.layerInteractionManager.hoverRemoveBtn
                            ? 255
                            : 100),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                    child: Icon(
                      editor.mainEditorConfigs.icons.removeElementZone,
                      size: 28,
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }
}
