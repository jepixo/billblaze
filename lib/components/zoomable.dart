// // library zoomable_widget;
// // Copyright 2014 The Flutter Authors. All rights reserved.
// // Use of this source code is governed by a BSD-style license that can be
// // found in the LICENSE file.

// import 'dart:math' as math;

// import 'package:flutter/foundation.dart' show clampDouble;
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/physics.dart';
// import 'package:vector_math/vector_math_64.dart' show Matrix4, Quad, Vector3;

// // Examples can assume:
// // late BuildContext context;
// // late Offset? _childWasTappedAt;
// // late TransformationController _transformationController;
// // Widget child = const Placeholder();

// /// A signature for widget builders that take a [Quad] of the current viewport.
// ///
// /// See also:
// ///
// ///   * [Zoomable.builder], whose builder is of this type.
// ///   * [WidgetBuilder], which is similar, but takes no viewport.
// typedef ZoomableWidgetBuilder = Widget Function(
//     BuildContext context, Quad viewport);

// /// A widget that enables pan and zoom interactions with its child.
// ///
// /// {@youtube 560 315 https://www.youtube.com/watch?v=zrn7V3bMJvg}
// ///
// /// The user can transform the child by dragging to pan or pinching to zoom.
// ///
// /// By default, InteractiveViewer clips its child using [Clip.hardEdge].
// /// To prevent this behavior, consider setting [clipBehavior] to [Clip.none].
// /// When [clipBehavior] is [Clip.none], InteractiveViewer may draw outside of
// /// its original area of the screen, such as when a child is zoomed in and
// /// increases in size. However, it will not receive gestures outside of its original area.
// /// To prevent dead areas where InteractiveViewer does not receive gestures,
// /// don't set [clipBehavior] or be sure that the InteractiveViewer widget is the
// /// size of the area that should be interactive.
// ///
// /// The [child] must not be null.
// ///
// /// See also:
// ///   * The [Flutter Gallery's transformations demo](https://github.com/flutter/gallery/blob/master/lib/demos/reference/transformations_demo.dart),
// ///     which includes the use of InteractiveViewer.
// ///   * The [flutter-go demo](https://github.com/justinmc/flutter-go), which includes robust positioning of an InteractiveViewer child
// ///     that works for all screen sizes and child sizes.
// ///   * The [Lazy Flutter Performance Session](https://www.youtube.com/watch?v=qax_nOpgz7E), which includes the use of an InteractiveViewer to
// ///     performantly view subsets of a large set of widgets using the builder constructor.
// ///
// /// {@tool dartpad}
// /// This example shows a simple Container that can be panned and zoomed.
// ///
// /// ** See code in examples/api/lib/widgets/interactive_viewer/interactive_viewer.0.dart **
// /// {@end-tool}
// @immutable
// class Zoomable extends StatefulWidget {
//   /// Create an InteractiveViewer.
//   ///
//   /// The [child] parameter must not be null.
//   Zoomable({
//     super.key,
//     this.clipBehavior = Clip.hardEdge,
//     @Deprecated(
//       'Use panAxis instead. '
//       'This feature was deprecated after v3.3.0-0.5.pre.',
//     )
//     this.alignPanAxis = false,
//     this.panAxis = PanAxis.free,
//     this.boundaryMargin = EdgeInsets.zero,
//     this.constrained = true,
//     // These default scale values were eyeballed as reasonable limits for common
//     // use cases.
//     this.maxScale = 2.5,
//     this.minScale = 0.8,
//     this.interactionEndFrictionCoefficient = _kDrag,
//     this.onInteractionEnd,
//     this.onInteractionStart,
//     this.onInteractionUpdate,
//     this.panEnabled = true,
//     this.scaleEnabled = true,
//     this.scaleFactor = kDefaultMouseScrollToScaleFactor,
//     this.transformationController,
//     this.alignment,
//     this.trackpadScrollCausesScale = false,
//     required Widget this.child,
//   })  : assert(minScale > 0),
//         assert(interactionEndFrictionCoefficient > 0),
//         assert(minScale.isFinite),
//         assert(maxScale > 0),
//         assert(!maxScale.isNaN),
//         assert(maxScale >= minScale),
//         // boundaryMargin must be either fully infinite or fully finite, but not
//         // a mix of both.
//         assert(
//           (boundaryMargin.horizontal.isInfinite &&
//                   boundaryMargin.vertical.isInfinite) ||
//               (boundaryMargin.top.isFinite &&
//                   boundaryMargin.right.isFinite &&
//                   boundaryMargin.bottom.isFinite &&
//                   boundaryMargin.left.isFinite),
//         ),
//         builder = null;

//   /// Creates an InteractiveViewer for a child that is created on demand.
//   ///
//   /// Can be used to render a child that changes in response to the current
//   /// transformation.
//   ///
//   /// The [builder] parameter must not be null. See its docs for an example of
//   /// using it to optimize a large child.
//   Zoomable.builder({
//     super.key,
//     this.clipBehavior = Clip.hardEdge,
//     @Deprecated(
//       'Use panAxis instead. '
//       'This feature was deprecated after v3.3.0-0.5.pre.',
//     )
//     this.alignPanAxis = false,
//     this.panAxis = PanAxis.free,
//     this.boundaryMargin = EdgeInsets.zero,
//     // These default scale values were eyeballed as reasonable limits for common
//     // use cases.
//     this.maxScale = 2.5,
//     this.minScale = 0.8,
//     this.interactionEndFrictionCoefficient = _kDrag,
//     this.onInteractionEnd,
//     this.onInteractionStart,
//     this.onInteractionUpdate,
//     this.panEnabled = true,
//     this.scaleEnabled = true,
//     this.scaleFactor = 200.0,
//     this.transformationController,
//     this.alignment,
//     this.trackpadScrollCausesScale = false,
//     required ZoomableWidgetBuilder this.builder,
//   })  : assert(minScale > 0),
//         assert(interactionEndFrictionCoefficient > 0),
//         assert(minScale.isFinite),
//         assert(maxScale > 0),
//         assert(!maxScale.isNaN),
//         assert(maxScale >= minScale),
//         // boundaryMargin must be either fully infinite or fully finite, but not
//         // a mix of both.
//         assert(
//           (boundaryMargin.horizontal.isInfinite &&
//                   boundaryMargin.vertical.isInfinite) ||
//               (boundaryMargin.top.isFinite &&
//                   boundaryMargin.right.isFinite &&
//                   boundaryMargin.bottom.isFinite &&
//                   boundaryMargin.left.isFinite),
//         ),
//         constrained = false,
//         child = null;

//   /// The alignment of the child's origin, relative to the size of the box.
//   final Alignment? alignment;

//   /// If set to [Clip.none], the child may extend beyond the size of the InteractiveViewer,
//   /// but it will not receive gestures in these areas.
//   /// Be sure that the InteractiveViewer is the desired size when using [Clip.none].
//   ///
//   /// Defaults to [Clip.hardEdge].
//   final Clip clipBehavior;

//   /// This property is deprecated, please use [panAxis] instead.
//   ///
//   /// If true, panning is only allowed in the direction of the horizontal axis
//   /// or the vertical axis.
//   ///
//   /// In other words, when this is true, diagonal panning is not allowed. A
//   /// single gesture begun along one axis cannot also cause panning along the
//   /// other axis without stopping and beginning a new gesture. This is a common
//   /// pattern in tables where data is displayed in columns and rows.
//   ///
//   /// See also:
//   ///  * [constrained], which has an example of creating a table that uses
//   ///    alignPanAxis.
//   @Deprecated(
//     'Use panAxis instead. '
//     'This feature was deprecated after v3.3.0-0.5.pre.',
//   )
//   final bool alignPanAxis;

//   /// When set to [PanAxis.aligned], panning is only allowed in the horizontal
//   /// axis or the vertical axis, diagonal panning is not allowed.
//   ///
//   /// When set to [PanAxis.vertical] or [PanAxis.horizontal] panning is only
//   /// allowed in the specified axis. For example, if set to [PanAxis.vertical],
//   /// panning will only be allowed in the vertical axis. And if set to [PanAxis.horizontal],
//   /// panning will only be allowed in the horizontal axis.
//   ///
//   /// When set to [PanAxis.free] panning is allowed in all directions.
//   ///
//   /// Defaults to [PanAxis.free].
//   final PanAxis panAxis;

//   /// A margin for the visible boundaries of the child.
//   ///
//   /// Any transformation that results in the viewport being able to view outside
//   /// of the boundaries will be stopped at the boundary. The boundaries do not
//   /// rotate with the rest of the scene, so they are always aligned with the
//   /// viewport.
//   ///
//   /// To produce no boundaries at all, pass infinite [EdgeInsets], such as
//   /// `EdgeInsets.all(double.infinity)`.
//   ///
//   /// No edge can be NaN.
//   ///
//   /// Defaults to [EdgeInsets.zero], which results in boundaries that are the
//   /// exact same size and position as the [child].
//   final EdgeInsets boundaryMargin;

//   /// Builds the child of this widget.
//   ///
//   /// Passed with the [Zoomable.builder] constructor. Otherwise, the
//   /// [child] parameter must be passed directly, and this is null.
//   ///
//   /// {@tool dartpad}
//   /// This example shows how to use builder to create a [Table] whose cell
//   /// contents are only built when they are visible. Built and remove cells are
//   /// logged in the console for illustration.
//   ///
//   /// ** See code in examples/api/lib/widgets/interactive_viewer/interactive_viewer.builder.0.dart **
//   /// {@end-tool}
//   ///
//   /// See also:
//   ///
//   ///   * [ListView.builder], which follows a similar pattern.
//   final ZoomableWidgetBuilder? builder;

//   /// The child [Widget] that is transformed by InteractiveViewer.
//   ///
//   /// If the [Zoomable.builder] constructor is used, then this will be
//   /// null, otherwise it is required.
//   final Widget? child;

//   /// Whether the normal size constraints at this point in the widget tree are
//   /// applied to the child.
//   ///
//   /// If set to false, then the child will be given infinite constraints. This
//   /// is often useful when a child should be bigger than the InteractiveViewer.
//   ///
//   /// For example, for a child which is bigger than the viewport but can be
//   /// panned to reveal parts that were initially offscreen, [constrained] must
//   /// be set to false to allow it to size itself properly. If [constrained] is
//   /// true and the child can only size itself to the viewport, then areas
//   /// initially outside of the viewport will not be able to receive user
//   /// interaction events. If experiencing regions of the child that are not
//   /// receptive to user gestures, make sure [constrained] is false and the child
//   /// is sized properly.
//   ///
//   /// Defaults to true.
//   ///
//   /// {@tool dartpad}
//   /// This example shows how to create a pannable table. Because the table is
//   /// larger than the entire screen, setting [constrained] to false is necessary
//   /// to allow it to be drawn to its full size. The parts of the table that
//   /// exceed the screen size can then be panned into view.
//   ///
//   /// ** See code in examples/api/lib/widgets/interactive_viewer/interactive_viewer.constrained.0.dart **
//   /// {@end-tool}
//   final bool constrained;

//   /// If false, the user will be prevented from panning.
//   ///
//   /// Defaults to true.
//   ///
//   /// See also:
//   ///
//   ///   * [scaleEnabled], which is similar but for scale.
//   final bool panEnabled;

//   /// If false, the user will be prevented from scaling.
//   ///
//   /// Defaults to true.
//   ///
//   /// See also:
//   ///
//   ///   * [panEnabled], which is similar but for panning.
//   final bool scaleEnabled;

//   /// {@macro flutter.gestures.scale.trackpadScrollCausesScale}
//   final bool trackpadScrollCausesScale;

