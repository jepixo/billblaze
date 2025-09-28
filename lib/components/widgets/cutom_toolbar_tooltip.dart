import 'package:billblaze/colors.dart';
import 'package:flutter/material.dart';

class CustomToolbarTooltip extends StatefulWidget {
  final Widget child;
  final String message;
  final double letterSpacing;

  const CustomToolbarTooltip({
    Key? key,
    required this.child,
    required this.message,
    this.letterSpacing = 0.2,
  }) : super(key: key);

  @override
  _CustomToolbarTooltipState createState() => _CustomToolbarTooltipState();
}

class _CustomToolbarTooltipState extends State<CustomToolbarTooltip> {
  OverlayEntry? _overlayEntry;

  void _showTooltip(BuildContext context) {
    if (_overlayEntry != null) return; // already showing

    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx + size.width + 8, // place to the right
        top: position.dy + (size.height / 2) - 20, // vertically centered
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: defaultPalette.primary,
              border: Border.all(),
            ),
            child: Text(
              widget.message,
              style: TextStyle(
                fontFamily: 'Lexend',
                color: defaultPalette.extras[0],
                fontSize: 14,
                letterSpacing: widget.letterSpacing,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _showTooltip(context),
      onExit: (_) => _hideTooltip(),
      child: widget.child,
    );
  }
}
