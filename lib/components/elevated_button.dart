import 'package:flutter/material.dart';

class ElevatedLayerButton extends StatefulWidget {
  final double? buttonHeight;
  final double? buttonWidth;
  final Duration? animationDuration;
  final Curve? animationCurve;
  final VoidCallback? onClick;
  final BoxDecoration? baseDecoration;
  final BoxDecoration? topDecoration;
  final Widget? topLayerChild;
  final BorderRadius? borderRadius;
  final bool toggleOnTap;
  final bool isTapped;
  final double subfac;

  const ElevatedLayerButton({
    Key? key,
    required this.buttonHeight,
    required this.buttonWidth,
    required this.animationDuration,
    required this.animationCurve,
    required this.onClick,
    this.baseDecoration,
    this.topDecoration,
    this.topLayerChild,
    this.borderRadius,
    this.toggleOnTap = false,
    this.isTapped = false,
    this.subfac = 10,
  }) : super(key: key);

  @override
  State<ElevatedLayerButton> createState() => _ElevatedLayerButtonState();
}

class _ElevatedLayerButtonState extends State<ElevatedLayerButton> {
  late bool toggleOnTap;
  late bool down;

  @override
  void initState() {
    super.initState();
    down = widget.isTapped;
    toggleOnTap = widget.toggleOnTap;
  }

  void _handleTapDown(TapDownDetails details) {
    widget.onClick!();

    setState(() {
      down = true;
      print(down);
    });
  }

  void _handleTapUp(TapUpDetails details) {
    if (!toggleOnTap && down) {
      setState(() {
        down = !down;
      });
    }
  }

  void _handleTapCancel() {}

  @override
  Widget build(BuildContext context) {
    double subfac = widget.subfac;
    return GestureDetector(
      onTap: () {
        if (!toggleOnTap) {
          setState(() {
            down = true;
          });
          Future.delayed(Durations.short4).then((y) {
            setState(() {
              down = false;
            });
          });
        }
      },
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: SizedBox(
        height: widget.buttonHeight,
        width: widget.buttonWidth,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: widget.buttonWidth! -subfac,
                height: widget.buttonHeight! -subfac,
                decoration: widget.baseDecoration!.copyWith(
                  borderRadius: widget.borderRadius,
                ),
              ),
            ),
            AnimatedPositioned(
              duration: widget.animationDuration!,
              curve: widget.animationCurve!,
              bottom: !down ? 4 : 0,
              right: !down ? 4 : 0,
              child: Container(
                width: widget.buttonWidth! -subfac,
                height: widget.buttonHeight! -subfac,
                alignment: Alignment.center,
                decoration: widget.topDecoration!.copyWith(
                  borderRadius: widget.borderRadius,
                ),
                child: widget.topLayerChild,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _disabled => widget.onClick == null;
}
