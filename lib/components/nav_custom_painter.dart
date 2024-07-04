// import 'dart:io';

import 'package:flutter/material.dart';

// const s = 0.2;

class NavCustomPainter extends CustomPainter {
  late double loc;
  late double bottom;
  Color color;
  bool hasLabel;
  TextDirection textDirection;
  double radius;
  double s;

  NavCustomPainter({
    required double startingLoc,
    required int itemsLength,
    required this.color,
    required this.textDirection,
    this.hasLabel = false,
    this.radius = 10,
    this.s = 0.2,
    this.bottom = 0.45,
  }) {
    final span = 1.0 / itemsLength;
    final l = startingLoc + (span - s) / 2;
    loc = textDirection == TextDirection.rtl ? 0.8 - l : l;
    // bottom = bottom hasLabel
    //     ? (Platform.isAndroid ? 0.55 : 0.45)
    //     : (Platform.isAndroid ? 0.6 : 0.5);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // final borderPaint = Paint()
    //   ..color = Colors.black
    //   ..style = PaintingStyle.stroke
    //   ..strokeWidth = 2;
    final double sizeWidth = size.width ;

    final path = Path()
      ..moveTo(radius, 0)
      ..lineTo((size.width - 5) * (loc), 0)
      ..cubicTo(
        (sizeWidth) * (loc + s * 0.2), // topX
        size.height * 0.05, // topY
        (sizeWidth) * loc, // bottomX
        size.height * bottom - 0.1, // bottomY
        (sizeWidth) * (loc + s * 0.5), // centerX
        size.height * bottom - 0.1, // centerY
      )
      ..cubicTo(
        (sizeWidth) * (loc + s), // bottomX
        size.height * bottom - 0.1, // bottomY
        (sizeWidth) * (loc + s * 0.8), // topX
        size.height * 0.05, // topY
        (sizeWidth) * (loc + s + 0.05),
        0,
      )
      ..addRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0, 0, (sizeWidth), size.height),
          topLeft: Radius.circular(
              (sizeWidth) * (loc - 0.05) < (sizeWidth) * 0.01
                  ? 0
                  : radius),
          topRight: Radius.circular(
              (sizeWidth) * (loc + s + 0.05) > (sizeWidth) * 0.95
                  ? 0
                  : radius),
          bottomRight: Radius.circular(radius),
          bottomLeft: Radius.circular(radius),
        ),
      )
      // ..lineTo(sizeWidth - radius, 0)
      // ..quadraticBezierTo(
      //   size.width,
      //   0,
      //   sizeWidth,
      //   size.height - radius,
      // )
      // ..lineTo(size.width-4, size.height - radius)
      // ..quadraticBezierTo(
      //   size.width, size.height,
      //   size.width - radius, size.height,
      // )
      // ..lineTo(radius, size.height)
      // ..quadraticBezierTo(
      //   0, size.height,
      //   0, size.height - radius,
      // )
      // ..lineTo(0, radius)
      // ..quadraticBezierTo(0, 0, radius, 0)
      ..close();
    canvas.drawPath(path, paint);
    // canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return this != oldDelegate;
  }
}


// final bool firstpos =
//         (sizeWidth) * (loc - 0.05) < (sizeWidth) * 0.1;

//     final path = Path()
//       ..moveTo(firstpos ? -30 : radius, firstpos ? 0 : 0)
//       ..lineTo(
//           firstpos
//               ? (size.width - 5) * (loc - 0.015)
//               : (size.width - 5) * (loc - 0.05),
//           firstpos ? 0 : 0)
//       ..cubicTo(firstpos?0:
//         (size.width - 5) * (loc + s * 0.2), // topX
//         size.height * 0.05, // topY
//         (size.width - 5) * loc, // bottomX
//         size.height * bottom - 0.1, // bottomY
//         (size.width - 5) * (loc + s * 0.5), // centerX
//         size.height * bottom - 0.1, // centerY
//       )
//       ..cubicTo(
//         (size.width - 5) * (loc + s), // bottomX
//         size.height * bottom - 0.1, // bottomY
//         (size.width - 5) * (loc + s * 0.8), // topX
//         size.height * 0.05, // topY
//         (size.width - 5) * (loc + s + 0.05) > (size.width - 5) * 0.95
//             ? (size.width - 5) * (loc + s - 0.02)
//             : (size.width - 5) * (loc + s + 0.05),
//         0,
//       )
//       ..addRRect(
//         RRect.fromRectAndCorners(
//           Rect.fromLTWH(firstpos?-5:0, 0, firstpos?(size.width - 5)+5:(size.width - 5), size.height),
//           topLeft: Radius.circular(firstpos ? 0 : radius),
//           topRight: Radius.circular(
//               (size.width - 5) * (loc + s + 0.05) > (size.width - 5) * 0.95
//                   ? 0
//                   : radius),
//           bottomRight: Radius.circular(radius),
//           bottomLeft: Radius.circular(radius),
//         ),
//       )
//       // ..lineTo(size.width - 5 - radius, 0)
//       // ..quadraticBezierTo(
//       //   size.width - 5,
//       //   0,
//       //   size.width - 5,
//       //   size.height - radius,
//       // )
//       // ..lineTo(size.width - 5, size.height - radius)
//       // ..quadraticBezierTo(
//       //   size.width,
//       //   size.height,
//       //   size.width - radius,
//       //   size.height,
//       // )
//       // ..lineTo(radius, size.height)
//       // ..quadraticBezierTo(
//       //   0,
//       //   size.height,
//       //   0,
//       //   size.height - radius,
//       // )
//       // ..lineTo(0, radius)
//       // ..quadraticBezierTo(
//       //     0,
//       //     0,
//       //     (size.width - 5) * (loc - 0.05) < (size.width - 5) * 0.1
//       //         ? -20
//       //         : radius,
//       //     (size.width - 5) * (loc - 0.05) < (size.width - 5) * 0.1 ? radius : 0)
//       ..close();
//     canvas.drawPath(path, paint);
//     // canvas.drawPath(path, borderPaint);