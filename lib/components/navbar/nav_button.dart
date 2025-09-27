import 'package:billblaze/colors.dart';
import 'package:flutter/material.dart';

class NavButton extends StatefulWidget {
  final double position;
  final int length;
  final int index;
  final ValueChanged<int> onTap;
  final Widget child;
  final int selectedIndex;

  const NavButton({
    required this.onTap,
    required this.position,
    required this.length,
    required this.index,
    required this.child,
    required this.selectedIndex,
    Key? key,
  }) : super(key: key);

  @override
  State<NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<NavButton> {
  bool _hovering = false;
  @override
  void didUpdateWidget(covariant NavButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If this button just became selected, kill hover state immediately
    if (widget.selectedIndex == widget.index && oldWidget.selectedIndex != widget.index) {
      setState(() {
        _hovering = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final desiredPosition = 1.0 / widget.length * widget.index;
    final difference = (widget.position - desiredPosition).abs();
    final verticalAlignment = 1 - widget.length * difference;
    final opacity = widget.length * difference;

    final isSelected = widget.selectedIndex == widget.index;

    return Expanded(
      child: MouseRegion(
        onEnter: (_) => setState((){ 
            
           _hovering = true;
           print( _hovering);
           }),
        onExit: (_) => setState(() => _hovering = false),
        child: Material(
          color: defaultPalette.transparent,
          child: InkWell(
            key: ValueKey(_hovering),
            highlightColor:(_hovering &&!isSelected)? defaultPalette.black.withOpacity(0.2): defaultPalette.transparent,
            splashColor:(_hovering &&!isSelected)? defaultPalette.black.withOpacity(0.2): defaultPalette.transparent,
            hoverColor: (!isSelected &&_hovering)
                ? defaultPalette.black.withOpacity(0.3)
                : defaultPalette.transparent,
            onTap: () => widget.onTap(widget.index),
            child: Container(
              height: 75.0,
              child: Transform.translate(
                offset: Offset(
                    0, difference < 1.0 / widget.length ? verticalAlignment * 40 : 0),
                child: Opacity(
                  opacity: difference < 1.0 / widget.length * 0.99 ? opacity : 1.0,
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
