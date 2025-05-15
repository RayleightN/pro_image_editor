import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pro_image_editor/shared/widgets/layer/interaction_helper/layer_interaction_helper_widget.dart';
import 'package:pro_image_editor/shared/widgets/layer/widgets/auto_sized_stack.dart';

import '/core/models/editor_callbacks/pro_image_editor_callbacks.dart';
import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/core/models/layers/layer.dart';
import '/features/main_editor/controllers/main_editor_controllers.dart';
import '/features/main_editor/services/layer_interaction_manager.dart';
import '/features/main_editor/services/sizes_manager.dart';
import '/plugins/defer_pointer/defer_pointer.dart';
import '/shared/utils/unique_id_generator.dart';
import '/shared/widgets/extended/mouse_region/extended_rebuild_mouse_region.dart';
import '/shared/widgets/layer/layer_widget.dart';
import '../main_editor.dart';
import '../services/state_manager.dart';

/// A widget that manages and displays layers in the main editor, handling
/// interactions, configurations, and callbacks for user actions.
class MainEditorLayers extends StatefulWidget {
  /// Creates a `MainEditorLayers` widget with the necessary configurations,
  /// managers, and callbacks.
  ///
  /// - [state]: Represents the current state of the editor.
  /// - [configs]: Configuration settings for the editor.
  /// - [callbacks]: Provides callbacks for editor interactions.
  /// - [sizesManager]: Manages size-related settings and adjustments.
  /// - [controllers]: Manages the main editor's controllers.
  /// - [layerInteraction]: Configurations for layer interactions.
  /// - [layerInteractionManager]: Handles interactions with editor layers.
  /// - [mouseCursorsKey]: Key for managing mouse cursor regions.
  /// - [activeLayers]: List of active layers in the editor.
  /// - [selectedLayerIndex]: The index of the currently selected layer.
  /// - [isSubEditorOpen]: Indicates whether a sub-editor is currently open.
  /// - [checkInteractiveViewer]: Callback to check the state of the
  ///   interactive viewer.
  /// - [onTextLayerTap]: Callback triggered when a text layer is tapped.
  /// - [setTempLayer]: Callback to temporarily set a layer for interaction.
  /// - [onContextMenuToggled]: Callback triggered when the context menu is
  ///   toggled.
  const MainEditorLayers({
    super.key,
    required this.controllers,
    required this.layerInteraction,
    required this.layerInteractionManager,
    required this.configs,
    required this.callbacks,
    required this.sizesManager,
    // required this.selectedLayerIndexes,
    required this.activeLayers,
    required this.isSubEditorOpen,
    required this.checkInteractiveViewer,
    required this.onTextLayerTap,
    required this.state,
    required this.setTempLayer,
    required this.onContextMenuToggled,
    required this.onSelectionRectChanged,
    required this.stateManager,
  });

  /// Represents the current state of the editor.
  final ProImageEditorState state;

  /// Configuration settings for the editor.
  final ProImageEditorConfigs configs;

  /// Provides callbacks for editor interactions.
  final ProImageEditorCallbacks callbacks;

  /// Manages size-related settings and adjustments.
  final SizesManager sizesManager;

  /// Manages the main editor's controllers.
  final MainEditorControllers controllers;

  /// Configurations for layer interactions.
  final LayerInteractionConfigs layerInteraction;

  /// Handles interactions with editor layers.
  final LayerInteractionManager layerInteractionManager;

  /// List of active layers in the editor.
  final List<Layer> activeLayers;

  /// The set of layer indexes that are currently selected.
  // final List<int> selectedLayerIndexes;

  /// Indicates whether a sub-editor is currently open.
  final bool isSubEditorOpen;

  /// Callback to check the state of the interactive viewer.
  final Function() checkInteractiveViewer;

  /// Callback triggered when a text layer is tapped.
  final Function(TextLayer layer) onTextLayerTap;

  /// Callback to temporarily set a layer for interaction.
  final Function(Layer layer) setTempLayer;

  /// Callback triggered when the context menu is toggled.
  final Function(bool isOpen)? onContextMenuToggled;

  /// Callback triggered when the selection rectangle changes.
  final ValueChanged<Rect> onSelectionRectChanged;

  /// state manager
  final StateManager stateManager;

  @override
  State<MainEditorLayers> createState() => _MainEditorLayersState();
}

class _MainEditorLayersState extends State<MainEditorLayers> {
  final _deferId = ValueNotifier(generateUniqueId());

  Rect _selectionRect = Rect.zero;

  /// Key for managing mouse cursor regions.
  final _mouseCursorsKey = GlobalKey<ExtendedRebuildMouseRegionState>();

  // Helper methods for handling layer interactions
  void _handleEditTap(int index, Layer layer) {
    if (layer is TextLayer) {
      widget.onTextLayerTap(layer);
    } else if (layer is WidgetLayer) {
      widget.callbacks.stickerEditorCallbacks?.onTapEditSticker
          ?.call(widget.state, layer, index);
    }
  }