//   /// Determines the amount of scale to be performed per pointer scroll.
//   ///
//   /// Defaults to [kDefaultMouseScrollToScaleFactor].
//   ///
//   /// Increasing this value above the default causes scaling to feel slower,
//   /// while decreasing it causes scaling to feel faster.
//   ///
//   /// The amount of scale is calculated as the exponential function of the
//   /// [PointerScrollEvent.scrollDelta] to [scaleFactor] ratio. In the Flutter
//   /// engine, the mousewheel [PointerScrollEvent.scrollDelta] is hardcoded to 20
//   /// per scroll, while a trackpad scroll can be any amount.
//   ///
//   /// Affects only pointer device scrolling, not pinch to zoom.
//   final double scaleFactor;

//   /// The maximum allowed scale.
//   ///
//   /// The scale will be clamped between this and [minScale] inclusively.
//   ///
//   /// Defaults to 2.5.
//   ///
//   /// Cannot be null, and must be greater than zero and greater than minScale.
//   final double maxScale;

//   /// The minimum allowed scale.
//   ///
//   /// The scale will be clamped between this and [maxScale] inclusively.
//   ///
//   /// Scale is also affected by [boundaryMargin]. If the scale would result in
//   /// viewing beyond the boundary, then it will not be allowed. By default,
//   /// boundaryMargin is EdgeInsets.zero, so scaling below 1.0 will not be
//   /// allowed in most cases without first increasing the boundaryMargin.
//   ///
//   /// Defaults to 0.8.
//   ///
//   /// Cannot be null, and must be a finite number greater than zero and less
//   /// than maxScale.
//   final double minScale;

//   /// Changes the deceleration behavior after a gesture.
//   ///
//   /// Defaults to 0.0000135.
//   ///
//   /// Cannot be null, and must be a finite number greater than zero.
//   final double interactionEndFrictionCoefficient;

//   /// Called when the user ends a pan or scale gesture on the widget.
//   ///
//   /// At the time this is called, the [TransformationController] will have
//   /// already been updated to reflect the change caused by the interaction,
//   /// though a pan may cause an inertia animation after this is called as well.
//   ///
//   /// {@template flutter.widgets.InteractiveViewer.onInteractionEnd}
//   /// Will be called even if the interaction is disabled with [panEnabled] or
//   /// [scaleEnabled] for both touch gestures and mouse interactions.
//   ///
//   /// A [GestureDetector] wrapping the InteractiveViewer will not respond to
//   /// [GestureDetector.onScaleStart], [GestureDetector.onScaleUpdate], and
//   /// [GestureDetector.onScaleEnd]. Use [onInteractionStart],
//   /// [onInteractionUpdate], and [onInteractionEnd] to respond to those
//   /// gestures.
//   /// {@endtemplate}
//   ///
//   /// See also:
//   ///
//   ///  * [onInteractionStart], which handles the start of the same interaction.
//   ///  * [onInteractionUpdate], which handles an update to the same interaction.
//   final GestureScaleEndCallback? onInteractionEnd;

//   /// Called when the user begins a pan or scale gesture on the widget.
//   ///
//   /// At the time this is called, the [TransformationController] will not have
//   /// changed due to this interaction.
//   ///
//   /// {@macro flutter.widgets.InteractiveViewer.onInteractionEnd}
//   ///
//   /// The coordinates provided in the details' `focalPoint` and
//   /// `localFocalPoint` are normal Flutter event coordinates, not
//   /// InteractiveViewer scene coordinates. See
//   /// [TransformationController.toScene] for how to convert these coordinates to
//   /// scene coordinates relative to the child.
//   ///
//   /// See also:
//   ///
//   ///  * [onInteractionUpdate], which handles an update to the same interaction.
//   ///  * [onInteractionEnd], which handles the end of the same interaction.
//   final GestureScaleStartCallback? onInteractionStart;

//   /// Called when the user updates a pan or scale gesture on the widget.
//   ///
//   /// At the time this is called, the [TransformationController] will have
//   /// already been updated to reflect the change caused by the interaction, if
//   /// the interaction caused the matrix to change.
//   ///
//   /// {@macro flutter.widgets.InteractiveViewer.onInteractionEnd}
//   ///
//   /// The coordinates provided in the details' `focalPoint` and
//   /// `localFocalPoint` are normal Flutter event coordinates, not
//   /// InteractiveViewer scene coordinates. See
//   /// [TransformationController.toScene] for how to convert these coordinates to
//   /// scene coordinates relative to the child.
//   ///
//   /// See also:
//   ///
//   ///  * [onInteractionStart], which handles the start of the same interaction.
//   ///  * [onInteractionEnd], which handles the end of the same interaction.
//   final GestureScaleUpdateCallback? onInteractionUpdate;

//   /// A [TransformationController] for the transformation performed on the
//   /// child.
//   ///
//   /// Whenever the child is transformed, the [Matrix4] value is updated and all
//   /// listeners are notified. If the value is set, InteractiveViewer will update
//   /// to respect the new value.
//   ///
//   /// {@tool dartpad}
//   /// This example shows how transformationController can be used to animate the
//   /// transformation back to its starting position.
//   ///
//   /// ** See code in examples/api/lib/widgets/interactive_viewer/interactive_viewer.transformation_controller.0.dart **
//   /// {@end-tool}
//   ///
//   /// See also:
//   ///
//   ///  * [ValueNotifier], the parent class of TransformationController.
//   ///  * [TextEditingController] for an example of another similar pattern.
//   final TransformationController? transformationController;

//   // Used as the coefficient of friction in the inertial translation animation.
//   // This value was eyeballed to give a feel similar to Google Photos.
//   static const double _kDrag = 0.0000135;

//   /// Returns the closest point to the given point on the given line segment.
//   @visibleForTesting
//   static Vector3 getNearestPointOnLine(Vector3 point, Vector3 l1, Vector3 l2) {
//     final double lengthSquared = math.pow(l2.x - l1.x, 2.0).toDouble() +
//         math.pow(l2.y - l1.y, 2.0).toDouble();

//     // In this case, l1 == l2.
//     if (lengthSquared == 0) {
//       return l1;
//     }

//     // Calculate how far down the line segment the closest point is and return
//     // the point.
//     final Vector3 l1P = point - l1;
//     final Vector3 l1L2 = l2 - l1;
//     final double fraction =
//         clampDouble(l1P.dot(l1L2) / lengthSquared, 0.0, 1.0);
//     return l1 + l1L2 * fraction;
//   }

//   /// Given a quad, return its axis aligned bounding box.
//   @visibleForTesting
//   static Quad getAxisAlignedBoundingBox(Quad quad) {
//     final double minX = math.min(
//       quad.point0.x,
//       math.min(
//         quad.point1.x,
//         math.min(
//           quad.point2.x,
//           quad.point3.x,
//         ),
//       ),
//     );
//     final double minY = math.min(
//       quad.point0.y,
//       math.min(
//         quad.point1.y,
//         math.min(
//           quad.point2.y,
//           quad.point3.y,
//         ),
//       ),
//     );
//     final double maxX = math.max(
//       quad.point0.x,
//       math.max(
//         quad.point1.x,
//         math.max(
//           quad.point2.x,
//           quad.point3.x,
//         ),
//       ),
//     );
//     final double maxY = math.max(
//       quad.point0.y,
//       math.max(
//         quad.point1.y,
//         math.max(
//           quad.point2.y,
//           quad.point3.y,
//         ),
//       ),
//     );
//     return Quad.points(
//       Vector3(minX, minY, 0),
//       Vector3(maxX, minY, 0),
//       Vector3(maxX, maxY, 0),
//       Vector3(minX, maxY, 0),
//     );
//   }

//   /// Returns true iff the point is inside the rectangle given by the Quad,
//   /// inclusively.
//   /// Algorithm from https://math.stackexchange.com/a/190373.
//   @visibleForTesting
//   static bool pointIsInside(Vector3 point, Quad quad) {
//     final Vector3 aM = point - quad.point0;
//     final Vector3 aB = quad.point1 - quad.point0;
//     final Vector3 aD = quad.point3 - quad.point0;

//     final double aMAB = aM.dot(aB);
//     final double aBAB = aB.dot(aB);
//     final double aMAD = aM.dot(aD);
//     final double aDAD = aD.dot(aD);

//     return 0 <= aMAB && aMAB <= aBAB && 0 <= aMAD && aMAD <= aDAD;
//   }

//   /// Get the point inside (inclusively) the given Quad that is nearest to the
//   /// given Vector3.
//   @visibleForTesting
//   static Vector3 getNearestPointInside(Vector3 point, Quad quad) {
//     // If the point is inside the axis aligned bounding box, then it's ok where
//     // it is.
//     if (pointIsInside(point, quad)) {
//       return point;
//     }

//     // Otherwise, return the nearest point on the quad.
//     final List<Vector3> closestPoints = <Vector3>[
//       Zoomable.getNearestPointOnLine(point, quad.point0, quad.point1),
//       Zoomable.getNearestPointOnLine(point, quad.point1, quad.point2),
//       Zoomable.getNearestPointOnLine(point, quad.point2, quad.point3),
//       Zoomable.getNearestPointOnLine(point, quad.point3, quad.point0),
//     ];
//     double minDistance = double.infinity;
//     late Vector3 closestOverall;
//     for (final Vector3 closePoint in closestPoints) {
//       final double distance = math.sqrt(
//         math.pow(point.x - closePoint.x, 2) +
//             math.pow(point.y - closePoint.y, 2),
//       );
//       if (distance < minDistance) {
//         minDistance = distance;
//         closestOverall = closePoint;
//       }
//     }
//     return closestOverall;
//   }

//   @override
//   State<Zoomable> createState() => _ZoomableState();
// }

// class _ZoomableState extends State<Zoomable> with TickerProviderStateMixin {
//   TransformationController? _transformationController;

//   final GlobalKey _childKey = GlobalKey();
//   final GlobalKey _parentKey = GlobalKey();
//   Animation<Offset>? _animation;
//   Animation<double>? _scaleAnimation;
//   late Offset _scaleAnimationFocalPoint;
//   late AnimationController _controller;
//   late AnimationController _scaleController;
//   Axis? _currentAxis; // Used with panAxis.
//   Offset? _referenceFocalPoint; // Point where the current gesture began.
//   double? _scaleStart; // Scale value at start of scaling gesture.
//   double? _rotationStart = 0.0; // Rotation at start of rotation gesture.
//   double _currentRotation = 0.0; // Rotation of _transformationController.value.
//   _GestureType? _gestureType;

//   // TODO(justinmc): Add rotateEnabled parameter to the widget and remove this
//   // hardcoded value when the rotation feature is implemented.
//   // https://github.com/flutter/flutter/issues/57698
//   final bool _rotateEnabled = false;

//   // The _boundaryRect is calculated by adding the boundaryMargin to the size of
//   // the child.
//   Rect get _boundaryRect {
//     assert(_childKey.currentContext != null);
//     assert(!widget.boundaryMargin.left.isNaN);
//     assert(!widget.boundaryMargin.right.isNaN);
//     assert(!widget.boundaryMargin.top.isNaN);
//     assert(!widget.boundaryMargin.bottom.isNaN);

//     final RenderBox childRenderBox =
//         _childKey.currentContext!.findRenderObject()! as RenderBox;
//     final Size childSize = childRenderBox.size;
//     final Rect boundaryRect =
//         widget.boundaryMargin.inflateRect(Offset.zero & childSize);
//     assert(
//       !boundaryRect.isEmpty,
//       "InteractiveViewer's child must have nonzero dimensions.",
//     );
//     // Boundaries that are partially infinite are not allowed because Matrix4's
//     // rotation and translation methods don't handle infinites well.
//     assert(
//       boundaryRect.isFinite ||
//           (boundaryRect.left.isInfinite &&
//               boundaryRect.top.isInfinite &&
//               boundaryRect.right.isInfinite &&
//               boundaryRect.bottom.isInfinite),
//       'boundaryRect must either be infinite in all directions or finite in all directions.',
//     );
//     return boundaryRect;
//   }

//   // The Rect representing the child's parent.
//   Rect get _viewport {
//     assert(_parentKey.currentContext != null);
//     final RenderBox parentRenderBox =
//         _parentKey.currentContext!.findRenderObject()! as RenderBox;
//     return Offset.zero & parentRenderBox.size;
//   }

