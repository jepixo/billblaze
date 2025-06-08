import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// A widget that applies a blend mode and opacity to its child.
///
/// The [BlendMask] widget allows you to blend its child with a specified
/// blend mode and opacity. This can be useful for creating various visual
/// effects such as overlays, blending images, and custom compositing effects.
///
/// ```dart
/// BlendMask(
///   blendMode: BlendMode.multiply,
///   opacity: 0.5,
///   child: Image.asset('assets/sample_image.png'),
/// )
/// ```
class BlendMask extends SingleChildRenderObjectWidget {
  /// The blend mode to apply to the child.
  ///
  /// The blend mode determines how the child widget's content is blended
  /// with its background.
  final BlendMode blendMode;

  /// The opacity to apply to the blend mode.
  ///
  /// The opacity should be a value between 0.0 (completely transparent)
  /// and 1.0 (completely opaque). Defaults to 1.0.
  final double opacity;

  /// Creates a [BlendMask] widget.
  ///
  /// The [blendMode] and [opacity] parameters must not be null. The [opacity]
  /// must be between 0.0 and 1.0.
  const BlendMask({
    required this.blendMode,
    this.opacity = 1.0,
    Key? key,
    Widget? child,
  })  : assert(opacity >= 0.0 && opacity <= 1.0),
        super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderBlendMask(blendMode, opacity);
  }

  @override
  void updateRenderObject(BuildContext context, RenderBlendMask renderObject) {
    renderObject
      ..blendMode = blendMode
      ..opacity = opacity;
  }
}

/// A render object that applies a blend mode and opacity to its child.
///
/// The [RenderBlendMask] render object is used by the [BlendMask] widget
/// to apply the specified blend mode and opacity to its child during the
/// painting phase.
class RenderBlendMask extends RenderProxyBox {
  /// The blend mode to apply to the child.
  BlendMode blendMode;

  /// The opacity to apply to the blend mode.
  double opacity;

  /// Creates a [RenderBlendMask] render object.
  ///
  /// The [blendMode] and [opacity] parameters must not be null. The [opacity]
  /// must be between 0.0 and 1.0.
  RenderBlendMask(this.blendMode, this.opacity)
      : assert(opacity >= 0.0 && opacity <= 1.0);

  @override
  void paint(PaintingContext context, Offset offset) {
    final Paint paint = Paint()
      ..blendMode = blendMode
      ..color = Color.fromRGBO(255, 255, 255, opacity);

    context.canvas.saveLayer(offset & size, paint);
    super.paint(context, offset);
    context.canvas.restore();
  }
}