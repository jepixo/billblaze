// ignore_for_file: must_be_immutable
library animated_search_bar;

import 'package:billblaze/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpandableSearchBar extends StatefulWidget {
  ExpandableSearchBar({
    Key? key,
    required this.onTap,
    required this.hintText,
    required this.editTextController,
    required this.focusNode,
    required this.onChange,
    this.width = 200,
    this.iconSize = 45,
    this.gutter = 20,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.fastOutSlowIn,
    this.textFieldAnimationDuration = const Duration(milliseconds: 200),
    this.textFieldAnimationCurve = Curves.easeInOut,
    this.iconBoxShadow,
    this.iconColor = const Color(0xff47E10C),
    this.iconBackgroundColor = const Color(0xff353535),
    this.boxShadow = const [
      BoxShadow(
        color: Colors.black38,
        spreadRadius: 4,
        blurRadius: 2,
        offset: Offset(0, 2),
      ),
    ],
    this.backgroundColor = const Color(0xff101010),
  }) : super(key: key);

  /// Search icon onTap function
  final void Function()? onTap;

  /// Animated bar width.
  final double? width;

  /// Suffix icon width.
  final FocusNode focusNode;
  ///
  final void Function(String value) onChange;
  /// Note: this icon is a sizedBox widget.
  final double? iconSize;

  /// Some extra space for expanded bar.
  final double? gutter;

  /// Hint text for textField inside expandable bar.
  final String? hintText;

  /// Animation duration for expandable bar.
  ///
  /// default is 500 milliseconds
  final Duration animationDuration;

  /// Animation curve for expandable bar.
  ///
  /// Default is Curves.fastOutSlowIn
  ///
  /// Note: Other curves may be glitchy.
  final Cubic animationCurve;

  /// Animation duration for textField.
  ///
  /// Default is 200 milliseconds
  final Duration textFieldAnimationDuration;

  /// Animation curve for textField.
  ///
  /// Default is Curves.easeInOut
  final Cubic textFieldAnimationCurve;

  /// Controller for textfield
  TextEditingController? editTextController;

  /// Shadow for icon button.
  final List<BoxShadow>? iconBoxShadow;

  /// Button Icon color.
  /// If not set default will be:
  /// ```dart
  /// const Color(0xff47E10C)
  /// ```
  final Color iconColor;

  /// Button Icon color.
  /// If not set default will be:
  /// ```dart
  ///const Color(0xff353535)
  /// ```
  final Color iconBackgroundColor;

  /// Shadow for animated bar.
  /// If not set default will be :
  /// ```dart
  /// [
  ///   BoxShadow(
  ///     color: Colors.black38,
  ///     spreadRadius: 4,
  ///     blurRadius: 2,
  ///     offset: Offset(0, 2),
  ///   ),
  /// ]
  /// ```
  final List<BoxShadow>? boxShadow;

  /// Background color for animated bar.
  /// If not set default will be:
  /// ```dart
  /// const Color(0xff101010)
  /// ```
  final Color backgroundColor;

  @override
  State<ExpandableSearchBar> createState() => _ExpandableSearchBarState();
}

class _ExpandableSearchBarState extends State<ExpandableSearchBar> {
  bool isSearchbarHidden = true;
  @override
  Widget build(BuildContext context) {
    // bool amIHovering = false;
    // Offset exitFrom = const Offset(0, 0);
    return MouseRegion(
      onEnter: (details) => setState(() {
        // TODO: make it also available for mobile devices
        // amIHovering = true;
        isSearchbarHidden = false;
      }),
      onExit: (details) => setState(() {
        // amIHovering = false;
        if (widget.editTextController!.text == '') {
          isSearchbarHidden = true;
        }
        // You can use details.position if you are interested in the global position of your pointer.
        // exitFrom = details.localPosition;
      }),
      child: AnimatedContainer(
        width: isSearchbarHidden
            ? widget.iconSize
            : widget.width! + (widget.gutter as double),
        duration: widget.animationDuration,
        curve: widget.animationCurve,
        padding: isSearchbarHidden
            ? const EdgeInsets.all(2).copyWith(right: 0)
            : const EdgeInsets.all(4).copyWith(left: 14,),
        decoration: BoxDecoration(
          color:!isSearchbarHidden? widget.backgroundColor: widget.iconBackgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(30)),
          boxShadow: widget.boxShadow,
        ),
        child: Stack(
          children: [
            AnimatedContainer(
              width: isSearchbarHidden
                  ? 0.0
                  : widget.width! - (widget.iconSize as double),
              height: widget.iconSize,
              duration: widget.textFieldAnimationDuration,
              curve: widget.textFieldAnimationCurve,
              child: TextFormField(
                controller: widget.editTextController,
                focusNode: widget.focusNode,
                onChanged: widget.onChange,
                style: GoogleFonts.lexend(
                      color: defaultPalette.extras[0],
                      letterSpacing: -1,
                      fontWeight: FontWeight.w400,
                      fontSize: 16
                      ),
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.all(0),
                  floatingLabelAlignment:
                      FloatingLabelAlignment.center,
                  hintStyle: GoogleFonts.lexend(
                      color: defaultPalette.extras[0],
                      letterSpacing: -1,
                      fontWeight: FontWeight.w400,
                      fontSize: 16
                      ),
                  hintText: widget.hintText,
                  border: InputBorder.none,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius:
                        BorderRadius.circular(
                            5.0), // Same as border
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius:
                        BorderRadius.circular(
                            5.0), // Same as border
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius:
                        BorderRadius.circular(
                            5.0), // Same as border
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              child: InkWell(
                borderRadius: const BorderRadius.all(Radius.circular(30)),
                onTap: widget.onTap,
                child: RoundSearchIcon(
                  width: widget.iconSize!+1,
                  backgroundColor:isSearchbarHidden? widget.iconBackgroundColor:widget.backgroundColor,
                  iconColor: widget.iconColor,
                  boxShadow: widget.iconBoxShadow,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RoundSearchIcon extends StatelessWidget {
  const RoundSearchIcon({
    Key? key,
    this.width = 41,
    this.boxShadow,
    this.iconColor = const Color(0xff47E10C),
    this.backgroundColor = const Color(0xff353535),
  }) : super(key: key);
  final double? width;
  final List<BoxShadow>? boxShadow;
  final Color iconColor;
  final Color backgroundColor;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(30)),
      child: Container(
        // padding: const EdgeInsets.all(2),
        width: width,
        height: width,
        decoration: BoxDecoration(
          color: backgroundColor,
          boxShadow: boxShadow,
        ),
        child: Icon(
          Icons.search_rounded,
          color: iconColor,
        ),
      ),
    );
  }
}