//   // Return a new matrix representing the given matrix after applying the given
//   // translation.
//   Matrix4 _matrixTranslate(Matrix4 matrix, Offset translation) {
//     if (translation == Offset.zero) {
//       return matrix.clone();
//     }

//     late final Offset alignedTranslation;

//     if (_currentAxis != null) {
//       switch (widget.panAxis) {
//         case PanAxis.horizontal:
//           alignedTranslation = _alignAxis(translation, Axis.horizontal);
//         case PanAxis.vertical:
//           alignedTranslation = _alignAxis(translation, Axis.vertical);
//         case PanAxis.aligned:
//           alignedTranslation = _alignAxis(translation, _currentAxis!);
//         case PanAxis.free:
//           alignedTranslation = translation;
//       }
//     } else {
//       alignedTranslation = translation;
//     }

//     final Matrix4 nextMatrix = matrix.clone()
//       ..translate(
//         alignedTranslation.dx,
//         alignedTranslation.dy,
//       );

//     // Transform the viewport to determine where its four corners will be after
//     // the child has been transformed.
//     final Quad nextViewport = _transformViewport(nextMatrix, _viewport);

//     // If the boundaries are infinite, then no need to check if the translation
//     // fits within them.
//     if (_boundaryRect.isInfinite) {
//       return nextMatrix;
//     }

//     // Expand the boundaries with rotation. This prevents the problem where a
//     // mismatch in orientation between the viewport and boundaries effectively
//     // limits translation. With this approach, all points that are visible with
//     // no rotation are visible after rotation.
//     final Quad boundariesAabbQuad = _getAxisAlignedBoundingBoxWithRotation(
//       _boundaryRect,
//       _currentRotation,
//     );

//     // If the given translation fits completely within the boundaries, allow it.
//     final Offset offendingDistance =
//         _exceedsBy(boundariesAabbQuad, nextViewport);
//     if (offendingDistance == Offset.zero) {
//       return nextMatrix;
//     }

//     // Desired translation goes out of bounds, so translate to the nearest
//     // in-bounds point instead.
//     final Offset nextTotalTranslation = _getMatrixTranslation(nextMatrix);
//     final double currentScale = matrix.getMaxScaleOnAxis();
//     final Offset correctedTotalTranslation = Offset(
//       nextTotalTranslation.dx - offendingDistance.dx * currentScale,
//       nextTotalTranslation.dy - offendingDistance.dy * currentScale,
//     );
//     // TODO(justinmc): This needs some work to handle rotation properly. The
//     // idea is that the boundaries are axis aligned (boundariesAabbQuad), but
//     // calculating the translation to put the viewport inside that Quad is more
//     // complicated than this when rotated.
//     // https://github.com/flutter/flutter/issues/57698
//     final Matrix4 correctedMatrix = matrix.clone()
//       ..setTranslation(Vector3(
//         correctedTotalTranslation.dx,
//         correctedTotalTranslation.dy,
//         0.0,
//       ));

//     // Double check that the corrected translation fits.
//     final Quad correctedViewport =
//         _transformViewport(correctedMatrix, _viewport);
//     final Offset offendingCorrectedDistance =
//         _exceedsBy(boundariesAabbQuad, correctedViewport);
//     if (offendingCorrectedDistance == Offset.zero) {
//       return correctedMatrix;
//     }

//     // If the corrected translation doesn't fit in either direction, don't allow
//     // any translation at all. This happens when the viewport is larger than the
//     // entire boundary.
//     if (offendingCorrectedDistance.dx != 0.0 &&
//         offendingCorrectedDistance.dy != 0.0) {
//       return matrix.clone();
//     }

//     // Otherwise, allow translation in only the direction that fits. This
//     // happens when the viewport is larger than the boundary in one direction.
//     final Offset unidirectionalCorrectedTotalTranslation = Offset(
//       offendingCorrectedDistance.dx == 0.0 ? correctedTotalTranslation.dx : 0.0,
//       offendingCorrectedDistance.dy == 0.0 ? correctedTotalTranslation.dy : 0.0,
//     );
//     return matrix.clone()
//       ..setTranslation(Vector3(
//         unidirectionalCorrectedTotalTranslation.dx,
//         unidirectionalCorrectedTotalTranslation.dy,
//         0.0,
//       ));
//   }

//   // Return a new matrix representing the given matrix after applying the given
//   // scale.
//   Matrix4 _matrixScale(Matrix4 matrix, double scale) {
//     if (scale == 1.0) {
//       return matrix.clone();
//     }
//     assert(scale != 0.0);

//     // Don't allow a scale that results in an overall scale beyond min/max
//     // scale.
//     final double currentScale =
//         _transformationController!.value.getMaxScaleOnAxis();
//     final double totalScale = math.max(
//       currentScale * scale,
//       // Ensure that the scale cannot make the child so big that it can't fit
//       // inside the boundaries (in either direction).
//       math.max(
//         _viewport.width / _boundaryRect.width,
//         _viewport.height / _boundaryRect.height,
//       ),
//     );
//     final double clampedTotalScale = clampDouble(
//       totalScale,
//       widget.minScale,
//       widget.maxScale,
//     );
//     final double clampedScale = clampedTotalScale / currentScale;
//     return matrix.clone()..scale(clampedScale);
//   }

//   // Return a new matrix representing the given matrix after applying the given
//   // rotation.
//   Matrix4 _matrixRotate(Matrix4 matrix, double rotation, Offset focalPoint) {
//     if (rotation == 0) {
//       return matrix.clone();
//     }
//     final Offset focalPointScene = _transformationController!.toScene(
//       focalPoint,
//     );
//     return matrix.clone()
//       ..translate(focalPointScene.dx, focalPointScene.dy)
//       ..rotateZ(-rotation)
//       ..translate(-focalPointScene.dx, -focalPointScene.dy);
//   }

//   // Returns true iff the given _GestureType is enabled.
//   bool _gestureIsSupported(_GestureType? gestureType) {
//     switch (gestureType) {
//       case _GestureType.rotate:
//         return _rotateEnabled;

//       case _GestureType.scale:
//         return widget.scaleEnabled;

//       case _GestureType.pan:
//       case null:
//         return widget.panEnabled;
//     }
//   }

//   // Decide which type of gesture this is by comparing the amount of scale
//   // and rotation in the gesture, if any. Scale starts at 1 and rotation
//   // starts at 0. Pan will have no scale and no rotation because it uses only one
//   // finger.
//   _GestureType _getGestureType(ScaleUpdateDetails details) {
//     final double scale = !widget.scaleEnabled ? 1.0 : details.scale;
//     final double rotation = !_rotateEnabled ? 0.0 : details.rotation;
//     if ((scale - 1).abs() > rotation.abs()) {
//       return _GestureType.scale;
//     } else if (rotation != 0.0) {
//       return _GestureType.rotate;
//     } else {
//       return _GestureType.pan;
//     }
//   }

//   // Handle the start of a gesture. All of pan, scale, and rotate are handled
//   // with GestureDetector's scale gesture.
//   void _onScaleStart(ScaleStartDetails details) {
//     widget.onInteractionStart?.call(details);

//     if (_controller.isAnimating) {
//       _controller.stop();
//       _controller.reset();
//       _animation?.removeListener(_onAnimate);
//       _animation = null;
//     }
//     if (_scaleController.isAnimating) {
//       _scaleController.stop();
//       _scaleController.reset();
//       _scaleAnimation?.removeListener(_onScaleAnimate);
//       _scaleAnimation = null;
//     }

//     _gestureType = null;
//     _currentAxis = null;
//     _scaleStart = _transformationController!.value.getMaxScaleOnAxis();
//     _referenceFocalPoint = _transformationController!.toScene(
//       details.localFocalPoint,
//     );
//     _rotationStart = _currentRotation;
//   }

//   // Handle an update to an ongoing gesture. All of pan, scale, and rotate are
//   // handled with GestureDetector's scale gesture.
//   void _onScaleUpdate(ScaleUpdateDetails details) {
//     final double scale = _transformationController!.value.getMaxScaleOnAxis();
//     _scaleAnimationFocalPoint = details.localFocalPoint;
//     final Offset focalPointScene = _transformationController!.toScene(
//       details.localFocalPoint,
//     );

//     if (_gestureType == _GestureType.pan) {
//       // When a gesture first starts, it sometimes has no change in scale and
//       // rotation despite being a two-finger gesture. Here the gesture is
//       // allowed to be reinterpreted as its correct type after originally
//       // being marked as a pan.
//       _gestureType = _getGestureType(details);
//     } else {
//       _gestureType ??= _getGestureType(details);
//     }
//     if (!_gestureIsSupported(_gestureType)) {
//       widget.onInteractionUpdate?.call(details);
//       return;
//     }

//     switch (_gestureType!) {
//       case _GestureType.scale:
//         assert(_scaleStart != null);
//         // details.scale gives us the amount to change the scale as of the
//         // start of this gesture, so calculate the amount to scale as of the
//         // previous call to _onScaleUpdate.
//         final double desiredScale = _scaleStart! * details.scale;
//         final double scaleChange = desiredScale / scale;
//         _transformationController!.value = _matrixScale(
//           _transformationController!.value,
//           scaleChange,
//         );

//         // While scaling, translate such that the user's two fingers stay on
//         // the same places in the scene. That means that the focal point of
//         // the scale should be on the same place in the scene before and after
//         // the scale.
//         final Offset focalPointSceneScaled = _transformationController!.toScene(
//           details.localFocalPoint,
//         );
//         _transformationController!.value = _matrixTranslate(
//           _transformationController!.value,
//           focalPointSceneScaled - _referenceFocalPoint!,
//         );

//         // details.localFocalPoint should now be at the same location as the
//         // original _referenceFocalPoint point. If it's not, that's because
//         // the translate came in contact with a boundary. In that case, update
//         // _referenceFocalPoint so subsequent updates happen in relation to
//         // the new effective focal point.
//         final Offset focalPointSceneCheck = _transformationController!.toScene(
//           details.localFocalPoint,
//         );
//         if (_round(_referenceFocalPoint!) != _round(focalPointSceneCheck)) {
//           _referenceFocalPoint = focalPointSceneCheck;
//         }

//       case _GestureType.rotate:
//         if (details.rotation == 0.0) {
//           widget.onInteractionUpdate?.call(details);
//           return;
//         }
//         final double desiredRotation = _rotationStart! + details.rotation;
//         _transformationController!.value = _matrixRotate(
//           _transformationController!.value,
//           _currentRotation - desiredRotation,
//           details.localFocalPoint,
//         );
//         _currentRotation = desiredRotation;

//       case _GestureType.pan:
//         assert(_referenceFocalPoint != null);
//         // details may have a change in scale here when scaleEnabled is false.
//         // In an effort to keep the behavior similar whether or not scaleEnabled
//         // is true, these gestures are thrown away.
//         if (details.scale != 1.0) {
//           widget.onInteractionUpdate?.call(details);
//           return;
//         }
//         _currentAxis ??= _getPanAxis(_referenceFocalPoint!, focalPointScene);
//         // Translate so that the same point in the scene is underneath the
//         // focal point before and after the movement.
//         final Offset translationChange =
//             focalPointScene - _referenceFocalPoint!;
//         _transformationController!.value = _matrixTranslate(
//           _transformationController!.value,
//           translationChange,
//         );
//         _referenceFocalPoint = _transformationController!.toScene(
//           details.localFocalPoint,
//         );
//     }
//     widget.onInteractionUpdate?.call(details);
//   }

//   // Handle the end of a gesture of _GestureType. All of pan, scale, and rotate
//   // are handled with GestureDetector's scale gesture.
//   void _onScaleEnd(ScaleEndDetails details) {
//     widget.onInteractionEnd?.call(details);
//     _scaleStart = null;
//     _rotationStart = null;
//     _referenceFocalPoint = null;

