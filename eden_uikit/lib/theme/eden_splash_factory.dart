import 'package:flutter/material.dart';

/// 关闭水波纹
class EdenSplashFactory extends InteractiveInkFeatureFactory {
  @override
  InteractiveInkFeature create({
    required MaterialInkController controller,
    required RenderBox referenceBox,
    required Offset position,
    required Color color,
    required TextDirection textDirection,
    bool containedInkWell = false,
    RectCallback? rectCallback,
    BorderRadius? borderRadius,
    ShapeBorder? customBorder,
    double? radius,
    VoidCallback? onRemoved,
  }) {
    return _NoInteractiveInkFeature(
        controller: controller,
        referenceBox: referenceBox,
        color: color,
        onRemoved: onRemoved);
  }
}

class _NoInteractiveInkFeature extends InteractiveInkFeature {
  _NoInteractiveInkFeature({
    required super.controller,
    required super.referenceBox,
    required super.color,
    super.onRemoved,
  });

  @override
  void paintFeature(Canvas canvas, Matrix4 transform) {}
}
