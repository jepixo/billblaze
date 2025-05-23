import 'package:billblaze/colors.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'list_item_model.dart';

class SideBarItem extends StatelessWidget {
  const SideBarItem(
    this.toolbarItem, {
    Key? key,
    required this.height,
    required this.scrollScale,
    this.isLongPressed = false,
    this.isTapped = false,
    this.gutter = 10,
    this.toolbarWidth,
    this.itemsOffset,
  }) : super(key: key);

  final ListItemModel toolbarItem;
  final double height;
  final double scrollScale;
  final bool isLongPressed;
  final double gutter;
  final double? toolbarWidth;
  final double? itemsOffset;
  final bool isTapped;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: toolbarItem.onTap,
        child: SizedBox(
          height: height + gutter,
          // width: Constants.toolbarWidth,
          child: Stack(
            children: [
              AnimatedScale(
                duration: Constants.scrollScaleAnimationDuration,
                curve: Constants.scrollScaleAnimationCurve,
                scale: scrollScale,
                child: AnimatedContainer(
                  duration: Constants.longPressAnimationDuration,
                  curve: Constants.scrollScaleAnimationCurve,
                  height: height + (isLongPressed ? 0 : 0),
                  width: isLongPressed ? toolbarWidth! * 2.5 : height,
                  decoration: BoxDecoration(
                    color: toolbarItem.isTapped
                        ? defaultPalette.tertiary
                        : toolbarItem.color,
                    borderRadius: const BorderRadius.all(Radius.circular(0)),
                    boxShadow: [
                      // BoxShadow(
                      //   blurRadius: 10,
                      //   color: Colors.black.withOpacity(0.1),
                      // ),
                    ],
                  ),
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(
                    bottom: gutter,
                    left: isLongPressed ? itemsOffset! : 0,
                  ),
                ),
              ),
              Positioned.fill(
                child: AnimatedPadding(
                  duration: Constants.longPressAnimationDuration,
                  curve: Constants.longPressAnimationCurve,
                  padding: EdgeInsets.only(
                    bottom: gutter,
                    left: 12 + (isLongPressed ? itemsOffset! : 0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      AnimatedScale(
                        scale: scrollScale,
                        duration: Constants.scrollScaleAnimationDuration,
                        curve: Constants.scrollScaleAnimationCurve,
                        child: Icon(
                          toolbarItem.icon,
                          color: Colors.black,
                          size: height / 2.4,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AnimatedOpacity(
                          opacity: isLongPressed ? 1 : 0,
                          duration: Constants.longPressAnimationDuration,
                          curve: Constants.longPressAnimationCurve,
                          child: Text(
                            toolbarItem.title,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
