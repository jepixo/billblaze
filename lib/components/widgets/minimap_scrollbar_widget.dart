import 'dart:async';
import 'dart:ui' as ui;
import 'package:billblaze/colors.dart';
import 'package:custom_border/border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// The position of the minimap scrollbar in the [MinimapScrollbarWidget].
/// The default value is [MinimapPosition.right].
enum MinimapPosition { left, right, top, bottom }

class MinimapScrollbarWidget extends StatefulWidget {
  const MinimapScrollbarWidget({
    super.key,
    required this.child,
    this.controller,
    required this.physics,
    this.miniSize = 100.0,
    this.scaleFactor = 0.1,
    this.highlightColor = Colors.blue,
    this.position = MinimapPosition.right,
    this.headrHeight = 88.0,
    this.imageUpdateInterval = 100,
  });
  final ScrollController? controller;
  final ScrollPhysics physics;
  /// `child` is the widget that will be displayed in the main view.
  /// This widget will be wrapped in a [SingleChildScrollView].
  final Widget child;

  /// `miniSize` is the size of the minimap scrollbar.
  /// The default value is 100.0 pixels.
  final double miniSize;

  /// `scaleFactor` is the scale factor of the minimap scrollbar.
  /// The default value is 0.1.
  final double scaleFactor;

  /// `highlightColor` is the color of the minimap scrollbar.
  /// The default value is [Colors.blue].
  final Color highlightColor;

  /// `position` is the position of the minimap scrollbar.
  /// The default value is [MinimapPosition.right].
  /// If the value is [MinimapPosition.left], the minimap scrollbar will be placed on the left side.
  final MinimapPosition position;

  /// `headrHeight` is the height of the header. above the minimap scrollbar.
  /// The default value is 88.0 pixels (the height of the AppBar).
  /// This is useful when the header is present above the minimap scrollbar.
  final double headrHeight;

  /// `imageUpdateInterval` is the interval at which the minimap image is updated.
  /// The default value is 100 microseconds.
  final int imageUpdateInterval;

  @override
  State<MinimapScrollbarWidget> createState() => _MinimapScrollbarWidgetState();
}

class _MinimapScrollbarWidgetState extends State<MinimapScrollbarWidget> {
  late final ScrollController _scrollController;
  final GlobalKey _childKey = GlobalKey();
  ui.Image? _miniImage;
  Timer? _imageUpdateTimer;
  late double assignedViewPortSize;

