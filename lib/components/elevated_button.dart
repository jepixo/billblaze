
import 'package:billblaze/colors.dart';
import 'package:flutter/material.dart';
import 'package:mesh_gradient/mesh_gradient.dart';

class ElevatedLayerButton extends StatefulWidget {
  final double? buttonHeight;
  final double? buttonWidth;
  final Duration? animationDuration;
  final Curve? animationCurve;
  final VoidCallback? onClick;
  final Function? onTapDown;
  final BoxDecoration? baseDecoration;
  final BoxDecoration? topDecoration;
  final Widget? topLayerChild;
  final BorderRadius? borderRadius;
  final bool toggleOnTap;
  final bool isTapped;
  final double subfac;
  final double depth;
  final bool extrudeLeft;
  final Alignment topAlignment;
  final bool isNavigation;

  const ElevatedLayerButton({
    Key? key,
    required this.buttonHeight,
    required this.buttonWidth,
    this.animationDuration = Durations.medium1,
    this.animationCurve = Curves.easeIn,
    required this.onClick,
    this.baseDecoration,
    this.topDecoration,
    this.topLayerChild,
    this.borderRadius,
    this.toggleOnTap = false,
    this.isTapped = false,
    this.subfac = 10,
    this.depth = 4,
    this.extrudeLeft = true,
    this.topAlignment = const Alignment(0, 0),
    this.isNavigation = false,
    this.onTapDown = null,
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

  @override
  void didUpdateWidget(covariant ElevatedLayerButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isTapped != widget.isTapped) {
      setState(() {
        isDown = widget.isTapped;
      });
    }
  }


  void _handleTapDown(TapDownDetails details) {
    if (!widget.toggleOnTap) {
      setState(() {
        isDown = true; // Press the button down
      });
    }
  }

  void _handleTapUp(TapUpDetails details) async {
    if (!widget.toggleOnTap) {
      await Future.delayed(Durations.short1);
      setState(() {
        
        isDown = false; // Release the button
      });
    }
    widget.onClick?.call(); // Trigger onClick callback
    widget.onTapDown?.call(details);
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
      // widget.onClick?.call(); // Trigger onClick callback
    }
  }

  @override
  Widget build(BuildContext context) {
    double subfac = widget.subfac;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: widget.toggleOnTap ? null : _handleTapDown,
        onTapUp: widget.toggleOnTap ? null : _handleTapUp,
        onTapCancel: widget.toggleOnTap ? null : _handleTapCancel,
        // onTap: widget.toggleOnTap ? _handleTapDown : null,
        child: SizedBox(
          height: widget.buttonHeight,
          width: widget.buttonWidth,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              // Base decoration layer
              Positioned(
                bottom: 0,
                right:widget.extrudeLeft? 0:widget.depth,
                child: widget.isNavigation?
                ClipRRect(
                  borderRadius: widget.borderRadius??BorderRadius.circular(0),
                  child: AnimatedMeshGradient(colors: [
                    defaultPalette.extras[0],
                    defaultPalette.extras[3],
                    defaultPalette.extras[4],
                    defaultPalette.tertiary,
                    // widget.baseDecoration?.color??defaultPalette.tertiary,
                    
                    // widget.baseDecoration?.color??defaultPalette.tertiary,
                  ], 
                  
                  options: AnimatedMeshGradientOptions(
                    frequency: 200,
                    amplitude: 2,
                    grain: 0.2,
                    speed: 10
                  ),
                  child: Container(
                    width: widget.buttonWidth! - subfac,
                    height: widget.buttonHeight! - subfac,),
                  ),
                ):
                 Container(
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
                bottom: widget.extrudeLeft? isDown
                    ? 0
                    : widget
                        .depth: null, // Adjust based on the pressed or toggled state
                right:widget.extrudeLeft? isDown ? 0 : widget.depth: null,
                left: !widget.extrudeLeft? isDown
                    ? 0
                    : widget
                        .depth:null,
                top:!widget.extrudeLeft?  isDown
                    ? widget
                        .depth
                    : 0:null,
                child: Container(
                  width: widget.buttonWidth! - subfac,
                  height: widget.buttonHeight! - subfac,
                  alignment: widget.topAlignment,
                  decoration: widget.topDecoration?.copyWith(
                    borderRadius: widget.borderRadius,
                  ),
                  child: widget.topLayerChild,
                ),
              ),
            ],
          ),
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
          buttonWidth:
              null, // Allow the parent's constraints to determine width
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
