import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pro_image_editor/core/models/editor_configs/pro_image_editor_configs.dart';
import 'package:pro_image_editor/core/models/layers/group_layer.dart';
import 'package:pro_image_editor/features/main_editor/services/layer_copy_manager.dart';
import 'package:pro_image_editor/shared/widgets/layer/layer_widget.dart';
import 'package:pro_image_editor/shared/widgets/layer/widgets/auto_sized_stack.dart';

/// A widget representing an emoji layer in the sticker editor.
class LayerWidgetGroupItem extends StatelessWidget {
  /// Creates a [LayerWidgetGroupItem] with the given emoji layer and editor
  /// configurations.
  const LayerWidgetGroupItem({
    super.key,
    required this.layer,
    required this.configs,
    required this.showMoveCursor,
    required this.onHitChanged,
    required this.selected,
    required this.enableHitDetection,
    required this.highPerformanceMode,
  });

  /// The group layer represented by this widget.
  final GroupLayer layer;

  /// The configuration options for the editor.
  final ProImageEditorConfigs configs;

  /// A value notifier that indicates whether the move cursor should be shown.
  final ValueNotifier<bool> showMoveCursor;

  /// A callback that is called when the hit detection state changes.
  final ValueChanged<bool> onHitChanged;

  /// Whether the layer is currently selected.
  final bool selected;

  /// Whether hit detection is enabled for the layer.
  final bool enableHitDetection;

  /// Whether the editor is in high-performance mode.
  final bool highPerformanceMode;

  @override
  Widget build(BuildContext context) {
    return AutoSizedStack(
      children: layer.children
          .map(
            (e) => PositionedItem(
              offset: getRotatedTopLeft(
                    original: e.offset,
                    center: layer.center,
                    angle: layer.rotation,
                  ) *
                  layer.scale,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(e.flipY ? pi : 0)
                  ..rotateY(e.flipX ? pi : 0)
                  ..rotateZ(e.rotation),
                child: RawLayerWidget(
                  layer: LayerCopyManager().copyLayer(e)
                    ..scale = layer.scale * e.scale,
                  configs: configs,
                  showMoveCursor: showMoveCursor,
                  onHitChanged: onHitChanged,
                  selected: true,
                  enableHitDetection: enableHitDetection,
                  highPerformanceMode: highPerformanceMode,
                ),
              ),
            ),
          )
          .toList(),
      onSelectionRectChanged: (rect) {
        layer.center = rect.center;
      },
    );
  }

  /// Calculates the new top-left position of a rectangle after rotation
  Offset getRotatedTopLeft({
    required Offset original,
    required Offset center,
    required double angle,
  }) {
    // Calculate vector from rotation center to original top-left
    final dx = original.dx - center.dx;
    final dy = original.dy - center.dy;

    // Apply rotation
    final rotatedDx = dx * cos(angle) - dy * sin(angle);
    final rotatedDy = dx * sin(angle) + dy * cos(angle);

    // Calculate new position
    final newX = center.dx + rotatedDx;
    final newY = center.dy + rotatedDy;

    return Offset(newX, newY);
  }
}