//     _animation?.removeListener(_onAnimate);
//     _scaleAnimation?.removeListener(_onScaleAnimate);
//     _controller.reset();
//     _scaleController.reset();

//     if (!_gestureIsSupported(_gestureType)) {
//       _currentAxis = null;
//       return;
//     }

//     if (_gestureType == _GestureType.pan) {
//       if (details.velocity.pixelsPerSecond.distance < kMinFlingVelocity) {
//         _currentAxis = null;
//         return;
//       }
//       final Vector3 translationVector =
//           _transformationController!.value.getTranslation();
//       final Offset translation =
//           Offset(translationVector.x, translationVector.y);
//       final FrictionSimulation frictionSimulationX = FrictionSimulation(
//         widget.interactionEndFrictionCoefficient,
//         translation.dx,
//         details.velocity.pixelsPerSecond.dx,
//       );
//       final FrictionSimulation frictionSimulationY = FrictionSimulation(
//         widget.interactionEndFrictionCoefficient,
//         translation.dy,
//         details.velocity.pixelsPerSecond.dy,
//       );
//       final double tFinal = _getFinalTime(
//         details.velocity.pixelsPerSecond.distance,
//         widget.interactionEndFrictionCoefficient,
//       );
//       _animation = Tween<Offset>(
//         begin: translation,
//         end: Offset(frictionSimulationX.finalX, frictionSimulationY.finalX),
//       ).animate(CurvedAnimation(
//         parent: _controller,
//         curve: Curves.decelerate,
//       ));
//       _controller.duration = Duration(milliseconds: (tFinal * 1000).round());
//       _animation!.addListener(_onAnimate);
//       _controller.forward();
//     } else if (_gestureType == _GestureType.scale) {
//       if (details.scaleVelocity.abs() < 0.1) {
//         _currentAxis = null;
//         return;
//       }
//       final double scale = _transformationController!.value.getMaxScaleOnAxis();
//       final FrictionSimulation frictionSimulation = FrictionSimulation(
//           widget.interactionEndFrictionCoefficient * widget.scaleFactor,
//           scale,
//           details.scaleVelocity / 10);
//       final double tFinal = _getFinalTime(
//           details.scaleVelocity.abs(), widget.interactionEndFrictionCoefficient,
//           effectivelyMotionless: 0.1);
//       _scaleAnimation =
//           Tween<double>(begin: scale, end: frictionSimulation.x(tFinal))
//               .animate(CurvedAnimation(
//                   parent: _scaleController, curve: Curves.decelerate));
//       _scaleController.duration =
//           Duration(milliseconds: (tFinal * 1000).round());
//       _scaleAnimation!.addListener(_onScaleAnimate);
//       _scaleController.forward();
//     }
//   }

//   // Handle mousewheel and web trackpad scroll events.
//   void _receivedPointerSignal(PointerSignalEvent event) {
//     final double scaleChange;
//     // Check if the event is a scroll event and the left mouse button is pressed.
//     if (event is PointerScrollEvent && _isLeftMouseButtonPressed) {
//       // Perform zooming here when the left mouse button is pressed and the user scrolls.
//       final double scaleChange =
//           1 + event.scrollDelta.dy / 1000; // Example scale factor calculation.
//       final Offset focalPointScene =
//           _transformationController!.toScene(event.localPosition);

//       _transformationController!.value = _matrixScale(
//         _transformationController!.value,
//         scaleChange,
//       );

//       // Adjust the translation so the focal point stays under the mouse cursor.
//       final Offset focalPointSceneScaled =
//           _transformationController!.toScene(event.localPosition);
//       _transformationController!.value = _matrixTranslate(
//         _transformationController!.value,
//         focalPointSceneScaled - focalPointScene,
//       );

//       // Optionally, invoke callback methods here.
//     }
//     if (event is PointerScrollEvent) {
//       // Allow both vertical and horizontal scrolling
//       if (event.scrollDelta.dy == 0.0 && event.scrollDelta.dx == 0.0) {
//         return;
//       }

//       // Allow panning when scrolling
//       final Offset localDelta = PointerEvent.transformDeltaViaPositions(
//         untransformedEndPosition: event.position + event.scrollDelta,
//         untransformedDelta: event.scrollDelta,
//         transform: event.transform,
//       );

//       _transformationController!.value = _matrixTranslate(
//         _transformationController!.value,
//         -localDelta,
//       );

//       widget.onInteractionUpdate?.call(ScaleUpdateDetails(
//         focalPoint: event.position - event.scrollDelta,
//         localFocalPoint: event.localPosition - localDelta,
//         focalPointDelta: -localDelta,
//       ));
//       widget.onInteractionEnd?.call(ScaleEndDetails());
//       return;
//     } else if (event is PointerScaleEvent) {
//       scaleChange = event.scale;
//     } else {
//       return;
//     }
//     widget.onInteractionStart?.call(
//       ScaleStartDetails(
//         focalPoint: event.position,
//         localFocalPoint: event.localPosition,
//       ),
//     );

//     if (!_gestureIsSupported(_GestureType.scale)) {
//       widget.onInteractionUpdate?.call(ScaleUpdateDetails(
//         focalPoint: event.position,
//         localFocalPoint: event.localPosition,
//         scale: scaleChange,
//       ));
//       widget.onInteractionEnd?.call(ScaleEndDetails());
//       return;
//     }

//     final Offset focalPointScene = _transformationController!.toScene(
//       event.localPosition,
//     );

//     _transformationController!.value = _matrixScale(
//       _transformationController!.value,
//       scaleChange,
//     );

//     // After scaling, translate such that the event's position is at the
//     // same scene point before and after the scale.
//     final Offset focalPointSceneScaled = _transformationController!.toScene(
//       event.localPosition,
//     );
//     _transformationController!.value = _matrixTranslate(
//       _transformationController!.value,
//       focalPointSceneScaled - focalPointScene,
//     );

//     widget.onInteractionUpdate?.call(ScaleUpdateDetails(
//       focalPoint: event.position,
//       localFocalPoint: event.localPosition,
//       scale: scaleChange,
//     ));
//     widget.onInteractionEnd?.call(ScaleEndDetails());
//   }

//   // void _receivedPointerSignal(PointerSignalEvent event) {
//   //   final double scaleChange;
//   //   if (event is PointerScrollEvent) {
//   //     if (event.kind == PointerDeviceKind.trackpad &&
//   //         !widget.trackpadScrollCausesScale) {
//   //       // Trackpad scroll, so treat it as a pan.
//   //       widget.onInteractionStart?.call(
//   //         ScaleStartDetails(
//   //           focalPoint: event.position,
//   //           localFocalPoint: event.localPosition,
//   //         ),
//   //       );

//   //       final Offset localDelta = PointerEvent.transformDeltaViaPositions(
//   //         untransformedEndPosition: event.position + event.scrollDelta,
//   //         untransformedDelta: event.scrollDelta,
//   //         transform: event.transform,
//   //       );

//   //       if (!_gestureIsSupported(_GestureType.pan)) {
//   //         widget.onInteractionUpdate?.call(ScaleUpdateDetails(
//   //           focalPoint: event.position - event.scrollDelta,
//   //           localFocalPoint: event.localPosition - event.scrollDelta,
//   //           focalPointDelta: -localDelta,
//   //         ));
//   //         widget.onInteractionEnd?.call(ScaleEndDetails());
//   //         return;
//   //       }

//   //       final Offset focalPointScene = _transformationController!.toScene(
//   //         event.localPosition,
//   //       );

//   //       final Offset newFocalPointScene = _transformationController!.toScene(
//   //         event.localPosition - localDelta,
//   //       );

//   //       _transformationController!.value = _matrixTranslate(
//   //           _transformationController!.value,
//   //           newFocalPointScene - focalPointScene);

//   //       widget.onInteractionUpdate?.call(ScaleUpdateDetails(
//   //           focalPoint: event.position - event.scrollDelta,
//   //           localFocalPoint: event.localPosition - localDelta,
//   //           focalPointDelta: -localDelta));
//   //       widget.onInteractionEnd?.call(ScaleEndDetails());
//   //       return;
//   //     }
//   //     // Ignore left and right mouse wheel scroll.
//   //     if (event.scrollDelta.dy == 0.0) {
//   //       return;
//   //     }
//   //     scaleChange = math.exp(-event.scrollDelta.dy / widget.scaleFactor);
//   //   } else if (event is PointerScaleEvent) {
//   //     scaleChange = event.scale;
//   //   } else {
//   //     return;
//   //   }
//   //   widget.onInteractionStart?.call(
//   //     ScaleStartDetails(
//   //       focalPoint: event.position,
//   //       localFocalPoint: event.localPosition,
//   //     ),
//   //   );

//   //   if (!_gestureIsSupported(_GestureType.scale)) {
//   //     widget.onInteractionUpdate?.call(ScaleUpdateDetails(
//   //       focalPoint: event.position,
//   //       localFocalPoint: event.localPosition,
//   //       scale: scaleChange,
//   //     ));
//   //     widget.onInteractionEnd?.call(ScaleEndDetails());
//   //     return;
//   //   }

//   //   final Offset focalPointScene = _transformationController!.toScene(
//   //     event.localPosition,
//   //   );

//   //   _transformationController!.value = _matrixScale(
//   //     _transformationController!.value,
//   //     scaleChange,
//   //   );

//   //   // After scaling, translate such that the event's position is at the
//   //   // same scene point before and after the scale.
//   //   final Offset focalPointSceneScaled = _transformationController!.toScene(
//   //     event.localPosition,
//   //   );
//   //   _transformationController!.value = _matrixTranslate(
//   //     _transformationController!.value,
//   //     focalPointSceneScaled - focalPointScene,
//   //   );

//   //   widget.onInteractionUpdate?.call(ScaleUpdateDetails(
//   //     focalPoint: event.position,
//   //     localFocalPoint: event.localPosition,
//   //     scale: scaleChange,
//   //   ));
//   //   widget.onInteractionEnd?.call(ScaleEndDetails());
//   // }

//   // Handle inertia drag animation.
//   void _onAnimate() {
//     if (!_controller.isAnimating) {
//       _currentAxis = null;
//       _animation?.removeListener(_onAnimate);
//       _animation = null;
//       _controller.reset();
//       return;
//     }
//     // Translate such that the resulting translation is _animation.value.
//     final Vector3 translationVector =
//         _transformationController!.value.getTranslation();
//     final Offset translation = Offset(translationVector.x, translationVector.y);
//     final Offset translationScene = _transformationController!.toScene(
//       translation,
//     );
//     final Offset animationScene = _transformationController!.toScene(
//       _animation!.value,
//     );
//     final Offset translationChangeScene = animationScene - translationScene;
//     _transformationController!.value = _matrixTranslate(
//       _transformationController!.value,
//       translationChangeScene,
//     );
//   }

//   // Handle inertia scale animation.
//   void _onScaleAnimate() {
//     if (!_scaleController.isAnimating) {
//       _currentAxis = null;
//       _scaleAnimation?.removeListener(_onScaleAnimate);
//       _scaleAnimation = null;
//       _scaleController.reset();
//       return;
//     }
//     final double desiredScale = _scaleAnimation!.value;
//     final double scaleChange =
//         desiredScale / _transformationController!.value.getMaxScaleOnAxis();
//     final Offset referenceFocalPoint = _transformationController!.toScene(
//       _scaleAnimationFocalPoint,
//     );
//     _transformationController!.value = _matrixScale(
//       _transformationController!.value,
//       scaleChange,
//     );

//     // While scaling, translate such that the user's two fingers stay on
//     // the same places in the scene. That means that the focal point of
//     // the scale should be on the same place in the scene before and after
//     // the scale.
//     final Offset focalPointSceneScaled = _transformationController!.toScene(
//       _scaleAnimationFocalPoint,
//     );
//     _transformationController!.value = _matrixTranslate(
//       _transformationController!.value,
//       focalPointSceneScaled - referenceFocalPoint,
//     );
//   }

//   void _onTransformationControllerChange() {
//     // A change to the TransformationController's value is a change to the
//     // state.
//     setState(() {});
//   }

