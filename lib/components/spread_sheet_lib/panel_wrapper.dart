// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:billblaze/colors.dart';

class PanelWrapper extends ConsumerStatefulWidget {
  final Widget child;
  const PanelWrapper({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PanelWrapperState();
}

class _PanelWrapperState extends ConsumerState<PanelWrapper> {
  @override
  Widget build(BuildContext context) {
    double sWidth = MediaQuery.of(context).size.width;
    double sHeight = MediaQuery.of(context).size.height;
    Widget child = widget.child;
    return AnimatedContainer(
      duration: Duration(microseconds: 1),
      padding: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IgnorePointer(
        ignoring: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Builder(builder: (context) {
              double textfieldSize = 45;

              //  (double.parse(documentPropertiesList[i]
              //             .textFieldControllers[index]
              //             .hintSizeController
              //             .text)
              //         .clamp(12, 20) +
              //     45);
              double tileHeightX = textfieldSize.clamp(45, 92) + 20;
              double tileHeight = tileHeightX - (textfieldSize / 2);
              double buttonsSize = 50;
              Duration positionedDur = Duration(milliseconds: 300);
              // Duration opacityDur = Duration(
              //     milliseconds:
              //         (positionedDur
              //                     .inMilliseconds /
              //                 3)
              //             .round());

              return Stack(
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    height: 50,
                    //   //  selectedIndex[currentPageIndex] == index
                    //   //     ? tileHeightX
                    //   //     : tileHeight,
                    // width: sWidth * 0.8,
                  ),

                  ///individual Textfield
                  AnimatedPositioned(
                    top: 0,
                    // selectedIndex[currentPageIndex] == index
                    //     ? (tileHeightX / 2) - tileHeight / 2
                    //     : 0,
                    duration: Duration(milliseconds: 200),
                    left: ((sWidth * 0.8) / 2) - 75,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(
                          color: defaultPalette.tertiary,
                          //  isReordering
                          //     ? Colors.transparent
                          //     : (selectedIndex[currentPageIndex] == index
                          //         ? defaultPalette.primary
                          //         : Colors.transparent),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: child,
                      // TextFormField(
                      //   maxLines: null,
                      //   // focusNode: documentPropertiesList[i]
                      //   //     .textFieldControllers[index]
                      //   //     .focusController,
                      //   // onTap: () {
                      //   //   documentPropertiesList[i]
                      //   //       .textFieldControllers[index]
                      //   //       .focusController
                      //   //       .requestFocus();
                      //   //   _selectTextField(index);
                      //   // },
                      //   // onTapOutside: (d) {
                      //   //   documentPropertiesList[i]
                      //   //       .textFieldControllers[index]
                      //   //       .focusController
                      //   //       .unfocus();
                      //   // },
                      //   // controller: documentPropertiesList[i]
                      //   //     .textFieldControllers[index]
                      //   //     .textController,
                      //   onChanged: (value) {
                      //     setState(() {});
                      //   },
                      //   decoration: InputDecoration(
                      //     filled: true,
                      //     fillColor: defaultPalette.secondary,
                      //     contentPadding: EdgeInsets.all(10),
                      //     // hintText: documentPropertiesList[i]
                      //     //     .textFieldControllers[index]
                      //     //     .hintController
                      //     //     .text,
                      //     // hintStyle: TextStyle(
                      //     //   fontSize: double.parse(documentPropertiesList[i]
                      //     //               .textFieldControllers[index]
                      //     //               .hintSizeController
                      //     //               .text) >
                      //     //           25
                      //     //       ? 20
                      //     //       : double.parse(documentPropertiesList[i]
                      //     //           .textFieldControllers[index]
                      //     //           .hintSizeController
                      //     //           .text),
                      //     //   color: Color(int.parse(documentPropertiesList[i]
                      //     //       .textFieldControllers[index]
                      //     //       .colorController
                      //     //       .text
                      //     //       .replaceFirst('#', '0xff'))),
                      //     // ),
                      //     border: InputBorder.none,
                      //   ),
                      //   // style: TextStyle(
                      //   //   color: documentPropertiesList[i]
                      //   //       .textFieldControllers[index]
                      //   //       .style
                      //   //       .color,
                      //   //   fontSize: documentPropertiesList[i]
                      //   //               .textFieldControllers[index]
                      //   //               .style
                      //   //               .fontSize! >
                      //   //           25
                      //   //       ? 20
                      //   //       : documentPropertiesList[i]
                      //   //           .textFieldControllers[index]
                      //   //           .style
                      //   //           .fontSize,
                      //   // ),
                      // ),
                    ),
                  ),

                  // // Left side button
                  buildAnimatedPositioned(
                    // selectedIndex: selectedIndex[currentPageIndex],
                    // currentPageIndex: currentPageIndex,
                    // index: index,
                    currentPageIndex: 1,
                    index: 0,
                    selectedIndex: 1,
                    top: (tileHeightX / 2) - buttonsSize / 2,
                    left: ((sWidth * 0.8) / 2) - 125,
                    initialTop: 0,
                    initialLeft: -(sWidth * 0.8) / 2,
                    width: 90,
                    height: buttonsSize,
                    opacity: 1,
                    duration: positionedDur,
                    containerHeight: 25,
                    containerWidth: 25,
                    containerColor: defaultPalette.primary,
                    iconColor: defaultPalette.secondary,
                  ),
                  // Right side button
                  buildAnimatedPositioned(
                    // selectedIndex: selectedIndex[currentPageIndex],
                    // currentPageIndex: currentPageIndex,
                    // index: index,
                    currentPageIndex: 1,
                    index: 0,
                    selectedIndex: 1,
                    top: (tileHeightX / 2) - (buttonsSize / 2),
                    left: ((sWidth * 0.8) / 2) + 35,
                    initialTop: 0,
                    initialLeft: sWidth * 0.8,
                    width: 90,
                    height: 50,
                    opacity: 1,
                    duration: positionedDur,
                    containerHeight: 25,
                    containerWidth: 25,
                    containerColor: defaultPalette.primary,
                    iconColor: defaultPalette.secondary,
                  ),
                  // North side button
                  buildAnimatedPositioned(
                    // selectedIndex: selectedIndex[currentPageIndex],
                    // currentPageIndex: currentPageIndex,
                    // index: index,
                    currentPageIndex: 1,
                    index: 0,
                    selectedIndex: 1,
                    top: (tileHeightX / 2) -
                        (tileHeight / 2) -
                        (buttonsSize / 2),
                    left: ((sWidth * 0.8) / 2) - 45,
                    initialTop: -tileHeightX,
                    initialLeft: ((sWidth * 0.8) / 2) - 45,
                    width: 90,
                    height: 50,
                    opacity: 1,
                    duration: positionedDur,
                    containerHeight: 25,
                    containerWidth: 25,
                    containerColor: defaultPalette.primary,
                    iconColor: defaultPalette.secondary,
                  ),
                  // South side button
                  buildAnimatedPositioned(
                    // selectedIndex: selectedIndex[currentPageIndex],
                    // currentPageIndex: currentPageIndex,
                    // index: index,
                    currentPageIndex: 1,
                    index: 0,
                    selectedIndex: 1,
                    top: (tileHeightX / 2) +
                        (tileHeight / 2) -
                        (buttonsSize / 2),
                    left: ((sWidth * 0.8) / 2) - 45,
                    initialTop: tileHeightX,
                    initialLeft: ((sWidth * 0.8) / 2) - 45,
                    width: 90,
                    height: 50,
                    opacity: 1,
                    duration: positionedDur,
                    containerHeight: 25,
                    containerWidth: 25,
                    containerColor: defaultPalette.primary,
                    iconColor: defaultPalette.secondary,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

AnimatedPositioned buildAnimatedPositioned({
  required int selectedIndex,
  required int currentPageIndex,
  required int index,
  required double top,
  required double left,
  required double initialTop,
  required double initialLeft,
  required double width,
  required double height,
  required double opacity,
  required Duration duration,
  required double containerHeight,
  required double containerWidth,
  required Color containerColor,
  required Color iconColor,
}) {
  Duration opacityDur =
      Duration(milliseconds: (duration.inMilliseconds / 2).round());
  return AnimatedPositioned(
    top: selectedIndex == index ? top : initialTop,
    left: selectedIndex == index ? left : initialLeft,
    duration: duration,
    height: height,
    width: width,
    child: AnimatedOpacity(
      duration: opacityDur,
      opacity: selectedIndex == index ? opacity : 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: duration,
            height: containerHeight,
            width: containerWidth,
            decoration: BoxDecoration(
              color: containerColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add,
              color: iconColor,
            ),
          ),
        ],
      ),
    ),
  );
}