  /// Returns `true` if the minimap scrollbar is vertical.
  bool get _isVertical =>
      widget.position == MinimapPosition.left ||
      widget.position == MinimapPosition.right;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_updateHighlight);
    WidgetsBinding.instance.addPostFrameCallback((_) => _captureMiniImage());

    /// Update the minimap image every 100 microseconds.
    /// This is necessary because the image may change due to scrolling.
    /// The image is captured using a [Timer] to avoid unnecessary repaints.
    _imageUpdateTimer = Timer.periodic(
      Duration(microseconds: widget.imageUpdateInterval),
      (_) => setState(_captureMiniImage),
    );
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    _imageUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MinimapScrollbarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _captureMiniImage();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _captureMiniImage();
  }

  void _updateHighlight() => setState(() {});

  void _captureMiniImage() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final boundary =
        _childKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    final RenderBox? childBox =
        _childKey.currentContext?.findRenderObject() as RenderBox?;

    if (boundary != null && childBox != null) {
      boundary
          .toImage(
        pixelRatio: widget.scaleFactor,
      )
          .then((image) {
        if (mounted) {
          setState(() => _miniImage = image);
        }
      });
    }
    },);
    
  }

  void _onMinimapInteraction(
    Offset localPosition,
    double miniContentSize,
  ) {
    if (!_scrollController.hasClients) return;

    final ratio = _isVertical
        ? localPosition.dy / miniContentSize
        : localPosition.dx / miniContentSize;

    final targetScroll = ratio * _scrollController.position.maxScrollExtent;

    _scrollController.jumpTo(
      targetScroll.clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      ),
    );
  }

  double _calculateHighlightPosition(double contentSize, double viewportSize) {
    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    final currentScrollPosition = _scrollController.offset;

    final scrollProgress = maxScrollExtent > 0
        ? (currentScrollPosition / maxScrollExtent).clamp(0.0, 1.0)
        : 0.0;

    final availableMovementSpace = contentSize - viewportSize;
    return scrollProgress * availableMovementSpace;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // final RenderBox? childBox =
        // _childKey.currentContext?.findRenderObject() as RenderBox?;
        final screenSize = MediaQuery.of(context).size;
        final maxSize = _isVertical
            ? screenSize.height -56
            : screenSize.width;
            
        assignedViewPortSize = maxSize *widget.scaleFactor;
        // print('maxSize in minimapscrollbar: '+ assignedViewPortSize.toString());
        double? childSize;
        final childContext = _childKey.currentContext;
        if (childContext != null) {
          final childRenderBox = childContext.findRenderObject() as RenderBox?;
          childSize = _isVertical
              ? childRenderBox?.size.height
              : childRenderBox?.size.width;
        }

        final miniContentSize = childSize != null
            ? (childSize * widget.scaleFactor).clamp(0.0, maxSize)-4
            : (double.maxFinite-40);

        final scrollView = Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: widget.physics,
            scrollDirection: _isVertical ? Axis.vertical : Axis.horizontal,
            child: RepaintBoundary(
              key: _childKey,
              child: ClipRect(child: widget.child),
            ),
          ),
        );

        Widget buildHighlight() {
          if (!_scrollController.hasClients) return const SizedBox();

          final highlightPosition = _calculateHighlightPosition(
            miniContentSize,
            assignedViewPortSize,
          );

          return AnimatedPositioned(
            duration: const Duration(milliseconds: 100),
            top: _isVertical ? highlightPosition+4 : 0,
            left: !_isVertical ? highlightPosition : 0,
            width: _isVertical ? widget.miniSize : assignedViewPortSize,
            height: _isVertical ? assignedViewPortSize : widget.miniSize,
            child: CustomBorder(
                color: defaultPalette.tertiary,
                radius: Radius.circular(2),
                strokeWidth: 1 ,
                dashPattern: [10, 3],
                strokeCap: StrokeCap.square,
                animateBorder: true,
                animateDuration: Duration(seconds: 5),
              child: Container(
                height: assignedViewPortSize,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(
                    color: defaultPalette.tertiary,
                    width: 1,
                  ),
                ),
              ),
            ),
          );
        }

        final minimap = SizedBox(
          width: _isVertical ? widget.miniSize : double.infinity,
          height:double.infinity ,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) => _onMinimapInteraction(
              details.localPosition,
              miniContentSize,
            ),
            onVerticalDragUpdate: _isVertical
                ? (details) => _onMinimapInteraction(
                      details.localPosition,
                      miniContentSize,
                    )
                : null,
            onHorizontalDragUpdate: !_isVertical
                ? (details) => _onMinimapInteraction(
                      details.localPosition,
                      miniContentSize,
                    )
                : null,
            child: Stack(
              children: [
                Container(
                  color: defaultPalette.extras[0],
                ),
                if (_miniImage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints.tight(Size(
                        _isVertical ? widget.miniSize : double.maxFinite,
                        _isVertical ? (double.maxFinite ): widget.miniSize,
                      )),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: CustomPaint(
                          size: Size(
                            _isVertical ? widget.miniSize : double.maxFinite,
                            _isVertical ? double.maxFinite : widget.miniSize,
                          ),
                          painter: ImagePainter(
                            _miniImage!,
                            _isVertical ? widget.miniSize : miniContentSize,
                            _isVertical ? miniContentSize : widget.miniSize,
                          ),
                        ),
                      ),
                    ),
                  ),
                
                buildHighlight(),
              ],
            ),
          ),
        );

        return switch (widget.position) {
          MinimapPosition.left => Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [minimap, scrollView],
            ),
          MinimapPosition.right => Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [scrollView, minimap],
            ),
          MinimapPosition.top => Column(
              mainAxisSize: MainAxisSize.min,
              children: [minimap, scrollView],
            ),
          MinimapPosition.bottom => Column(
              mainAxisSize: MainAxisSize.min,
              children: [scrollView, minimap],
            ),
        };
      },
    );
  }
}

/// A custom painter that paints an image on a canvas.
class ImagePainter extends CustomPainter {
  final ui.Image image;
  final double miniWidth;
  final double miniHeight;

  ImagePainter(this.image, this.miniWidth, this.miniHeight);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..filterQuality = FilterQuality.none;

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, miniWidth, miniHeight),
      paint,
    );
  }

  @override
  bool shouldRepaint(ImagePainter oldDelegate) {
    return true;
  }
}
