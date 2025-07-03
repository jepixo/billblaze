
import 'dart:math';

import 'package:billblaze/colors.dart';
import 'package:billblaze/components/elevated_button.dart';
import 'package:billblaze/components/navbar/nav_button.dart';
import 'package:billblaze/components/navbar/nav_custom_painter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; 

typedef _LetIndexPage = bool Function(int value);

class CurvedNavigationBar extends StatefulWidget {
  final List<Icon> items;
  final int index;
  final Color color;
  final Color? buttonBackgroundColor;
  final Color backgroundColor;
  final Color buttonIconColor;
  final ValueChanged<int>? onTap;
  final _LetIndexPage letIndexChange;
  final Curve animationCurve;
  final Duration animationDuration;
  final double height;
  final double width;
  final double? maxWidth;

  final double radius;
  final double s;
  final double bottom;

  final double bgHeight;

  final double disp;

  CurvedNavigationBar({
    Key? key,
    required this.items,
    this.index = 0,
    this.color = Colors.white,
    this.buttonBackgroundColor,
    this.backgroundColor = Colors.blueAccent,
    this.buttonIconColor = Colors.black,
    this.onTap,
    _LetIndexPage? letIndexChange,
    this.animationCurve = Curves.easeOut,
    this.animationDuration = const Duration(milliseconds: 600),
    this.height = 75.0,
    this.maxWidth,
    this.radius = 10.0,
    this.s = 0.2,
    this.bottom = 0.45,
    double? width,
    required this.bgHeight,
    this.disp = 50,
  })  : letIndexChange = letIndexChange ?? ((_) => true),
        assert(items.isNotEmpty),
        assert(0 <= index && index < items.length),
        // assert(0 <= height && height <= 75.0),
        assert(maxWidth == null || 0 <= maxWidth),
        width = width ?? 200,
        super(key: key);

  @override
  CurvedNavigationBarState createState() => CurvedNavigationBarState();
}

class CurvedNavigationBarState extends State<CurvedNavigationBar>
    with SingleTickerProviderStateMixin {
  late double _startingPos;
  late int _endingIndex;
  late double _pos;
  double _buttonHide = 0;
  late Icon _icon;
  late AnimationController _animationController;
  late int _length;

  @override
  void initState() {
    super.initState();
    _icon = widget.items[widget.index];
    _length = widget.items.length;
    _pos = widget.index / _length;
    _startingPos = widget.index / _length;
    _endingIndex = widget.index;
    _animationController = AnimationController(vsync: this, value: _pos);
    _animationController.addListener(() {
      setState(() {
        _pos = _animationController.value;
        final endingPos = _endingIndex / widget.items.length;
        final middle = (endingPos + _startingPos) / 2;
        if ((endingPos - _pos).abs() < (_startingPos - _pos).abs()) {
          _icon = widget.items[_endingIndex];
        }
        _buttonHide =
            (1 - ((middle - _pos) / (_startingPos - middle)).abs()).abs();
      });
    });
  }

  @override
  void didUpdateWidget(CurvedNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      final newPosition = widget.index / _length;
      _startingPos = _pos;
      _endingIndex = widget.index;
      _animationController.animateTo(newPosition,
          duration: widget.animationDuration, curve: widget.animationCurve);
    }
    if (!_animationController.isAnimating) {
      _icon = widget.items[_endingIndex];
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textDirection = Directionality.of(context);
    final width = widget.width;
    final sHeight = widget.bgHeight;
    double sWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      height: 61,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = min(
              constraints.maxWidth, widget.maxWidth ?? constraints.maxWidth);
          return Align(
            alignment: textDirection == TextDirection.ltr
                ? Alignment.bottomLeft
                : Alignment.bottomRight,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                // Selected button
                Positioned(
                  bottom: -widget.disp,
                  left: Directionality.of(context) == TextDirection.rtl
                      ? null
                      : _pos * width - 4,
                  right: Directionality.of(context) == TextDirection.rtl
                      ? _pos * width
                      : null,
                  width: (width) / _length,
                  child: IgnorePointer(
                    ignoring: true,
                    // behavior: HitTestBehavior.translucent,
                    child: Center(
                      child: Transform.translate(
                        offset: Offset(2, ((_buttonHide - 1) * 80)),
                        // transformHitTests: true,
                        child: ElevatedLayerButton(
                          onClick: () => setState(() {
                            // print('object');
                          }),
                          buttonHeight: widget.height,
                          buttonWidth: widget.height,
                          borderRadius: BorderRadius.circular(100),
                          animationDuration:
                              const Duration(milliseconds: 200),
                          animationCurve: Curves.ease,
                          topDecoration: BoxDecoration(
                            color: widget.buttonBackgroundColor,
                            border: Border.all(),
                          ),
                          topLayerChild: Transform.rotate(
                            angle: -pi/2,
                            child: Icon(
                              _icon.icon,
                              color: widget.buttonIconColor,
                              size: _icon.size,
                            ),
                          ),
                          baseDecoration: BoxDecoration(
                            color: widget.color,
                            border: Border.all(),
                          ),
                          subfac: 5,
                          depth: 5,
                        ),
                        // Material(
                        //   color: widget.buttonBackgroundColor ?? widget.color,
                        //   type: MaterialType.circle,
                        //   child: Padding(
                        //     padding: EdgeInsets.all(widget.iconPadding),
                        //     child: _icon,
                        //   ),
                        // ),
                      ),
                    ),
                  ),
                ),
                //
                // Background
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: sHeight,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    child: CustomPaint(
                      painter: NavCustomPainter(
                        startingLoc: _pos,
                        itemsLength: _length,
                        color: widget.color,
                        textDirection: Directionality.of(context),
                        hasLabel: false,
                        radius: widget.radius,
                        s: widget.s,
                        bottom: widget.bottom,
                      ),
                      child:
                          //UNselectedIcons
                          Row(
                              children: widget.items.map((item) {
                        return NavButton(
                          onTap: _buttonTap,
                          position: _pos,
                          length: _length,
                          index: widget.items.indexOf(item),
                          child: Center(child: Transform.rotate(
                            angle: 3 * pi / 2,
                            child: item)),
                        );
                      }).toList()),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void setPage(int index) {
    _buttonTap(index);
  }

  void _buttonTap(int index) {
    if (!widget.letIndexChange(index) || _animationController.isAnimating) {
      return;
    }
    if (widget.onTap != null) {
      widget.onTap!(index);
    }
    final newPosition = index / _length;
    setState(() {
      _startingPos = _pos;
      _endingIndex = index;
      _animationController.animateTo(newPosition,
          duration: widget.animationDuration, curve: widget.animationCurve);
    });
  }
}