  void _handleLayerTap(Layer layer) {
    if (widget.layerInteractionManager.layersAreSelectable(widget.configs) &&
        layer.interaction.enableSelection) {
      switch (widget.configs.layerInteraction.selectionMode) {
        case LayerInteractionSelectionMode.single:
          if (widget.layerInteractionManager.selectedLayerIds
              .contains(layer.id)) {
            widget.layerInteractionManager.updateSelectedLayerIds([]);
          } else {
            widget.layerInteractionManager.updateSelectedLayerIds([layer.id]);
          }
          break;
        case LayerInteractionSelectionMode.multiple:
          if (widget.layerInteractionManager.selectedLayerIds
              .contains(layer.id)) {
            widget.layerInteractionManager.removeSelectedId(layer.id);
          } else {
            widget.layerInteractionManager.addSelectedLayerId(layer.id);
          }
          break;
      }

      widget.checkInteractiveViewer();
    } else if (layer is TextLayer && layer.interaction.enableEdit) {
      widget.onTextLayerTap(layer);
    }
  }

  void _handleTapUp(Layer layer) {
    if (widget.layerInteractionManager.hoverRemoveBtn) {
      widget.state.removeLayer(layer);
    }
    widget.controllers.uiLayerCtrl.add(null);
    widget.callbacks.mainEditorCallbacks?.handleUpdateUI();
    // widget.state.selectedLayerIndexes.clear();
    widget.checkInteractiveViewer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _deferId.value = generateUniqueId();
    });
  }

  void _handleTapDown(int index, Layer layer) {
    // widget.state.selectedLayerIndexes.add(index);
    widget.setTempLayer(layer);
    widget.checkInteractiveViewer();
  }

  void _handleScaleRotateDown(int index, Size layerOriginalSize, Layer layer) {
    // widget.state.selectedLayerIndexes.add(index);
    widget.layerInteractionManager
      ..rotateScaleLayerSizeHelper = layerOriginalSize
      ..rotateScaleLayerScaleHelper = layer.scale;
    widget.checkInteractiveViewer();
  }

  void _handleScaleRotateUp() {
    widget.layerInteractionManager
      ..rotateScaleLayerSizeHelper = null
      ..rotateScaleLayerScaleHelper = null;
    // widget.state.setState(() => widget.state.selectedLayerIndexes.clear());
    widget.checkInteractiveViewer();
    widget.callbacks.mainEditorCallbacks?.handleUpdateUI();
  }

  void _handleRemoveLayer(Layer layer) {
    widget.state.setState(() => widget.state.removeLayer(layer));
    widget.layerInteractionManager.removeSelectedId(layer.id);
    widget.callbacks.mainEditorCallbacks?.handleUpdateUI();
  }

  void _handleRemoveLayers(List<Layer> layers) {
    widget.state.setState(() => widget.state.removeLayers(layers));
    for (var layer in layers) {
      widget.layerInteractionManager.removeSelectedId(layer.id);
    }
    widget.callbacks.mainEditorCallbacks?.handleUpdateUI();
  }

  /// Handles mouse hover events to change the cursor style
  void _handleMouseHover(PointerHoverEvent event) {
    final bool hasHit = widget.activeLayers
        .any((element) => element is PaintLayer && element.item.hit);

    final activeCursor = _mouseCursorsKey.currentState!.currentCursor;
    final moveCursor = widget.layerInteraction.style.hoverCursor;

    if (hasHit && activeCursor != moveCursor) {
      _mouseCursorsKey.currentState!.setCursor(moveCursor);
    } else if (!hasHit && activeCursor != SystemMouseCursors.basic) {
      _mouseCursorsKey.currentState!.setCursor(SystemMouseCursors.basic);
    }
  }

  void _handleSelectionRectChanged(Rect rect) {
    _selectionRect = rect;
    widget.onSelectionRectChanged(rect);
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  void _handleUnlockLayer(Layer layer) {
    widget.state.setState(() => widget.state.unLockLayer(layer));
    widget.callbacks.mainEditorCallbacks?.handleUpdateUI();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      // ignoring: widget.selectedLayerIndexes.isNotEmpty,
      ignoring: false,
      child: StreamBuilder<bool>(
        stream: widget.controllers.layerHeroResetCtrl.stream,
        initialData: false,
        builder: (context, resetLayerSnapshot) {
          // Render an empty container when resetting layers
          if (resetLayerSnapshot.data!) return const SizedBox.shrink();

          return _buildLayerRepaintBoundary();
        },
      ),
    );
  }

  /// Builds the layer repaint boundary widget
  Widget _buildLayerRepaintBoundary() {
    if (widget.activeLayers.isEmpty) return const SizedBox.shrink();
    return RepaintBoundary(
      child: ExtendedRebuildMouseRegion(
        key: _mouseCursorsKey,
        onHover: isDesktop ? _handleMouseHover : null,
        child: ValueListenableBuilder(
            valueListenable: _deferId,
            builder: (_, deferId, __) {
              return DeferredPointerHandler(
                id: deferId,
                selectedLayerIds:
                    widget.layerInteractionManager.selectedLayerIds,
                child: StreamBuilder(
                  stream: widget.controllers.uiLayerCtrl.stream,
                  builder: (context, snapshot) {
                    return Stack(
                      fit: StackFit.loose,
                      children: [
                        ...widget.activeLayers
                            .asMap()
                            .entries
                            .map(_buildLayerWidget),
                        if (widget.configs.layerInteraction.selectionMode ==
                            LayerInteractionSelectionMode.multiple)
                          ..._buildGroupedItem(),
                      ],
                    );
                  },
                ),
              );
            }),
      ),
    );
  }

  /// Builds grouped item
  List<Widget> _buildGroupedItem() {
    if (widget.layerInteractionManager.selectedLayerIds.isEmpty) {
      _handleSelectionRectChanged(Rect.zero);
      return [];
    }

    return [
      if (_selectionRect != Rect.zero)
        Positioned.fromRect(
          // 48 is the margin inside LayerInteractionHelperWidget
          rect: _selectionRect.inflate(48),
          child: LayerInteractionHelperWidget(
            layerData: Layer(),
            configs: widget.configs,
            selected: true,
            isInteractive: true,
            onRemoveLayer: () => _handleRemoveLayers(widget
                .layerInteractionManager.selectedLayerIds
                .map((e) => widget.activeLayers.firstWhere((l) => l.id == e))
                .toList()),
            onScaleRotateDown: (details) {
              widget.layerInteractionManager.selectedLayerIds
                  .map((e) => widget.activeLayers.firstWhere((l) => l.id == e))
                  .toList()
                  .asMap()
                  .entries
                  .forEach(
                    (e) => _handleScaleRotateDown(
                        e.key, _selectionRect.size, e.value),
                  );
            },
            onScaleRotateUp: (details) => _handleScaleRotateUp(),
            onUnLockLayer: () {},
            callbacks: widget.callbacks,
            child: const SizedBox.expand(),
          ),
        ),
      UnconstrainedBox(
        child: AutoSizedStack(
          onSelectionRectChanged: _handleSelectionRectChanged,
          children: [
            ...widget.activeLayers
                .asMap()
                .entries
                .where((e) => widget.layerInteractionManager.selectedLayerIds
                    .contains(e.value.id))
                .map((e) {
              Layer layer = e.value;
              final editorCenterX = widget.sizesManager.editorSize.width / 2;
              final editorCenterY = widget.sizesManager.editorCenterY();
              double offsetX = layer.offset.dx + editorCenterX;
              double offsetY = layer.offset.dy + editorCenterY;
              return PositionedItem(
                offset: Offset(offsetX, offsetY),
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateZ(layer.rotation),
                  child: Opacity(
                    opacity: 0,
                    child: RawLayerWidget(
                      layer: layer,
                      configs: widget.configs,
                      showMoveCursor: ValueNotifier(false),
                      onHitChanged: (state) {},
                      enableHitDetection: false,
                      selected: true,
                      highPerformanceMode: false,
                    ),
                  ),
                ),
              );
            })
          ],
        ),
      )
    ];
  }

  /// Builds a single layer widget
  Widget _buildLayerWidget(MapEntry<int, Layer> entry) {
    int index = entry.key;
    Layer layer = entry.value;
    return LayerWidget(
      key: layer.key,
      configs: widget.configs,
      callbacks: widget.callbacks,
      editorCenterX: widget.sizesManager.editorSize.width / 2,
      editorCenterY: widget.sizesManager.editorCenterY(),
      layerData: layer,
      enableHitDetection: widget.layerInteractionManager.enabledHitDetection,
      selected:
          widget.layerInteractionManager.selectedLayerIds.contains(layer.id),
      isInteractive: !widget.isSubEditorOpen,
      highPerformanceMode:
          widget.layerInteractionManager.freeStyleHighPerformance,
      onEditTap: () => _handleEditTap(index, layer),
      onTap: _handleLayerTap,
      onTapUp: () => _handleTapUp(layer),
      onTapDown: () => _handleTapDown(index, layer),
      onScaleRotateDown: (details, layerOriginalSize) =>
          _handleScaleRotateDown(index, layerOriginalSize, layer),
      onContextMenuToggled: widget.onContextMenuToggled,
      onScaleRotateUp: (details) => _handleScaleRotateUp(),
      onRemoveTap: () => _handleRemoveLayer(layer),
      onUnlockLayer: () => _handleUnlockLayer(layer),
    );
  }
}