//   @override
//   void initState() {
//     super.initState();

//     _transformationController =
//         widget.transformationController ?? TransformationController();
//     _transformationController!.addListener(_onTransformationControllerChange);
//     _controller = AnimationController(
//       vsync: this,
//     );
//     _scaleController = AnimationController(vsync: this);
//   }

//   @override
//   void didUpdateWidget(Zoomable oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     // Handle all cases of needing to dispose and initialize
//     // transformationControllers.
//     if (oldWidget.transformationController == null) {
//       if (widget.transformationController != null) {
//         _transformationController!
//             .removeListener(_onTransformationControllerChange);
//         _transformationController!.dispose();
//         _transformationController = widget.transformationController;
//         _transformationController!
//             .addListener(_onTransformationControllerChange);
//       }
//     } else {
//       if (widget.transformationController == null) {
//         _transformationController!
//             .removeListener(_onTransformationControllerChange);
//         _transformationController = TransformationController();
//         _transformationController!
//             .addListener(_onTransformationControllerChange);
//       } else if (widget.transformationController !=
//           oldWidget.transformationController) {
//         _transformationController!
//             .removeListener(_onTransformationControllerChange);
//         _transformationController = widget.transformationController;
//         _transformationController!
//             .addListener(_onTransformationControllerChange);
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _scaleController.dispose();
//     _transformationController!
//         .removeListener(_onTransformationControllerChange);
//     if (widget.transformationController == null) {
//       _transformationController!.dispose();
//     }
//     super.dispose();
//   }

//   bool _isLeftMouseButtonPressed = false;

//   @override
//   Widget build(BuildContext context) {
//     Widget child;
//     if (widget.child != null) {
//       child = _InteractiveViewerBuilt(
//         childKey: _childKey,
//         clipBehavior: widget.clipBehavior,
//         constrained: widget.constrained,
//         matrix: _transformationController!.value,
//         alignment: widget.alignment,
//         child: widget.child!,
//       );
//     } else {
//       // When using InteractiveViewer.builder, then constrained is false and the
//       // viewport is the size of the constraints.
//       assert(widget.builder != null);
//       assert(!widget.constrained);
//       child = LayoutBuilder(
//         builder: (BuildContext context, BoxConstraints constraints) {
//           final Matrix4 matrix = _transformationController!.value;
//           return _InteractiveViewerBuilt(
//             childKey: _childKey,
//             clipBehavior: widget.clipBehavior,
//             constrained: widget.constrained,
//             alignment: widget.alignment,
//             matrix: matrix,
//             child: widget.builder!(
//               context,
//               _transformViewport(matrix, Offset.zero & constraints.biggest),
//             ),
//           );
//         },
//       );
//     }

//     return Listener(
//       key: _parentKey,
//       onPointerDown: (PointerDownEvent event) {
//         if (event.kind == PointerDeviceKind.mouse &&
//             event.buttons == kPrimaryMouseButton) {
//           setState(() {
//             _isLeftMouseButtonPressed = true;
//           });
//         }
//       },
//       onPointerUp: (PointerUpEvent event) {
//         // Reset without checking event.buttons here.
//         if (event.kind == PointerDeviceKind.mouse) {
//           setState(() {
//             _isLeftMouseButtonPressed = false;
//           });
//         }
//       },
//       onPointerSignal: _receivedPointerSignal,
//       child: GestureDetector(
//         behavior: HitTestBehavior.opaque, // Necessary when panning off screen.
//         onScaleEnd: _onScaleEnd,
//         onScaleStart: _onScaleStart,
//         onScaleUpdate: _onScaleUpdate,
//         trackpadScrollCausesScale: widget.trackpadScrollCausesScale,
//         trackpadScrollToScaleFactor: Offset(0, -1 / widget.scaleFactor),
//         child: child,
//       ),
//     );
//   }
// }

// // This widget allows us to easily swap in and out the LayoutBuilder in
// // InteractiveViewer's depending on if it's using a builder or a child.
// class _InteractiveViewerBuilt extends StatelessWidget {
//   const _InteractiveViewerBuilt({
//     required this.child,
//     required this.childKey,
//     required this.clipBehavior,
//     required this.constrained,
//     required this.matrix,
//     required this.alignment,
//   });

//   final Widget child;
//   final GlobalKey childKey;
//   final Clip clipBehavior;
//   final bool constrained;
//   final Matrix4 matrix;
//   final Alignment? alignment;

//   @override
//   Widget build(BuildContext context) {
//     Widget child = Transform(
//       transform: matrix,
//       alignment: alignment,
//       child: KeyedSubtree(
//         key: childKey,
//         child: this.child,
//       ),
//     );

//     if (!constrained) {
//       child = OverflowBox(
//         alignment: Alignment.topLeft,
//         minWidth: 0.0,
//         minHeight: 0.0,
//         maxWidth: double.infinity,
//         maxHeight: double.infinity,
//         child: child,
//       );
//     }

//     return ClipRect(
//       clipBehavior: clipBehavior,
//       child: child,
//     );
//   }
// }

// /// A thin wrapper on [ValueNotifier] whose value is a [Matrix4] representing a
// /// transformation.
// ///
// /// The [value] defaults to the identity matrix, which corresponds to no
// /// transformation.
// ///
// /// See also:
// ///
// ///  * [Zoomable.transformationController] for detailed documentation
// ///    on how to use TransformationController with [Zoomable].
// class TransformationController extends ValueNotifier<Matrix4> {
//   /// Create an instance of [TransformationController].
//   ///
//   /// The [value] defaults to the identity matrix, which corresponds to no
//   /// transformation.
//   TransformationController([Matrix4? value])
//       : super(value ?? Matrix4.identity());

//   /// Return the scene point at the given viewport point.
//   ///
//   /// A viewport point is relative to the parent while a scene point is relative
//   /// to the child, regardless of transformation. Calling toScene with a
//   /// viewport point essentially returns the scene coordinate that lies
//   /// underneath the viewport point given the transform.
//   ///
//   /// The viewport transforms as the inverse of the child (i.e. moving the child
//   /// left is equivalent to moving the viewport right).
//   ///
//   /// This method is often useful when determining where an event on the parent
//   /// occurs on the child. This example shows how to determine where a tap on
//   /// the parent occurred on the child.
//   ///
//   /// ```dart
//   /// @override
//   /// Widget build(BuildContext context) {
//   ///   return GestureDetector(
//   ///     onTapUp: (TapUpDetails details) {
//   ///       _childWasTappedAt = _transformationController.toScene(
//   ///         details.localPosition,
//   ///       );
//   ///     },
//   ///     child: InteractiveViewer(
//   ///       transformationController: _transformationController,
//   ///       child: child,
//   ///     ),
//   ///   );
//   /// }
//   /// ```
//   Offset toScene(Offset viewportPoint) {
//     // On viewportPoint, perform the inverse transformation of the scene to get
//     // where the point would be in the scene before the transformation.
//     final Matrix4 inverseMatrix = Matrix4.inverted(value);
//     final Vector3 untransformed = inverseMatrix.transform3(Vector3(
//       viewportPoint.dx,
//       viewportPoint.dy,
//       0,
//     ));
//     return Offset(untransformed.x, untransformed.y);
//   }
// }

// // A classification of relevant user gestures. Each contiguous user gesture is
// // represented by exactly one _GestureType.
// enum _GestureType {
//   pan,
//   scale,
//   rotate,
// }

// // Given a velocity and drag, calculate the time at which motion will come to
// // a stop, within the margin of effectivelyMotionless.
// double _getFinalTime(double velocity, double drag,
//     {double effectivelyMotionless = 10}) {
//   return math.log(effectivelyMotionless / velocity) / math.log(drag / 100);
// }

// // Return the translation from the given Matrix4 as an Offset.
// Offset _getMatrixTranslation(Matrix4 matrix) {
//   final Vector3 nextTranslation = matrix.getTranslation();
//   return Offset(nextTranslation.x, nextTranslation.y);
// }

// // Transform the four corners of the viewport by the inverse of the given
// // matrix. This gives the viewport after the child has been transformed by the
// // given matrix. The viewport transforms as the inverse of the child (i.e.
// // moving the child left is equivalent to moving the viewport right).
// Quad _transformViewport(Matrix4 matrix, Rect viewport) {
//   final Matrix4 inverseMatrix = matrix.clone()..invert();
//   return Quad.points(
//     inverseMatrix.transform3(Vector3(
//       viewport.topLeft.dx,
//       viewport.topLeft.dy,
//       0.0,
//     )),
//     inverseMatrix.transform3(Vector3(
//       viewport.topRight.dx,
//       viewport.topRight.dy,
//       0.0,
//     )),
//     inverseMatrix.transform3(Vector3(
//       viewport.bottomRight.dx,
//       viewport.bottomRight.dy,
//       0.0,
//     )),
//     inverseMatrix.transform3(Vector3(
//       viewport.bottomLeft.dx,
//       viewport.bottomLeft.dy,
//       0.0,
//     )),
//   );
// }

// // Find the axis aligned bounding box for the rect rotated about its center by
// // the given amount.
// Quad _getAxisAlignedBoundingBoxWithRotation(Rect rect, double rotation) {
//   final Matrix4 rotationMatrix = Matrix4.identity()
//     ..translate(rect.size.width / 2, rect.size.height / 2)
//     ..rotateZ(rotation)
//     ..translate(-rect.size.width / 2, -rect.size.height / 2);
//   final Quad boundariesRotated = Quad.points(
//     rotationMatrix.transform3(Vector3(rect.left, rect.top, 0.0)),
//     rotationMatrix.transform3(Vector3(rect.right, rect.top, 0.0)),
//     rotationMatrix.transform3(Vector3(rect.right, rect.bottom, 0.0)),
//     rotationMatrix.transform3(Vector3(rect.left, rect.bottom, 0.0)),
//   );
//   return Zoomable.getAxisAlignedBoundingBox(boundariesRotated);
// }

// // Return the amount that viewport lies outside of boundary. If the viewport
// // is completely contained within the boundary (inclusively), then returns
// // Offset.zero.
// Offset _exceedsBy(Quad boundary, Quad viewport) {
//   final List<Vector3> viewportPoints = <Vector3>[
//     viewport.point0,
//     viewport.point1,
//     viewport.point2,
//     viewport.point3,
//   ];
//   Offset largestExcess = Offset.zero;
//   for (final Vector3 point in viewportPoints) {
//     final Vector3 pointInside = Zoomable.getNearestPointInside(point, boundary);
//     final Offset excess = Offset(
//       pointInside.x - point.x,
//       pointInside.y - point.y,
//     );
//     if (excess.dx.abs() > largestExcess.dx.abs()) {
//       largestExcess = Offset(excess.dx, largestExcess.dy);
//     }
//     if (excess.dy.abs() > largestExcess.dy.abs()) {
//       largestExcess = Offset(largestExcess.dx, excess.dy);
//     }
//   }

//   return _round(largestExcess);
// }

// // Round the output values. This works around a precision problem where
// // values that should have been zero were given as within 10^-10 of zero.
// Offset _round(Offset offset) {
//   return Offset(
//     double.parse(offset.dx.toStringAsFixed(9)),
//     double.parse(offset.dy.toStringAsFixed(9)),
//   );
// }

// // Align the given offset to the given axis by allowing movement only in the
// // axis direction.
// Offset _alignAxis(Offset offset, Axis axis) {
//   switch (axis) {
//     case Axis.horizontal:
//       return Offset(offset.dx, 0.0);
//     case Axis.vertical:
//       return Offset(0.0, offset.dy);
//   }
// }

// // Given two points, return the axis where the distance between the points is
// // greatest. If they are equal, return null.
// Axis? _getPanAxis(Offset point1, Offset point2) {
//   if (point1 == point2) {
//     return null;
//   }
//   final double x = point2.dx - point1.dx;
//   final double y = point2.dy - point1.dy;
//   return x.abs() > y.abs() ? Axis.horizontal : Axis.vertical;
// }

