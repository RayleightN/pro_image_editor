import 'package:flutter/cupertino.dart';
import 'package:pro_image_editor/core/models/layers/layer.dart';

/// A class representing a group of layers.
class GroupLayer extends Layer {
  /// Factory constructor for creating an [GroupLayer] instance from a Layer
  /// and a map.
  factory GroupLayer.fromMap(
    Layer layer,
    Map<String, dynamic> map, {
    Function(String key)? keyConverter,
  }) {
    keyConverter ??= (String key) => key;

    /// Constructs and returns an [GroupLayer] instance with properties
    /// derived from the layer and map.
    return GroupLayer(
      id: layer.id,
      center: map[keyConverter('center')],
      flipX: layer.flipX,
      flipY: layer.flipY,
      interaction: layer.interaction,
      offset: layer.offset,
      rotation: layer.rotation,
      scale: layer.scale,
      isDeleted: layer.isDeleted,
      meta: layer.meta,
      children: map[keyConverter('children')],
    );
  }

  /// Creates a new instance of [GroupLayer].
  GroupLayer({
    required this.children,
    required this.center,
    super.offset,
    super.rotation,
    super.scale,
    super.id,
    super.flipX,
    super.flipY,
    super.interaction,
    super.isDeleted,
    super.meta,
  });

  /// The list of layers in the group.
  final List<Layer> children;

  /// The center of the group.
  Offset center;

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'children': children,
      'center': center,
      'type': 'group',
    };
  }

  @override
  Map<String, dynamic> toMapFromReference(Layer layer) {
    final groupLayer = (layer as GroupLayer);
    return {
      ...super.toMapFromReference(layer),
      if (groupLayer.children != children) 'children': children,
      if (groupLayer.center != center) 'center': center,
    };
  }
}
