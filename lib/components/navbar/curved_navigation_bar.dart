// import 'dart:io';

// import 'package:billblaze/components/curved_navigation_bar_item.dart';
// import 'package:billblaze/components/nav_bar_item_widget.dart';
// import 'package:billblaze/components/nav_custom_painter.dart';
// import 'package:flutter/material.dart';
// import 'package:simple_animated_button/elevated_layer_button.dart';
//
// typedef _LetIndexPage = bool Function(int value);
//
// class CurvedNavigationBar extends StatefulWidget {
//   /// Defines the appearance of the [CurvedNavigationBarItem] list that are
//   /// arrayed within the bottom navigation bar.
//   final List<CurvedNavigationBarItem> items;
//
//   /// The index into [items] for the current active [CurvedNavigationBarItem].
//   final int index;
//
//   /// The color of the [CurvedNavigationBar] itself, default Colors.white.
//   final Color color;
//
//   /// The background color of floating button, default same as [color] attribute.
//   final Color? buttonBackgroundColor;
//
//   /// The color of [CurvedNavigationBar]'s background, default Colors.blueAccent.
//   final Color backgroundColor;
//
//   /// Called when one of the [items] is tapped.
//   final ValueChanged<int>? onTap;
//
//   /// Function which takes page index as argument and returns bool. If function
//   /// returns false then page is not changed on button tap. It returns true by
//   /// default.
//   final _LetIndexPage letIndexChange;
//
//   /// Curves interpolating button change animation, default Curves.easeOut.
//   final Curve animationCurve;
//
//   /// Duration of button change animation, default Duration(milliseconds: 600).
//   final Duration animationDuration;
//
//   /// Height of [CurvedNavigationBar].
//   final double height;
//   final double width;
//
//   /// Padding of icon in floating button.
//   final double iconPadding;
//
//   /// Check if [CurvedNavigationBar] has label.
//   final bool hasLabel;
//
//   final double radius;
//   final double s;
//   final double bottom;
//
//   CurvedNavigationBar({
//     Key? key,
//     required this.items,
//     this.index = 0,
//     this.color = Colors.white,
//     this.buttonBackgroundColor,
//     this.backgroundColor = Colors.blueAccent,
//     this.onTap,
//     _LetIndexPage? letIndexChange,
//     this.animationCurve = Curves.easeOut,
//     this.animationDuration = const Duration(milliseconds: 600),
//     this.iconPadding = 12.0,
//     double? height,
//     double? width,
//     this.radius = 10.0,
//     this.s = 0.2,
//     this.bottom = 0.45,
//   })  : assert(items.isNotEmpty),
//         assert(0 <= index && index < items.length),
//         letIndexChange = letIndexChange ?? ((_) => true),
//         height = height ?? (Platform.isAndroid ? 70.0 : 80.0),
//         width = width ?? 200,
//         hasLabel = items.any((item) => item.label != null),
//         super(key: key);
//
//   @override
//   CurvedNavigationBarState createState() => CurvedNavigationBarState();
// }
//
// class CurvedNavigationBarState extends State<CurvedNavigationBar>
//     with SingleTickerProviderStateMixin {
//   late double _startingPos;
//   late double _pos;
//   late Widget _icon;
//   late AnimationController _animationController;
//   late int _length;
//   int _endingIndex = 0;
//   double _buttonHide = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _icon = widget.items[widget.index].child;
//     _length = widget.items.length;
//     _pos = widget.index / _length;
//     _startingPos = widget.index / _length;
//     _animationController = AnimationController(vsync: this, value: _pos);
//     _animationController.addListener(() {
//       setState(() {
//         _pos = _animationController.value;
//         final endingPos = _endingIndex / widget.items.length;
//         final middle = (endingPos + _startingPos) / 2;
//         if ((endingPos - _pos).abs() < (_startingPos - _pos).abs()) {
//           _icon = widget.items[_endingIndex].child;
//         }
//         _buttonHide =
//             (1 - ((middle - _pos) / (_startingPos - middle)).abs()).abs();
//       });
//     });
//   }
//
//   @override
//   void didUpdateWidget(CurvedNavigationBar oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.index != widget.index) {
//       final newPosition = widget.index / _length;
//       _startingPos = _pos;
//       _endingIndex = widget.index;
//       _animationController.animateTo(
//         newPosition,
//         duration: widget.animationDuration,
//         curve: widget.animationCurve,
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final width = widget.width;
//     return Container(
//       color: widget.backgroundColor,
//       height: widget.height,
//       child: Stack(
//         clipBehavior: Clip.none,
//         alignment: Alignment.bottomCenter,
//         children: <Widget>[
//           // Selected button
//           Positioned(
//             bottom: -widget.height/2.2,
//             left: Directionality.of(context) == TextDirection.rtl
//                 ? null
//                 : _pos * width - 4,
//             right: Directionality.of(context) == TextDirection.rtl
//                 ? _pos * width
//                 : null,
//             width: (width) / _length,
//             child: GestureDetector(
//               behavior: HitTestBehavior.deferToChild,
//               child: Center(
//                 child: Transform.translate(
//                   offset: Offset(0, ((_buttonHide - 1) * 80)),
//                   // transformHitTests: true,
//                   child: ElevatedLayerButton(
//                     onClick: () => setState(() {
//                       print('object');
//                     }),
//                     buttonHeight: widget.height/1.1,
//                     buttonWidth: widget.height/1.1,
//                     borderRadius: BorderRadius.circular(100),
//                     animationDuration: const Duration(milliseconds: 200),
//                     animationCurve: Curves.ease,
//                     topDecoration: BoxDecoration(
//                       color: Colors.green,
//                       // border: Border.all(),
//                     ),
//                     topLayerChild: _icon,
//                     baseDecoration: BoxDecoration(
//                       color: Colors.black,
//                       // border: Border.all(),
//                     ),
//                   ),
//                   // Material(
//                   //   color: widget.buttonBackgroundColor ?? widget.color,
//                   //   type: MaterialType.circle,
//                   //   child: Padding(
//                   //     padding: EdgeInsets.all(widget.iconPadding),
//                   //     child: _icon,
//                   //   ),
//                   // ),
//                 ),
//               ),
//             ),
//           ),
//           //
//           // Positioned(
//           //   left:5,
//           //   // right: 0,
//           //   bottom: 0,
//           //   width: width,
//           //   child: CustomPaint(
//           //     painter: NavCustomPainter(
//           //       startingLoc: _pos,
//           //       itemsLength: _length,
//           //       color: Colors.black,
//           //       textDirection: Directionality.of(context),
//           //       hasLabel: widget.hasLabel,
//           //       radius: widget.radius,
//           //       s: widget.s,
//           //       bottom: widget.bottom,
//           //     ),
//           //     child: Container(height: widget.height),
//           //   ),
//           // ),
//           // //
//           // Background
//           Positioned(
//             left: 0,
//             right: 0,
//             bottom: 0,
//             child: GestureDetector(
//               behavior: HitTestBehavior.translucent,
//               child: CustomPaint(
//                 painter: NavCustomPainter(
//                   startingLoc: _pos,
//                   itemsLength: _length,
//                   color: widget.color,
//                   textDirection: Directionality.of(context),
//                   hasLabel: widget.hasLabel,
//                   radius: widget.radius,
//                   s: widget.s,
//                   bottom: widget.bottom,
//                 ),
//                 child: Container(height: widget.height - 4),
//               ),
//             ),
//           ),
//           // Unselected buttons
//           Positioned(
//             left: 0,
//             right: 0,
//             bottom: 0,
//             child: SizedBox(
//               height: widget.height,
//               child: Row(
//                 children: widget.items.map((item) {
//                   return NavBarItemWidget(
//                     onTap: _buttonTap,
//                     position: _pos,
//                     length: _length,
//                     index: widget.items.indexOf(item),
//                     child: Center(child: item.child),
//                     label: item.label,
//                     labelStyle: item.labelStyle,
//                   );
//                 }).toList(),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void setPage(int index) {
//     _buttonTap(index);
//   }
//
//   void _buttonTap(int index) {
//     if (!widget.letIndexChange(index) || _animationController.isAnimating) {
//       return;
//     }
//     if (widget.onTap != null) {
//       widget.onTap!(index);
//     }
//     final newPosition = index / _length;
//     setState(() {
//       _startingPos = _pos;
//       _endingIndex = index;
//       _animationController.animateTo(
//         newPosition,
//         duration: widget.animationDuration,
//         curve: widget.animationCurve,
//       );
//     });
//   }
// }

