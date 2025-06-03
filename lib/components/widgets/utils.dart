import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;

//bool get isPhoneScreen => !(screenSize.shortestSide >= 600);

extension Screen on MediaQueryData {
  bool get isPhone => size.shortestSide < 600;
}

extension Chroma on String {
  /// converts string to [Color]
  /// fill incomplete values with 0
  /// ex: 'ff00'.toColor() => Color(0xffff0000)
  Color toColor({bool argb = false}) {
    final colorString = '0x${argb ? '' : 'ff'}$this'.padRight(10, '0');
    return Color(int.tryParse(colorString) ?? 0);
  }
}

/// shortcuts to manipulate [Color]
extension Utils on Color {
  HSLColor get hsl => HSLColor.fromColor(this);

  double get hue => hsl.hue;

  double get saturation => hsl.saturation;

  double get lightness => hsl.lightness;

  Color withHue(double value) => hsl.withHue(value).toColor();

  /// ff001232
  String get hexARGB => value.toRadixString(16).padLeft(8, '0');

  /// 001232ac
  String get hexRGB =>
      value.toRadixString(16).padLeft(8, '0').replaceRange(0, 2, '');

  Color withSaturation(double value) =>
      HSLColor.fromAHSL(opacity, hue, value, lightness).toColor();

  Color withLightness(double value) => hsl.withLightness(value).toColor();

  /// generate the gradient of a color with
  /// lightness from 0 to 1 in [stepCount] steps
  List<Color> getShades(int stepCount, {bool skipFirst = true}) =>
      List.generate(
        stepCount,
        (index) {
          return hsl
              .withLightness(1 -
                  ((index + (skipFirst ? 1 : 0)) /
                      (stepCount - (skipFirst ? -1 : 1))))
              .toColor();
        },
      );
}

extension Helper on List<Color> {
  /// return the central item of a color list or black if the list is empty
  Color get center => isEmpty ? Colors.black : this[length ~/ 2];
}

List<Color> getHueGradientColors({double? saturation, int steps = 36}) =>
    List.generate(steps, (value) => value)
        .map<Color>((v) {
          final hsl = HSLColor.fromAHSL(1, v * (360 / steps), 0.67, 0.50);
          final rgb = hsl.toColor();
          return rgb.withOpacity(1);
        })
        .map((c) => saturation != null ? c.withSaturation(saturation) : c)
        .toList();

const samplingGridSize = 9;

List<Color> getPixelColors(
  img.Image image,
  Offset offset, {
  int size = samplingGridSize,
}) =>
    List.generate(
      size * size,
      (index) => getPixelColor(
        image,
        offset + _offsetFromIndex(index, samplingGridSize),
      ),
    );

Color getPixelColor(img.Image image, Offset offset) => (offset.dx >= 0 &&
        offset.dy >= 0 &&
        offset.dx < image.width &&
        offset.dy < image.height)
    ? pixel2Color(image.getPixel(offset.dx.toInt(), offset.dy.toInt()))
    : const Color(0x00000000);

ui.Offset _offsetFromIndex(int index, int numColumns) => Offset(
      (index % numColumns).toDouble(),
      ((index ~/ numColumns) % numColumns).toDouble(),
    );

/*Color toColorFlutter(img.Color c)
{
  return Color(c.)
}*/

Color pixel2Color(img.Pixel p) {
  return Color.fromARGB(p.a.toInt(), p.r.toInt(), p.g.toInt(), p.b.toInt());
}

Color abgr2Color(int value) {
  final a = (value >> 24) & 0xFF;
  final b = (value >> 16) & 0xFF;
  final g = (value >> 8) & 0xFF;
  final r = (value >> 0) & 0xFF;

  return Color.fromARGB(a, r, g, b);
}

Future<img.Image?> repaintBoundaryToImage(
  RenderRepaintBoundary renderer,
) async {
  try {
    final rawImage = await renderer.toImage(pixelRatio: 1);
    final byteData =
        await rawImage.toByteData(format: ui.ImageByteFormat.rawStraightRgba);

    if (byteData == null) throw Exception('Null image byteData !');

    final pngBytes = byteData.buffer;

    return img.Image.fromBytes(
      width: rawImage.width,
      height: rawImage.height,
      bytes: pngBytes,
      order: img.ChannelOrder.rgba,
    );
  } catch (err, stackTrace) {
    debugPrint('repaintBoundaryToImage... $err $stackTrace');

    rethrow;
  }
}

const double kEyeDropperSize = 16;
const Size kOverlaySize = Size(64, 88);

Color getPixelFromByteData(
  ByteData byteData, {
  required int width,
  required int x,
  required int y,
}) {
  try {
    final index = (y * width + x) * 4;
    final r = byteData.getUint8(index);
    final g = byteData.getUint8(index + 1);
    final b = byteData.getUint8(index + 2);
    final a = byteData.getUint8(index + 3);

    return Color.fromARGB(a, r, g, b);
  } catch (e) {
    return Colors.transparent;
  }
}

/// Returns the [color] in hexadecimal (#RRGGBB) format.
///
/// If [withAlpha] is [true], then returns it in #AARRGGBB format.
String colorToHexString(Color color, {bool withAlpha = false}) {
  final a = color.alpha.toRadixString(16).padLeft(2, '0');
  final r = color.red.toRadixString(16).padLeft(2, '0');
  final g = color.green.toRadixString(16).padLeft(2, '0');
  final b = color.blue.toRadixString(16).padLeft(2, '0');

  if (withAlpha) {
    return '$a$r$g$b';
  }

  return '#$r$g$b';
}

Color getTextColorOnBackground(Color background) {
  final luminance = background.computeLuminance();

  if (luminance > 0.5) return Colors.black;
  return Colors.white;
}