// /// This enum is used to specify the behavior of the [Zoomable] when
// /// the user drags the viewport.
// enum PanAxis {
//   /// The user can only pan the viewport along the horizontal axis.
//   horizontal,

//   /// The user can only pan the viewport along the vertical axis.
//   vertical,

//   /// The user can pan the viewport along the horizontal and vertical axes
//   /// but not diagonally.
//   aligned,

//   /// The user can pan the viewport freely in any direction.
//   free,
// }
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' show Quad, Vector3, Matrix4;

typedef ZoomWidgetBuilder = Widget Function(
    BuildContext context, Quad viewport);

@immutable
class Zoom extends StatefulWidget {
  Zoom({
    this.backgroundColor = Colors.grey,
    this.canvasColor = Colors.white,
    this.centerOnScale = true,
    required this.child,
    this.colorScrollBars = Colors.black12,
    this.doubleTapAnimDuration = const Duration(milliseconds: 300),
    this.doubleTapScaleChange = 1.1,
    this.doubleTapZoom = true,
    this.enableScroll = true,
    this.initPosition,
    this.initScale,
    this.initTotalZoomOut = false,
    Key? key,
    this.maxScale = 2.5,
    this.maxZoomHeight,
    this.maxZoomWidth,
    this.onPositionUpdate,
    this.onScaleUpdate,
    this.onPanUpPosition,
    this.onMinZoom,
    this.onTap,
    this.opacityScrollBars = 0.5,
    this.radiusScrollBars = 4,
    this.scrollWeight = 10,
    this.transformationController,
    this.zoomSensibility = 1.0,
  })  : assert(maxScale > 0),
        assert(!maxScale.isNaN),
        super(key: key);

  final Color backgroundColor;
  final Color canvasColor;
  final bool centerOnScale;
  final Widget child;
  final Color colorScrollBars;
  final Duration doubleTapAnimDuration;
  final double doubleTapScaleChange;
  final bool doubleTapZoom;
  final bool enableScroll;
  final Offset? initPosition;
  final double? initScale;
  final bool initTotalZoomOut;
  final double maxScale;
  final double? maxZoomHeight;
  final double? maxZoomWidth;
  final Function(Offset)? onPositionUpdate;
  final Function(double, double)? onScaleUpdate;
  final Function(Offset)? onPanUpPosition;
  final Function(bool)? onMinZoom;
  final Function()? onTap;
  final double opacityScrollBars;
  final double radiusScrollBars;
  final double scrollWeight;
  final TransformationController? transformationController;
  final double zoomSensibility;

  static Vector3 getNearestPointOnLine(Vector3 point, Vector3 l1, Vector3 l2) {
    final double lengthSquared = math.pow(l2.x - l1.x, 2.0).toDouble() +
        math.pow(l2.y - l1.y, 2.0).toDouble();

    if (lengthSquared == 0) {
      return l1;
    }

    final Vector3 l1P = point - l1;
    final Vector3 l1L2 = l2 - l1;
    final double fraction = (l1P.dot(l1L2) / lengthSquared).clamp(0.0, 1.0);
    return l1 + l1L2 * fraction;
  }

  static Quad getAxisAlignedBoundingBox(Quad quad) {
    final double minX = math.min(
      quad.point0.x,
      math.min(
        quad.point1.x,
        math.min(
          quad.point2.x,
          quad.point3.x,
        ),
      ),
    );
    final double minY = math.min(
      quad.point0.y,
      math.min(
        quad.point1.y,
        math.min(
          quad.point2.y,
          quad.point3.y,
        ),
      ),
    );
    final double maxX = math.max(
      quad.point0.x,
      math.max(
        quad.point1.x,
        math.max(
          quad.point2.x,
          quad.point3.x,
        ),
      ),
    );
    final double maxY = math.max(
      quad.point0.y,
      math.max(
        quad.point1.y,
        math.max(
          quad.point2.y,
          quad.point3.y,
        ),
      ),
    );
    return Quad.points(
      Vector3(minX, minY, 0),
      Vector3(maxX, minY, 0),
      Vector3(maxX, maxY, 0),
      Vector3(minX, maxY, 0),
    );
  }

  static bool pointIsInside(Vector3 point, Quad quad) {
    final Vector3 aM = point - quad.point0;
    final Vector3 aB = quad.point1 - quad.point0;
    final Vector3 aD = quad.point3 - quad.point0;

    final double aMAB = aM.dot(aB);
    final double aBAB = aB.dot(aB);
    final double aMAD = aM.dot(aD);
    final double aDAD = aD.dot(aD);

    return 0 <= aMAB && aMAB <= aBAB && 0 <= aMAD && aMAD <= aDAD;
  }

  static Vector3 getNearestPointInside(Vector3 point, Quad quad) {
    if (pointIsInside(point, quad)) {
      return point;
    }

    final List<Vector3> closestPoints = <Vector3>[
      Zoom.getNearestPointOnLine(point, quad.point0, quad.point1),
      Zoom.getNearestPointOnLine(point, quad.point1, quad.point2),
      Zoom.getNearestPointOnLine(point, quad.point2, quad.point3),
      Zoom.getNearestPointOnLine(point, quad.point3, quad.point0),
    ];
    double minDistance = double.infinity;
    late Vector3 closestOverall;
    for (final Vector3 closePoint in closestPoints) {
      final double distance = math.sqrt(
        math.pow(point.x - closePoint.x, 2) +
            math.pow(point.y - closePoint.y, 2),
      );
      if (distance < minDistance) {
        minDistance = distance;
        closestOverall = closePoint;
      }
    }
    return closestOverall;
  }

  @override
  State<Zoom> createState() => _ZoomState();
}

