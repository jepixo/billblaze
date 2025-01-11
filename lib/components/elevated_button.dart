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
  late bool isDown; // Tracks whether the button is currently pressed or toggled

  @override
  void initState() {
    super.initState();
    isDown = widget.isTapped; // Initialize from `isTapped`
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.toggleOnTap) {
      setState(() {
        isDown = true; // Press the button down
      });
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.toggleOnTap) {
      setState(() {
        isDown = false; // Release the button
      });
    }
    widget.onClick?.call(); // Trigger onClick callback
  }

  void _handleTapCancel() {
    if (!widget.toggleOnTap) {
      setState(() {
        isDown = false; // Reset button to unpressed state on cancel
      });
    }
  }

  void _handleTap() {
    if (widget.toggleOnTap) {
      setState(() {
        isDown = !isDown; // Toggle the button state
      });
      widget.onClick?.call(); // Trigger onClick callback
    }
  }

  @override
  Widget build(BuildContext context) {
    double subfac = widget.subfac;

    return GestureDetector(
      onTapDown: widget.toggleOnTap ? null : _handleTapDown,
      onTapUp: widget.toggleOnTap ? null : _handleTapUp,
      onTapCancel: widget.toggleOnTap ? null : _handleTapCancel,
      onTap: widget.toggleOnTap ? _handleTap : null,
      child: SizedBox(
        height: widget.buttonHeight,
        width: widget.buttonWidth,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            // Base decoration layer
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: widget.buttonWidth! - subfac,
                height: widget.buttonHeight! - subfac,
                decoration: widget.baseDecoration?.copyWith(
                  borderRadius: widget.borderRadius,
                ),
              ),
            ),
            // Top decoration layer with animation
            AnimatedPositioned(
              duration: widget.animationDuration!,
              curve: widget.animationCurve!,
              bottom: isDown ? 0 : 4, // Adjust based on the pressed or toggled state
              right: isDown ? 0 : 4,
              child: Container(
                width: widget.buttonWidth! - subfac,
                height: widget.buttonHeight! - subfac,
                alignment: Alignment.center,
                decoration: widget.topDecoration?.copyWith(
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
} 

class ResizableElevatedLayerButton extends StatelessWidget {
  final int flex;
  final VoidCallback? onClick;
  final double buttonHeight;
  final BorderRadius? borderRadius;
  final Duration animationDuration;
  final Curve animationCurve;
  final BoxDecoration? topDecoration;
  final BoxDecoration? baseDecoration;
  final Widget? topLayerChild;
  final bool toggleOnTap;
  final double subfac;

  const ResizableElevatedLayerButton({
    Key? key,
    required this.flex,
    required this.buttonHeight,
    required this.onClick,
    required this.animationDuration,
    required this.animationCurve,
    this.borderRadius,
    this.topDecoration,
    this.baseDecoration,
    this.topLayerChild,
    this.toggleOnTap = false,
    this.subfac = 10,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: SizedBox(
        height: buttonHeight, // Constrain height
        child: ElevatedLayerButton(
          buttonHeight: buttonHeight,
          buttonWidth: null, // Allow the parent's constraints to determine width
          borderRadius: borderRadius,
          animationDuration: animationDuration,
          animationCurve: animationCurve,
          onClick: onClick,
          topDecoration: topDecoration,
          baseDecoration: baseDecoration,
          topLayerChild: topLayerChild,
          toggleOnTap: toggleOnTap,
          subfac: subfac,
        ),
      ),
    );
  }
}