import 'dart:io';
import 'dart:math';

import 'package:billblaze/components/navbar/nav_button.dart';
import 'package:billblaze/components/navbar/nav_custom_painter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:simple_animated_button/simple_animated_button.dart';

typedef _LetIndexPage = bool Function(int value);

class CurvedNavigationBar extends StatefulWidget {
  final List<Widget> items;
  final int index;
  final Color color;
  final Color? buttonBackgroundColor;
  final Color backgroundColor;
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

  CurvedNavigationBar({
    Key? key,
    required this.items,
    this.index = 0,
    this.color = Colors.white,
    this.buttonBackgroundColor,
    this.backgroundColor = Colors.blueAccent,
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
  late Widget _icon;
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
    final sHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      height: widget.height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = min(
              constraints.maxWidth, widget.maxWidth ?? constraints.maxWidth);
          return Align(
            alignment: textDirection == TextDirection.ltr
                ? Alignment.bottomLeft
                : Alignment.bottomRight,
            child: Container(
              color: widget.backgroundColor,
              width: maxWidth,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  // Selected button
                  Positioned(
                    bottom: kIsWeb || Platform.isWindows
                        ? -widget.height / 1.5
                        : -widget.height / 2,
                    left: Directionality.of(context) == TextDirection.rtl
                        ? null
                        : _pos * width - 4,
                    right: Directionality.of(context) == TextDirection.rtl
                        ? _pos * width
                        : null,
                    width: (width) / _length,
                    child: GestureDetector(
                      behavior: HitTestBehavior.deferToChild,
                      child: Center(
                        child: Transform.translate(
                          offset: Offset(0, ((_buttonHide - 1) * 80)),
                          // transformHitTests: true,
                          child: ElevatedLayerButton(
                            onClick: () => setState(() {
                              print('object');
                            }),
                            buttonHeight: widget.height / 1.1,
                            buttonWidth: widget.height / 1.1,
                            borderRadius: BorderRadius.circular(100),
                            animationDuration:
                                const Duration(milliseconds: 200),
                            animationCurve: Curves.ease,
                            topDecoration: BoxDecoration(
                              color: Colors.green,
                              // border: Border.all(),
                            ),
                            topLayerChild: _icon,
                            baseDecoration: BoxDecoration(
                              color: Colors.black,
                              // border: Border.all(),
                            ),
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
                    height: sHeight / 12,
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
                            child: Center(child: item),
                          );
                        }).toList()),
                      ),
                    ),
                  ),
                  //
                  //unselected buttons
                  // Positioned(
                  //   left: 0,
                  //   right: 0,
                  //   bottom: kIsWeb
                  //       ? -((widget.height - 4) / 2)
                  //       : -((widget.height - 4) / 2) + sHeight / 40.5,
                  //   child: SizedBox(
                  //       height: 100.0,
                  //       child: Row(
                  //           children: widget.items.map((item) {
                  //         return NavButton(
                  //           onTap: _buttonTap,
                  //           position: _pos,
                  //           length: _length,
                  //           index: widget.items.indexOf(item),
                  //           child: Center(child: item),
                  //         );
                  //       }).toList())),
                  // ),
                ],
              ),
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
