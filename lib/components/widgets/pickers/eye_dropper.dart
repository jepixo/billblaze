
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:billblaze/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quiver/iterables.dart';
import '../utils.dart';

const _cellSize = 10;

const _gridSize = 90.0;

class EyeDropper extends StatefulWidget {
  const EyeDropper({
    super.key,
    required this.child,
    this.haveTextColorWidget = true,
  });

  final Widget child;
  final bool haveTextColorWidget;

  static void enableEyeDropper(
      BuildContext context, Function(Color?)? onEyeDropper) async {
    _EyeDropperState? state =
        context.findAncestorStateOfType<_EyeDropperState>();
    state?.enableEyeDropper(onEyeDropper);
  }

  @override
  State<EyeDropper> createState() => _EyeDropperState();
}

class _EyeDropperState extends State<EyeDropper> {
  final GlobalKey _renderKey = GlobalKey();

  ui.Image? _image;
  bool _enableEyeDropper = false;

  final _offsetNotifier = ValueNotifier<Offset>(const Offset(0, 0));
  final _colorNotifier = ValueNotifier<Color?>(null);
  final _byteDataStateNotifier = ValueNotifier<ByteData?>(null);
  Function(Color?)? _onEyeDropper;

  void enableEyeDropper(Function(Color?)? onEyeDropper) async {
    var renderBox = _renderKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;

    final boundary =
        _renderKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;

    // inital image - byte data
    _image = await boundary.toImage();
    _byteDataStateNotifier.value = await _image!.toByteData();

    setState(() {
      // enable color picker
      _enableEyeDropper = true;
      // place the color picker overlay's position in the center
      updatePosition(Offset(size.width / 2, size.height / 2));

      _onEyeDropper = onEyeDropper;
    });
  }

  List<Color> getSamplingGridColors(Offset position) {
  if (_byteDataStateNotifier.value == null || _image == null) {
    return List<Color>.filled(samplingGridSize * samplingGridSize, Colors.transparent);
  }
  final width = _image!.width;
  final height = _image!.height;

  final centerX = position.dx.toInt();
  final centerY = position.dy.toInt();

  final halfGrid = samplingGridSize ~/ 2;

  List<Color> colors = [];

  for (int y = centerY - halfGrid; y <= centerY + halfGrid; y++) {
    for (int x = centerX - halfGrid; x <= centerX + halfGrid; x++) {
      if (x >= 0 && y >= 0 && x < width && y < height) {
        final color = getPixelFromByteData(_byteDataStateNotifier.value!,
            width: width, x: x, y: y);
        colors.add(color);
      } else {
        colors.add(Colors.transparent);
      }
    }
  }
  return colors;
}

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: onPointerDown,
          onPointerMove: onPointerMove,
          onPointerUp: onPointerUp,
          child: RepaintBoundary(
            key: _renderKey,
            child: widget.child,
          ),
        ),
        Visibility(
          visible: _enableEyeDropper,
          child: Positioned(
            left: getOverlayPosition().dx-10,
            top: getOverlayPosition().dy+30,
            child: Listener(
              onPointerMove: onPointerMove,
              onPointerUp: onPointerUp,
              child: Material(
                elevation: 5,
                color: defaultPalette.transparent,
                borderRadius: BorderRadius.circular(15),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: EyeDropperGridOverlay(
                    colors: getSamplingGridColors(_offsetNotifier.value),
                  ),
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible: _enableEyeDropper,
          child: Positioned(
            left: _offsetNotifier.value.dx-36,
            top: _offsetNotifier.value.dy + 45,
            child: Container(
              width: 80,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
              color: defaultPalette.tertiary,),
              padding: const EdgeInsets.all(5),
              child: Text(
                _colorNotifier.value == null
                    ? ''
                    : colorToHex(_colorNotifier.value!),
                    maxLines: 1,
                      style: GoogleFonts.lexend(
                          fontSize: 15,
                          letterSpacing: -1,
                          fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Offset getOverlayPosition() {
    double dx = _offsetNotifier.value.dx - kOverlaySize.width / 2;
    double dy =
        _offsetNotifier.value.dy - kOverlaySize.height + kEyeDropperSize / 2;
    return Offset(dx, dy);
  }

  void onPointerDown(PointerDownEvent event) {
    if (_enableEyeDropper) {
      updatePosition(event.position);
    }
  }

  void onPointerMove(PointerMoveEvent event) {
    if (_enableEyeDropper) {
      updatePosition(event.position);
    }
  }

  void onPointerUp(PointerUpEvent event) async {
    if (_enableEyeDropper) {
      if (_colorNotifier.value != null) {
        _onEyeDropper?.call(_colorNotifier.value);
      }

      setState(() {
        _enableEyeDropper = false;
        _offsetNotifier.value = const Offset(0, 0);
        _colorNotifier.value = null;
        _image = null;
      });
    }
  }

  updatePosition(Offset newPosition) async {
    var color = getPixelFromByteData(
      _byteDataStateNotifier.value!,
      width: _image!.width,
      x: newPosition.dx.toInt(),
      y: newPosition.dy.toInt(),
    );

    setState(() {
      // update position
      _offsetNotifier.value = newPosition;

      // update color
      _colorNotifier.value = color;
    });
  }
}

class EyeDropperGridOverlay extends StatelessWidget {
  final List<Color> colors;

  const EyeDropperGridOverlay({
    Key? key,
    required this.colors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(9 * _cellSize.toDouble(), 9 * _cellSize.toDouble()),
      painter: PixelGridPainter(colors),
    );
  }
}


/// paint a hovered pixel/colors preview
class PixelGridPainter extends CustomPainter {
  final List<Color> colors;

  static const gridSize = 9;
  static const eyeRadius = 35.0;

  final blackStroke = Paint()
    ..color = defaultPalette.extras[0]
    ..strokeWidth = 10
    ..style = PaintingStyle.stroke;

  PixelGridPainter(this.colors);

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke;

    final blackLine = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final selectedStroke = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // fill pixels color square
    for (final color in enumerate(colors)) {
      final fill = Paint()..color = color.value;
      final rect = Rect.fromLTWH(
        (color.index % gridSize).toDouble() * _cellSize,
        ((color.index ~/ gridSize) % gridSize).toDouble() * _cellSize,
        _cellSize.toDouble(),
        _cellSize.toDouble(),
      );
      canvas.drawRect(rect, fill);
    }

    // draw pixels borders after fills
    for (final color in enumerate(colors)) {
      final rect = Rect.fromLTWH(
        (color.index % gridSize).toDouble() * _cellSize,
        ((color.index ~/ gridSize) % gridSize).toDouble() * _cellSize,
        _cellSize.toDouble(),
        _cellSize.toDouble(),
      );
      canvas.drawRect(
          rect, color.index == colors.length ~/ 2 ? selectedStroke : stroke);

      if (color.index == colors.length ~/ 2) {
        canvas.drawRect(rect.deflate(1), blackLine);
      }
    }

    // black contrast ring
    canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, _gridSize, _gridSize),
      const Radius.circular(15),
    ),
    blackStroke,
  );

  }

  @override
  bool shouldRepaint(PixelGridPainter oldDelegate) =>
      !listEquals(oldDelegate.colors, colors);
}