class _ZoomState extends State<Zoom>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  TransformationController? _transformationController;

  final GlobalKey _childKey = GlobalKey();
  final GlobalKey _parentKey = GlobalKey();
  Animation<Offset>? _animation;
  late AnimationController _controller;
  Animation<double>? _scaleAnimation;
  late AnimationController _scaleController;
  Axis? _panAxis;
  Offset? _referenceFocalPoint;
  double? _scaleStart;
  _GestureType? _gestureType;
  ValueNotifier<_ScrollBarData> verticalScrollNotifier =
      ValueNotifier(_ScrollBarData(length: 0, position: 0));
  ValueNotifier<_ScrollBarData> horizontalScrollNotifier =
      ValueNotifier(_ScrollBarData(length: 0, position: 0));
  Size parentSize = Size.zero;
  Size childSize = Size.zero;
  Orientation? _orientation;
  Offset? _doubleTapFocalPoint;
  bool doubleTapZoomIn = true;
  bool firstDraw = true;

  static const double _kDrag = 0.0000135;

  bool _isAltPressed = false;

  Rect get _boundaryRect {
    assert(_childKey.currentContext != null);

    final Rect boundaryRect =
        EdgeInsets.zero.inflateRect(Offset.zero & childSize);
    assert(
      !boundaryRect.isEmpty,
      "Zoom's child must have nonzero dimensions.",
    );

    assert(
      boundaryRect.isFinite ||
          (boundaryRect.left.isInfinite &&
              boundaryRect.top.isInfinite &&
              boundaryRect.right.isInfinite &&
              boundaryRect.bottom.isInfinite),
      'boundaryRect must either be infinite in all directions or finite in all directions.',
    );
    return boundaryRect;
  }

  Rect get _viewport {
    assert(_parentKey.currentContext != null);
    final RenderBox parentRenderBox =
        _parentKey.currentContext!.findRenderObject()! as RenderBox;
    return Offset.zero & parentRenderBox.size;
  }

  double _getScrollPercent(Matrix4 matrix, {required _ScrollType scrollType}) {
    switch (scrollType) {
      case _ScrollType.horizontal:
        return _getMatrixTranslation(matrix).dx.abs() /
            ((childSize.width * matrix.getMaxScaleOnAxis()) -
                parentSize.width) *
            100.0;

      case _ScrollType.vertical:
        return _getMatrixTranslation(matrix).dy.abs() /
            ((childSize.height * matrix.getMaxScaleOnAxis()) -
                parentSize.height) *
            100.0;
    }
  }

  double _getScrollBarLength(Matrix4 matrix,
      {required _ScrollType scrollType}) {
    double percent = 0;
    switch (scrollType) {
      case _ScrollType.horizontal:
        percent =
            (parentSize.width / (childSize.width * matrix.getMaxScaleOnAxis()));
        return parentSize.width * percent;

      case _ScrollType.vertical:
        percent = (parentSize.height /
            (childSize.height * matrix.getMaxScaleOnAxis()));
        return parentSize.height * percent;
    }
  }

  void onDisabledScrolls() {
    if (horizontalScrollNotifier.value.length == 0 &&
        horizontalScrollNotifier.value.position == 0 &&
        verticalScrollNotifier.value.length == 0 &&
        verticalScrollNotifier.value.position == 0) {
      widget.onMinZoom?.call(true);
    } else {
      widget.onMinZoom?.call(false);
    }
  }

  void _updateScroll(Matrix4 matrix) {
    if (childSize.width * matrix.getMaxScaleOnAxis() >
        parentSize.width + (parentSize.width * 0.01)) {
      var horizontalPercent =
          _getScrollPercent(matrix, scrollType: _ScrollType.horizontal);

      final horizontalLength =
          _getScrollBarLength(matrix, scrollType: _ScrollType.horizontal);

      horizontalScrollNotifier.value = _ScrollBarData(
          length: horizontalLength,
          position: (horizontalPercent / 100.0) *
              (parentSize.width - horizontalLength));
    } else {
      horizontalScrollNotifier.value = _ScrollBarData(length: 0, position: 0);
      onDisabledScrolls();
    }

    if (childSize.height * matrix.getMaxScaleOnAxis() >
        parentSize.height + (parentSize.height * 0.01)) {
      final verticalPercent =
          _getScrollPercent(matrix, scrollType: _ScrollType.vertical);

      final verticalLength =
          _getScrollBarLength(matrix, scrollType: _ScrollType.vertical);

      verticalScrollNotifier.value = _ScrollBarData(
          length: verticalLength,
          position:
              (verticalPercent / 100) * (parentSize.height - verticalLength));
    } else {
      verticalScrollNotifier.value = _ScrollBarData(length: 0, position: 0);
      onDisabledScrolls();
    }
  }

  Matrix4 _matrixTranslate(Matrix4 matrix, Offset translation,
      {bool fixOffset = false}) {
    if (translation == Offset.zero) {
      return matrix.clone();
    }

    final Offset alignedTranslation = translation;

    final Matrix4 nextMatrix = matrix.clone()
      ..translate(
        alignedTranslation.dx,
        alignedTranslation.dy,
      );

    final Quad nextViewport = _transformViewport(nextMatrix, _viewport);

    if (_boundaryRect.isInfinite && !fixOffset) {
      _updateScroll(nextMatrix);
      widget.onPositionUpdate?.call(_getMatrixTranslation(nextMatrix));
      return nextMatrix;
    }

    final Quad boundariesAabbQuad = _getAxisAlignedBoundingBoxWithRotation(
      _boundaryRect,
      0.0,
    );

    final Offset offendingDistance =
        _exceedsBy(boundariesAabbQuad, nextViewport);
    if (offendingDistance == Offset.zero) {
      _updateScroll(nextMatrix);
      widget.onPositionUpdate?.call(_getMatrixTranslation(nextMatrix));
      return nextMatrix;
    }

    final Offset nextTotalTranslation = _getMatrixTranslation(nextMatrix);
    final double currentScale = matrix.getMaxScaleOnAxis();
    final Offset correctedTotalTranslation = Offset(
      nextTotalTranslation.dx - offendingDistance.dx * currentScale,
      nextTotalTranslation.dy - offendingDistance.dy * currentScale,
    );

    final Matrix4 correctedMatrix = matrix.clone()
      ..setTranslation(Vector3(
        correctedTotalTranslation.dx,
        correctedTotalTranslation.dy,
        0.0,
      ));

    final Quad correctedViewport =
        _transformViewport(correctedMatrix, _viewport);
    final Offset offendingCorrectedDistance =
        _exceedsBy(boundariesAabbQuad, correctedViewport);
    if (offendingCorrectedDistance == Offset.zero && !fixOffset) {
      _updateScroll(correctedMatrix);
      widget.onPositionUpdate?.call(_getMatrixTranslation(correctedMatrix));
      return correctedMatrix;
    }

    if (offendingCorrectedDistance.dx != 0.0 &&
        offendingCorrectedDistance.dy != 0.0 &&
        !fixOffset &&
        (childSize.width > parentSize.width ||
            childSize.height > parentSize.height)) {
      return matrix.clone();
    }

    final Offset unidirectionalCorrectedTotalTranslation = Offset(
      offendingCorrectedDistance.dx == 0.0 ? correctedTotalTranslation.dx : 0.0,
      offendingCorrectedDistance.dy == 0.0 ? correctedTotalTranslation.dy : 0.0,
    );
    final verticalMidLength =
        (parentSize.height - childSize.height * matrix.getMaxScaleOnAxis()) / 2;
    final horizontalMidLength =
        (parentSize.width - (childSize.width * matrix.getMaxScaleOnAxis())) / 2;

    double horizontalMid = 0;
    double verticalMid = 0;

    void calculateMids(bool sizeCondition) {
      if (sizeCondition) {
        verticalMid = verticalMidLength;
        if (childSize.width < parentSize.width) {
          horizontalMid = horizontalMidLength;
        }
      } else {
        horizontalMid = horizontalMidLength;
        if (childSize.height < parentSize.height) {
          verticalMid = verticalMidLength;
        }
      }
    }

    if (childSize.width == childSize.height) {
      calculateMids(parentSize.height > parentSize.width);
    } else {
      calculateMids(childSize.height < childSize.width);
    }

    final midMatrix = matrix.clone()
      ..setTranslation(Vector3(
        unidirectionalCorrectedTotalTranslation.dx +
            (widget.centerOnScale
                ? horizontalMid < 0
                    ? 0
                    : horizontalMid
                : 0),
        unidirectionalCorrectedTotalTranslation.dy +
            (widget.centerOnScale
                ? verticalMid < 0
                    ? 0
                    : verticalMid
                : 0),
        0.0,
      ));
    _updateScroll(midMatrix);
    widget.onPositionUpdate?.call(_getMatrixTranslation(midMatrix));
    return midMatrix;
  }

  Matrix4 _matrixScale(Matrix4 matrix, double scale, {bool fixScale = false}) {
    double sensibleScale = scale > 1.0
        ? 1.0 + ((scale - 1.0) * widget.zoomSensibility)
        : 1.0 - ((1.0 - scale) * widget.zoomSensibility);
    if (scale == 1.0) {
      return matrix.clone();
    }
    assert(scale != 0.0);

    final nextScale =
        (matrix.clone()..scale(sensibleScale)).getMaxScaleOnAxis();

    if (childSize.width == childSize.height) {
      if (parentSize.height > parentSize.width) {
        if ((childSize.width * nextScale) < parentSize.width &&
            nextScale < 1.0) {
          return matrix.clone();
        }
      } else {
        if ((childSize.height * nextScale) < parentSize.height &&
            nextScale < 1.0) {
          return matrix.clone();
        }
      }
    } else {
      if (childSize.height < childSize.width) {
        if ((childSize.width * nextScale) < parentSize.width &&
            nextScale < 1.0) {
          return matrix.clone();
        }
      } else {
        if ((childSize.height * nextScale) < parentSize.height &&
            nextScale < 1.0) {
          return matrix.clone();
        }
      }
    }

    if (matrix.getMaxScaleOnAxis() > widget.maxScale && sensibleScale > 1) {
      return matrix.clone();
    }
    final newMatrix = matrix.clone()
      ..scale(fixScale ? scale : sensibleScale.abs());

    widget.onScaleUpdate?.call(
      fixScale ? scale : sensibleScale.abs(),
      newMatrix.getMaxScaleOnAxis(),
    );

    return newMatrix;
  }

  bool _gestureIsSupported(_GestureType? gestureType) {
    switch (gestureType) {
      case _GestureType.scale:
        return true;

      case _GestureType.pan:
      case null:
        return true;
    }
  }

  _GestureType _getGestureType(ScaleUpdateDetails details) {
    final double scale = details.scale;
    if ((scale - 1).abs() != 0) {
      return _GestureType.scale;
    } else {
      return _GestureType.pan;
    }
  }

  void _onScaleStart(ScaleStartDetails details) {
    if (_controller.isAnimating) {
      _controller.stop();
      _controller.reset();
      _animation?.removeListener(_onAnimate);
      _animation = null;
    }

    _gestureType = null;
    _panAxis = null;
    _scaleStart = _transformationController!.value.getMaxScaleOnAxis();
    _referenceFocalPoint = _transformationController!.toScene(
      details.localFocalPoint,
    );
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final double scale = _transformationController!.value.getMaxScaleOnAxis();
    final Offset focalPointScene = _transformationController!.toScene(
      details.localFocalPoint,
    );

    if (_gestureType == _GestureType.pan) {
      _gestureType = _getGestureType(details);
    } else {
      _gestureType ??= _getGestureType(details);
    }

    switch (_gestureType!) {
      case _GestureType.scale:
        assert(_scaleStart != null);

        final double desiredScale = _scaleStart! * details.scale;
        final double scaleChange = desiredScale / scale;
        _transformationController!.value = _matrixScale(
          _transformationController!.value,
          scaleChange,
        );

        final Offset focalPointSceneScaled = _transformationController!.toScene(
          details.localFocalPoint,
        );

        _transformationController!.value = _matrixTranslate(
          _transformationController!.value,
          focalPointSceneScaled - _referenceFocalPoint!,
        );

        final Offset focalPointSceneCheck = _transformationController!.toScene(
          details.localFocalPoint,
        );
        if (_round(_referenceFocalPoint!) != _round(focalPointSceneCheck)) {
          _referenceFocalPoint = focalPointSceneCheck;
        }
        break;

      case _GestureType.pan:
        assert(_referenceFocalPoint != null);

        _panAxis ??= _getPanAxis(_referenceFocalPoint!, focalPointScene);

        final Offset translationChange =
            focalPointScene - _referenceFocalPoint!;
        _transformationController!.value = _matrixTranslate(
          _transformationController!.value,
          translationChange,
        );
        _referenceFocalPoint = _transformationController!.toScene(
          details.localFocalPoint,
        );
        break;
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    _scaleStart = null;

    _animation?.removeListener(_onAnimate);
    _controller.reset();

    if (!_gestureIsSupported(_gestureType)) {
      _panAxis = null;
      return;
    }

    if (_gestureType != _GestureType.pan ||
        details.velocity.pixelsPerSecond.distance < kMinFlingVelocity) {
      _panAxis = null;
      return;
    }

    final Vector3 translationVector =
        _transformationController!.value.getTranslation();
    final Offset translation = Offset(translationVector.x, translationVector.y);
    final FrictionSimulation frictionSimulationX = FrictionSimulation(
      _kDrag,
      translation.dx,
      details.velocity.pixelsPerSecond.dx,
    );
    final FrictionSimulation frictionSimulationY = FrictionSimulation(
      _kDrag,
      translation.dy,
      details.velocity.pixelsPerSecond.dy,
    );
    final double tFinal = _getFinalTime(
      details.velocity.pixelsPerSecond.distance,
      _kDrag,
    );
    _animation = Tween<Offset>(
      begin: translation,
      end: Offset(frictionSimulationX.finalX, frictionSimulationY.finalX),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.decelerate,
    ));
    _controller.duration = Duration(milliseconds: (tFinal * 1000).round());
    _animation!.addListener(_onAnimate);
    _controller.forward();
  }

  void _receivedPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      if (true
        // _isAltPressed
        ) {
        // Alt key is pressed, perform zoom
        double scaleChange = event.scrollDelta.dy > 0 ? 0.9 : 1.1;
        _transformationController!.value = _matrixScale(
          _transformationController!.value,
          scaleChange,
        );
      } else {
        // Alt key is not pressed, pass the scroll event to child
        // This can be handled by doing nothing, letting the scroll propagate
      }
    }
  }

  void _onDoubleTap() {
    if (!_scaleController.isAnimating && widget.doubleTapZoom) {
      doubleTapZoomIn = _transformationController!.value.getMaxScaleOnAxis() <
          widget.maxScale;

      _scaleAnimation = Tween<double>(
        begin: _transformationController!.value.getMaxScaleOnAxis(),
        end: widget.maxScale,
      ).animate(CurvedAnimation(
        parent: _scaleController,
        curve: Curves.decelerate,
      ));
      _scaleController.duration = doubleTapZoomIn
          ? Duration(
              milliseconds: 100 + widget.doubleTapAnimDuration.inMilliseconds)
          : widget.doubleTapAnimDuration;
      _scaleAnimation!.addListener(_onAnimateScale);
      _scaleController.forward();
    }
  }

  void _onAnimate() {
    if (!_controller.isAnimating) {
      _panAxis = null;
      _animation?.removeListener(_onAnimate);
      _animation = null;
      _controller.reset();
      return;
    }

    final Vector3 translationVector =
        _transformationController!.value.getTranslation();
    final Offset translation = Offset(translationVector.x, translationVector.y);
    final Offset translationScene = _transformationController!.toScene(
      translation,
    );
    final Offset animationScene = _transformationController!.toScene(
      _animation!.value,
    );
    final Offset translationChangeScene = animationScene - translationScene;
    _transformationController!.value = _matrixTranslate(
      _transformationController!.value,
      translationChangeScene,
    );
  }

  void _onAnimateScale() {
    if (!_scaleController.isAnimating) {
      _scaleAnimation?.removeListener(_onAnimateScale);
      _scaleAnimation = null;
      _scaleController.reset();
      return;
    }
    double scaleChange;

    if (widget.doubleTapScaleChange < 1.0) {
      scaleChange = doubleTapZoomIn ? 1.01 : 0.99;
    } else {
      scaleChange = doubleTapZoomIn
          ? widget.doubleTapScaleChange
          : 1 - (widget.doubleTapScaleChange - 1);
    }

    final Offset focalPointScene = _transformationController!.toScene(
      _doubleTapFocalPoint ?? Offset.zero,
    );

    _transformationController!.value = _matrixScale(
      _transformationController!.value,
      scaleChange,
      fixScale: true,
    );

    final Offset focalPointSceneScaled = _transformationController!.toScene(
      _doubleTapFocalPoint ?? Offset.zero,
    );

    Offset diference = focalPointSceneScaled - focalPointScene;

    _transformationController!.value = _matrixTranslate(
      _transformationController!.value,
      diference,
    );
  }

  void _onTransformationControllerChange() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _transformationController =
        widget.transformationController ?? TransformationController();
    _transformationController!.addListener(_onTransformationControllerChange);
    _controller = AnimationController(
      vsync: this,
    );
    _scaleController = AnimationController(
      vsync: this,
    );
    RawKeyboard.instance.addListener(_handleKeyEvent);
  }

  void _handleKeyEvent(RawKeyEvent event) {
    setState(() {
      if (event.isKeyPressed(LogicalKeyboardKey.altLeft) ||
          event.isKeyPressed(LogicalKeyboardKey.altRight)) {
        _isAltPressed = true;
      } else if (event is RawKeyUpEvent &&
          (event.logicalKey == LogicalKeyboardKey.altLeft ||
              event.logicalKey == LogicalKeyboardKey.altRight)) {
        _isAltPressed = false;
      }
    });
  }

  @override
  void didChangeMetrics() {
    setState(() {
      recalculateSizes();
    });
  }

  @override
  void didUpdateWidget(Zoom oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.transformationController == null) {
      if (widget.transformationController != null) {
        _transformationController!
            .removeListener(_onTransformationControllerChange);
        _transformationController!.dispose();
        _transformationController = widget.transformationController;
        _transformationController!
            .addListener(_onTransformationControllerChange);
      }
    } else {
      if (widget.transformationController == null) {
        _transformationController!
            .removeListener(_onTransformationControllerChange);
        _transformationController = TransformationController();
        _transformationController!
            .addListener(_onTransformationControllerChange);
      } else if (widget.transformationController !=
          oldWidget.transformationController) {
        _transformationController!
            .removeListener(_onTransformationControllerChange);
        _transformationController = widget.transformationController;
        _transformationController!
            .addListener(_onTransformationControllerChange);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scaleController.dispose();
    _transformationController!
        .removeListener(_onTransformationControllerChange);
    WidgetsBinding.instance.removeObserver(this);
    if (widget.transformationController == null) {
      _transformationController!.dispose();
    }
    super.dispose();
  }

  void fixScale(double scale) {
    _transformationController!.value = _matrixScale(
      _transformationController!.value,
      scale,
      fixScale: true,
    );
    _transformationController!.toScene(
      _referenceFocalPoint ?? Offset.zero,
    );
    _transformationController!.toScene(
      _referenceFocalPoint ?? Offset.zero,
    );
  }

  void recalculateSizes() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_parentKey.currentContext?.findRenderObject() == null) {
        return;
      }

      final RenderBox parentRenderBox =
          _parentKey.currentContext!.findRenderObject()! as RenderBox;
      parentSize = parentRenderBox.size;
      final RenderBox childRenderBox =
          _childKey.currentContext!.findRenderObject()! as RenderBox;
      childSize = childRenderBox.size;
      double scale = 0;

      final currentScale = _transformationController!.value.getMaxScaleOnAxis();

      _transformationController!.value = _matrixTranslate(
          _transformationController!.value,
          Offset(
            -0.01,
            -0.01,
          ),
          fixOffset: true);

      if (childSize.width == childSize.height) {
        if (childSize.width > parentSize.width &&
            ((childSize.width * currentScale) < parentSize.width ||
                (childSize.height * currentScale) < parentSize.height)) {
          scale = parentSize.width / (childSize.width * currentScale);
          fixScale(scale);
        }
      } else {
        if (childSize.width > childSize.height) {
          if (childSize.width > parentSize.width &&
              (childSize.width * currentScale) < parentSize.width) {
            scale = parentSize.width / (childSize.width * currentScale);
            fixScale(scale);
          }
        } else {
          if (childSize.height > parentSize.height &&
              (childSize.height * currentScale) < parentSize.height) {
            scale = parentSize.height / (childSize.height * currentScale);
            fixScale(scale);
          }
        }
      }

      _transformationController!.value = _matrixTranslate(
        _transformationController!.value,
        Offset(
          -0.01,
          -0.01,
        ),
      );

      void fitChild(bool condition) {
        if (condition) {
          _transformationController!.value = _matrixScale(
              _transformationController!.value,
              parentSize.height / childSize.height,
              fixScale: true);

          _transformationController!.value = _matrixTranslate(
              _transformationController!.value, Offset(-0.01, -0.01),
              fixOffset: true);
        } else {
          _transformationController!.value = _matrixScale(
              _transformationController!.value,
              parentSize.width / childSize.width,
              fixScale: true);

          _transformationController!.value = _matrixTranslate(
              _transformationController!.value, Offset(-0.01, -0.01),
              fixOffset: true);
        }
      }

      if (widget.initTotalZoomOut) {
        if (firstDraw &&
            (childSize.width > parentSize.width ||
                childSize.height > parentSize.height)) {
          if (childSize.width == childSize.height) {
            fitChild(parentSize.width > parentSize.height);
          } else {
            fitChild(childSize.width < childSize.height);
          }
          firstDraw = false;
        }
      } else {
        if (widget.initScale != null) {
          _transformationController!.value = _matrixScale(
              _transformationController!.value, widget.initScale ?? 0.0,
              fixScale: true);

          _transformationController!.value = _matrixTranslate(
              _transformationController!.value, Offset(-0.01, -0.01),
              fixOffset: true);
        }
        if (widget.initPosition != null) {
          _transformationController!.value = _matrixTranslate(
            _transformationController!.value,
            widget.initPosition ?? Offset.zero,
          );

          _referenceFocalPoint = _transformationController!.toScene(
            widget.initPosition ?? Offset.zero,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    child = _ZoomBuilt(
      childKey: _childKey,
      constrained: false,
      matrix: _transformationController!.value,
      child: Listener(
        onPointerUp: (event) {
          if (widget.onPanUpPosition != null) {
            widget.onPanUpPosition!(event.localPosition);
          }
        },
        child: (widget.maxZoomWidth == null || widget.maxZoomHeight == null)
            ? Container(
                color: widget.canvasColor,
                child: widget.child,
              )
            : Center(
                child: Container(
                    width: widget.maxZoomWidth,
                    height: widget.maxZoomHeight,
                    color: widget.canvasColor,
                    child: widget.child),
              ),
      ),
    );

    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (notification) {
        recalculateSizes();
        return true;
      },
      child: OrientationBuilder(builder: (context, orientation) {
        if (_orientation != orientation) {
          _orientation = orientation;
          recalculateSizes();
        }

        double opacity = widget.opacityScrollBars < 0
            ? 0
            : widget.opacityScrollBars > 1
                ? 1
                : widget.opacityScrollBars;

        return ClipRect(
          child: Container(
            color: widget.backgroundColor,
            child: Listener(
              key: _parentKey,
              onPointerSignal: _receivedPointerSignal,
              onPointerDown: (PointerDownEvent event) {
                _doubleTapFocalPoint = event.localPosition;
              },
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onScaleEnd: _onScaleEnd,
                onScaleStart: _onScaleStart,
                onScaleUpdate: _onScaleUpdate,
                onDoubleTap: _onDoubleTap,
                onTap: widget.onTap,
                child: widget.enableScroll
                    ? Stack(
                        children: [
                          child,
                          ValueListenableBuilder<_ScrollBarData>(
                              valueListenable: horizontalScrollNotifier,
                              builder: (_, scrollData, __) {
                                return scrollData.length == 0
                                    ? Container()
                                    : Positioned(
                                        bottom: widget.scrollWeight,
                                        left: scrollData.position,
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: widget.colorScrollBars
                                                  .withAlpha(
                                                      (opacity * 255).toInt()),
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(
                                                  widget.radiusScrollBars,
                                                ),
                                                topRight: Radius.circular(
                                                    widget.radiusScrollBars),
                                              )),
                                          height: 20,
                                          width: scrollData.length,
                                        ),
                                      );
                              }),
                          ValueListenableBuilder<_ScrollBarData>(
                              valueListenable: verticalScrollNotifier,
                              builder: (_, scrollData, __) {
                                return Positioned(
                                  left: parentSize.width - widget.scrollWeight,
                                  top: scrollData.position,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: widget.colorScrollBars
                                            .withAlpha((opacity * 255).toInt()),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(
                                              widget.radiusScrollBars),
                                          bottomLeft: Radius.circular(
                                              widget.radiusScrollBars),
                                        )),
                                    height: scrollData.length,
                                    width: widget.scrollWeight,
                                  ),
                                );
                              }),
                        ],
                      )
                    : child,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _ZoomBuilt extends StatelessWidget {
  const _ZoomBuilt({
    Key? key,
    required this.child,
    required this.childKey,
    required this.constrained,
    required this.matrix,
  }) : super(key: key);

  final Widget child;
  final GlobalKey childKey;
  final bool constrained;
  final Matrix4 matrix;

  @override
  Widget build(BuildContext context) {
    Widget child = Transform(
      transform: matrix,
      child: KeyedSubtree(
        key: childKey,
        child: this.child,
      ),
    );

    if (!constrained) {
      child = OverflowBox(
        alignment: Alignment.topLeft,
        minWidth: 0.0,
        minHeight: 0.0,
        maxWidth: double.infinity,
        maxHeight: double.infinity,
        child: child,
      );
    }

    return child;
  }
}

class TransformationController extends ValueNotifier<Matrix4> {
  TransformationController([Matrix4? value])
      : super(value ?? Matrix4.identity());

  Offset toScene(Offset viewportPoint) {
    final Matrix4 inverseMatrix = Matrix4.inverted(value);
    final Vector3 untransformed = inverseMatrix.transform3(Vector3(
      viewportPoint.dx,
      viewportPoint.dy,
      0,
    ));
    return Offset(untransformed.x, untransformed.y);
  }
}

enum _GestureType {
  pan,
  scale,
}

enum _ScrollType {
  horizontal,
  vertical,
}

class _ScrollBarData {
  _ScrollBarData({
    required this.length,
    required this.position,
  });

  final double position;
  final double length;
}

double _getFinalTime(double velocity, double drag) {
  const double effectivelyMotionless = 10.0;
  return math.log(effectivelyMotionless / velocity) / math.log(drag / 100);
}

Offset _getMatrixTranslation(Matrix4 matrix) {
  final Vector3 nextTranslation = matrix.getTranslation();
  return Offset(nextTranslation.x, nextTranslation.y);
}

Quad _transformViewport(Matrix4 matrix, Rect viewport) {
  final Matrix4 inverseMatrix = matrix.clone()..invert();
  return Quad.points(
    inverseMatrix.transform3(Vector3(
      viewport.topLeft.dx,
      viewport.topLeft.dy,
      0.0,
    )),
    inverseMatrix.transform3(Vector3(
      viewport.topRight.dx,
      viewport.topRight.dy,
      0.0,
    )),
    inverseMatrix.transform3(Vector3(
      viewport.bottomRight.dx,
      viewport.bottomRight.dy,
      0.0,
    )),
    inverseMatrix.transform3(Vector3(
      viewport.bottomLeft.dx,
      viewport.bottomLeft.dy,
      0.0,
    )),
  );
}

Quad _getAxisAlignedBoundingBoxWithRotation(Rect rect, double rotation) {
  final Matrix4 rotationMatrix = Matrix4.identity()
    ..translate(rect.size.width / 2, rect.size.height / 2)
    ..rotateZ(rotation)
    ..translate(-rect.size.width / 2, -rect.size.height / 2);
  final Quad boundariesRotated = Quad.points(
    rotationMatrix.transform3(Vector3(rect.left, rect.top, 0.0)),
    rotationMatrix.transform3(Vector3(rect.right, rect.top, 0.0)),
    rotationMatrix.transform3(Vector3(rect.right, rect.bottom, 0.0)),
    rotationMatrix.transform3(Vector3(rect.left, rect.bottom, 0.0)),
  );
  return Zoom.getAxisAlignedBoundingBox(boundariesRotated);
}

Offset _exceedsBy(Quad boundary, Quad viewport) {
  final List<Vector3> viewportPoints = <Vector3>[
    viewport.point0,
    viewport.point1,
    viewport.point2,
    viewport.point3,
  ];
  Offset largestExcess = Offset.zero;
  for (final Vector3 point in viewportPoints) {
    final Vector3 pointInside = Zoom.getNearestPointInside(point, boundary);
    final Offset excess = Offset(
      pointInside.x - point.x,
      pointInside.y - point.y,
    );
    if (excess.dx.abs() > largestExcess.dx.abs()) {
      largestExcess = Offset(excess.dx, largestExcess.dy);
    }
    if (excess.dy.abs() > largestExcess.dy.abs()) {
      largestExcess = Offset(largestExcess.dx, excess.dy);
    }
  }

  return _round(largestExcess);
}

Offset _round(Offset offset) {
  return Offset(
    double.parse(offset.dx.toStringAsFixed(9)),
    double.parse(offset.dy.toStringAsFixed(9)),
  );
}

Axis? _getPanAxis(Offset point1, Offset point2) {
  if (point1 == point2) {
    return null;
  }
  final double x = point2.dx - point1.dx;
  final double y = point2.dy - point1.dy;
  return x.abs() > y.abs() ? Axis.horizontal : Axis.vertical;
}
