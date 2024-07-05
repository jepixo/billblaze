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
  }) : super(key: key);

  @override
  State<ElevatedLayerButton> createState() => _ElevatedLayerButtonState();
}

class _ElevatedLayerButtonState extends State<ElevatedLayerButton> {
  late bool _isTappedDown;

  @override
  void initState() {
    super.initState();
    _isTappedDown = widget.isTapped;
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isTappedDown = true;
    });
    widget.onClick?.call();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isTappedDown = false;
    });
  }

  void _handleTapCancel() {
    setState(() {
      _isTappedDown = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
                width: widget.buttonWidth! - 10,
                height: widget.buttonHeight! - 10,
                decoration: widget.baseDecoration!.copyWith(
                  borderRadius: widget.borderRadius,
                ),
              ),
            ),
            AnimatedPositioned(
              duration: widget.animationDuration!,
              curve: widget.animationCurve!,
              bottom: !_isTappedDown ? 4 : 0,
              right: !_isTappedDown ? 4 : 0,
              child: Container(
                width: widget.buttonWidth! - 10,
                height: widget.buttonHeight! - 10,
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
