// ignore_for_file: public_member_api_docs

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class AutoSizedStack extends MultiChildRenderObjectWidget {
  const AutoSizedStack(
      {super.key, required super.children, this.onSelectionRectChanged});
  final ValueChanged<Rect>? onSelectionRectChanged;

  @override
  RenderAutoSizedStack createRenderObject(BuildContext context) =>
      RenderAutoSizedStack(onSelectionRectChanged: onSelectionRectChanged);

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderAutoSizedStack renderObject) {}

  @override
  MultiChildRenderObjectElement createElement() =>
      MultiChildRenderObjectElement(this);
}

class PositionedItem extends ParentDataWidget<AutoSizedStackParentData> {
  const PositionedItem({
    super.key,
    required this.offset,
    required super.child,
  });
  final Offset offset;

  @override
  void applyParentData(RenderObject renderObject) {
    final AutoSizedStackParentData parentData =
        renderObject.parentData as AutoSizedStackParentData;
    if (parentData.offset != offset) {
      parentData.offset = offset;
      renderObject.parent?.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => AutoSizedStack;
}

class AutoSizedStackParentData extends ContainerBoxParentData<RenderBox> {}

class RenderAutoSizedStack extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, AutoSizedStackParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, AutoSizedStackParentData> {
  RenderAutoSizedStack({this.onSelectionRectChanged});

  final ValueChanged<Rect>? onSelectionRectChanged;

  @override
  void performLayout() {
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    // First pass: layout children and calculate bounding box
    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as AutoSizedStackParentData;

      child.layout(constraints.loosen(), parentUsesSize: true);
      final Size childSize = child.size;
      final Offset center = childParentData.offset;

      var rect = Rect.fromCenter(
        center: center,
        width: childSize.width,
        height: childSize.height,
      );
      if (child is RenderTransform) {
        final realChild = child.child;
        if (realChild != null) {
          final childRect = MatrixUtils.transformRect(
            realChild.getTransformTo(child),
            Offset.zero & child.size,
          );
          rect = Rect.fromCenter(
            center: center,
            width: childRect.width,
            height: childRect.height,
          );
        }
      }
      minX = min(minX, rect.left);
      minY = min(minY, rect.top);
      maxX = max(maxX, rect.right);
      maxY = max(maxY, rect.bottom);

      child = childParentData.nextSibling;
    }

    // Set container size
    if (minX == double.infinity) {
      size = Size.zero;
      return;
    }

    final double groupWidth = maxX - minX;
    final double groupHeight = maxY - minY;
    size = Size(groupWidth, groupHeight);

    // Second pass: adjust offsets relative to top-left corner
    child = firstChild;
    while (child != null) {
      final AutoSizedStackParentData childParentData =
          child.parentData as AutoSizedStackParentData;
      final Size childSize = child.size;
      final Offset center = childParentData.offset;

      final double adjustedLeft = center.dx - childSize.width / 2 - minX;
      final double adjustedTop = center.dy - childSize.height / 2 - minY;

      childParentData.offset = Offset(adjustedLeft, adjustedTop);

      child = childParentData.nextSibling;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onSelectionRectChanged?.call(Rect.fromLTRB(minX, minY, maxX, maxY));
    });
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    RenderBox? child = firstChild;
    while (child != null) {
      final AutoSizedStackParentData childParentData =
          child.parentData as AutoSizedStackParentData;
      context.paintChild(child, offset + childParentData.offset);
      child = childParentData.nextSibling;
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! AutoSizedStackParentData) {
      child.parentData = AutoSizedStackParentData();
    }
  }
}
