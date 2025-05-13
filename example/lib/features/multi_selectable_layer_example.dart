// Flutter imports:
import 'package:flutter/material.dart';
// Package imports:
import 'package:pro_image_editor/pro_image_editor.dart';

// Project imports:
import '/core/constants/example_constants.dart';
import '/core/mixin/example_helper.dart';

/// A widget that demonstrates a selectable layer functionality.
///
/// The [MultiSelectableLayerExample] widget is a stateful widget that allows
/// users to interact with and select different layers within an editor or a
/// similar application. This feature is commonly used in image or graphic
/// editors where users can manipulate individual layers.
///
/// The state for this widget is managed by the
/// [_MultiSelectableLayerExampleState] class.
///
/// Example usage:
/// ```dart
/// MutilSelectableLayerExample();
/// ```
class MultiSelectableLayerExample extends StatefulWidget {
  /// Creates a new [MultiSelectableLayerExample] widget.
  const MultiSelectableLayerExample({super.key});

  @override
  State<MultiSelectableLayerExample> createState() =>
      _MultiSelectableLayerExampleState();
}

/// The state for the [MultiSelectableLayerExample] widget.
///
/// This class manages the behavior and state related to the selectable layers
/// within the [MultiSelectableLayerExample] widget.
class _MultiSelectableLayerExampleState
    extends State<MultiSelectableLayerExample>
    with ExampleHelperState<MultiSelectableLayerExample> {
  @override
  void initState() {
    super.initState();
    preCacheImage(assetPath: kImageEditorExampleAssetPath);
  }

  @override
  Widget build(BuildContext context) {
    if (!isPreCached) return const PrepareImageWidget();

    return ProImageEditor.asset(
      kImageEditorExampleAssetPath,
      key: editorKey,
      callbacks: ProImageEditorCallbacks(
        onImageEditingStarted: onImageEditingStarted,
        onImageEditingComplete: onImageEditingComplete,
        onCloseEditor: (editorMode) => onCloseEditor(
          editorMode: editorMode,
          enablePop: !isDesktopMode(context),
        ),
        mainEditorCallbacks: MainEditorCallbacks(
          helperLines: HelperLinesCallbacks(onLineHit: vibrateLineHit),
        ),
      ),
      configs: ProImageEditorConfigs(
        designMode: platformDesignMode,
        mainEditor: MainEditorConfigs(
          enableCloseButton: !isDesktopMode(context),
          widgets: MainEditorWidgets(
            bodyItems: (editor, rebuildStream) {
              return [
                ReactiveWidget(
                  stream: rebuildStream,
                  builder: (_) => Positioned(
                    bottom: 20,
                    left: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green.shade700,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(100),
                          bottomRight: Radius.circular(100),
                        ),
                      ),
                      child: TextButton.icon(
                        onPressed: () {
                          editor.groupSelectedLayers();
                        },
                        label: const Text('Group'),
                        icon: const Icon(Icons.center_focus_strong),
                      ),
                    ),
                  ),
                ),
                ReactiveWidget(
                  stream: rebuildStream,
                  builder: (_) => Positioned(
                    bottom: 80,
                    left: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade700,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(100),
                          bottomRight: Radius.circular(100),
                        ),
                      ),
                      child: TextButton.icon(
                        onPressed: () {
                          editor.ungroupSelectedLayers();
                        },
                        label: const Text('Ungroup'),
                        icon: const Icon(Icons.zoom_out_map),
                      ),
                    ),
                  ),
                ),
              ];
            },
          ),
        ),
        imageGeneration: const ImageGenerationConfigs(
          processorConfigs: ProcessorConfigs(
            processorMode: ProcessorMode.auto,
          ),
        ),
        layerInteraction: const LayerInteractionConfigs(
          /// Choose between `auto`, `enabled` and `disabled`.
          ///
          /// Mode `auto`:
          /// Automatically determines if the layer is selectable based on the
          /// device type.
          /// If the device is a desktop-device, the layer is selectable;
          /// otherwise, the layer is not selectable.
          selectable: LayerInteractionSelectable.enabled,
          selectionMode: LayerInteractionSelectionMode.multiple,
          initialSelected: true,
          icons: LayerInteractionIcons(
            remove: Icons.clear,
            edit: Icons.edit_outlined,
            rotateScale: Icons.rotate_left,
          ),
          style: LayerInteractionStyle(
            buttonRadius: 10,
            strokeWidth: 1.2,
            borderElementWidth: 0,
            borderElementSpace: 0,
            borderColor: Colors.blue,
            removeCursor: SystemMouseCursors.click,
            rotateScaleCursor: SystemMouseCursors.click,
            editCursor: SystemMouseCursors.click,
            hoverCursor: SystemMouseCursors.move,
            borderStyle: LayerInteractionBorderStyle.solid,
            showTooltips: false,
          ),
        ),
        i18n: const I18n(
          layerInteraction: I18nLayerInteraction(
            remove: 'Remove',
            edit: 'Edit',
            rotateScale: 'Rotate and Scale',
          ),
        ),
      ),
    );
  }
}
