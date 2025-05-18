import 'package:flutter/material.dart';
import 'dart:math' as math;

class AmbientGradientBorder extends StatefulWidget {
  final double width;
  final double height;
  final double strokeWidth; 
  final double radius;
  final List<Color> gradientColors;
  final double glowSpread;  
  final double glowWidthMultiplier;  
  final Widget child;
  final Duration animationDuration;
  final bool showSharpBorder;  

  const AmbientGradientBorder({
    Key? key,
    required this.width,
    required this.height,
    required this.strokeWidth,
    required this.radius,
    required this.gradientColors,
    required this.glowSpread,
    required this.glowWidthMultiplier,  
    required this.child,
    this.animationDuration = const Duration(seconds: 5),
    this.showSharpBorder = false,  
  })  : assert(strokeWidth > 0),
        assert(radius >= 0),
        assert(gradientColors.length >= 2),
        assert(glowSpread >= 0),
        assert(glowWidthMultiplier > 0),  
        super(key: key);

  @override
  State<AmbientGradientBorder> createState() => _AmbientGradientBorderState();
}

class _AmbientGradientBorderState extends State<AmbientGradientBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
     
    final innerRadiusValue = math.max(0.0, widget.radius - widget.strokeWidth);
    final innerBorderRadius = BorderRadius.circular(innerRadiusValue);
    final innerWidth = math.max(0.0, widget.width - widget.strokeWidth * 2);
    final innerHeight = math.max(0.0, widget.height - widget.strokeWidth * 2);

     
    final Color internalBackgroundColor =
        Theme.of(context).scaffoldBackgroundColor;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
               
              CustomPaint(
                size: Size(widget.width, widget.height),
                painter: _AmbientOuterEffectPainter(
                  
                  strokeWidth: widget.strokeWidth,
                  radius: widget.radius,
                  gradientColors: widget.gradientColors,
                  animationValue: _controller.value,
                  glowSpread: widget.glowSpread,
                  glowWidthMultiplier: widget.glowWidthMultiplier,  
                ),
              ),

               
              Container(
                width: innerWidth,
                height: innerHeight,
                decoration: BoxDecoration(
                   
                  color: internalBackgroundColor,
                  borderRadius: innerBorderRadius,
                ),
                 
                child: ClipRRect(
                  borderRadius: innerBorderRadius,
                  child: widget.child,
                ),
              ),

               
              if (widget.showSharpBorder)
                CustomPaint(
                  size: Size(widget.width, widget.height),
                  painter: _AnimatedGradientStrokePainter(
                    strokeWidth: widget.strokeWidth,
                    radius: widget.radius,
                    gradientColors: widget.gradientColors,
                    animationValue: _controller.value,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

 
class _AmbientOuterEffectPainter extends CustomPainter {
  final double strokeWidth;  
  final double radius;
  final List<Color> gradientColors;
  final double animationValue;
  final double glowSpread;  
  final double glowWidthMultiplier;  

  _AmbientOuterEffectPainter({
    required this.strokeWidth,
    required this.radius,
    required this.gradientColors,
    required this.animationValue,
    required this.glowSpread,
    required this.glowWidthMultiplier,  
  });

  @override
  void paint(Canvas canvas, Size size) {
     
    final double glowPaintStrokeWidth =
        strokeWidth * glowWidthMultiplier;  
    final Paint glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = glowPaintStrokeWidth 
       
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowSpread);

     
    final Rect rect = Rect.fromLTWH(
        strokeWidth / 2,  
        strokeWidth / 2,  
        size.width - strokeWidth,  
        size.height - strokeWidth  
        );

    // Radius 
    final Radius borderRadius =
        Radius.circular(math.max(0, radius - strokeWidth / 2));
    final RRect glowRRect = RRect.fromRectAndRadius(rect, borderRadius);

     
    final SweepGradient sweepGradient = SweepGradient(
      center: Alignment.center,
      colors: gradientColors,
      startAngle: 0.0,
      endAngle: math.pi * 2,
      transform: GradientRotation(animationValue * 2 * math.pi),
      tileMode: TileMode.repeated,
    );

    
    glowPaint.shader = sweepGradient
        .createShader(Rect.fromLTWH(0, 0, size.width, size.height));

     
    canvas.drawRRect(glowRRect, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _AmbientOuterEffectPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius ||
        !listEquals(oldDelegate.gradientColors, gradientColors) ||
        oldDelegate.glowSpread != glowSpread ||
        oldDelegate.glowWidthMultiplier != glowWidthMultiplier;  
  }

   
  bool listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

 
class _AnimatedGradientStrokePainter extends CustomPainter {
   
  final double strokeWidth;
  final double radius;
  final List<Color> gradientColors;
  final double animationValue;

  _AnimatedGradientStrokePainter({
    required this.strokeWidth,
    required this.radius,
    required this.gradientColors,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final RRect outerRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2, size.width - strokeWidth,
          size.height - strokeWidth),
      Radius.circular(math.max(0, radius - strokeWidth / 2)),
    );
    final SweepGradient sweepGradient = SweepGradient(
      center: Alignment.center,
      colors: gradientColors,
      startAngle: 0.0,
      endAngle: math.pi * 2,
      transform: GradientRotation(animationValue * 2 * math.pi),
      tileMode: TileMode.repeated,
    );
    borderPaint.shader = sweepGradient
        .createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRRect(outerRRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _AnimatedGradientStrokePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius ||
        !listEquals(oldDelegate.gradientColors, gradientColors);  
  }

  bool listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}