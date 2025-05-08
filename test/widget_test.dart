// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:billblaze/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MainApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}




    // return Stack(
    //   children: [

    //     Transform.translate(
    //       offset:Offset(whichPropertyTabIsClicked==2?0: sWidth,0),
    //       child: AppinioSwiper(
    //           backgroundCardCount: 1,
    //           backgroundCardOffset: Offset(4, 4),
    //           duration: Duration(milliseconds: 150),
    //           backgroundCardScale: 1,
    //           loop: true,
    //           cardCount: 3,
    //           allowUnSwipe: true,
    //           allowUnlimitedUnSwipe: true,
    //           initialIndex: whichTextPropertyTabIsClicked,
    //           controller: textPropertyCardsController,
    //           onCardPositionChanged: (position) {
    //             setState(() {
    //               _cardPosition =
    //                   position.offset.dx.abs() + position.offset.dy.abs();
    //               // print(_cardPosition);
    //             });
    //           },
    //           onSwipeEnd: (a, b, direction) {
    //             // print(direction.toString());
    //             setState(() {
    //               // if (_cardPosition > 50) {
    //               //   currentPageIndex = (currentPageIndex + 1) % pageCount;
    //               //   _renderPagePreviewOnProperties();
    //               // }
    //               whichTextPropertyTabIsClicked = b;
    //               textPropertyTabContainerController.index =
    //                   whichTextPropertyTabIsClicked;
    //               _cardPosition = 0;
    //             });
    //           },
    //           onSwipeCancelled: (activity) {
    //             setState(() {
    //               // currentPageIndex =
    //               //     (currentPageIndex - 1) % pageCount;
    //             });
    //           },
    //           cardBuilder: (BuildContext context, int index) {
    //             int currentCardIndex = whichTextPropertyTabIsClicked;
          
    //             bool _getIsToggled(
    //                 Map<String, Attribute> attrs, Attribute attribute) {
    //               if (attribute.key == Attribute.list.key ||
    //                   attribute.key == Attribute.header.key ||
    //                   attribute.key == Attribute.script.key ||
    //                   attribute.key == Attribute.align.key) {
    //                 final currentAttribute = attrs[attribute.key];
    //                 if (currentAttribute == null) {
    //                   // print('returning false');
    //                   return false;
    //                 }
    //                 // print(
    //                 // 'returning ${currentAttribute.value == attribute.value}');
    //                 return currentAttribute.value == attribute.value;
    //               }
    //               // print('returning ${attrs.containsKey(attribute.key)}');
    //               return attrs.containsKey(attribute.key);
    //             }
          
    //             Widget buildElevatedLayerButton(
    //                 {required double buttonHeight,
    //                 required double buttonWidth,
    //                 required Duration animationDuration,
    //                 required Curve animationCurve,
    //                 required void Function() onClick,
    //                 required BoxDecoration baseDecoration,
    //                 required BoxDecoration topDecoration,
    //                 required Widget topLayerChild,
    //                 required BorderRadius borderRadius,
    //                 bool toggleOnTap = false,
    //                 bool isTapped = false,
    //                 double elevation = 5}) {
    //               var down = isTapped;
    //               void _handleTapDown(TapDownDetails details) {
    //                 onClick();
          
    //                 setState(() {
    //                   down = true;
    //                   print(down);
    //                 });
    //               }
          
    //               void _handleTapUp(TapUpDetails details) {
    //                 if (!toggleOnTap && down) {
    //                   setState(() {
    //                     down = !down;
    //                   });
    //                 }
    //               }
          
    //               void _handleTapCancel() {}
          
    //               return GestureDetector(
    //                 onTap: () {},
    //                 onTapDown: _handleTapDown,
    //                 onTapUp: _handleTapUp,
    //                 onTapCancel: _handleTapCancel,
    //                 child: SizedBox(
    //                   height: buttonHeight,
    //                   width: buttonWidth,
    //                   child: Stack(
    //                     alignment: Alignment.bottomRight,
    //                     children: [
    //                       Positioned(
    //                         bottom: 0,
    //                         right: 0,
    //                         child: Container(
    //                           width: buttonWidth - 10,
    //                           height: buttonHeight - 10,
    //                           decoration: baseDecoration.copyWith(
    //                             borderRadius: borderRadius,
    //                           ),
    //                         ),
    //                       ),
    //                       AnimatedPositioned(
    //                         duration: animationDuration,
    //                         curve: animationCurve,
    //                         bottom: !down ? elevation : 0,
    //                         right: !down ? elevation : 0,
    //                         child: Container(
    //                           width: buttonWidth - 10,
    //                           height: buttonHeight - 10,
    //                           alignment: Alignment.center,
    //                           decoration: topDecoration.copyWith(
    //                             borderRadius: borderRadius,
    //                           ),
    //                           child: topLayerChild,
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //               );
    //             }
          
    //             var width = (sWidth * wH2DividerPosition - 30);
          
    //             TextEditingController hexController = TextEditingController()
    //               ..text =
    //                   '${item.textEditorController.getSelectionStyle().attributes['color']?.value ?? '#00000000'}';
    //             TextEditingController bghexController = TextEditingController()
    //               ..text =
    //                   '${(item.textEditorController.getSelectionStyle().attributes['background']?.value ?? '#00000000')}';
    //             TextEditingController strokeHexController = TextEditingController()
    //               ..text =
    //                   '${(item.textEditorController.getSelectionStyle().attributes['stroke']?.value?.split(',')[0] ?? '#000000')}';
          
    //             TextEditingController fontSizeController = TextEditingController()
    //               ..text =
    //                   '${double.parse(item.textEditorController.getSelectionStyle().attributes['size']?.value ?? '0')}';
    //             if (fontSizeController.text.endsWith('.0')) {
    //               fontSizeController.text =
    //                   '${double.parse(item.textEditorController.getSelectionStyle().attributes['size']?.value ?? '0').ceil()}';
    //             }
    //             TextEditingController letterSpaceController =
    //                 TextEditingController()
    //                   ..text =
    //                       '${double.parse(item.textEditorController.getSelectionStyle().attributes[LetterSpacingAttribute._key]?.value ?? '0')}';
    //             if (letterSpaceController.text.endsWith('.0')) {
    //               letterSpaceController.text =
    //                   letterSpaceController.text.replaceAll('.0', '');
    //             }
    //             TextEditingController wordSpaceController = TextEditingController()
    //               ..text =
    //                   '${double.parse(item.textEditorController.getSelectionStyle().attributes[WordSpacingAttribute._key]?.value ?? '0')}';
    //             if (wordSpaceController.text.endsWith('.0')) {
    //               wordSpaceController.text =
    //                   wordSpaceController.text.replaceAll('.0', '');
    //             }
    //             TextEditingController lineSpaceController = TextEditingController()
    //               ..text =
    //                   '${double.parse(item.textEditorController.getSelectionStyle().attributes[LineHeightAttribute._key]?.value ?? '0')}';
    //             if (lineSpaceController.text.endsWith('.0')) {
    //               lineSpaceController.text =
    //                   lineSpaceController.text.replaceAll('.0', '');
    //             }
    //             TextEditingController strokeWidthController =
    //                 TextEditingController();
    //             int crossAxisCount = 4;
    //             var iconWidth = width / crossAxisCount;
    //             var iconHeight = iconWidth;
    //             var fCrossAxisCount = width < 150
    //                 ? 1
    //                 : width > 300
    //                     ? width > 420
    //                         ? 4
    //                         : 3
    //                     : 2;
    //             return Stack(
    //               children: [
    //                 //The main bgCOLOR OF THE CARD
    //                 Positioned.fill(
    //                   child: AnimatedContainer(
    //                     duration: Durations.short3,
    //                     margin: EdgeInsets.all(10).copyWith(left: 5, right: 8),
    //                     alignment: Alignment.center,
    //                     decoration: BoxDecoration(
    //                       color: defaultPalette.secondary,
    //                       border: Border.all(width: 2),
    //                       borderRadius: BorderRadius.circular(25),
    //                     ),
    //                   ),
    //                 ),
    //                 //OPACITY OF BGCOLOR OF THE CARD
    //                 Positioned.fill(
    //                   child: AnimatedOpacity(
    //                     opacity: currentCardIndex == index
    //                         ? 0
    //                         // : index >= (currentCardIndex + 2) % 10
    //                         //     ? 1
    //                         : (1 - (_cardPosition / 200).clamp(0.0, 1.0)),
    //                     duration: Duration(milliseconds: 300),
    //                     child: AnimatedContainer(
    //                       duration: Duration(milliseconds: 300),
    //                       margin:
    //                           EdgeInsets.all(10).copyWith(left: 5, right: 10),
    //                       alignment: Alignment.center,
    //                       decoration: BoxDecoration(
    //                         color: index == (currentCardIndex + 1) % 10
    //                             ? defaultPalette.extras[0]
    //                             : index == (currentCardIndex + 2) % 10
    //                                 ? defaultPalette.extras[0]
    //                                 : defaultPalette.extras[0],
    //                         border: Border.all(width: 2),
    //                         borderRadius: BorderRadius.circular(25),
    //                       ),
    //                     ),
    //                   ),
    //                 ),
    //                 if (index == 0)
    //                   //FONTS //Desktop WEB
    //                   Positioned.fill(
    //                     child: Stack(
    //                       children: [
    //                         //GRAPH BEHIND FONT CARD
    //                         Padding(
    //                           padding: const EdgeInsets.all(10),
    //                           child: ClipRRect(
    //                             borderRadius: BorderRadius.circular(25),
    //                             child: Opacity(
    //                               opacity: 0.35,
    //                               child: SizedBox(
    //                                 width: sWidth,
    //                                 height: sHeight,
    //                                 child: LineChart(LineChartData(
    //                                     lineBarsData: [LineChartBarData()],
    //                                     titlesData:
    //                                         const FlTitlesData(show: false),
    //                                     gridData: FlGridData(
    //                                         getDrawingVerticalLine: (value) =>
    //                                             FlLine(
    //                                                 color: defaultPalette.extras[0]
    //                                                     .withOpacity(0.8),
    //                                                 dashArray: [5, 5],
    //                                                 strokeWidth: 1),
    //                                         getDrawingHorizontalLine: (value) =>
    //                                             FlLine(
    //                                                 color: defaultPalette
    //                                                     .extras[0]
    //                                                     .withOpacity(0.8),
    //                                                 dashArray: [5, 5],
    //                                                 strokeWidth: 1),
    //                                         show: true,
    //                                         horizontalInterval: 10,
    //                                         verticalInterval: 50),
    //                                     borderData: FlBorderData(show: false),
    //                                     minY: 0,
    //                                     maxY: 50,
    //                                     maxX: dateTimeNow.millisecondsSinceEpoch
    //                                                 .ceilToDouble() /
    //                                             500 +
    //                                         250,
    //                                     minX: dateTimeNow.millisecondsSinceEpoch.ceilToDouble() / 500)),
    //                               ),
    //                             ),
    //                           ),
    //                         ),
          
    //                         //FONT CARD
    //                         Container(
    //                           height: sHeight * 0.9,
    //                           width: width + 4,
    //                           margin: const EdgeInsets.only(
    //                               top: 120, left: 10, bottom: 22, right: 0),
    //                           child: ClipRRect(
    //                             borderRadius: const BorderRadius.only(
    //                                 bottomLeft: Radius.circular(22),
    //                                 bottomRight: Radius.circular(22)),
    //                             child: TabContainer(
    //                               tabs: [
    //                                 // Text('ss'),
    //                                 // Text('d'),
    //                                 // Text('s'),
    //                                 // Text('h'),
    //                                 // Text('m'),
    //                                 Icon(
    //                                   TablerIcons.search,
    //                                   size: selectedFontCategory == 'search'
    //                                       ? 0
    //                                       : 15,
    //                                   color: defaultPalette.extras[0],
    //                                 ),
    //                                 Icon(
    //                                   TablerIcons.circle,
    //                                   size: 15,
    //                                   color: defaultPalette.extras[0],
    //                                 ),
    //                                 Icon(
    //                                   TablerIcons.circles,
    //                                   size: 15,
    //                                   color: defaultPalette.extras[0],
    //                                 ),
    //                                 Icon(
    //                                   TablerIcons.circle_dashed,
    //                                   size: 15,
    //                                   color: defaultPalette.extras[0],
    //                                 ),
    //                                 Icon(
    //                                   TablerIcons.oval_vertical,
    //                                   size: 15,
    //                                   color: defaultPalette.extras[0],
    //                                 ),
    //                                 Icon(
    //                                   TablerIcons.grain,
    //                                   size: 15,
    //                                   color: defaultPalette.extras[0],
    //                                 ),
    //                               ],
    //                               tabEdge: TabEdge.left,
    //                               controller: fontsTabContainerController,
    //                               borderRadius: BorderRadius.circular(12),
    //                               tabExtent: 25,
    //                               tabsStart: 0,
    //                               tabsEnd: 1,
    //                               colors: [
    //                                 defaultPalette.tertiary,
    //                                 defaultPalette.tertiary,
    //                                 defaultPalette.tertiary,
    //                                 defaultPalette.tertiary,
    //                                 defaultPalette.tertiary,
    //                                 defaultPalette.tertiary,
    //                                 // defaultPalette.extras[4],
    //                                 // defaultPalette.extras[5]
    //                               ],
    //                               selectedTextStyle: GoogleFonts.abrilFatface(
    //                                 fontSize: 14,
    //                                 color: defaultPalette.extras[0],
    //                               ),
    //                               unselectedTextStyle: GoogleFonts.abrilFatface(
    //                                 fontSize: 12,
    //                                 color: defaultPalette.primary,
    //                               ),
    //                               children: [
    //                                 //SEARCH RESULT TAB
    //                                 Container(
    //                                   decoration: BoxDecoration(
    //                                     color: defaultPalette.primary,
    //                                     borderRadius: const BorderRadius.only(
    //                                         topLeft: Radius.circular(10),
    //                                         topRight: Radius.circular(10),
    //                                         bottomLeft: Radius.circular(10),
    //                                         bottomRight: Radius.circular(22)),
    //                                   ),
    //                                   margin: const EdgeInsets.only(
    //                                       top: 55,
    //                                       left: 3,
    //                                       right: 3,
    //                                       bottom: 3),
    //                                   child: ClipRRect(
    //                                     borderRadius: const BorderRadius.only(
    //                                         topLeft: Radius.circular(10),
    //                                         topRight: Radius.circular(10),
    //                                         bottomLeft: Radius.circular(10),
    //                                         bottomRight: Radius.circular(22)),
    //                                     child: GridView.builder(
    //                                       gridDelegate:
    //                                           SliverGridDelegateWithFixedCrossAxisCount(
    //                                         crossAxisCount: fCrossAxisCount,
    //                                         childAspectRatio: 2.8,
    //                                         crossAxisSpacing: 5,
    //                                         mainAxisSpacing: 0,
    //                                       ),
    //                                       itemCount: filteredFonts.length,
    //                                       itemBuilder: (context, index) {
    //                                         final fontName =
    //                                             filteredFonts[index];
          
    //                                         return Padding(
    //                                           padding: const EdgeInsets.only(
    //                                               bottom: 5),
    //                                           child: TextButton(
    //                                               style: TextButton.styleFrom(
    //                                                 backgroundColor: item
    //                                                             .textEditorController
    //                                                             .getSelectionStyle()
    //                                                             .attributes[
    //                                                                 Attribute
    //                                                                     .font
    //                                                                     .key]
    //                                                             ?.value ==
    //                                                         GoogleFonts.getFont(
    //                                                                 fontName)
    //                                                             .fontFamily
    //                                                     ? defaultPalette
    //                                                         .tertiary
    //                                                     : defaultPalette
    //                                                         .primary,
    //                                                 foregroundColor:
    //                                                     defaultPalette
    //                                                         .extras[0],
    //                                                 minimumSize: Size(75, 75),
    //                                                 shape: RoundedRectangleBorder(
    //                                                     // side: item.textEditorController
    //                                                     //             .getSelectionStyle()
    //                                                     //             .attributes[
    //                                                     //                 Attribute
    //                                                     //                     .font
    //                                                     //                     .key]
    //                                                     //             ?.value ==
    //                                                     //         GoogleFonts.getFont(
    //                                                     //                 fontName)
    //                                                     //             .fontFamily
    //                                                     //     ? BorderSide(
    //                                                     //         color: defaultPalette
    //                                                     //             .extras[0] ,
    //                                                     //         width: 0.8)
    //                                                     //     : BorderSide.none,
    //                                                     // borderRadius:
    //                                                     //     BorderRadius
    //                                                     //         .circular(5),
    //                                                     ),
    //                                               ),
    //                                               onPressed: () {
    //                                                 item.textEditorController
    //                                                     .formatSelection(
    //                                                   Attribute.fromKeyValue(
    //                                                     Attribute.font.key,
    //                                                     GoogleFonts.getFont(
    //                                                                     fontName)
    //                                                                 .fontFamily ==
    //                                                             'Clear'
    //                                                         ? null
    //                                                         : GoogleFonts
    //                                                                 .getFont(
    //                                                                     fontName)
    //                                                             .fontFamily,
    //                                                   ),
    //                                                 );
    //                                                 setState(() {});
    //                                               },
    //                                               child: Text(
    //                                                 fontName,
    //                                                 textAlign: TextAlign.center,
    //                                                 style: GoogleFonts.getFont(
    //                                                     fontName,
    //                                                     fontSize: 14),
    //                                                 maxLines: 1,
    //                                               )),
    //                                         );
    //                                       },
    //                                     ),
    //                                   ),
    //                                 ),
    //                                 //OTHER FONT CATEGORIES TABS
    //                                 ...categorizedFonts.keys.map((category) {
    //                                   final fontsInCategory =
    //                                       categorizedFonts[category]!
    //                                           .where((font) =>
    //                                               GoogleFonts.asMap()
    //                                                   .containsKey(font))
    //                                           .toList();
          
    //                                   if (fontsInCategory.isEmpty) {
    //                                     return Center(
    //                                       child: Text(
    //                                         'No fonts available in this category.',
    //                                         style: TextStyle(
    //                                             color: Colors.grey,
    //                                             fontSize: 16),
    //                                       ),
    //                                     );
    //                                   }
    //                                   final fontName = fontsInCategory[index];
    //                                   return Container(
    //                                     decoration: BoxDecoration(
    //                                       color: defaultPalette.primary,
    //                                       borderRadius: const BorderRadius.only(
    //                                           topLeft: Radius.circular(10),
    //                                           topRight: Radius.circular(10),
    //                                           bottomLeft: Radius.circular(10),
    //                                           bottomRight: Radius.circular(22)),
    //                                     ),
    //                                     margin: const EdgeInsets.only(
    //                                         top: 3,
    //                                         left: 3,
    //                                         right: 3,
    //                                         bottom: 35),
    //                                     child: ClipRRect(
    //                                       borderRadius: const BorderRadius.only(
    //                                           topLeft: Radius.circular(10),
    //                                           topRight: Radius.circular(10),
    //                                           bottomLeft: Radius.circular(10),
    //                                           bottomRight: Radius.circular(22)),
    //                                       child: DynMouseScroll(
    //                                           durationMS: 500,
    //                                           scrollSpeed: 1,
    //                                           builder: (context, controller,
    //                                               physics) {
    //                                             return GridView.builder(
    //                                               gridDelegate:
    //                                                   SliverGridDelegateWithFixedCrossAxisCount(
    //                                                 crossAxisCount:
    //                                                     fCrossAxisCount,
    //                                                 childAspectRatio: 2.8,
    //                                                 crossAxisSpacing: 0,
    //                                                 mainAxisSpacing: 0,
    //                                               ),
    //                                               itemCount:
    //                                                   fontsInCategory.length,
    //                                               controller: controller,
    //                                               physics: physics,
    //                                               itemBuilder:
    //                                                   (context, index) {
    //                                                 final fontName =
    //                                                     fontsInCategory[index];
          
    //                                                 return Padding(
    //                                                   padding:
    //                                                       const EdgeInsets.only(
    //                                                           bottom: 5),
    //                                                   child: TextButton(
    //                                                       style: TextButton
    //                                                           .styleFrom(
    //                                                         backgroundColor: item
    //                                                                     .textEditorController
    //                                                                     .getSelectionStyle()
    //                                                                     .attributes[Attribute
    //                                                                         .font
    //                                                                         .key]
    //                                                                     ?.value ==
    //                                                                 GoogleFonts.getFont(
    //                                                                         fontName)
    //                                                                     .fontFamily
    //                                                             ? defaultPalette
    //                                                                 .tertiary
    //                                                             : defaultPalette
    //                                                                 .primary,
    //                                                         foregroundColor:
    //                                                             defaultPalette
    //                                                                 .extras[0],
    //                                                         minimumSize:
    //                                                             Size(75, 75),
    //                                                         shape:
    //                                                             RoundedRectangleBorder(),
    //                                                       ),
    //                                                       onPressed: () {
    //                                                         item.textEditorController
    //                                                             .formatSelection(
    //                                                           Attribute
    //                                                               .fromKeyValue(
    //                                                             Attribute
    //                                                                 .font.key,
    //                                                             GoogleFonts.getFont(fontName)
    //                                                                         .fontFamily ==
    //                                                                     'Clear'
    //                                                                 ? null
    //                                                                 : GoogleFonts.getFont(
    //                                                                         fontName)
    //                                                                     .fontFamily,
    //                                                           ),
    //                                                         );
    //                                                         setState(() {});
    //                                                       },
    //                                                       child: Text(
    //                                                         fontName,
    //                                                         textAlign: TextAlign
    //                                                             .center,
    //                                                         style: GoogleFonts.getFont(
    //                                                             color: defaultPalette
    //                                                                 .extras[0],
    //                                                             fontName,
    //                                                             fontSize: 14),
    //                                                         maxLines: 1,
    //                                                       )),
    //                                                 );
    //                                               },
    //                                             );
    //                                           }),
    //                                     ),
    //                                   );
    //                                 }).toList()
    //                               ],
    //                             ),
    //                           ),
    //                         ),
          
    //                         //FONT TITLE TEXT
    //                         Positioned(
    //                             left: 30,
    //                             top: 30,
    //                             width: width * 1.5,
    //                             child: Text('FONTS',
    //                                 textAlign: TextAlign.start,
    //                                 style: GoogleFonts.bungee(
    //                                     color: defaultPalette.extras[0],
    //                                     fontSize: (width / 6).clamp(5, 30)))),
    //                         //SELECTED FONT Green STRIP
    //                         Positioned(
    //                             left: 30,
    //                             top: 70,
    //                             width: width - 8,
    //                             child: Container(
    //                               width: width,
    //                               padding: const EdgeInsets.only(
    //                                   left: 10, top: 3, bottom: 3),
    //                               margin: EdgeInsets.only(
    //                                   right: index == currentCardIndex ? 0 : 5),
    //                               decoration: BoxDecoration(
    //                                   color: defaultPalette.tertiary,
    //                                   borderRadius: BorderRadius.only(
    //                                     topLeft: Radius.circular(12),
    //                                     bottomLeft: Radius.circular(12),
    //                                   )),
    //                               child: Text(
    //                                   (item.textEditorController
    //                                           .getSelectionStyle()
    //                                           .attributes[Attribute.font.key]
    //                                           ?.value
    //                                           ?.replaceAll(
    //                                               RegExp(r'_regular'), '') ??
    //                                       'mixedfonts'),
    //                                   textAlign: TextAlign.start,
    //                                   maxLines: 1,
    //                                   style: TextStyle(
    //                                       fontFamily: (item.textEditorController
    //                                               .getSelectionStyle()
    //                                               .attributes[
    //                                                   Attribute.font.key]
    //                                               ?.value ??
    //                                           null),
    //                                       color: defaultPalette.primary,
    //                                       fontSize:
    //                                           (width / 20).clamp(15, 20))),
    //                             )),
    //                         //CURRENT TAB
    //                         Positioned(
    //                             left: 55,
    //                             bottom: 25,
    //                             width: width,
    //                             child: Text(
    //                                 selectedFontCategory == 'search'
    //                                     ? ''
    //                                     : selectedFontCategory,
    //                                 textAlign: TextAlign.start,
    //                                 maxLines: 1,
    //                                 style: GoogleFonts.leagueSpartan(
    //                                     color: defaultPalette.primary,
    //                                     fontSize: (width / 7).clamp(10, 20),
    //                                     letterSpacing: 0))),
    //                         //
    //                         if (selectedFontCategory == 'search')
    //                           //Search BAR TEXTFIELDFORM
    //                           Positioned(
    //                             right: 23,
    //                             top: 122,
    //                             width: width,
    //                             child: TextFormField(
    //                               style: GoogleFonts.bungee(
    //                                   color: defaultPalette.primary,
    //                                   fontSize: (width / 6).clamp(5, 15)),
    //                               cursorColor: defaultPalette.primary,
    //                               decoration: InputDecoration(
    //                                 // labelText: 'Search Fonts',
    //                                 hintText: 'Type to search fonts...',
    //                                 focusColor: defaultPalette.primary,
    //                                 hintStyle: GoogleFonts.leagueSpartan(
    //                                     fontSize: 15,
    //                                     color: defaultPalette.primary),
    //                                 prefixIcon: Icon(TablerIcons.search,
    //                                     color: defaultPalette.primary),
    //                                 border: OutlineInputBorder(
    //                                   borderSide: BorderSide(
    //                                     color: defaultPalette.primary,
    //                                   ),
    //                                   gapPadding: 2,
    //                                   borderRadius: BorderRadius.circular(12),
    //                                 ),
    //                               ),
    //                               onChanged: (query) {
    //                                 setState(() {
    //                                   // Flatten and filter fonts from categorizedFonts, excluding invalid ones
    //                                   filteredFonts = categorizedFonts.entries
    //                                       .expand((entry) => entry
    //                                           .value) // Combine all font lists
    //                                       .where((font) =>
    //                                           font.toLowerCase().contains(query
    //                                               .toLowerCase()) && // Filter by query
    //                                           GoogleFonts.asMap().containsKey(
    //                                               font)) // Check validity
    //                                       .toList();
          
    //                                   print(filteredFonts); // Debugging output
    //                                 });
    //                               },
    //                             ),
    //                           ),
    //                       ],
    //                     ),
    //                   ),
          
    //                 if (index == 1) ...[
    //                   //GRAPH BEHIND FORMAT CARD
    //                   Padding(
    //                     padding: const EdgeInsets.all(10),
    //                     child: ClipRRect(
    //                       borderRadius: BorderRadius.circular(25),
    //                       child: Opacity(
    //                         opacity: 0.35,
    //                         child: LineChart(LineChartData(
    //                             lineBarsData: [LineChartBarData()],
    //                             titlesData: const FlTitlesData(show: false),
    //                             gridData: FlGridData(
    //                                 getDrawingVerticalLine: (value) => FlLine(
    //                                     color: defaultPalette.extras[0]
    //                                         .withOpacity(0.8),
    //                                     dashArray: [5, 5],
    //                                     strokeWidth: 1),
    //                                 getDrawingHorizontalLine: (value) => FlLine(
    //                                     color: defaultPalette.extras[0]
    //                                         .withOpacity(0.8),
    //                                     dashArray: [5, 5],
    //                                     strokeWidth: 1),
    //                                 show: true,
    //                                 horizontalInterval: 4,
    //                                 verticalInterval: 40),
    //                             borderData: FlBorderData(show: false),
    //                             minY: 0,
    //                             maxY: 50,
    //                             maxX: dateTimeNow.millisecondsSinceEpoch
    //                                         .ceilToDouble() /
    //                                     500 +
    //                                 250,
    //                             minX: dateTimeNow.millisecondsSinceEpoch
    //                                     .ceilToDouble() /
    //                                 500)),
    //                       ),
    //                     ),
    //                   ),
    //                   //FORMATTING ALL THAT PAGE  //Desktop WEB
    //                   Positioned.fill(
    //                     child: Container(
    //                       width: width,
    //                       height: sHeight * 0.9,
    //                       decoration: BoxDecoration(
    //                         borderRadius: BorderRadius.circular(20),
    //                       ),
    //                       margin: EdgeInsets.only(
    //                           top: 20,
    //                           bottom: index == currentCardIndex ? 20 : 23,
    //                           left: 10,
    //                           right: 10),
    //                       child: ClipRRect(
    //                         borderRadius: BorderRadius.circular(20),
    //                         child: Stack(
    //                           children: [
    //                             DynMouseScroll(
    //                                 durationMS: 500,
    //                                 scrollSpeed: 1,
    //                                 builder: (context, controller, physics) {
    //                                   return SingleChildScrollView(
    //                                     controller: controller,
    //                                     physics: physics,
    //                                     child: Column(
    //                                       crossAxisAlignment:
    //                                           CrossAxisAlignment.start,
    //                                       children: [
    //                                         //FORMAT TITLE TEXT
    //                                         Container(
    //                                           width: width,
    //                                           padding: EdgeInsets.only(
    //                                               left: 10, top: 12, bottom: 5),
    //                                           margin: EdgeInsets.only(
    //                                               left: 3, top: 3, bottom: 3),
    //                                           decoration: BoxDecoration(),
    //                                           child: Text('FORMAT',
    //                                               textAlign: TextAlign.start,
    //                                               maxLines: 1,
    //                                               style: TextStyle(
    //                                                   height: 1,
    //                                                   fontFamily:
    //                                                       GoogleFonts.bungee()
    //                                                           .fontFamily,
    //                                                   color: defaultPalette
    //                                                       .extras[0],
    //                                                   fontSize: (width / 6)
    //                                                       .clamp(15, 30))),
    //                                         ),
          
    //                                         // BOLD ITALIC UNDERLINE STRIKETHRU // LEFT RIGHT CENTER JUSTIFY
    //                                         SizedBox(
    //                                           width: width,
    //                                           height: iconHeight * 2,
    //                                           child: GridView.builder(
    //                                             physics:
    //                                                 NeverScrollableScrollPhysics(),
    //                                             itemCount: 8,
    //                                             padding: EdgeInsets.all(0),
    //                                             gridDelegate:
    //                                                 SliverGridDelegateWithFixedCrossAxisCount(
    //                                               crossAxisCount: 4,
    //                                               crossAxisSpacing: 0,
    //                                               mainAxisSpacing: 0,
    //                                               // mainAxisExtent: width/3
    //                                             ),
    //                                             itemBuilder:
    //                                                 (BuildContext context,
    //                                                     int index) {
    //                                               switch (index) {
    //                                                 case 0:
    //                                                   // BOLD
    //                                                   return buildElevatedLayerButton(
    //                                                     buttonHeight:
    //                                                         iconHeight,
    //                                                     buttonWidth: iconWidth,
    //                                                     toggleOnTap: true,
    //                                                     isTapped: _getIsToggled(
    //                                                         item.textEditorController
    //                                                             .getSelectionStyle()
    //                                                             .attributes,
    //                                                         Attribute.bold),
    //                                                     animationDuration:
    //                                                         const Duration(
    //                                                             milliseconds:
    //                                                                 100),
    //                                                     animationCurve:
    //                                                         Curves.ease,
    //                                                     onClick: () {
    //                                                       final currentValue = item
    //                                                           .textEditorController
    //                                                           .getSelectionStyle()
    //                                                           .attributes
    //                                                           .containsKey(
    //                                                               Attribute.bold
    //                                                                   .key);
    //                                                       item.textEditorController
    //                                                           .formatSelection(
    //                                                         currentValue
    //                                                             ? Attribute.clone(
    //                                                                 Attribute
    //                                                                     .bold,
    //                                                                 null)
    //                                                             : Attribute
    //                                                                 .bold,
    //                                                       );
    //                                                     },
    //                                                     baseDecoration:
    //                                                         BoxDecoration(
    //                                                       color: Colors.green,
    //                                                       border: Border.all(),
    //                                                     ),
    //                                                     topDecoration:
    //                                                         BoxDecoration(
    //                                                       color: Colors.white,
    //                                                       border: Border.all(),
    //                                                     ),
    //                                                     topLayerChild: Icon(
    //                                                       TablerIcons.bold,
    //                                                       color: Colors.black,
    //                                                       size: 20,
    //                                                     ),
    //                                                     borderRadius:
    //                                                         BorderRadius
    //                                                             .circular(10),
    //                                                   );
    //                                                 case 1:
    //                                                   //ITALIC
    //                                                   return buildElevatedLayerButton(
    //                                                     buttonHeight:
    //                                                         iconHeight,
    //                                                     buttonWidth: iconWidth,
    //                                                     toggleOnTap: true,
    //                                                     isTapped: _getIsToggled(
    //                                                         item.textEditorController
    //                                                             .getSelectionStyle()
    //                                                             .attributes,
    //                                                         Attribute.italic),
    //                                                     animationDuration:
    //                                                         const Duration(
    //                                                             milliseconds:
    //                                                                 100),
    //                                                     animationCurve:
    //                                                         Curves.ease,
    //                                                     onClick: () {
    //                                                       final currentValue = item
    //                                                           .textEditorController
    //                                                           .getSelectionStyle()
    //                                                           .attributes
    //                                                           .containsKey(
    //                                                               Attribute
    //                                                                   .italic
    //                                                                   .key);
    //                                                       item.textEditorController
    //                                                           .formatSelection(
    //                                                         currentValue
    //                                                             ? Attribute.clone(
    //                                                                 Attribute
    //                                                                     .italic,
    //                                                                 null)
    //                                                             : Attribute
    //                                                                 .italic,
    //                                                       );
    //                                                     },
    //                                                     baseDecoration:
    //                                                         BoxDecoration(
    //                                                       color: Colors.green,
    //                                                       border: Border.all(),
    //                                                     ),
    //                                                     topDecoration:
    //                                                         BoxDecoration(
    //                                                       color: Colors.white,
    //                                                       border: Border.all(),
    //                                                     ),
    //                                                     topLayerChild: Icon(
    //                                                       TablerIcons.italic,
    //                                                       color: Colors.black,
    //                                                       size: 20,
    //                                                     ),
    //                                                     borderRadius:
    //                                                         BorderRadius
    //                                                             .circular(10),
    //                                                   );
    //                                                 case 2:
    //                                                   //UNDERLINE
    //                                                   return buildElevatedLayerButton(
    //                                                     buttonHeight:
    //                                                         iconHeight,
    //                                                     buttonWidth: iconWidth,
    //                                                     toggleOnTap: true,
    //                                                     isTapped: _getIsToggled(
    //                                                         item.textEditorController
    //                                                             .getSelectionStyle()
    //                                                             .attributes,
    //                                                         Attribute
    //                                                             .underline),
    //                                                     animationDuration:
    //                                                         const Duration(
    //                                                             milliseconds:
    //                                                                 100),
    //                                                     animationCurve:
    //                                                         Curves.ease,
    //                                                     onClick: () {
    //                                                       final currentValue = item
    //                                                           .textEditorController
    //                                                           .getSelectionStyle()
    //                                                           .attributes
    //                                                           .containsKey(
    //                                                               Attribute
    //                                                                   .underline
    //                                                                   .key);
    //                                                       item.textEditorController
    //                                                           .formatSelection(
    //                                                         currentValue
    //                                                             ? Attribute.clone(
    //                                                                 Attribute
    //                                                                     .underline,
    //                                                                 null)
    //                                                             : Attribute
    //                                                                 .underline,
    //                                                       );
    //                                                     },
    //                                                     baseDecoration:
    //                                                         BoxDecoration(
    //                                                       color: Colors.green,
    //                                                       border: Border.all(),
    //                                                     ),
    //                                                     topDecoration:
    //                                                         BoxDecoration(
    //                                                       color: Colors.white,
    //                                                       border: Border.all(),
    //                                                     ),
    //                                                     topLayerChild: Icon(
    //                                                       TablerIcons.underline,
    //                                                       color: Colors.black,
    //                                                       size: 20,
    //                                                     ),
    //                                                     borderRadius:
    //                                                         BorderRadius
    //                                                             .circular(10),
    //                                                   );
    //                                                 case 3:
    //                                                   //STRIKETHRU
    //                                                   return buildElevatedLayerButton(
    //                                                     buttonHeight:
    //                                                         iconHeight,
    //                                                     buttonWidth: iconWidth,
    //                                                     toggleOnTap: true,
    //                                                     isTapped: _getIsToggled(
    //                                                         item.textEditorController
    //                                                             .getSelectionStyle()
    //                                                             .attributes,
    //                                                         Attribute
    //                                                             .strikeThrough),
    //                                                     animationDuration:
    //                                                         const Duration(
    //                                                             milliseconds:
    //                                                                 100),
    //                                                     animationCurve:
    //                                                         Curves.ease,
    //                                                     onClick: () {
    //                                                       final currentValue = item
    //                                                           .textEditorController
    //                                                           .getSelectionStyle()
    //                                                           .attributes
    //                                                           .containsKey(Attribute
    //                                                               .strikeThrough
    //                                                               .key);
    //                                                       item.textEditorController
    //                                                           .formatSelection(
    //                                                         currentValue
    //                                                             ? Attribute.clone(
    //                                                                 Attribute
    //                                                                     .strikeThrough,
    //                                                                 null)
    //                                                             : Attribute
    //                                                                 .strikeThrough,
    //                                                       );
    //                                                     },
    //                                                     baseDecoration:
    //                                                         BoxDecoration(
    //                                                       color: Colors.green,
    //                                                       border: Border.all(),
    //                                                     ),
    //                                                     topDecoration:
    //                                                         BoxDecoration(
    //                                                       color: Colors.white,
    //                                                       border: Border.all(),
    //                                                     ),
    //                                                     topLayerChild: Icon(
    //                                                       TablerIcons
    //                                                           .strikethrough,
    //                                                       color: Colors.black,
    //                                                       size: 20,
    //                                                     ),
    //                                                     borderRadius:
    //                                                         BorderRadius
    //                                                             .circular(10),
    //                                                   );
    //                                                 case 4:
    //                                                   //LEFT ALIGN
    //                                                   return buildElevatedLayerButton(
    //                                                     buttonHeight:
    //                                                         iconHeight,
    //                                                     buttonWidth: iconWidth,
    //                                                     toggleOnTap: true,
    //                                                     isTapped: _getIsToggled(
    //                                                         item.textEditorController
    //                                                             .getSelectionStyle()
    //                                                             .attributes,
    //                                                         Attribute
    //                                                             .leftAlignment),
    //                                                     animationDuration:
    //                                                         const Duration(
    //                                                             milliseconds:
    //                                                                 100),
    //                                                     animationCurve:
    //                                                         Curves.ease,
    //                                                     onClick: () {
    //                                                       var currentValue = _getIsToggled(
    //                                                           item.textEditorController
    //                                                               .getSelectionStyle()
    //                                                               .attributes,
    //                                                           Attribute
    //                                                               .leftAlignment);
    //                                                       item.textEditorController
    //                                                           .formatSelection(
    //                                                         currentValue
    //                                                             ? Attribute.clone(
    //                                                                 Attribute
    //                                                                     .leftAlignment,
    //                                                                 null)
    //                                                             : Attribute
    //                                                                 .leftAlignment,
    //                                                       );
    //                                                       final uncurrentValue = item
    //                                                           .textEditorController
    //                                                           .getSelectionStyle()
    //                                                           .attributes
    //                                                           .containsKey(Attribute
    //                                                               .rightAlignment
    //                                                               .key);
    //                                                       if (uncurrentValue &&
    //                                                           currentValue) {
    //                                                         item.textEditorController
    //                                                             .formatSelection(
    //                                                           Attribute.clone(
    //                                                               Attribute
    //                                                                   .leftAlignment,
    //                                                               null),
    //                                                         );
    //                                                         currentValue = _getIsToggled(
    //                                                             item.textEditorController
    //                                                                 .getSelectionStyle()
    //                                                                 .attributes,
    //                                                             Attribute
    //                                                                 .leftAlignment);
    //                                                       }
    //                                                       print(
    //                                                           '$uncurrentValue && $currentValue');
    //                                                       if (uncurrentValue &&
    //                                                           !currentValue) {
    //                                                         print('un');
    //                                                         print(
    //                                                             uncurrentValue);
    //                                                         item.textEditorController
    //                                                             .formatSelection(
    //                                                                 Attribute.clone(
    //                                                                     Attribute
    //                                                                         .rightAlignment,
    //                                                                     null));
    //                                                         item.textEditorController
    //                                                             .formatSelection(
    //                                                           Attribute
    //                                                               .leftAlignment,
    //                                                         );
    //                                                         setState(() {
    //                                                           currentValue = _getIsToggled(
    //                                                               item.textEditorController
    //                                                                   .getSelectionStyle()
    //                                                                   .attributes,
    //                                                               Attribute
    //                                                                   .leftAlignment);
    //                                                         });
    //                                                         print('cu');
    //                                                         print(currentValue);
    //                                                         return;
    //                                                       }
    //                                                       item.textEditorController
    //                                                           .formatSelection(
    //                                                         currentValue
    //                                                             ? Attribute.clone(
    //                                                                 Attribute
    //                                                                     .leftAlignment,
    //                                                                 null)
    //                                                             : Attribute
    //                                                                 .leftAlignment,
    //                                                       );
    //                                                     },
    //                                                     baseDecoration:
    //                                                         BoxDecoration(
    //                                                       color: Colors.green,
    //                                                       border: Border.all(),
    //                                                     ),
    //                                                     topDecoration:
    //                                                         BoxDecoration(
    //                                                       color: Colors.white,
    //                                                       border: Border.all(),
    //                                                     ),
    //                                                     topLayerChild: Icon(
    //                                                       TablerIcons
    //                                                           .align_left,
    //                                                       color: Colors.black,
    //                                                       size: 20,
    //                                                     ),
    //                                                     borderRadius:
    //                                                         BorderRadius
    //                                                             .circular(10),
    //                                                   );
    //                                                 case 5:
    //                                                   //RIGHT ALIGN
    //                                                   return buildElevatedLayerButton(
    //                                                     buttonHeight:
    //                                                         iconHeight,
    //                                                     buttonWidth: iconWidth,
    //                                                     toggleOnTap: true,
    //                                                     isTapped: _getIsToggled(
    //                                                         item.textEditorController
    //                                                             .getSelectionStyle()
    //                                                             .attributes,
    //                                                         Attribute
    //                                                             .rightAlignment),
    //                                                     animationDuration:
    //                                                         const Duration(
    //                                                             milliseconds:
    //                                                                 100),
    //                                                     animationCurve:
    //                                                         Curves.ease,
    //                                                     onClick: () {
    //                                                       var currentValue = _getIsToggled(
    //                                                           item.textEditorController
    //                                                               .getSelectionStyle()
    //                                                               .attributes,
    //                                                           Attribute
    //                                                               .rightAlignment);
    //                                                       item.textEditorController
    //                                                           .formatSelection(
    //                                                         currentValue
    //                                                             ? Attribute.clone(
    //                                                                 Attribute
    //                                                                     .rightAlignment,
    //                                                                 null)
    //                                                             : Attribute
    //                                                                 .rightAlignment,
    //                                                       );
    //                                                       final uncurrentValue = item
    //                                                           .textEditorController
    //                                                           .getSelectionStyle()
    //                                                           .attributes
    //                                                           .containsKey(Attribute
    //                                                               .leftAlignment
    //                                                               .key);
    //                                                       if (uncurrentValue &&
    //                                                           currentValue) {
    //                                                         item.textEditorController
    //                                                             .formatSelection(
    //                                                           Attribute.clone(
    //                                                               Attribute
    //                                                                   .rightAlignment,
    //                                                               null),
    //                                                         );
    //                                                         currentValue = _getIsToggled(
    //                                                             item.textEditorController
    //                                                                 .getSelectionStyle()
    //                                                                 .attributes,
    //                                                             Attribute
    //                                                                 .rightAlignment);
    //                                                       }
    //                                                       print(
    //                                                           '$uncurrentValue && $currentValue');
    //                                                       if (uncurrentValue &&
    //                                                           !currentValue) {
    //                                                         print('un');
    //                                                         print(
    //                                                             uncurrentValue);
    //                                                         item.textEditorController
    //                                                             .formatSelection(
    //                                                                 Attribute.clone(
    //                                                                     Attribute
    //                                                                         .leftAlignment,
    //                                                                     null));
    //                                                         item.textEditorController
    //                                                             .formatSelection(
    //                                                           Attribute
    //                                                               .rightAlignment,
    //                                                         );
    //                                                         setState(() {
    //                                                           currentValue = _getIsToggled(
    //                                                               item.textEditorController
    //                                                                   .getSelectionStyle()
    //                                                                   .attributes,
    //                                                               Attribute
    //                                                                   .rightAlignment);
    //                                                         });
    //                                                         print('cu');
    //                                                         print(currentValue);
    //                                                         return;
    //                                                       }
    //                                                       item.textEditorController
    //                                                           .formatSelection(
    //                                                         currentValue
    //                                                             ? Attribute.clone(
    //                                                                 Attribute
    //                                                                     .rightAlignment,
    //                                                                 null)
    //                                                             : Attribute
    //                                                                 .rightAlignment,
    //                                                       );
    //                                                     },
    //                                                     baseDecoration:
    //                                                         BoxDecoration(
    //                                                       color: Colors.green,
    //                                                       border: Border.all(),
    //                                                     ),
    //                                                     topDecoration:
    //                                                         BoxDecoration(
    //                                                       color: Colors.white,
    //                                                       border: Border.all(),
    //                                                     ),
    //                                                     topLayerChild: Icon(
    //                                                       TablerIcons
    //                                                           .align_right,
    //                                                       color: Colors.black,
    //                                                       size: 20,
    //                                                     ),
    //                                                     borderRadius:
    //                                                         BorderRadius
    //                                                             .circular(10),
    //                                                   );
    //                                                 case 6:
    //                                                   //CENTER ALIGN
    //                                                   return buildElevatedLayerButton(
    //                                                     buttonHeight:
    //                                                         iconHeight,
    //                                                     buttonWidth: iconWidth,
    //                                                     toggleOnTap: true,
    //                                                     isTapped: _getIsToggled(
    //                                                         item.textEditorController
    //                                                             .getSelectionStyle()
    //                                                             .attributes,
    //                                                         Attribute
    //                                                             .centerAlignment),
    //                                                     animationDuration:
    //                                                         const Duration(
    //                                                             milliseconds:
    //                                                                 100),
    //                                                     animationCurve:
    //                                                         Curves.ease,
    //                                                     onClick: () {
    //                                                       var currentValue = _getIsToggled(
    //                                                           item.textEditorController
    //                                                               .getSelectionStyle()
    //                                                               .attributes,
    //                                                           Attribute
    //                                                               .centerAlignment);
    //                                                       item.textEditorController
    //                                                           .formatSelection(
    //                                                         currentValue
    //                                                             ? Attribute.clone(
    //                                                                 Attribute
    //                                                                     .centerAlignment,
    //                                                                 null)
    //                                                             : Attribute
    //                                                                 .centerAlignment,
    //                                                       );
    //                                                     },
    //                                                     baseDecoration:
    //                                                         BoxDecoration(
    //                                                       color: Colors.green,
    //                                                       border: Border.all(),
    //                                                     ),
    //                                                     topDecoration:
    //                                                         BoxDecoration(
    //                                                       color: Colors.white,
    //                                                       border: Border.all(),
    //                                                     ),
    //                                                     topLayerChild: Icon(
    //                                                       TablerIcons
    //                                                           .align_center,
    //                                                       color: Colors.black,
    //                                                       size: 20,
    //                                                     ),
    //                                                     borderRadius:
    //                                                         BorderRadius
    //                                                             .circular(10),
    //                                                   );
    //                                                 case 7:
    //                                                   //JUSTIFY ALIGN
    //                                                   return buildElevatedLayerButton(
    //                                                     buttonHeight:
    //                                                         iconHeight,
    //                                                     buttonWidth: iconWidth,
    //                                                     toggleOnTap: true,
    //                                                     isTapped: _getIsToggled(
    //                                                         item.textEditorController
    //                                                             .getSelectionStyle()
    //                                                             .attributes,
    //                                                         Attribute
    //                                                             .justifyAlignment),
    //                                                     animationDuration:
    //                                                         const Duration(
    //                                                             milliseconds:
    //                                                                 100),
    //                                                     animationCurve:
    //                                                         Curves.ease,
    //                                                     onClick: () {
    //                                                       var currentValue = _getIsToggled(
    //                                                           item.textEditorController
    //                                                               .getSelectionStyle()
    //                                                               .attributes,
    //                                                           Attribute
    //                                                               .justifyAlignment);
    //                                                       item.textEditorController
    //                                                           .formatSelection(
    //                                                         currentValue
    //                                                             ? Attribute.clone(
    //                                                                 Attribute
    //                                                                     .justifyAlignment,
    //                                                                 null)
    //                                                             : Attribute
    //                                                                 .justifyAlignment,
    //                                                       );
    //                                                     },
    //                                                     baseDecoration:
    //                                                         BoxDecoration(
    //                                                       color: Colors.green,
    //                                                       border: Border.all(),
    //                                                     ),
    //                                                     topDecoration:
    //                                                         BoxDecoration(
    //                                                       color: Colors.white,
    //                                                       border: Border.all(),
    //                                                     ),
    //                                                     topLayerChild: Icon(
    //                                                       TablerIcons
    //                                                           .align_justified,
    //                                                       color: Colors.black,
    //                                                       size: 20,
    //                                                     ),
    //                                                     borderRadius:
    //                                                         BorderRadius
    //                                                             .circular(10),
    //                                                   );
          
    //                                                 default:
    //                                                   return Container();
    //                                               }
    //                                             },
    //                                           ),
    //                                         ),
    //                                         // SUPER, SUBS, LTR, RTL
    //                                         SizedBox(
    //                                             width: width,
    //                                             height: iconHeight * 1,
    //                                             child: Row(
    //                                               children: [
    //                                                 //SUBSCRIPT
    //                                                 buildElevatedLayerButton(
    //                                                   buttonHeight: iconHeight,
    //                                                   buttonWidth:
    //                                                       iconWidth * 2,
    //                                                   toggleOnTap: true,
    //                                                   isTapped: _getIsToggled(
    //                                                       item.textEditorController
    //                                                           .getSelectionStyle()
    //                                                           .attributes,
    //                                                       Attribute.subscript),
    //                                                   animationDuration:
    //                                                       const Duration(
    //                                                           milliseconds:
    //                                                               100),
    //                                                   animationCurve:
    //                                                       Curves.ease,
    //                                                   onClick: () {
    //                                                     var currentValue =
    //                                                         _getIsToggled(
    //                                                             item.textEditorController
    //                                                                 .getSelectionStyle()
    //                                                                 .attributes,
    //                                                             Attribute
    //                                                                 .subscript);
    //                                                     item.textEditorController
    //                                                         .formatSelection(
    //                                                       currentValue
    //                                                           ? Attribute.clone(
    //                                                               Attribute
    //                                                                   .subscript,
    //                                                               null)
    //                                                           : Attribute
    //                                                               .subscript,
    //                                                     );
    //                                                     final uncurrentValue = item
    //                                                         .textEditorController
    //                                                         .getSelectionStyle()
    //                                                         .attributes
    //                                                         .containsKey(
    //                                                             Attribute
    //                                                                 .superscript
    //                                                                 .key);
    //                                                     if (uncurrentValue &&
    //                                                         currentValue) {
    //                                                       item.textEditorController
    //                                                           .formatSelection(
    //                                                         Attribute.clone(
    //                                                             Attribute
    //                                                                 .subscript,
    //                                                             null),
    //                                                       );
    //                                                       currentValue = _getIsToggled(
    //                                                           item.textEditorController
    //                                                               .getSelectionStyle()
    //                                                               .attributes,
    //                                                           Attribute
    //                                                               .subscript);
    //                                                     }
    //                                                     print(
    //                                                         '$uncurrentValue && $currentValue');
    //                                                     if (uncurrentValue &&
    //                                                         !currentValue) {
    //                                                       print('un');
    //                                                       print(uncurrentValue);
    //                                                       item.textEditorController
    //                                                           .formatSelection(
    //                                                               Attribute.clone(
    //                                                                   Attribute
    //                                                                       .superscript,
    //                                                                   null));
    //                                                       item.textEditorController
    //                                                           .formatSelection(
    //                                                         Attribute.subscript,
    //                                                       );
    //                                                       setState(() {
    //                                                         currentValue = _getIsToggled(
    //                                                             item.textEditorController
    //                                                                 .getSelectionStyle()
    //                                                                 .attributes,
    //                                                             Attribute
    //                                                                 .subscript);
    //                                                       });
    //                                                       print('cu');
    //                                                       print(currentValue);
    //                                                       return;
    //                                                     }
    //                                                     item.textEditorController
    //                                                         .formatSelection(
    //                                                       currentValue
    //                                                           ? Attribute.clone(
    //                                                               Attribute
    //                                                                   .subscript,
    //                                                               null)
    //                                                           : Attribute
    //                                                               .subscript,
    //                                                     );
    //                                                   },
    //                                                   baseDecoration:
    //                                                       BoxDecoration(
    //                                                     color: Colors.green,
    //                                                     border: Border.all(),
    //                                                   ),
    //                                                   topDecoration:
    //                                                       BoxDecoration(
    //                                                     color: Colors.white,
    //                                                     border: Border.all(),
    //                                                   ),
    //                                                   topLayerChild: Icon(
    //                                                     TablerIcons.subscript,
    //                                                     color: Colors.black,
    //                                                     size: 20,
    //                                                   ),
    //                                                   borderRadius:
    //                                                       BorderRadius.circular(
    //                                                           10),
    //                                                 ),
    //                                                 //SUPERSCIPT
    //                                                 buildElevatedLayerButton(
    //                                                   buttonHeight: iconHeight,
    //                                                   buttonWidth:
    //                                                       iconWidth * 2,
    //                                                   toggleOnTap: true,
    //                                                   isTapped: _getIsToggled(
    //                                                       item.textEditorController
    //                                                           .getSelectionStyle()
    //                                                           .attributes,
    //                                                       Attribute
    //                                                           .superscript),
    //                                                   animationDuration:
    //                                                       const Duration(
    //                                                           milliseconds:
    //                                                               100),
    //                                                   animationCurve:
    //                                                       Curves.ease,
    //                                                   onClick: () {
    //                                                     var currentValue = _getIsToggled(
    //                                                         item.textEditorController
    //                                                             .getSelectionStyle()
    //                                                             .attributes,
    //                                                         Attribute
    //                                                             .superscript);
    //                                                     item.textEditorController
    //                                                         .formatSelection(
    //                                                       currentValue
    //                                                           ? Attribute.clone(
    //                                                               Attribute
    //                                                                   .superscript,
    //                                                               null)
    //                                                           : Attribute
    //                                                               .superscript,
    //                                                     );
    //                                                     final uncurrentValue = item
    //                                                         .textEditorController
    //                                                         .getSelectionStyle()
    //                                                         .attributes
    //                                                         .containsKey(
    //                                                             Attribute
    //                                                                 .subscript
    //                                                                 .key);
    //                                                     if (uncurrentValue &&
    //                                                         currentValue) {
    //                                                       item.textEditorController
    //                                                           .formatSelection(
    //                                                         Attribute.clone(
    //                                                             Attribute
    //                                                                 .superscript,
    //                                                             null),
    //                                                       );
    //                                                       currentValue = _getIsToggled(
    //                                                           item.textEditorController
    //                                                               .getSelectionStyle()
    //                                                               .attributes,
    //                                                           Attribute
    //                                                               .superscript);
    //                                                     }
    //                                                     print(
    //                                                         '$uncurrentValue && $currentValue');
    //                                                     if (uncurrentValue &&
    //                                                         !currentValue) {
    //                                                       print('un');
    //                                                       print(uncurrentValue);
    //                                                       item.textEditorController
    //                                                           .formatSelection(
    //                                                               Attribute.clone(
    //                                                                   Attribute
    //                                                                       .subscript,
    //                                                                   null));
    //                                                       item.textEditorController
    //                                                           .formatSelection(
    //                                                         Attribute
    //                                                             .superscript,
    //                                                       );
    //                                                       setState(() {
    //                                                         currentValue = _getIsToggled(
    //                                                             item.textEditorController
    //                                                                 .getSelectionStyle()
    //                                                                 .attributes,
    //                                                             Attribute
    //                                                                 .superscript);
    //                                                       });
    //                                                       print('cu');
    //                                                       print(currentValue);
    //                                                       return;
    //                                                     }
    //                                                     item.textEditorController
    //                                                         .formatSelection(
    //                                                       currentValue
    //                                                           ? Attribute.clone(
    //                                                               Attribute
    //                                                                   .superscript,
    //                                                               null)
    //                                                           : Attribute
    //                                                               .superscript,
    //                                                     );
    //                                                   },
    //                                                   baseDecoration:
    //                                                       BoxDecoration(
    //                                                     color: Colors.green,
    //                                                     border: Border.all(),
    //                                                   ),
    //                                                   topDecoration:
    //                                                       BoxDecoration(
    //                                                     color: Colors.white,
    //                                                     border: Border.all(),
    //                                                   ),
    //                                                   topLayerChild: Icon(
    //                                                     TablerIcons.superscript,
    //                                                     color: Colors.black,
    //                                                     size: 20,
    //                                                   ),
    //                                                   borderRadius:
    //                                                       BorderRadius.circular(
    //                                                           10),
    //                                                 )
    //                                               ],
    //                                             )),
    //                                         //SELECTED FONT
    //                                         Container(
    //                                           width: width,
    //                                           padding: EdgeInsets.only(
    //                                               left: 10, top: 3, bottom: 3),
    //                                           margin: EdgeInsets.only(
    //                                               left: 3, top: 10, bottom: 3),
    //                                           decoration: BoxDecoration(
    //                                               color:
    //                                                   defaultPalette.tertiary,
    //                                               borderRadius: BorderRadius.circular(
    //                                                   25
    //                                                   // topLeft: Radius.circular(12),
    //                                                   // bottomLeft: Radius.circular(12),
    //                                                   )),
    //                                           child: Text('also size & spacing',
    //                                               textAlign: TextAlign.start,
    //                                               maxLines: 1,
    //                                               style: TextStyle(
    //                                                   fontFamily:
    //                                                       GoogleFonts.bungee()
    //                                                           .fontFamily,
    //                                                   color: defaultPalette
    //                                                       .primary,
    //                                                   fontSize: (width / 20)
    //                                                       .clamp(12, 15))),
    //                                         ),
          
    //                                         // FONT SIZE LETTER SPACING ALLAT
    //                                         Container(
    //                                           margin: EdgeInsets.only(
    //                                               top: 10,
    //                                               bottom: 20,
    //                                               left: 5,
    //                                               right: 5),
    //                                           width: width,
    //                                           height: 50 * 6,
    //                                           child: SingleChildScrollView(
    //                                             child: Column(
    //                                               crossAxisAlignment:
    //                                                   CrossAxisAlignment.start,
    //                                               children: [
    //                                                 //Font Size TEXT FIELD PARENT
    //                                                 ClipRRect(
    //                                                   borderRadius:
    //                                                       BorderRadius.circular(
    //                                                           10),
    //                                                   child: Container(
    //                                                     decoration: BoxDecoration(
    //                                                         color:
    //                                                             defaultPalette
    //                                                                 .primary,
    //                                                         border: Border.all(
    //                                                             width: 2,
    //                                                             strokeAlign:
    //                                                                 BorderSide
    //                                                                     .strokeAlignInside),
    //                                                         borderRadius:
    //                                                             BorderRadius
    //                                                                 .circular(
    //                                                                     8)),
    //                                                     height: 70,
    //                                                     width: width,
    //                                                     child: Row(
    //                                                       children: [
    //                                                         //Icon title slider field
    //                                                         Expanded(
    //                                                           flex: (1600 *
    //                                                                   vDividerPosition)
    //                                                               .ceil(),
    //                                                           child: Stack(
    //                                                             children: [
    //                                                               //Row font and title
    //                                                               GestureDetector(
    //                                                                 onTap: () {
    //                                                                   // fontSizeFocus.unfocus();
    //                                                                   fontSizeFocus
    //                                                                       .requestFocus();
    //                                                                 },
    //                                                                 child:
    //                                                                     Padding(
    //                                                                   padding: EdgeInsets.only(
    //                                                                       top:
    //                                                                           5,
    //                                                                       left:
    //                                                                           5),
    //                                                                   child:
    //                                                                       Row(
    //                                                                     mainAxisAlignment:
    //                                                                         MainAxisAlignment.spaceEvenly,
    //                                                                     children: [
    //                                                                       Expanded(
    //                                                                           flex: 100,
    //                                                                           child: Icon(
    //                                                                             TablerIcons.text_size,
    //                                                                             size: 18,
    //                                                                           )),
    //                                                                       vDividerPosition > 0.45
    //                                                                           ? Expanded(
    //                                                                               flex: 700,
    //                                                                               child: Container(
    //                                                                                 height: 18,
    //                                                                                 alignment: Alignment.bottomLeft,
    //                                                                                 child: Text(
    //                                                                                   '  Font Size',
    //                                                                                   style: TextStyle(fontSize: 12, textBaseline: TextBaseline.ideographic),
    //                                                                                 ),
    //                                                                               ))
    //                                                                           : Container(),
    //                                                                     ],
    //                                                                   ),
    //                                                                 ),
    //                                                               ),
    //                                                               //TextField
    //                                                               TextField(
    //                                                                 onTapOutside:
    //                                                                     (event) {
    //                                                                   // fontSizeFocus.unfocus();
    //                                                                 },
    //                                                                 onSubmitted:
    //                                                                     (value) {
    //                                                                   item.textEditorController
    //                                                                       .formatSelection(
    //                                                                     Attribute.clone(
    //                                                                         Attribute.size,
    //                                                                         value.toString()),
    //                                                                   );
    //                                                                 },
    //                                                                 focusNode:
    //                                                                     fontSizeFocus,
    //                                                                 controller:
    //                                                                     fontSizeController,
    //                                                                 inputFormatters: [
    //                                                                   NumericInputFormatter(
    //                                                                       maxValue:
    //                                                                           100),
    //                                                                 ],
    //                                                                 style: GoogleFonts.lexend(
    //                                                                     color: defaultPalette.black.withOpacity(fontSizeFocus.hasFocus
    //                                                                         ? 0.5
    //                                                                         : 0.1),
    //                                                                     fontWeight:
    //                                                                         FontWeight
    //                                                                             .bold,
    //                                                                     fontSize: (80 * vDividerPosition).clamp(
    //                                                                         70,
    //                                                                         100)),
    //                                                                 cursorColor:
    //                                                                     defaultPalette
    //                                                                         .black,
    //                                                                 // selectionControls: MaterialTextSelectionControls(),
    //                                                                 textAlign:
    //                                                                     TextAlign
    //                                                                         .right,
    //                                                                 scrollPadding:
    //                                                                     EdgeInsets
    //                                                                         .all(0),
    //                                                                 textAlignVertical:
    //                                                                     TextAlignVertical
    //                                                                         .top,
    //                                                                 decoration:
    //                                                                     InputDecoration(
    //                                                                   contentPadding:
    //                                                                       EdgeInsets.all(
    //                                                                           0),
          
    //                                                                   // filled: true,
    //                                                                   // fillColor: defaultPalette.primary,
    //                                                                   enabledBorder:
    //                                                                       OutlineInputBorder(
    //                                                                     borderSide: BorderSide(
    //                                                                         width:
    //                                                                             2,
    //                                                                         color:
    //                                                                             defaultPalette.transparent),
    //                                                                     borderRadius:
    //                                                                         BorderRadius.circular(2.0), // Same as border
    //                                                                   ),
    //                                                                   focusedBorder:
    //                                                                       OutlineInputBorder(
    //                                                                     borderSide: BorderSide(
    //                                                                         width:
    //                                                                             2,
    //                                                                         color:
    //                                                                             defaultPalette.transparent),
    //                                                                     borderRadius:
    //                                                                         BorderRadius.circular(2.0), // Same as border
    //                                                                   ),
    //                                                                 ),
    //                                                                 keyboardType:
    //                                                                     TextInputType
    //                                                                         .number,
    //                                                               ),
          
    //                                                               //Balloon Slider
    //                                                               Positioned(
    //                                                                 bottom: 0,
    //                                                                 width:
    //                                                                     width *
    //                                                                         0.6,
    //                                                                 child: BalloonSlider(
    //                                                                     trackHeight: 15,
    //                                                                     thumbRadius: 7.5,
    //                                                                     showRope: true,
    //                                                                     color: defaultPalette.tertiary,
    //                                                                     ropeLength: 300 / 8,
    //                                                                     value: double.parse((item.textEditorController.getSelectionStyle().attributes[Attribute.size.key]?.value) ?? 20.toString()) / 100,
    //                                                                     onChanged: (val) {
    //                                                                       setState(
    //                                                                           () {
    //                                                                         item.textEditorController.formatSelection(
    //                                                                           Attribute.clone(Attribute.size, (val * 100).toStringAsFixed(0)),
    //                                                                         );
    //                                                                       });
    //                                                                     }),
    //                                                               ),
    //                                                             ],
    //                                                           ),
    //                                                         ),
    //                                                         //+ -
    //                                                         Expanded(
    //                                                           flex: (600 *
    //                                                                   vDividerPosition)
    //                                                               .ceil(),
    //                                                           child: Stack(
    //                                                             // mainAxisAlignment: MainAxisAlignment.start,
    //                                                             children: [
    //                                                               Positioned(
    //                                                                 top: -4,
    //                                                                 right: 4,
    //                                                                 height: 35,
    //                                                                 child:
    //                                                                     ElevatedLayerButton(
    //                                                                   // isTapped: false,
    //                                                                   // toggleOnTap: true,
    //                                                                   depth: 2,
    //                                                                   onClick:
    //                                                                       () {
    //                                                                     setState(
    //                                                                         () {
    //                                                                       var val =
    //                                                                           int.parse(fontSizeController.text) + 1;
    //                                                                       item.textEditorController
    //                                                                           .formatSelection(
    //                                                                         Attribute.clone(Attribute.size,
    //                                                                             val.toString()),
    //                                                                       );
    //                                                                     });
    //                                                                   },
    //                                                                   buttonHeight:
    //                                                                       32,
    //                                                                   buttonWidth:
    //                                                                       65 *
    //                                                                           vDividerPosition,
    //                                                                   borderRadius:
    //                                                                       BorderRadius.circular(
    //                                                                           100),
    //                                                                   animationDuration:
    //                                                                       const Duration(
    //                                                                           milliseconds: 100),
    //                                                                   animationCurve:
    //                                                                       Curves
    //                                                                           .ease,
    //                                                                   topDecoration:
    //                                                                       BoxDecoration(
    //                                                                     color: Colors
    //                                                                         .white,
    //                                                                     border:
    //                                                                         Border.all(),
    //                                                                   ),
    //                                                                   topLayerChild:
    //                                                                       Icon(
    //                                                                     IconsaxPlusLinear
    //                                                                         .add,
    //                                                                     size:
    //                                                                         20,
    //                                                                   ),
    //                                                                   baseDecoration:
    //                                                                       BoxDecoration(
    //                                                                     color: Colors
    //                                                                         .green,
    //                                                                     border:
    //                                                                         Border.all(),
    //                                                                   ),
    //                                                                 ),
    //                                                               ),
    //                                                               Positioned(
    //                                                                 bottom: 5,
    //                                                                 right: 4,
    //                                                                 child:
    //                                                                     ElevatedLayerButton(
    //                                                                   // isTapped: false,
    //                                                                   // toggleOnTap: true,
    //                                                                   depth: 2,
    //                                                                   onClick:
    //                                                                       () {
    //                                                                     setState(
    //                                                                         () {
    //                                                                       var val = (int.parse(fontSizeController.text) - 1).clamp(
    //                                                                           0,
    //                                                                           100);
    //                                                                       item.textEditorController
    //                                                                           .formatSelection(
    //                                                                         Attribute.clone(Attribute.size,
    //                                                                             val.toString()),
    //                                                                       );
    //                                                                     });
    //                                                                   },
    //                                                                   buttonHeight:
    //                                                                       32,
    //                                                                   buttonWidth:
    //                                                                       65 *
    //                                                                           vDividerPosition,
    //                                                                   borderRadius:
    //                                                                       BorderRadius.circular(
    //                                                                           100),
    //                                                                   animationDuration:
    //                                                                       const Duration(
    //                                                                           milliseconds: 100),
    //                                                                   animationCurve:
    //                                                                       Curves
    //                                                                           .ease,
    //                                                                   topDecoration:
    //                                                                       BoxDecoration(
    //                                                                     color: Colors
    //                                                                         .white,
    //                                                                     border:
    //                                                                         Border.all(),
    //                                                                   ),
    //                                                                   topLayerChild:
    //                                                                       Icon(
    //                                                                     IconsaxPlusLinear
    //                                                                         .minus,
    //                                                                     size:
    //                                                                         20,
    //                                                                   ),
    //                                                                   baseDecoration:
    //                                                                       BoxDecoration(
    //                                                                     color: Colors
    //                                                                         .green,
    //                                                                     border:
    //                                                                         Border.all(),
    //                                                                   ),
    //                                                                 ),
    //                                                               ),
    //                                                             ],
    //                                                           ),
    //                                                         )
    //                                                       ],
    //                                                     ),
    //                                                   ),
    //                                                 ),
    //                                                 //
    //                                                 //
    //                                                 SizedBox(
    //                                                   height: 5,
    //                                                 ),
    //                                                 //LetterSpacing Parentt
    //                                                 ClipRRect(
    //                                                   borderRadius:
    //                                                       BorderRadius.circular(
    //                                                           10),
    //                                                   child: Container(
    //                                                     decoration: BoxDecoration(
    //                                                         color:
    //                                                             defaultPalette
    //                                                                 .primary,
    //                                                         border: Border.all(
    //                                                             width: 2,
    //                                                             strokeAlign:
    //                                                                 BorderSide
    //                                                                     .strokeAlignInside),
    //                                                         borderRadius:
    //                                                             BorderRadius
    //                                                                 .circular(
    //                                                                     8)),
    //                                                     height: 70,
    //                                                     width: width,
    //                                                     child: Row(
    //                                                       children: [
    //                                                         //LetterSpacing
    //                                                         //Icon title slider field
    //                                                         Expanded(
    //                                                           flex: (1600 *
    //                                                                   vDividerPosition)
    //                                                               .ceil(),
    //                                                           child: Stack(
    //                                                             children: [
    //                                                               //LetterSpacing
    //                                                               //Row font and title
    //                                                               GestureDetector(
    //                                                                 onTap: () {
    //                                                                   letterSpaceFocus
    //                                                                       .requestFocus();
    //                                                                 },
    //                                                                 //LetterSpacing
    //                                                                 //Row font and title
    //                                                                 child:
    //                                                                     Padding(
    //                                                                   padding: EdgeInsets.only(
    //                                                                       top:
    //                                                                           5,
    //                                                                       left:
    //                                                                           5),
    //                                                                   //LetterSpacing
    //                                                                   //Row font and title
    //                                                                   child:
    //                                                                       Row(
    //                                                                     mainAxisAlignment:
    //                                                                         MainAxisAlignment.spaceEvenly,
    //                                                                     children: [
    //                                                                       //LetterSpacing
    //                                                                       //icon
    //                                                                       Expanded(
    //                                                                           flex: 100,
    //                                                                           child: Icon(
    //                                                                             TablerIcons.letter_spacing,
    //                                                                             size: 18,
    //                                                                           )),
    //                                                                       //LetterSpacing
    //                                                                       //title
    //                                                                       vDividerPosition > 0.45
    //                                                                           ? Expanded(
    //                                                                               flex: 700,
    //                                                                               child: Container(
    //                                                                                 height: 18,
    //                                                                                 alignment: Alignment.bottomLeft,
    //                                                                                 child: Text(
    //                                                                                   '  Letter Space',
    //                                                                                   style: TextStyle(fontSize: 12, textBaseline: TextBaseline.ideographic),
    //                                                                                 ),
    //                                                                               ))
    //                                                                           : Container(),
    //                                                                     ],
    //                                                                   ),
    //                                                                 ),
    //                                                               ),
    //                                                               //LetterSpacing
    //                                                               //TextField
    //                                                               TextField(
    //                                                                 onTapOutside:
    //                                                                     (event) {
    //                                                                   // fontSizeFocus.unfocus();
    //                                                                 },
    //                                                                 onSubmitted:
    //                                                                     (value) {
    //                                                                   item.textEditorController
    //                                                                       .formatSelection(
    //                                                                     LetterSpacingAttribute(
    //                                                                         (value).toString()),
    //                                                                   );
    //                                                                 },
    //                                                                 focusNode:
    //                                                                     letterSpaceFocus,
    //                                                                 controller:
    //                                                                     letterSpaceController,
    //                                                                 inputFormatters: [
    //                                                                   NumericInputFormatter(
    //                                                                       maxValue:
    //                                                                           100),
    //                                                                 ],
    //                                                                 style: GoogleFonts.lexend(
    //                                                                     color: defaultPalette.black.withOpacity(fontSizeFocus.hasFocus
    //                                                                         ? 0.5
    //                                                                         : 0.1),
    //                                                                     fontWeight:
    //                                                                         FontWeight
    //                                                                             .bold,
    //                                                                     fontSize: (80 * vDividerPosition).clamp(
    //                                                                         70,
    //                                                                         100)),
    //                                                                 cursorColor:
    //                                                                     defaultPalette
    //                                                                         .black,
    //                                                                 // selectionControls: MaterialTextSelectionControls(),
    //                                                                 textAlign:
    //                                                                     TextAlign
    //                                                                         .right,
    //                                                                 scrollPadding:
    //                                                                     EdgeInsets
    //                                                                         .all(0),
    //                                                                 textAlignVertical:
    //                                                                     TextAlignVertical
    //                                                                         .top,
    //                                                                 decoration:
    //                                                                     InputDecoration(
    //                                                                   contentPadding:
    //                                                                       EdgeInsets.all(
    //                                                                           0),
          
    //                                                                   // filled: true,
    //                                                                   // fillColor: defaultPalette.primary,
    //                                                                   enabledBorder:
    //                                                                       OutlineInputBorder(
    //                                                                     borderSide: BorderSide(
    //                                                                         width:
    //                                                                             2,
    //                                                                         color:
    //                                                                             defaultPalette.transparent),
    //                                                                     borderRadius:
    //                                                                         BorderRadius.circular(2.0), // Same as border
    //                                                                   ),
    //                                                                   focusedBorder:
    //                                                                       OutlineInputBorder(
    //                                                                     borderSide: BorderSide(
    //                                                                         width:
    //                                                                             2,
    //                                                                         color:
    //                                                                             defaultPalette.transparent),
    //                                                                     borderRadius:
    //                                                                         BorderRadius.circular(2.0), // Same as border
    //                                                                   ),
    //                                                                 ),
    //                                                                 keyboardType:
    //                                                                     TextInputType
    //                                                                         .number,
    //                                                               ),
    //                                                               //LetterSpacing
    //                                                               //Balloon Slider
    //                                                               Positioned(
    //                                                                 bottom: 0,
    //                                                                 width:
    //                                                                     width *
    //                                                                         0.6,
    //                                                                 child: BalloonSlider(
    //                                                                     trackHeight: 15,
    //                                                                     thumbRadius: 7.5,
    //                                                                     showRope: true,
    //                                                                     color: defaultPalette.tertiary,
    //                                                                     ropeLength: 300 / 8,
    //                                                                     value: double.parse((item.textEditorController.getSelectionStyle().attributes[LetterSpacingAttribute._key]?.value) ?? 0.toString()) / 100,
    //                                                                     onChanged: (val) {
    //                                                                       setState(
    //                                                                           () {
    //                                                                         item.textEditorController.formatSelection(
    //                                                                           LetterSpacingAttribute((val * 100).ceil().toString()),
    //                                                                         );
    //                                                                       });
    //                                                                     }),
    //                                                               ),
    //                                                             ],
    //                                                           ),
    //                                                         ),
    //                                                         //LetterSpacing
    //                                                         //+ -
    //                                                         Expanded(
    //                                                           flex: (600 *
    //                                                                   vDividerPosition)
    //                                                               .ceil(),
    //                                                           child: Stack(
    //                                                             children: [
    //                                                               Positioned(
    //                                                                 top: -4,
    //                                                                 right: 4,
    //                                                                 height: 35,
    //                                                                 child:
    //                                                                     ElevatedLayerButton(
    //                                                                   depth: 2,
    //                                                                   onClick:
    //                                                                       () {
    //                                                                     setState(
    //                                                                         () {
    //                                                                       var val =
    //                                                                           int.parse(letterSpaceController.text) + 1;
          
    //                                                                       item.textEditorController
    //                                                                           .formatSelection(
    //                                                                         LetterSpacingAttribute((val).toString()),
    //                                                                       );
    //                                                                     });
    //                                                                   },
    //                                                                   buttonHeight:
    //                                                                       32,
    //                                                                   buttonWidth:
    //                                                                       65 *
    //                                                                           vDividerPosition,
    //                                                                   borderRadius:
    //                                                                       BorderRadius.circular(
    //                                                                           100),
    //                                                                   animationDuration:
    //                                                                       const Duration(
    //                                                                           milliseconds: 100),
    //                                                                   animationCurve:
    //                                                                       Curves
    //                                                                           .ease,
    //                                                                   topDecoration:
    //                                                                       BoxDecoration(
    //                                                                     color: Colors
    //                                                                         .white,
    //                                                                     border:
    //                                                                         Border.all(),
    //                                                                   ),
    //                                                                   topLayerChild:
    //                                                                       Icon(
    //                                                                     IconsaxPlusLinear
    //                                                                         .add,
    //                                                                     size:
    //                                                                         20,
    //                                                                   ),
    //                                                                   baseDecoration:
    //                                                                       BoxDecoration(
    //                                                                     color: Colors
    //                                                                         .green,
    //                                                                     border:
    //                                                                         Border.all(),
    //                                                                   ),
    //                                                                 ),
    //                                                               ),
    //                                                               Positioned(
    //                                                                 bottom: 5,
    //                                                                 right: 4,
    //                                                                 child:
    //                                                                     ElevatedLayerButton(
    //                                                                   // isTapped: false,
    //                                                                   // toggleOnTap: true,
    //                                                                   depth: 2,
    //                                                                   onClick:
    //                                                                       () {
    //                                                                     setState(
    //                                                                         () {
    //                                                                       var val = (int.parse(letterSpaceController.text) - 1).clamp(
    //                                                                           0,
    //                                                                           100);
    //                                                                       item.textEditorController
    //                                                                           .formatSelection(
    //                                                                         LetterSpacingAttribute((val).toString()),
    //                                                                       );
    //                                                                     });
    //                                                                   },
    //                                                                   buttonHeight:
    //                                                                       32,
    //                                                                   buttonWidth:
    //                                                                       65 *
    //                                                                           vDividerPosition,
    //                                                                   borderRadius:
    //                                                                       BorderRadius.circular(
    //                                                                           100),
    //                                                                   animationDuration:
    //                                                                       const Duration(
    //                                                                           milliseconds: 100),
    //                                                                   animationCurve:
    //                                                                       Curves
    //                                                                           .ease,
    //                                                                   topDecoration:
    //                                                                       BoxDecoration(
    //                                                                     color: Colors
    //                                                                         .white,
    //                                                                     border:
    //                                                                         Border.all(),
    //                                                                   ),
    //                                                                   topLayerChild:
    //                                                                       Icon(
    //                                                                     IconsaxPlusLinear
    //                                                                         .minus,
    //                                                                     size:
    //                                                                         20,
    //                                                                   ),
    //                                                                   baseDecoration:
    //                                                                       BoxDecoration(
    //                                                                     color: Colors
    //                                                                         .green,
    //                                                                     border:
    //                                                                         Border.all(),
    //                                                                   ),
    //                                                                 ),
    //                                                               ),
    //                                                             ],
    //                                                           ),
    //                                                         )
    //                                                       ],
    //                                                     ),
    //                                                   ),
    //                                                 ),
          
    //                                                 SizedBox(
    //                                                   height: 5,
    //                                                 ),
    //                                                 //WordSpacing
    //                                                 ClipRRect(
    //                                                   borderRadius:
    //                                                       BorderRadius.circular(
    //                                                           10),
    //                                                   child: Container(
    //                                                     decoration: BoxDecoration(
    //                                                         color:
    //                                                             defaultPalette
    //                                                                 .primary,
    //                                                         border: Border.all(
    //                                                             width: 2,
    //                                                             strokeAlign:
    //                                                                 BorderSide
    //                                                                     .strokeAlignInside),
    //                                                         borderRadius:
    //                                                             BorderRadius
    //                                                                 .circular(
    //                                                                     8)),
    //                                                     height: 70,
    //                                                     width: width,
    //                                                     child: Row(
    //                                                       children: [
    //                                                         //WordSpacing
    //                                                         //Icon title slider field
    //                                                         Expanded(
    //                                                           flex: (1600 *
    //                                                                   vDividerPosition)
    //                                                               .ceil(),
    //                                                           child: Stack(
    //                                                             children: [
    //                                                               //WordSpacing
    //                                                               //Row font and title
    //                                                               GestureDetector(
    //                                                                 onTap: () {
    //                                                                   wordSpaceFocus
    //                                                                       .requestFocus();
    //                                                                 },
    //                                                                 //WordSpacing
    //                                                                 //Row font and title
    //                                                                 child:
    //                                                                     Padding(
    //                                                                   padding: EdgeInsets.only(
    //                                                                       top:
    //                                                                           5,
    //                                                                       left:
    //                                                                           5),
    //                                                                   //WordSpacing
    //                                                                   //Row font and title
    //                                                                   child:
    //                                                                       Row(
    //                                                                     mainAxisAlignment:
    //                                                                         MainAxisAlignment.spaceEvenly,
    //                                                                     children: [
    //                                                                       //WordSpacing
    //                                                                       //icon
    //                                                                       Expanded(
    //                                                                           flex: 100,
    //                                                                           child: Icon(
    //                                                                             TablerIcons.spacing_horizontal,
    //                                                                             size: 18,
    //                                                                           )),
    //                                                                       //WordSpacing
    //                                                                       //title
    //                                                                       vDividerPosition > 0.45
    //                                                                           ? Expanded(
    //                                                                               flex: 700,
    //                                                                               child: Container(
    //                                                                                 height: 18,
    //                                                                                 alignment: Alignment.bottomLeft,
    //                                                                                 child: Text(
    //                                                                                   '  Word Space',
    //                                                                                   style: TextStyle(fontSize: 12, textBaseline: TextBaseline.ideographic),
    //                                                                                 ),
    //                                                                               ))
    //                                                                           : Container(),
    //                                                                     ],
    //                                                                   ),
    //                                                                 ),
    //                                                               ),
    //                                                               //WordSpacing
    //                                                               //TextField
    //                                                               TextField(
    //                                                                 onTapOutside:
    //                                                                     (event) {
    //                                                                   // fontSizeFocus.unfocus();
    //                                                                 },
    //                                                                 onSubmitted:
    //                                                                     (value) {
    //                                                                   item.textEditorController
    //                                                                       .formatSelection(
    //                                                                     WordSpacingAttribute(
    //                                                                         (value).toString()),
    //                                                                   );
    //                                                                 },
    //                                                                 focusNode:
    //                                                                     wordSpaceFocus,
    //                                                                 controller:
    //                                                                     wordSpaceController,
    //                                                                 inputFormatters: [
    //                                                                   NumericInputFormatter(
    //                                                                       maxValue:
    //                                                                           100),
    //                                                                 ],
    //                                                                 style: GoogleFonts.lexend(
    //                                                                     color: defaultPalette.black.withOpacity(fontSizeFocus.hasFocus
    //                                                                         ? 0.5
    //                                                                         : 0.1),
    //                                                                     fontWeight:
    //                                                                         FontWeight
    //                                                                             .bold,
    //                                                                     fontSize: (80 * vDividerPosition).clamp(
    //                                                                         70,
    //                                                                         100)),
    //                                                                 cursorColor:
    //                                                                     defaultPalette
    //                                                                         .black,
    //                                                                 // selectionControls: MaterialTextSelectionControls(),
    //                                                                 textAlign:
    //                                                                     TextAlign
    //                                                                         .right,
    //                                                                 scrollPadding:
    //                                                                     EdgeInsets
    //                                                                         .all(0),
    //                                                                 textAlignVertical:
    //                                                                     TextAlignVertical
    //                                                                         .top,
    //                                                                 decoration:
    //                                                                     InputDecoration(
    //                                                                   contentPadding:
    //                                                                       EdgeInsets.all(
    //                                                                           0),
          
    //                                                                   // filled: true,
    //                                                                   // fillColor: defaultPalette.primary,
    //                                                                   enabledBorder:
    //                                                                       OutlineInputBorder(
    //                                                                     borderSide: BorderSide(
    //                                                                         width:
    //                                                                             2,
    //                                                                         color:
    //                                                                             defaultPalette.transparent),
    //                                                                     borderRadius:
    //                                                                         BorderRadius.circular(2.0), // Same as border
    //                                                                   ),
    //                                                                   focusedBorder:
    //                                                                       OutlineInputBorder(
    //                                                                     borderSide: BorderSide(
    //                                                                         width:
    //                                                                             2,
    //                                                                         color:
    //                                                                             defaultPalette.transparent),
    //                                                                     borderRadius:
    //                                                                         BorderRadius.circular(2.0), // Same as border
    //                                                                   ),
    //                                                                 ),
    //                                                                 keyboardType:
    //                                                                     TextInputType
    //                                                                         .number,
    //                                                               ),
    //                                                               //WordSpacing
    //                                                               //Balloon Slider
    //                                                               Positioned(
    //                                                                 bottom: 0,
    //                                                                 width:
    //                                                                     width *
    //                                                                         0.6,
    //                                                                 child: BalloonSlider(
    //                                                                     trackHeight: 15,
    //                                                                     thumbRadius: 7.5,
    //                                                                     showRope: true,
    //                                                                     color: defaultPalette.tertiary,
    //                                                                     ropeLength: 300 / 8,
    //                                                                     value: double.parse((item.textEditorController.getSelectionStyle().attributes[WordSpacingAttribute._key]?.value) ?? 0.toString()) / 100,
    //                                                                     onChanged: (val) {
    //                                                                       setState(
    //                                                                           () {
    //                                                                         item.textEditorController.formatSelection(
    //                                                                           WordSpacingAttribute((val * 100).ceil().toString()),
    //                                                                         );
    //                                                                       });
    //                                                                     }),
    //                                                               ),
    //                                                             ],
    //                                                           ),
    //                                                         ),
    //                                                         //WordSpacing
    //                                                         //+ -
    //                                                         Expanded(
    //                                                           flex: (600 *
    //                                                                   vDividerPosition)
    //                                                               .ceil(),
    //                                                           child: Stack(
    //                                                             children: [
    //                                                               Positioned(
    //                                                                 top: -4,
    //                                                                 right: 4,
    //                                                                 height: 35,
    //                                                                 child:
    //                                                                     ElevatedLayerButton(
    //                                                                   depth: 2,
    //                                                                   onClick:
    //                                                                       () {
    //                                                                     setState(
    //                                                                         () {
    //                                                                       var val =
    //                                                                           int.parse(wordSpaceController.text) + 1;
          
    //                                                                       item.textEditorController
    //                                                                           .formatSelection(
    //                                                                         WordSpacingAttribute((val).toString()),
    //                                                                       );
    //                                                                     });
    //                                                                   },
    //                                                                   buttonHeight:
    //                                                                       32,
    //                                                                   buttonWidth:
    //                                                                       65 *
    //                                                                           vDividerPosition,
    //                                                                   borderRadius:
    //                                                                       BorderRadius.circular(
    //                                                                           100),
    //                                                                   animationDuration:
    //                                                                       const Duration(
    //                                                                           milliseconds: 100),
    //                                                                   animationCurve:
    //                                                                       Curves
    //                                                                           .ease,
    //                                                                   topDecoration:
    //                                                                       BoxDecoration(
    //                                                                     color: Colors
    //                                                                         .white,
    //                                                                     border:
    //                                                                         Border.all(),
    //                                                                   ),
    //                                                                   topLayerChild:
    //                                                                       Icon(
    //                                                                     IconsaxPlusLinear
    //                                                                         .add,
    //                                                                     size:
    //                                                                         20,
    //                                                                   ),
    //                                                                   baseDecoration:
    //                                                                       BoxDecoration(
    //                                                                     color: Colors
    //                                                                         .green,
    //                                                                     border:
    //                                                                         Border.all(),
    //                                                                   ),
    //                                                                 ),
    //                                                               ),
    //                                                               Positioned(
    //                                                                 bottom: 5,
    //                                                                 right: 4,
    //                                                                 child:
    //                                                                     ElevatedLayerButton(
    //                                                                   depth: 2,
    //                                                                   // isTapped: false,
    //                                                                   // toggleOnTap: true,
    //                                                                   onClick:
    //                                                                       () {
    //                                                                     setState(
    //                                                                         () {
    //                                                                       var val = (int.parse(wordSpaceController.text) - 1).clamp(
    //                                                                           0,
    //                                                                           100);
    //                                                                       item.textEditorController
    //                                                                           .formatSelection(
    //                                                                         WordSpacingAttribute((val).toString()),
    //                                                                       );
    //                                                                     });
    //                                                                   },
    //                                                                   buttonHeight:
    //                                                                       32,
    //                                                                   buttonWidth:
    //                                                                       65 *
    //                                                                           vDividerPosition,
    //                                                                   borderRadius:
    //                                                                       BorderRadius.circular(
    //                                                                           100),
    //                                                                   animationDuration:
    //                                                                       const Duration(
    //                                                                           milliseconds: 100),
    //                                                                   animationCurve:
    //                                                                       Curves
    //                                                                           .ease,
    //                                                                   topDecoration:
    //                                                                       BoxDecoration(
    //                                                                     color: Colors
    //                                                                         .white,
    //                                                                     border:
    //                                                                         Border.all(),
    //                                                                   ),
    //                                                                   topLayerChild:
    //                                                                       Icon(
    //                                                                     IconsaxPlusLinear
    //                                                                         .minus,
    //                                                                     size:
    //                                                                         20,
    //                                                                   ),
    //                                                                   baseDecoration:
    //                                                                       BoxDecoration(
    //                                                                     color: Colors
    //                                                                         .green,
    //                                                                     border:
    //                                                                         Border.all(),
    //                                                                   ),
    //                                                                 ),
    //                                                               ),
    //                                                             ],
    //                                                           ),
    //                                                         )
    //                                                       ],
    //                                                     ),
    //                                                   ),
    //                                                 ),
    //                                                 //
    //                                                 SizedBox(
    //                                                   height: 5,
    //                                                 ),
    //                                                 //LineHeight
    //                                                 ClipRRect(
    //                                                   borderRadius:
    //                                                       BorderRadius.circular(
    //                                                           10),
    //                                                   child: Container(
    //                                                     decoration: BoxDecoration(
    //                                                         color:
    //                                                             defaultPalette
    //                                                                 .primary,
    //                                                         border: Border.all(
    //                                                             width: 2,
    //                                                             strokeAlign:
    //                                                                 BorderSide
    //                                                                     .strokeAlignInside),
    //                                                         borderRadius:
    //                                                             BorderRadius
    //                                                                 .circular(
    //                                                                     8)),
    //                                                     height: 70,
    //                                                     width: width,
    //                                                     child: Row(
    //                                                       children: [
    //                                                         //LineHeight
    //                                                         //Icon title slider field
    //                                                         Expanded(
    //                                                           flex: (1600 *
    //                                                                   vDividerPosition)
    //                                                               .ceil(),
    //                                                           child: Stack(
    //                                                             children: [
    //                                                               //LineHeight
    //                                                               //Row font and title
    //                                                               GestureDetector(
    //                                                                 onTap: () {
    //                                                                   lineSpaceFocus
    //                                                                       .requestFocus();
    //                                                                 },
    //                                                                 //LineHeight
    //                                                                 //Row font and title
    //                                                                 child:
    //                                                                     Padding(
    //                                                                   padding: EdgeInsets.only(
    //                                                                       top:
    //                                                                           5,
    //                                                                       left:
    //                                                                           5),
    //                                                                   //LineHeight
    //                                                                   //Row font and title
    //                                                                   child:
    //                                                                       Row(
    //                                                                     mainAxisAlignment:
    //                                                                         MainAxisAlignment.spaceEvenly,
    //                                                                     children: [
    //                                                                       //LineHeight
    //                                                                       //icon
    //                                                                       Expanded(
    //                                                                           flex: 100,
    //                                                                           child: Icon(
    //                                                                             TablerIcons.spacing_vertical,
    //                                                                             size: 18,
    //                                                                           )),
    //                                                                       //LineHeight
    //                                                                       //title
    //                                                                       vDividerPosition > 0.45
    //                                                                           ? Expanded(
    //                                                                               flex: 700,
    //                                                                               child: Container(
    //                                                                                 height: 18,
    //                                                                                 alignment: Alignment.bottomLeft,
    //                                                                                 child: Text(
    //                                                                                   '  Line Space',
    //                                                                                   style: TextStyle(fontSize: 12, textBaseline: TextBaseline.ideographic),
    //                                                                                 ),
    //                                                                               ))
    //                                                                           : Container(),
    //                                                                     ],
    //                                                                   ),
    //                                                                 ),
    //                                                               ),
    //                                                               //LineHeight
    //                                                               //TextField
    //                                                               TextField(
    //                                                                 onTapOutside:
    //                                                                     (event) {
    //                                                                   // fontSizeFocus.unfocus();
    //                                                                 },
    //                                                                 onSubmitted:
    //                                                                     (value) {
    //                                                                   item.textEditorController
    //                                                                       .formatSelection(
    //                                                                     LineHeightAttribute(
    //                                                                         (value).toString()),
    //                                                                   );
    //                                                                 },
    //                                                                 focusNode:
    //                                                                     lineSpaceFocus,
    //                                                                 controller:
    //                                                                     lineSpaceController,
    //                                                                 inputFormatters: [
    //                                                                   NumericInputFormatter(
    //                                                                       maxValue:
    //                                                                           100),
    //                                                                 ],
    //                                                                 style: GoogleFonts.lexend(
    //                                                                     color: defaultPalette.black.withOpacity(fontSizeFocus.hasFocus
    //                                                                         ? 0.5
    //                                                                         : 0.1),
    //                                                                     fontWeight:
    //                                                                         FontWeight
    //                                                                             .bold,
    //                                                                     fontSize: (80 * vDividerPosition).clamp(
    //                                                                         70,
    //                                                                         100)),
    //                                                                 cursorColor:
    //                                                                     defaultPalette
    //                                                                         .black,
    //                                                                 // selectionControls: MaterialTextSelectionControls(),
    //                                                                 textAlign:
    //                                                                     TextAlign
    //                                                                         .right,
    //                                                                 scrollPadding:
    //                                                                     EdgeInsets
    //                                                                         .all(0),
    //                                                                 textAlignVertical:
    //                                                                     TextAlignVertical
    //                                                                         .top,
    //                                                                 decoration:
    //                                                                     InputDecoration(
    //                                                                   contentPadding:
    //                                                                       EdgeInsets.all(
    //                                                                           0),
          
    //                                                                   // filled: true,
    //                                                                   // fillColor: defaultPalette.primary,
    //                                                                   enabledBorder:
    //                                                                       OutlineInputBorder(
    //                                                                     borderSide: BorderSide(
    //                                                                         width:
    //                                                                             2,
    //                                                                         color:
    //                                                                             defaultPalette.transparent),
    //                                                                     borderRadius:
    //                                                                         BorderRadius.circular(2.0), // Same as border
    //                                                                   ),
    //                                                                   focusedBorder:
    //                                                                       OutlineInputBorder(
    //                                                                     borderSide: BorderSide(
    //                                                                         width:
    //                                                                             2,
    //                                                                         color:
    //                                                                             defaultPalette.transparent),
    //                                                                     borderRadius:
    //                                                                         BorderRadius.circular(2.0), // Same as border
    //                                                                   ),
    //                                                                 ),
    //                                                                 keyboardType:
    //                                                                     TextInputType
    //                                                                         .number,
    //                                                               ),
    //                                                               //LineHeight
    //                                                               //Balloon Slider
    //                                                               Positioned(
    //                                                                 bottom: 0,
    //                                                                 width:
    //                                                                     width *
    //                                                                         0.6,
    //                                                                 child: BalloonSlider(
    //                                                                     trackHeight: 15,
    //                                                                     thumbRadius: 7.5,
    //                                                                     showRope: true,
    //                                                                     color: defaultPalette.tertiary,
    //                                                                     ropeLength: 300 / 8,
    //                                                                     value: double.parse((item.textEditorController.getSelectionStyle().attributes[LineHeightAttribute._key]?.value) ?? 0.toString()) / 100,
    //                                                                     onChanged: (val) {
    //                                                                       setState(
    //                                                                           () {
    //                                                                         item.textEditorController.formatSelection(
    //                                                                           LineHeightAttribute((val * 100).ceil().toString()),
    //                                                                         );
    //                                                                       });
    //                                                                     }),
    //                                                               ),
    //                                                             ],
    //                                                           ),
    //                                                         ),
    //                                                         //LineHeight
    //                                                         //+ -
    //                                                         Expanded(
    //                                                           flex: (600 *
    //                                                                   vDividerPosition)
    //                                                               .ceil(),
    //                                                           child: Stack(
    //                                                             children: [
    //                                                               Positioned(
    //                                                                 top: -4,
    //                                                                 right: 4,
    //                                                                 height: 35,
    //                                                                 child:
    //                                                                     ElevatedLayerButton(
    //                                                                   depth: 2,
    //                                                                   onClick:
    //                                                                       () {
    //                                                                     setState(
    //                                                                         () {
    //                                                                       var val =
    //                                                                           int.parse(lineSpaceController.text) + 1;
          
    //                                                                       item.textEditorController
    //                                                                           .formatSelection(
    //                                                                         LineHeightAttribute((val).toString()),
    //                                                                       );
    //                                                                     });
    //                                                                   },
    //                                                                   buttonHeight:
    //                                                                       32,
    //                                                                   buttonWidth:
    //                                                                       65 *
    //                                                                           vDividerPosition,
    //                                                                   borderRadius:
    //                                                                       BorderRadius.circular(
    //                                                                           100),
    //                                                                   animationDuration:
    //                                                                       const Duration(
    //                                                                           milliseconds: 100),
    //                                                                   animationCurve:
    //                                                                       Curves
    //                                                                           .ease,
    //                                                                   topDecoration:
    //                                                                       BoxDecoration(
    //                                                                     color: Colors
    //                                                                         .white,
    //                                                                     border:
    //                                                                         Border.all(),
    //                                                                   ),
    //                                                                   topLayerChild:
    //                                                                       Icon(
    //                                                                     IconsaxPlusLinear
    //                                                                         .add,
    //                                                                     size:
    //                                                                         20,
    //                                                                   ),
    //                                                                   baseDecoration:
    //                                                                       BoxDecoration(
    //                                                                     color: Colors
    //                                                                         .green,
    //                                                                     border:
    //                                                                         Border.all(),
    //                                                                   ),
    //                                                                 ),
    //                                                               ),
    //                                                               Positioned(
    //                                                                 bottom: 5,
    //                                                                 right: 4,
    //                                                                 child:
    //                                                                     ElevatedLayerButton(
    //                                                                   depth: 2,
    //                                                                   // isTapped: false,
    //                                                                   // toggleOnTap: true,
    //                                                                   onClick:
    //                                                                       () {
    //                                                                     setState(
    //                                                                         () {
    //                                                                       var val = (int.parse(lineSpaceController.text) - 1).clamp(
    //                                                                           0,
    //                                                                           100);
    //                                                                       item.textEditorController
    //                                                                           .formatSelection(
    //                                                                         LineHeightAttribute((val).toString()),
    //                                                                       );
    //                                                                     });
    //                                                                   },
    //                                                                   buttonHeight:
    //                                                                       32,
    //                                                                   buttonWidth:
    //                                                                       65 *
    //                                                                           vDividerPosition,
    //                                                                   borderRadius:
    //                                                                       BorderRadius.circular(
    //                                                                           100),
    //                                                                   animationDuration:
    //                                                                       const Duration(
    //                                                                           milliseconds: 100),
    //                                                                   animationCurve:
    //                                                                       Curves
    //                                                                           .ease,
    //                                                                   topDecoration:
    //                                                                       BoxDecoration(
    //                                                                     color: Colors
    //                                                                         .white,
    //                                                                     border:
    //                                                                         Border.all(),
    //                                                                   ),
    //                                                                   topLayerChild:
    //                                                                       Icon(
    //                                                                     IconsaxPlusLinear
    //                                                                         .minus,
    //                                                                     size:
    //                                                                         20,
    //                                                                   ),
    //                                                                   baseDecoration:
    //                                                                       BoxDecoration(
    //                                                                     color: Colors
    //                                                                         .green,
    //                                                                     border:
    //                                                                         Border.all(),
    //                                                                   ),
    //                                                                 ),
    //                                                               ),
    //                                                             ],
    //                                                           ),
    //                                                         )
    //                                                       ],
    //                                                     ),
    //                                                   ),
    //                                                 ),
    //                                                 //
    //                                               ],
    //                                             ),
    //                                           ),
    //                                         ),
    //                                       ],
    //                                     ),
    //                                   );
    //                                 }),
    //                           ],
    //                         ),
    //                       ),
    //                     ),
    //                   ),
    //                 ],
          
    //                 if (index == 2) ...[
    //                   //GRAPH BEHIND COLOR CARD
    //                   Padding(
    //                     padding: const EdgeInsets.all(10),
    //                     child: ClipRRect(
    //                       borderRadius: BorderRadius.circular(25),
    //                       child: Opacity(
    //                         opacity: 0.35,
    //                         child: SizedBox(
    //                           width: sWidth,
    //                           height: sHeight,
    //                           child: LineChart(LineChartData(
    //                               lineBarsData: [LineChartBarData()],
    //                               titlesData: const FlTitlesData(show: false),
    //                               gridData: FlGridData(
    //                                   getDrawingVerticalLine: (value) => FlLine(
    //                                       color: defaultPalette.extras[0]
    //                                           .withOpacity(0.8),
    //                                       dashArray: [5, 5],
    //                                       strokeWidth: 1),
    //                                   getDrawingHorizontalLine: (value) => FlLine(
    //                                       color: defaultPalette.extras[0]
    //                                           .withOpacity(0.8),
    //                                       dashArray: [5, 5],
    //                                       strokeWidth: 1),
    //                                   show: true,
    //                                   horizontalInterval: 10,
    //                                   verticalInterval: 50),
    //                               borderData: FlBorderData(show: false),
    //                               minY: 0,
    //                               maxY: 50,
    //                               maxX: dateTimeNow.millisecondsSinceEpoch
    //                                           .ceilToDouble() /
    //                                       500 +
    //                                   250,
    //                               minX: dateTimeNow.millisecondsSinceEpoch
    //                                       .ceilToDouble() /
    //                                   500)),
    //                         ),
    //                       ),
    //                     ),
    //                   ),
          
    //                   Positioned.fill(
    //                     child: Container(
    //                       width: width,
    //                       height: sHeight * 0.8,
    //                       margin: const EdgeInsets.all(20),
    //                       decoration: BoxDecoration(
    //                         borderRadius: BorderRadius.circular(20),
    //                       ),
    //                       child: ClipRRect(
    //                           borderRadius: BorderRadius.circular(20),
    //                           child: DynMouseScroll(
    //                               durationMS: 500,
    //                               scrollSpeed: 0.1,
    //                               builder: (context, controller, physics) {
    //                                 return ListView(
    //                                   controller: controller,
    //                                   physics: physics,
    //                                   children: [
    //                                     SizedBox(height: 10),
    //                                     //FONT COlOR TITLE TEXT
    //                                     Text('FONT COLOR',
    //                                         textAlign: TextAlign.start,
    //                                         style: GoogleFonts.bungee(
    //                                             color: defaultPalette.extras[0],
    //                                             fontSize:
    //                                                 (width / 6).clamp(5, 25))),
    //                                     //FontColor HEX TITLE
    //                                     Container(
    //                                       width:
    //                                           sWidth * wH2DividerPosition - 45,
    //                                       height: 15,
    //                                       alignment: Alignment.topCenter,
    //                                       margin: EdgeInsets.only(
    //                                           top: 10, right: 5),
    //                                       padding: EdgeInsets.only(
    //                                           left: 5, right: 5),
    //                                       decoration: BoxDecoration(
    //                                           borderRadius:
    //                                               BorderRadius.circular(5),
    //                                           border: Border.all(width: 0.1)),
    //                                       child: Row(
    //                                         mainAxisAlignment:
    //                                             MainAxisAlignment.spaceBetween,
    //                                         crossAxisAlignment:
    //                                             CrossAxisAlignment.start,
    //                                         children: [
    //                                           Expanded(
    //                                             flex: 5,
    //                                             child: Text(
    //                                               'FONT HEX',
    //                                               style: GoogleFonts.bungee(
    //                                                   fontSize: 10),
    //                                             ),
    //                                           ),
    //                                           Expanded(
    //                                             flex: 3,
    //                                             child: TextFormField(
    //                                               onTapOutside: (event) {},
    //                                               controller: hexController,
    //                                               inputFormatters: [
    //                                                 HexColorInputFormatter()
    //                                               ],
    //                                               onFieldSubmitted: (color) {
    //                                                 item.textEditorController
    //                                                     .formatSelection(
    //                                                   ColorAttribute(color),
    //                                                 );
    //                                               },
    //                                               style: GoogleFonts.bungee(
    //                                                   fontSize: 10),
    //                                               cursorColor:
    //                                                   defaultPalette.tertiary,
    //                                               textAlign: TextAlign.center,
    //                                               textAlignVertical:
    //                                                   TextAlignVertical.center,
    //                                               decoration: InputDecoration(
    //                                                 contentPadding:
    //                                                     const EdgeInsets.all(0),
    //                                                 border: InputBorder.none,
    //                                                 enabledBorder:
    //                                                     OutlineInputBorder(
    //                                                   borderSide: BorderSide(
    //                                                       width: 2,
    //                                                       color: defaultPalette
    //                                                           .transparent),
    //                                                   borderRadius:
    //                                                       BorderRadius.circular(
    //                                                           12.0),
    //                                                 ),
    //                                                 focusedBorder:
    //                                                     OutlineInputBorder(
    //                                                   borderSide: BorderSide(
    //                                                       width: 3,
    //                                                       color: defaultPalette
    //                                                           .transparent),
    //                                                   borderRadius:
    //                                                       BorderRadius.circular(
    //                                                           10.0),
    //                                                 ),
    //                                               ),
    //                                               keyboardType:
    //                                                   TextInputType.number,
    //                                             ),
    //                                           ),
    //                                         ],
    //                                       ),
    //                                     ),
          
    //                                     //FontColor SWATCH And WHEEL FOR FONT COLOR
    //                                     Stack(
    //                                       children: [
    //                                         SizedBox(
    //                                             width: ((sWidth *
    //                                                     wH2DividerPosition -
    //                                                 110)),
    //                                             height: 140),
    //                                         //COLOR WHEEL FOR FONT COLOR
    //                                         Positioned(
    //                                           right: 7,
    //                                           height: 140,
    //                                           width: 100,
    //                                           top: 4,
    //                                           child: Column(
    //                                             crossAxisAlignment:
    //                                                 CrossAxisAlignment.end,
    //                                             children: [
    //                                               //COLOR WHEEL FOR FONT COLOR
    //                                               SizedBox(
    //                                                 height: 100,
    //                                                 width: 95,
    //                                                 child: fl.ColorWheelPicker(
    //                                                   color: hexToColor(item
    //                                                       .textEditorController
    //                                                       .getSelectionStyle()
    //                                                       .attributes['color']
    //                                                       ?.value),
    //                                                   onChanged: (color) {
    //                                                     setState(() {
    //                                                       item.textEditorController
    //                                                           .formatSelection(
    //                                                         ColorAttribute(
    //                                                             '#${colorToHex(color)}'),
    //                                                       );
    //                                                       hexController.text =
    //                                                           '${item.textEditorController.getSelectionStyle().attributes['color']?.value}';
    //                                                     });
    //                                                   },
    //                                                   onChangeEnd: (value) {
    //                                                     _renderPagePreviewOnProperties();
    //                                                   },
    //                                                   onWheel: (bool value) {},
    //                                                   wheelSquarePadding: 5,
    //                                                   wheelWidth: 8,
    //                                                   hasBorder: true,
    //                                                   shouldUpdate: true,
    //                                                 ),
    //                                               ),
    //                                               SizedBox(
    //                                                 height: 0,
    //                                               ),
          
    //                                               //Name of FONT COLOR
    //                                               Text(
    //                                                   fl.ColorTools
    //                                                       .nameThatColor(
    //                                                     hexToColor(item
    //                                                         .textEditorController
    //                                                         .getSelectionStyle()
    //                                                         .attributes['color']
    //                                                         ?.value),
    //                                                   ),
    //                                                   textAlign: TextAlign.end,
    //                                                   style: GoogleFonts.bungee(
    //                                                       fontSize: 12)),
    //                                             ],
    //                                           ),
    //                                         ),
    //                                         //COLOR SWATCH FOR PAGE COLOR
          
    //                                         fl.ColorPicker(
    //                                           color: hexToColor(item
    //                                               .textEditorController
    //                                               .getSelectionStyle()
    //                                               .attributes['color']
    //                                               ?.value),
    //                                           pickersEnabled: const {
    //                                             fl.ColorPickerType.both: false,
    //                                             fl.ColorPickerType.primary:
    //                                                 false,
    //                                             fl.ColorPickerType.accent:
    //                                                 false,
    //                                             fl.ColorPickerType.bw: false,
    //                                             fl.ColorPickerType.custom: true,
    //                                             fl.ColorPickerType.wheel: false
    //                                           },
    //                                           enableTooltips: true,
    //                                           showColorName: false,
    //                                           //  ((sWidth *
    //                                           //           wH2DividerPosition) -
    //                                           //       145) >
    //                                           //   66? true:false,
    //                                           // showColorCode: true,
    //                                           // enableOpacity: true,
    //                                           customColorSwatchesAndNames: {
    //                                             createSwatch(
    //                                                 hexToColor(item
    //                                                     .textEditorController
    //                                                     .getSelectionStyle()
    //                                                     .attributes['color']
    //                                                     ?.value),
    //                                                 12): ''
    //                                           },
    //                                           colorCodeHasColor: true,
    //                                           enableShadesSelection: true,
    //                                           colorCodeReadOnly: false,
    //                                           height:
    //                                               ((sWidth * wH2DividerPosition -
    //                                                           145) /
    //                                                       3)
    //                                                   .clamp(15, 30),
    //                                           width:
    //                                               ((sWidth * wH2DividerPosition -
    //                                                           145) /
    //                                                       4)
    //                                                   .clamp(15, 30),
    //                                           runSpacing: 2,
    //                                           shadesSpacing: 0,
    //                                           spacing: 1,
    //                                           borderRadius: 5,
    //                                           hasBorder: true,
    //                                           borderColor:
    //                                               const Color(0xFF3F3F3F)
    //                                                   .withOpacity(0.6),
    //                                           colorNameTextStyle:
    //                                               GoogleFonts.bungee(
    //                                                   fontSize: 10),
    //                                           colorCodeTextStyle:
    //                                               GoogleFonts.bungee(
    //                                                   fontSize: 8),
    //                                           colorCodePrefixStyle:
    //                                               GoogleFonts.bungee(
    //                                                   fontSize: 8),
    //                                           columnSpacing: 5,
    //                                           crossAxisAlignment:
    //                                               CrossAxisAlignment.start,
    //                                           toolbarSpacing: 0,
    //                                           selectedColorIcon:
    //                                               TablerIcons.circle,
    //                                           editIcon: TablerIcons.circle,
    //                                           padding: EdgeInsets.only(
    //                                               right: 115, top: 10),
    //                                           wheelWidth: 5,
    //                                           wheelSquarePadding: 8,
    //                                           wheelDiameter: 120,
    //                                           wheelSquareBorderRadius: 8,
    //                                           opacityThumbRadius: 12,
    //                                           opacityTrackHeight: 12,
    //                                           wheelHasBorder: true,
    //                                           onColorChangeEnd: (value) {
    //                                             _renderPagePreviewOnProperties();
    //                                           },
    //                                           onColorChanged: (color) {
    //                                             setState(() {
    //                                               item.textEditorController
    //                                                   .formatSelection(
    //                                                 ColorAttribute(
    //                                                     '#${colorToHex(color)}'),
    //                                               );
    //                                               hexController.text =
    //                                                   '${item.textEditorController.getSelectionStyle().attributes['color']?.value}';
    //                                             });
    //                                           },
    //                                         ),
    //                                       ],
    //                                     ),
    //                                     //Text BG COLOR
    //                                     Text('TEXT BACKGROUND',
    //                                         textAlign: TextAlign.start,
    //                                         style: GoogleFonts.bungee(
    //                                             color: defaultPalette.extras[0],
    //                                             fontSize:
    //                                                 (width / 6).clamp(5, 25))),
          
    //                                     //FontBGColor HEX TITLE
    //                                     Container(
    //                                       width:
    //                                           sWidth * wH2DividerPosition - 45,
    //                                       height: 15,
    //                                       alignment: Alignment.topCenter,
    //                                       margin: EdgeInsets.only(
    //                                           top: 10, right: 5),
    //                                       padding: EdgeInsets.only(
    //                                           left: 5, right: 5),
    //                                       decoration: BoxDecoration(
    //                                           borderRadius:
    //                                               BorderRadius.circular(5),
    //                                           border: Border.all(width: 0.1)),
    //                                       child: Row(
    //                                         mainAxisAlignment:
    //                                             MainAxisAlignment.spaceBetween,
    //                                         crossAxisAlignment:
    //                                             CrossAxisAlignment.start,
    //                                         children: [
    //                                           Expanded(
    //                                             flex: 5,
    //                                             child: Text(
    //                                               'FONT BG HEX',
    //                                               style: GoogleFonts.bungee(
    //                                                   fontSize: 10),
    //                                             ),
    //                                           ),
    //                                           Expanded(
    //                                             flex: 3,
    //                                             child: TextFormField(
    //                                               onTapOutside: (event) {},
    //                                               controller: bghexController,
    //                                               inputFormatters: [
    //                                                 HexColorInputFormatter()
    //                                               ],
    //                                               onFieldSubmitted: (color) {
    //                                                 item.textEditorController
    //                                                     .formatSelection(
    //                                                   BackgroundAttribute(
    //                                                       color),
    //                                                 );
    //                                               },
    //                                               style: GoogleFonts.bungee(
    //                                                   fontSize: 10),
    //                                               cursorColor:
    //                                                   defaultPalette.tertiary,
    //                                               textAlign: TextAlign.center,
    //                                               textAlignVertical:
    //                                                   TextAlignVertical.center,
    //                                               decoration: InputDecoration(
    //                                                 contentPadding:
    //                                                     const EdgeInsets.all(0),
    //                                                 border: InputBorder.none,
    //                                                 enabledBorder:
    //                                                     OutlineInputBorder(
    //                                                   borderSide: BorderSide(
    //                                                       width: 2,
    //                                                       color: defaultPalette
    //                                                           .transparent),
    //                                                   borderRadius:
    //                                                       BorderRadius.circular(
    //                                                           12.0),
    //                                                 ),
    //                                                 focusedBorder:
    //                                                     OutlineInputBorder(
    //                                                   borderSide: BorderSide(
    //                                                       width: 3,
    //                                                       color: defaultPalette
    //                                                           .transparent),
    //                                                   borderRadius:
    //                                                       BorderRadius.circular(
    //                                                           10.0),
    //                                                 ),
    //                                               ),
    //                                               keyboardType:
    //                                                   TextInputType.number,
    //                                             ),
    //                                           ),
    //                                         ],
    //                                       ),
    //                                     ),
          
    //                                     //FontBGColor SWATCH And WHEEL FOR PAGE COLOR
    //                                     Stack(
    //                                       children: [
    //                                         SizedBox(
    //                                             width: ((sWidth *
    //                                                     wH2DividerPosition -
    //                                                 115)),
    //                                             height: 140),
    //                                         //COLOR WHEEL FOR PAGE COLOR
    //                                         Positioned(
    //                                           right: 7,
    //                                           height: 140,
    //                                           width: 100,
    //                                           top: 4,
    //                                           child: Column(
    //                                             crossAxisAlignment:
    //                                                 CrossAxisAlignment.end,
    //                                             children: [
    //                                               //COLOR WHEEL FOR PAGE COLOR
    //                                               SizedBox(
    //                                                 height: 100,
    //                                                 width: 95,
    //                                                 child: fl.ColorWheelPicker(
    //                                                   color: hexToColor(item
    //                                                       .textEditorController
    //                                                       .getSelectionStyle()
    //                                                       .attributes[
    //                                                           'background']
    //                                                       ?.value),
    //                                                   onChanged: (color) {
    //                                                     setState(() {
    //                                                       item.textEditorController
    //                                                           .formatSelection(
    //                                                         BackgroundAttribute(
    //                                                             '#${colorToHex(color)}'),
    //                                                       );
    //                                                       bghexController.text =
    //                                                           '${item.textEditorController.getSelectionStyle().attributes['background']?.value}';
    //                                                     });
    //                                                   },
    //                                                   onChangeEnd: (value) {
    //                                                     _renderPagePreviewOnProperties();
    //                                                   },
    //                                                   onWheel: (bool value) {},
    //                                                   wheelSquarePadding: 5,
    //                                                   wheelWidth: 8,
    //                                                   hasBorder: true,
    //                                                   shouldUpdate: true,
    //                                                 ),
    //                                               ),
    //                                               SizedBox(
    //                                                 height: 0,
    //                                               ),
          
    //                                               //Name of PAGE COLOR
    //                                               Text(
    //                                                   fl.ColorTools
    //                                                       .nameThatColor(
    //                                                     hexToColor(item
    //                                                         .textEditorController
    //                                                         .getSelectionStyle()
    //                                                         .attributes[
    //                                                             'background']
    //                                                         ?.value),
    //                                                   ),
    //                                                   textAlign: TextAlign.end,
    //                                                   style: GoogleFonts.bungee(
    //                                                       fontSize: 12)),
    //                                             ],
    //                                           ),
    //                                         ),
    //                                         //COLOR SWATCH FOR PAGE COLOR
          
    //                                         fl.ColorPicker(
    //                                           color: hexToColor(item
    //                                               .textEditorController
    //                                               .getSelectionStyle()
    //                                               .attributes['background']
    //                                               ?.value),
    //                                           pickersEnabled: const {
    //                                             fl.ColorPickerType.both: false,
    //                                             fl.ColorPickerType.primary:
    //                                                 false,
    //                                             fl.ColorPickerType.accent:
    //                                                 false,
    //                                             fl.ColorPickerType.bw: false,
    //                                             fl.ColorPickerType.custom: true,
    //                                             fl.ColorPickerType.wheel: false
    //                                           },
    //                                           enableTooltips: true,
    //                                           showColorName: false,
    //                                           //  ((sWidth *
    //                                           //           wH2DividerPosition) -
    //                                           //       145) >
    //                                           //   66? true:false,
    //                                           // showColorCode: true,
    //                                           // enableOpacity: true,
    //                                           customColorSwatchesAndNames: {
    //                                             createSwatch(
    //                                                 hexToColor(item
    //                                                     .textEditorController
    //                                                     .getSelectionStyle()
    //                                                     .attributes[
    //                                                         'background']
    //                                                     ?.value),
    //                                                 12): ''
    //                                           },
    //                                           colorCodeHasColor: true,
    //                                           enableShadesSelection: true,
    //                                           colorCodeReadOnly: false,
    //                                           height:
    //                                               ((sWidth * wH2DividerPosition -
    //                                                           145) /
    //                                                       3)
    //                                                   .clamp(15, 30),
    //                                           width:
    //                                               ((sWidth * wH2DividerPosition -
    //                                                           145) /
    //                                                       4)
    //                                                   .clamp(15, 30),
    //                                           runSpacing: 2,
    //                                           shadesSpacing: 0,
    //                                           spacing: 1,
    //                                           borderRadius: 5,
    //                                           hasBorder: true,
    //                                           borderColor:
    //                                               const Color(0xFF3F3F3F)
    //                                                   .withOpacity(0.6),
    //                                           colorNameTextStyle:
    //                                               GoogleFonts.bungee(
    //                                                   fontSize: 10),
    //                                           colorCodeTextStyle:
    //                                               GoogleFonts.bungee(
    //                                                   fontSize: 8),
    //                                           colorCodePrefixStyle:
    //                                               GoogleFonts.bungee(
    //                                                   fontSize: 8),
    //                                           columnSpacing: 5,
    //                                           crossAxisAlignment:
    //                                               CrossAxisAlignment.start,
    //                                           toolbarSpacing: 0,
    //                                           selectedColorIcon:
    //                                               TablerIcons.circle,
    //                                           editIcon: TablerIcons.circle,
    //                                           padding: EdgeInsets.only(
    //                                               right: 115, top: 10),
    //                                           wheelWidth: 5,
    //                                           wheelSquarePadding: 8,
    //                                           wheelDiameter: 120,
    //                                           wheelSquareBorderRadius: 8,
    //                                           opacityThumbRadius: 12,
    //                                           opacityTrackHeight: 12,
    //                                           wheelHasBorder: true,
    //                                           onColorChangeEnd: (value) {
    //                                             _renderPagePreviewOnProperties();
    //                                           },
    //                                           onColorChanged: (color) {
    //                                             setState(() {
    //                                               item.textEditorController
    //                                                   .formatSelection(
    //                                                 BackgroundAttribute(
    //                                                     '#${colorToHex(color)}'),
    //                                               );
    //                                               bghexController.text =
    //                                                   '${item.textEditorController.getSelectionStyle().attributes['background']?.value}';
    //                                             });
    //                                           },
    //                                         ),
    //                                       ],
    //                                     ),
    //                                   ],
    //                                 );
    //                               })),
    //                       //
    //                     ),
    //                   )
    //                 ]
    //               ],
    //             );
    //           }),
    //     ),
    //     Transform.translate(
    //       offset:Offset(whichPropertyTabIsClicked==3?0: sWidth,0),
    //       child: AppinioSwiper(
    //         controller: listPropertyCardsController,
    //         backgroundCardCount: 1,
    //         backgroundCardOffset: Offset(3, 3),
    //         duration: Duration(milliseconds: 150),
    //         backgroundCardScale: 1,
    //         loop: true,
    //         cardCount: 2,
    //         allowUnSwipe: true,
    //         allowUnlimitedUnSwipe: true,
    //         initialIndex: 0,
    //         onCardPositionChanged: (position) {
    //           setState(() {
    //             _cardPosition =
    //                 position.offset.dx.abs() + position.offset.dy.abs();
    //           });
    //         },
    //         onSwipeEnd: (a, b, direction) {
    //           // print(direction.toString());
    //           setState(() {
    //             // ref.read(propertyCardIndexProvider.notifier).update((s) => s = b);
    //             whichListPropertyTabIsClicked = b;
    //             listPropertyTabContainerController.index =
    //                 whichListPropertyTabIsClicked;
    //             _cardPosition = 0;
    //           });
    //         },
    //         onSwipeCancelled: (activity) {},
    //         cardBuilder: (BuildContext context, int index) {
    //           int currentCardIndex = whichListPropertyTabIsClicked;
    //           var width = (sWidth * wH2DividerPosition - 25);
          
    //           // bool useIndListPad = (sheetListItem.listDecoration.padding.top ==
    //           //         sheetListItem.listDecoration.padding.bottom &&
    //           //     sheetListItem.listDecoration.padding.bottom ==
    //           //         sheetListItem.listDecoration.padding.left &&
    //           //     sheetListItem.listDecoration.padding.left ==
    //           //         sheetListItem.listDecoration.padding.right);
    //           // bool useIndWidthAdj =
    //           //     (sheetListItem.listDecoration.widthAdjustment.top ==
    //           //             sheetListItem.listDecoration.widthAdjustment.bottom &&
    //           //         sheetListItem.listDecoration.widthAdjustment.bottom ==
    //           //             sheetListItem.listDecoration.widthAdjustment.left &&
    //           //         sheetListItem.listDecoration.widthAdjustment.left ==
    //           //             sheetListItem.listDecoration.widthAdjustment.right);
    //           // var listPaddingControllers = [
    //           //   TextEditingController(
    //           //       text: !useIndListPad
    //           //           ? '.'
    //           //           : sheetListItem.listDecoration.padding.top.toString()),
    //           //   TextEditingController(
    //           //       text:
    //           //           (sheetListItem.listDecoration.padding.top).toString()),
    //           //   TextEditingController(
    //           //       text: (sheetListItem.listDecoration.padding.bottom)
    //           //           .toString()),
    //           //   TextEditingController(
    //           //       text:
    //           //           (sheetListItem.listDecoration.padding.left).toString()),
    //           //   TextEditingController(
    //           //       text: (sheetListItem.listDecoration.padding.right)
    //           //           .toString()),
    //           // ];
    //       //
    //           // var widthAdjustmentControllers = [
    //           //   TextEditingController(
    //           //       text: !useIndWidthAdj
    //           //           ? '.'
    //           //           : sheetListItem.listDecoration.widthAdjustment.top
    //           //               .toString()),
    //           //   TextEditingController(
    //           //       text: (sheetListItem.listDecoration.widthAdjustment.top)
    //           //           .toString()),
    //           //   TextEditingController(
    //           //       text: (sheetListItem.listDecoration.widthAdjustment.bottom)
    //           //           .toString()),
    //           //   TextEditingController(
    //           //       text: (sheetListItem.listDecoration.widthAdjustment.left)
    //           //           .toString()),
    //           //   TextEditingController(
    //           //       text: (sheetListItem.listDecoration.widthAdjustment.right)
    //           //           .toString()),
    //           // ];
    //       //
    //           // var colorHexControllers = [
    //           //   TextEditingController(
    //           //     text: colorToHex(
    //           //         sheetListItem.listDecoration.decoration.color ??
    //           //             defaultPalette.transparent),
    //           //   ),
    //           //   TextEditingController(
    //           //     text: colorToHex(sheetListItem
    //           //             .listDecoration.decoration.border?.bottom.color ??
    //           //         defaultPalette.transparent),
    //           //   )
    //           // ];
    //       //
    //           // var borderControllers = [
    //           //   TextEditingController(
    //           //     text: ((sheetListItem.listDecoration.decoration.border?.bottom
    //           //                 .width) ??
    //           //             1)
    //           //         .toString(),
    //           //   ),
    //           //   TextEditingController(
    //           //     text: (sheetListItem.listDecoration.decoration.border != null
    //           //             ? (sheetListItem.listDecoration.decoration.border
    //           //                     as Border)
    //           //                 .right
    //           //                 .width
    //           //             : 1)
    //           //         .toString(),
    //           //   ),
    //           //   TextEditingController(
    //           //     text: (sheetListItem.listDecoration.decoration.border != null
    //           //             ? (sheetListItem.listDecoration.decoration.border
    //           //                     as Border)
    //           //                 .left
    //           //                 .width
    //           //             : 1)
    //           //         .toString(),
    //           //   ),
    //           // ];
    //       //
    //           // var borderRadiusControllers = [
    //           //   TextEditingController(
    //           //       text: sheetListItem
    //           //                   .listDecoration.decoration.borderRadius !=
    //           //               null
    //           //           ? (sheetListItem.listDecoration.decoration.borderRadius
    //           //                   as BorderRadius)
    //           //               .topLeft
    //           //               .x
    //           //               .toString()
    //           //           : '0'),
    //           //   TextEditingController(
    //           //       text: sheetListItem
    //           //                   .listDecoration.decoration.borderRadius !=
    //           //               null
    //           //           ? (sheetListItem.listDecoration.decoration.borderRadius
    //           //                   as BorderRadius)
    //           //               .topLeft
    //           //               .x
    //           //               .toString()
    //           //           : '0'),
    //           //   TextEditingController(
    //           //       text: sheetListItem
    //           //                   .listDecoration.decoration.borderRadius !=
    //           //               null
    //           //           ? (sheetListItem.listDecoration.decoration.borderRadius
    //           //                   as BorderRadius)
    //           //               .topRight
    //           //               .x
    //           //               .toString()
    //           //           : '0'),
    //           //   TextEditingController(
    //           //       text: sheetListItem
    //           //                   .listDecoration.decoration.borderRadius !=
    //           //               null
    //           //           ? (sheetListItem.listDecoration.decoration.borderRadius
    //           //                   as BorderRadius)
    //           //               .bottomLeft
    //           //               .x
    //           //               .toString()
    //           //           : '0'),
    //           //   TextEditingController(
    //           //       text: sheetListItem
    //           //                   .listDecoration.decoration.borderRadius !=
    //           //               null
    //           //           ? (sheetListItem.listDecoration.decoration.borderRadius
    //           //                   as BorderRadius)
    //           //               .bottomRight
    //           //               .x
    //           //               .toString()
    //           //           : '0'),
    //           // ];
          
    //           return Stack(
    //             children: [
    //               Positioned.fill(
    //                 child: AnimatedContainer(
    //                   duration: Durations.short3,
    //                   margin: EdgeInsets.all(10).copyWith(left: 5, right: 8),
    //                   alignment: Alignment.center,
    //                   decoration: BoxDecoration(
    //                     color: Colors.white,
    //                     border: Border.all(width: 2),
    //                     borderRadius: BorderRadius.circular(25),
    //                   ),
    //                 ),
    //               ),
    //               Positioned.fill(
    //                 child: AnimatedOpacity(
    //                   opacity: currentCardIndex == index
    //                       ? 0
    //                       : index >= (currentCardIndex + 2) % 10
    //                           ? 1
    //                           : (1 - (_cardPosition / 200).clamp(0.0, 1.0)),
    //                   duration: Duration(milliseconds: 300),
    //                   child: AnimatedContainer(
    //                     duration: Duration(milliseconds: 300),
    //                     margin: EdgeInsets.all(10).copyWith(left: 5, right: 8),
    //                     alignment: Alignment.center,
    //                     decoration: BoxDecoration(
    //                       color: index == (currentCardIndex + 1) % 10
    //                           ? defaultPalette.extras[0]
    //                           : index == (currentCardIndex + 2) % 10
    //                               ? defaultPalette.extras[0]
    //                               : defaultPalette.extras[0],
    //                       border: Border.all(width: 2),
    //                       borderRadius: BorderRadius.circular(25),
    //                     ),
    //                   ),
    //                 ),
    //               ),
          
    //               // LIST PROPERTIES Tab Parent
    //               if (index == 2) ...[
    //                 Positioned.fill(
    //                   top: 5,
    //                   left: 0,
    //                   child: AnimatedOpacity(
    //                     opacity: 1,
    //                     duration: Duration.zero,
    //                     child: Padding(
    //                       padding:
    //                           EdgeInsets.all(15).copyWith(left: 5, right: 5),
    //                       child: PieCanvas(
    //                         child: Container(
    //                           padding: EdgeInsets.only(
    //                               top: 10, left: 8, right: 8, bottom: 10),
    //                           decoration: BoxDecoration(
    //                             borderRadius: BorderRadius.circular(25),
    //                             color: defaultPalette.transparent,
    //                           ),
    //                           child: ClipRRect(
    //                             borderRadius: BorderRadius.circular(20),
    //                             child: ScrollConfiguration(
    //                               behavior: ScrollBehavior()
    //                                   .copyWith(scrollbars: false),
    //                               child: DynMouseScroll(
    //                                   durationMS: 500,
    //                                   scrollSpeed: 1,
    //                                   builder: (context, controller, physics) {
    //                                     return SingleChildScrollView(
    //                                       controller: controller,
    //                                       physics: physics,
    //                                       child: Column(
    //                                         crossAxisAlignment:
    //                                             CrossAxisAlignment.center,
    //                                         children: [
    //                                           SizedBox(height: 50),
          
    //                                           ////The setup for direction Switching
    //                                           Container(
    //                                             width: width,
    //                                             decoration: BoxDecoration(
    //                                                 color:
    //                                                     defaultPalette.primary,
    //                                                 borderRadius:
    //                                                     BorderRadius.circular(
    //                                                         10)),
    //                                             padding: EdgeInsets.all(3)
    //                                                 .copyWith(top: 2),
    //                                             child: Column(
    //                                               children: [
    //                                                 Text(
    //                                                   'direction',
    //                                                   style: GoogleFonts.prompt(
    //                                                       fontSize: 10,
    //                                                       fontWeight:
    //                                                           FontWeight.w500),
    //                                                 ),
    //                                                 AnimatedToggleSwitch<
    //                                                     Axis>.dual(
    //                                                   current: sheetListItem
    //                                                       .direction,
    //                                                   first: Axis.vertical,
    //                                                   second: Axis.horizontal,
    //                                                   onChanged: (value) {
    //                                                     setState(() {
    //                                                       sheetListItem
    //                                                               .direction =
    //                                                           value;
    //                                                     });
    //                                                   },
    //                                                   animationCurve:
    //                                                       Curves.easeInOutExpo,
    //                                                   animationDuration:
    //                                                       Durations.medium4,
    //                                                   borderWidth:
    //                                                       2, // backgroundColor is set independently of the current selection
    //                                                   styleBuilder: (value) =>
    //                                                       ToggleStyle(
    //                                                           borderRadius:
    //                                                               BorderRadius
    //                                                                   .circular(
    //                                                                       10),
    //                                                           // indicatorBorder: Border.all(
    //                                                           //   width: 1.5,
    //                                                           //   color: defaultPalette.extras[0],
    //                                                           // ),
    //                                                           indicatorBorderRadius:
    //                                                               BorderRadius
    //                                                                   .circular(
    //                                                                       15),
    //                                                           borderColor:
    //                                                               defaultPalette
    //                                                                   .secondary,
    //                                                           backgroundColor:
    //                                                               defaultPalette
    //                                                                   .secondary,
    //                                                           indicatorColor:
    //                                                               defaultPalette
    //                                                                       .extras[
    //                                                                   0]), // indicatorColor changes and animates its value with the selection
    //                                                   iconBuilder: (value) {
    //                                                     return Icon(
    //                                                         value ==
    //                                                                 Axis
    //                                                                     .horizontal
    //                                                             ? TablerIcons
    //                                                                 .grip_horizontal
    //                                                             : TablerIcons
    //                                                                 .grip_vertical,
    //                                                         size: 12,
    //                                                         color:
    //                                                             defaultPalette
    //                                                                 .primary);
    //                                                   },
    //                                                   textBuilder: (value) {
    //                                                     return Text(
    //                                                       value ==
    //                                                               Axis.horizontal
    //                                                           ? 'Horizontal'
    //                                                           : 'Vertical',
    //                                                       style: GoogleFonts
    //                                                           .bungee(
    //                                                               fontSize: 12),
    //                                                     );
    //                                                   },
    //                                                   height: 25,
    //                                                   spacing: (width),
    //                                                 ),
    //                                               ],
    //                                             ),
    //                                           ),
          
    //                                           SizedBox(height: 10),
          
    //                                           //The setup for both cross and main AxisSelectionButtons
    //                                           Row(children: [
    //                                             //The setup for mainAxisSelectionButton
    //                                             Expanded(
    //                                                 flex: 1,
    //                                                 child: Container(
    //                                                   decoration: BoxDecoration(
    //                                                       color: defaultPalette
    //                                                           .primary,
    //                                                       borderRadius:
    //                                                           BorderRadius
    //                                                               .circular(
    //                                                                   20)),
    //                                                   padding: EdgeInsets.all(3)
    //                                                       .copyWith(top: 2),
    //                                                   child: Column(
    //                                                     children: [
    //                                                       Text(
    //                                                         'mainAxis',
    //                                                         style: GoogleFonts
    //                                                             .prompt(
    //                                                                 fontSize:
    //                                                                     10,
    //                                                                 fontWeight:
    //                                                                     FontWeight
    //                                                                         .w500),
    //                                                       ),
    //                                                       PieMenu(
    //                                                         controller:
    //                                                             listMainAxisAlignmentPieController,
    //                                                         actions: [
    //                                                           getPieActionForListAxis(
    //                                                               0),
    //                                                           getPieActionForListAxis(
    //                                                               1),
    //                                                           getPieActionForListAxis(
    //                                                               2),
    //                                                           getPieActionForListAxis(
    //                                                               3),
    //                                                           getPieActionForListAxis(
    //                                                               4),
    //                                                           getPieActionForListAxis(
    //                                                               5),
    //                                                         ],
    //                                                         onToggle:
    //                                                             (menuOpen) {
    //                                                           if (!menuOpen) {
    //                                                             listDirectionPieController
    //                                                                 .closeMenu();
    //                                                             listCrossAxisAlignmentDirectionPieController
    //                                                                 .closeMenu();
    //                                                             listMainAxisAlignmentPieController
    //                                                                 .closeMenu();
    //                                                           }
    //                                                         },
    //                                                         theme: PieTheme(
    //                                                             rightClickShowsMenu:
    //                                                                 true,
    //                                                             buttonSize:
    //                                                                 ((sWidth * wH2DividerPosition - 100) / 3)
    //                                                                     .clamp(
    //                                                                         40, 70),
    //                                                             spacing: 5,
    //                                                             radius: ((sWidth * wH2DividerPosition - 85) /
    //                                                                     2)
    //                                                                 .clamp(
    //                                                                     50, 100),
    //                                                             customAngle: 0,
    //                                                             menuAlignment:
    //                                                                 Alignment
    //                                                                     .center,
    //                                                             pointerSize: 20,
    //                                                             menuDisplacement:
    //                                                                 Offset(
    //                                                                     0, 0),
    //                                                             // tooltipPadding: EdgeInsets.all(5),
    //                                                             tooltipTextStyle:
    //                                                                 GoogleFonts.bungee(
    //                                                                     fontSize:
    //                                                                         20),
    //                                                             buttonTheme:
    //                                                                 PieButtonTheme(
    //                                                                     backgroundColor: defaultPalette
    //                                                                         .tertiary,
    //                                                                     iconColor:
    //                                                                         defaultPalette
    //                                                                             .primary,
    //                                                                     decoration:
    //                                                                         BoxDecoration(
    //                                                                       border:
    //                                                                           Border.all(width: 1),
    //                                                                       borderRadius:
    //                                                                           BorderRadius.circular(200),
    //                                                                       color:
    //                                                                           defaultPalette.extras[0],
    //                                                                     ))),
    //                                                         child:
    //                                                             GestureDetector(
    //                                                           onTap: () {
    //                                                             listMainAxisAlignmentPieController
    //                                                                 .openMenu();
    //                                                           }, // Handle tap manually
    //                                                           child: Container(
    //                                                             decoration:
    //                                                                 BoxDecoration(
    //                                                               color: defaultPalette
    //                                                                   .secondary,
    //                                                               borderRadius:
    //                                                                   BorderRadius
    //                                                                       .circular(
    //                                                                           15.0), // Custom shape
    //                                                             ),
    //                                                             margin:
    //                                                                 const EdgeInsets
    //                                                                     .only(
    //                                                                     top:
    //                                                                         2.0,
    //                                                                     left: 1,
    //                                                                     right:
    //                                                                         1,
    //                                                                     bottom:
    //                                                                         0),
    //                                                             height: 62,
    //                                                             padding: EdgeInsets
    //                                                                 .symmetric(
    //                                                                     horizontal:
    //                                                                         3), // Padding
    //                                                             // constraints: BoxConstraints(
    //                                                             //   minWidth: (sWidth * wH2DividerPosition - 90) / 2, // Width constraint
    //                                                             //   minHeight: 42, // Height constraint
    //                                                             // ),
    //                                                             child: Center(
    //                                                               child: Column(
    //                                                                 mainAxisAlignment:
    //                                                                     MainAxisAlignment
    //                                                                         .spaceAround,
    //                                                                 children: [
    //                                                                   Container(
    //                                                                       decoration:
    //                                                                           BoxDecoration(
    //                                                                         color:
    //                                                                             defaultPalette.extras[1],
    //                                                                         borderRadius:
    //                                                                             BorderRadius.circular(15.0), // Custom shape
    //                                                                       ),
    //                                                                       margin: const EdgeInsets
    //                                                                           .only(
    //                                                                           top:
    //                                                                               2.0,
    //                                                                           left:
    //                                                                               1,
    //                                                                           right:
    //                                                                               1,
    //                                                                           bottom:
    //                                                                               0),
    //                                                                       alignment: Alignment
    //                                                                           .center,
    //                                                                       height:
    //                                                                           40,
    //                                                                       child:
    //                                                                           Icon(TablerIcons.kerning)),
    //                                                                   //The text under the mainAxis button that says space between start end or wtever
    //                                                                   Padding(
    //                                                                     padding: const EdgeInsets
    //                                                                         .symmetric(
    //                                                                         horizontal:
    //                                                                             10.0),
    //                                                                     child:
    //                                                                         Text(
    //                                                                       sheetListItem
    //                                                                           .mainAxisAlignment
    //                                                                           .name,
    //                                                                       maxLines:
    //                                                                           1,
    //                                                                       style:
    //                                                                           GoogleFonts.bungee(
    //                                                                         fontSize:
    //                                                                             10,
    //                                                                         color:
    //                                                                             defaultPalette.extras[0],
    //                                                                       ),
    //                                                                     ),
    //                                                                   ),
    //                                                                 ],
    //                                                               ),
    //                                                             ),
    //                                                           ),
    //                                                         ),
    //                                                       ),
    //                                                     ],
    //                                                   ),
    //                                                 )),
    //                                             SizedBox(width: 5),
    //                                             //The setup for crossAxisSelectionButton
    //                                             Expanded(
    //                                                 flex: 1,
    //                                                 child: Container(
    //                                                   decoration: BoxDecoration(
    //                                                       color: defaultPalette
    //                                                           .primary,
    //                                                       borderRadius:
    //                                                           BorderRadius
    //                                                               .circular(
    //                                                                   20)),
    //                                                   padding:
    //                                                       const EdgeInsets.all(
    //                                                               3)
    //                                                           .copyWith(top: 2),
    //                                                   child: Column(
    //                                                     children: [
    //                                                       //THE HEADING "crossAxis"
    //                                                       Text(
    //                                                         'crossAxis',
    //                                                         style: GoogleFonts
    //                                                             .prompt(
    //                                                                 fontSize:
    //                                                                     10,
    //                                                                 fontWeight:
    //                                                                     FontWeight
    //                                                                         .w500),
    //                                                       ),
    //                                                       PieMenu(
    //                                                         controller:
    //                                                             listDirectionPieController,
    //                                                         actions: [
    //                                                           getPieActionForListAxis(
    //                                                               0,
    //                                                               cross: true),
    //                                                           getPieActionForListAxis(
    //                                                               1,
    //                                                               cross: true),
    //                                                           getPieActionForListAxis(
    //                                                               2,
    //                                                               cross: true),
    //                                                         ],
    //                                                         onToggle:
    //                                                             (menuOpen) {
    //                                                           if (!menuOpen) {
    //                                                             listDirectionPieController
    //                                                                 .closeMenu();
    //                                                             listCrossAxisAlignmentDirectionPieController
    //                                                                 .closeMenu();
    //                                                             listMainAxisAlignmentPieController
    //                                                                 .closeMenu();
    //                                                           }
    //                                                         },
    //                                                         theme: PieTheme(
    //                                                             rightClickShowsMenu:
    //                                                                 true,
    //                                                             buttonSize:
    //                                                                 ((sWidth * wH2DividerPosition - 65) / 3).clamp(
    //                                                                     40, 80),
    //                                                             spacing: 5,
    //                                                             radius: ((sWidth * wH2DividerPosition - 65) /
    //                                                                     2)
    //                                                                 .clamp(
    //                                                                     50, 100),
    //                                                             customAngle:
    //                                                                 180,
    //                                                             menuAlignment:
    //                                                                 Alignment
    //                                                                     .center,
    //                                                             pointerSize: 20,
    //                                                             menuDisplacement:
    //                                                                 Offset(
    //                                                                     0, 0),
    //                                                             // tooltipPadding: EdgeInsets.all(5),
    //                                                             tooltipTextStyle:
    //                                                                 GoogleFonts.bungee(
    //                                                                     fontSize:
    //                                                                         20),
    //                                                             buttonTheme:
    //                                                                 PieButtonTheme(
    //                                                                     backgroundColor:
    //                                                                         defaultPalette
    //                                                                             .tertiary,
    //                                                                     iconColor:
    //                                                                         defaultPalette
    //                                                                             .primary,
    //                                                                     decoration:
    //                                                                         BoxDecoration(
    //                                                                       border:
    //                                                                           Border.all(width: 1),
    //                                                                       borderRadius:
    //                                                                           BorderRadius.circular(200),
    //                                                                       color:
    //                                                                           defaultPalette.extras[0],
    //                                                                     ))),
    //                                                         child:
    //                                                             GestureDetector(
    //                                                           onTap: () {
    //                                                             listDirectionPieController
    //                                                                 .openMenu();
    //                                                           }, // Handle tap manually
    //                                                           child: Container(
    //                                                             decoration:
    //                                                                 BoxDecoration(
    //                                                               color: defaultPalette
    //                                                                   .secondary,
    //                                                               borderRadius:
    //                                                                   BorderRadius
    //                                                                       .circular(
    //                                                                           15.0), // Custom shape
    //                                                             ),
    //                                                             margin:
    //                                                                 const EdgeInsets
    //                                                                     .only(
    //                                                                     top:
    //                                                                         2.0,
    //                                                                     left: 1,
    //                                                                     right:
    //                                                                         1,
    //                                                                     bottom:
    //                                                                         0),
    //                                                             height: 62,
    //                                                             padding: EdgeInsets
    //                                                                 .symmetric(
    //                                                                     horizontal:
    //                                                                         3),
    //                                                             child: Center(
    //                                                               child: Column(
    //                                                                 mainAxisAlignment:
    //                                                                     MainAxisAlignment
    //                                                                         .spaceAround,
    //                                                                 children: [
    //                                                                   Container(
    //                                                                       decoration:
    //                                                                           BoxDecoration(
    //                                                                         color:
    //                                                                             defaultPalette.extras[1],
    //                                                                         borderRadius:
    //                                                                             BorderRadius.circular(15.0), // Custom shape
    //                                                                       ),
    //                                                                       margin: const EdgeInsets
    //                                                                           .only(
    //                                                                           top:
    //                                                                               2.0,
    //                                                                           left:
    //                                                                               1,
    //                                                                           right:
    //                                                                               1,
    //                                                                           bottom:
    //                                                                               0),
    //                                                                       alignment: Alignment
    //                                                                           .center,
    //                                                                       height:
    //                                                                           40,
    //                                                                       child:
    //                                                                           Icon(TablerIcons.karate)),
    //                                                                   Padding(
    //                                                                     padding: const EdgeInsets
    //                                                                         .symmetric(
    //                                                                         horizontal:
    //                                                                             10.0),
    //                                                                     child:
    //                                                                         Text(
    //                                                                       sheetListItem
    //                                                                           .crossAxisAlignment
    //                                                                           .name,
    //                                                                       maxLines:
    //                                                                           1,
    //                                                                       style:
    //                                                                           GoogleFonts.bungee(
    //                                                                         fontSize:
    //                                                                             10,
    //                                                                         color:
    //                                                                             defaultPalette.extras[0],
    //                                                                       ),
    //                                                                     ),
    //                                                                   ),
    //                                                                 ],
    //                                                               ),
    //                                                             ),
    //                                                           ),
    //                                                         ),
    //                                                       ),
    //                                                     ],
    //                                                   ),
    //                                                 )),
    //                                           ]),
    //                                           SizedBox(height: 10),
          
    //                                           SizedBox(height: 10),
    //                                         ],
    //                                       ),
    //                                     );
    //                                   }),
    //                             ),
    //                           ),
    //                         ),
    //                       ),
    //                     ),
    //                   ),
    //                 ),
    //               ],
          
    //               if (index == 1) ...[
    //                 Positioned.fill(
    //                   child: AnimatedPadding(
    //                     duration: Durations.medium1,
    //                     padding:
    //                         EdgeInsets.all(17.2).copyWith(right: 15, left: 12.2),
    //                     child: ClipRRect(
    //                       borderRadius: BorderRadius.circular(10),
    //                       child: Column(
    //                         children: [
    //                           //DECO TITLE 
    //                           Row(
    //                             mainAxisAlignment:
    //                                 MainAxisAlignment
    //                                     .spaceBetween,
    //                             crossAxisAlignment: CrossAxisAlignment.start,
    //                             children: [
    //                               //Black Balloon button and circlebutton elevated on upper half
    //                               Column(
    //                                 crossAxisAlignment: CrossAxisAlignment.start,
    //                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                                 children: [
    //                                   GestureDetector(
    //                                     onTap:(){
    //                                        setState(() {
    //                                       if (sheetListItem
    //                                                 .listDecoration
    //                                                 .itemDecorationList.length<70) {
    //                                       sheetListItem
    //                                               .listDecoration =
    //                                           sheetListItem
    //                                               .listDecoration
    //                                               .copyWith(
    //                                                   itemDecorationList: [
    //                                             ...sheetListItem
    //                                                 .listDecoration
    //                                                 .itemDecorationList,
    //                                                 SuperDecoration(id: Uuid().v4())
    //                                              , 
    //                                           ]);
    //                                           print(
    //                                         'new decoration added');
    //                                     } else {
    //                                       print(
    //                                         'guys come on, turn this into a super now');
    //                                     }
    //                                     });
    //                                     },
    //                                     child: AnimatedContainer(
    //                                       duration:Durations.medium4,
    //                                       curve: Curves.easeInOut,
    //                                       height:32,
    //                                       width:32,
    //                                       child: Icon(TablerIcons.balloon, size:20,
    //                                       color: defaultPalette.primary),
    //                                       // padding: EdgeInsets.only(left:5), 
    //                                       decoration: BoxDecoration(
    //                                         color: defaultPalette.extras[0],
    //                                         borderRadius: BorderRadius.circular(500) ,
    //                                       ),  
    //                                     ),
    //                                   ), 
    //                                   SizedBox(height:3),
    //                                   //add new itemdecoration Layer
    //                                   ElevatedLayerButton( 
    //                                     subfac: 2,
    //                                     depth:2,
    //                                     onClick: ()  { 
    //                                       print(
    //                                         'tapped to add new decoration ');
    //                                     setState(() {
    //                                       if (sheetListItem
    //                                                 .listDecoration
    //                                                 .itemDecorationList.length<70) {
    //                                       sheetListItem
    //                                               .listDecoration =
    //                                           sheetListItem
    //                                               .listDecoration
    //                                               .copyWith(
    //                                                   itemDecorationList: [
    //                                             ...sheetListItem
    //                                                 .listDecoration
    //                                                 .itemDecorationList,
    //                                             ItemDecoration(
    //                                                 pinned: defaultPins(),
    //                                                 id: Uuid()
    //                                                     .v4(),
    //                                                 padding:
    //                                                     EdgeInsets.all(
    //                                                         5),
    //                                                 alignment: Alignment.topLeft,
    //                                                 decoration: BoxDecoration(
                                                        
    //                                                     color: defaultPalette
    //                                                         .tertiary,
    //                                                     border:
    //                                                         Border.all())),
    //                                           ]);
    //                                           print(
    //                                         'new decoration added'); 
    //                                         print(defaultPins()['padding']['isPinned']);
    //                                     } else {
    //                                       print(
    //                                         'guys come on, turn this into a super now');
    //                                     }
    //                                     }); 
    //                                     },
    //                                     buttonHeight: 25,
    //                                     buttonWidth: 25,
    //                                     borderRadius:
    //                                         BorderRadius.circular(50),
    //                                     animationDuration:
    //                                         const Duration(milliseconds: 30),
    //                                     animationCurve: Curves.ease,
    //                                     topDecoration: BoxDecoration(
    //                                       color: Colors.white,
    //                                       border: Border.all(),
    //                                     ),
    //                                     topLayerChild: Icon(
    //                                       TablerIcons.north_star,
    //                                       size: 18,
    //                                       // color: defaultPalette.tertiary
    //                                       // color: Colors.blue,
    //                                     ),
    //                                     baseDecoration: BoxDecoration(
    //                                       color: defaultPalette.extras[0],
    //                                       border: Border.all(),
    //                                     ),
    //                                   ),
    //                                   SizedBox(height:2),
    //                                   ElevatedLayerButton( 
    //                                     subfac: 2,
    //                                     depth:2,
    //                                     onClick: () { 
                                          
    //                                     },
    //                                     buttonHeight: 25,
    //                                     buttonWidth: 25,
    //                                     borderRadius:
    //                                         BorderRadius.circular(50),
    //                                     animationDuration:
    //                                         const Duration(milliseconds: 30),
    //                                     animationCurve: Curves.ease,
    //                                     topDecoration: BoxDecoration(
    //                                       color: Colors.white,
    //                                       border: Border.all(),
    //                                     ),
    //                                     topLayerChild: Icon(
    //                                       TablerIcons.tank,
    //                                       size: 18,
    //                                       // color: defaultPalette.tertiary
    //                                       // color: Colors.blue,
    //                                     ),
    //                                     baseDecoration: BoxDecoration(
    //                                       color: defaultPalette.extras[0],
    //                                       border: Border.all(),
    //                                     ),
    //                                   ),SizedBox(height:3),
    //                                   ElevatedLayerButton( 
    //                                     subfac: 2,
    //                                     depth:2,
    //                                     onClick: () { 
                                          
    //                                     },
    //                                     buttonHeight: 25,
    //                                     buttonWidth: 25,
    //                                     borderRadius:
    //                                         BorderRadius.circular(50),
    //                                     animationDuration:
    //                                         const Duration(milliseconds: 30),
    //                                     animationCurve: Curves.ease,
    //                                     topDecoration: BoxDecoration(
    //                                       color: Colors.white,
    //                                       border: Border.all(),
    //                                     ),
    //                                     topLayerChild: Icon(
    //                                       TablerIcons.baguette,
    //                                       size: 18,
    //                                       // color: defaultPalette.tertiary
    //                                       // color: Colors.blue,
    //                                     ),
    //                                     baseDecoration: BoxDecoration(
    //                                       color: defaultPalette.extras[0],
    //                                       border: Border.all(),
    //                                     ),
    //                                   ),
                                       
    //                                 ],
    //                               ), 
    //                               SizedBox(
    //                                 width:3
    //                               ),
    //                               //DECOR Title and the preview box and text information besides
    //                               Expanded(
    //                                 flex:2,
    //                                 child: Column(
    //                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                                   children: [
    //                                     //Matrix rain and TITILE saying "DECOR"
    //                                     ClipRRect(
    //                                       borderRadius: BorderRadius.circular(50),
    //                                       child: Stack(
    //                                         children: [
    //                                           SizedBox( 
    //                                             height:30,
    //                                             child: MatrixRainAnimation(
    //                                                backgroundColor:defaultPalette.extras[0], 
    //                                             ),
    //                                           ),
    //                                           Positioned(
    //                                             right:0,
    //                                             height: 30,
    //                                             child: Text(
    //                                               "Decor  ",
    //                                               style: GoogleFonts.lexend(
    //                                                 fontSize: 18,
    //                                                 color:defaultPalette.primary
    //                                               ),
    //                                               textAlign:
    //                                                   TextAlign.start, ),
    //                                           ), 
    //                                         ],
    //                                       ),
    //                                     ),
    //                                     SizedBox(height:6),
    //                                     //PreviewBox of Decoration AND Name of Decoration Editing Field. Title saying "SUPER". ID of Decoration display
    //                                     Row(
    //                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                                       crossAxisAlignment: CrossAxisAlignment.end,
    //                                       children:[
    //                                         Expanded(
    //                                           //Name of Decoration Editing Field. Title saying "SUPER". ID of Decoration display
    //                                           child: Column(
    //                                             crossAxisAlignment: CrossAxisAlignment.start, 
    //                                             children: [
    //                                               // Title saying "SUPER" 
    //                                               RichText(
    //                                               maxLines: 1,
    //                                               text: TextSpan(
    //                                                 style: GoogleFonts.rockSalt(
    //                                                 color: defaultPalette.extras[0], 
    //                                                 height: 1.5, fontSize: 16,
                                                    
                                            
    //                                               ),
    //                                                 children: [
    //                                                   TextSpan(
    //                                                     text:''+ (decorationIndex==-1?sheetListItem.listDecoration:sheetListItem.listDecoration.itemDecorationList[decorationIndex]).runtimeType.toString().replaceAll(RegExp(r'Decoration'), '').replaceAll(RegExp(r'Item'), 'Layer '+ decorationIndex.toString()) ,
                                                        
    //                                                   ), 
    //                                                 ]
    //                                               )
    //                                               ),
    //                                               //Name of Decoration Editing Field.
    //                                               SizedBox(
    //                                                   height: 20,
    //                                                   child: TextFormField(
    //                                                     focusNode: decorationNameFocusNode,
    //                                                     cursorColor: defaultPalette.extras[0],
    //                                                     controller: decorationNameController, 
    //                                                     decoration: InputDecoration( 
    //                                                       filled: true,
    //                                                       fillColor: defaultPalette.transparent,
    //                                                       contentPadding: EdgeInsets.all(0),
    //                                                       border: OutlineInputBorder(
    //                                                         borderRadius: BorderRadius.circular(
    //                                                             5),  
    //                                                       ),
    //                                                       enabledBorder: OutlineInputBorder(
    //                                                         borderSide: BorderSide(
    //                                                             width: 0, color: defaultPalette.transparent),
    //                                                         borderRadius:
    //                                                             BorderRadius.circular(5),  
    //                                                       ),
    //                                                       focusedBorder: OutlineInputBorder(
    //                                                         borderSide: BorderSide(
    //                                                           width: 3,
    //                                                           color: nameExists
    //                                                               ? layoutName.text == initialLayoutName
    //                                                                   ? defaultPalette.extras[1]
    //                                                                   : Colors.red
    //                                                               : defaultPalette.transparent,
    //                                                         ),
    //                                                         borderRadius:
    //                                                             BorderRadius.circular(5), 
    //                                                       ),
    //                                                     ),
    //                                                     onChanged: (value) {
    //                                                       setState(() {
    //                                                         if (decorationIndex ==-1) {
    //                                                           sheetListItem.listDecoration = sheetListItem.listDecoration.copyWith(name: value);
    //                                                         } else {
    //                                                           if (sheetListItem.listDecoration.itemDecorationList[decorationIndex] is ItemDecoration) {
    //                                                             sheetListItem.listDecoration.itemDecorationList[decorationIndex] = (sheetListItem.listDecoration.itemDecorationList[decorationIndex] as ItemDecoration).copyWith(name: value);
    //                                                           } else {
    //                                                             sheetListItem.listDecoration.itemDecorationList[decorationIndex] = (sheetListItem.listDecoration.itemDecorationList[decorationIndex] as SuperDecoration).copyWith(name: value);
                                                              
    //                                                           }
                                                                
           
    //                                                         }
    //                                                       });
    //                                                     },
    //                                                     style: GoogleFonts.lexend(
    //                                                         color: defaultPalette.black, fontSize: 15),
                                                        
    //                                                   ),
    //                                                 ),
    //                                               //ID of Decoration display
    //                                               SingleChildScrollView(
    //                                                   scrollDirection: Axis.horizontal,
    //                                                   child:RichText(
    //                                                     maxLines: 1,
    //                                                   overflow: TextOverflow.ellipsis,
                                                      
    //                                                 text: TextSpan(
    //                                                   style: GoogleFonts.lexend(
    //                                                   color: defaultPalette.extras[0], 
    //                                                   height: 1.5, fontSize: 6, 
    //                                                 ),
    //                                                   children: [
    //                                                     TextSpan(
    //                                                       text: 'id: '
    //                                                     ),
    //                                                     TextSpan(
    //                                                       text:decorationIndex==-1?sheetListItem.listDecoration.id:sheetListItem.listDecoration.itemDecorationList[decorationIndex].id,style: GoogleFonts.lexend(
    //                                                     color: defaultPalette.extras[0], fontSize: 6 ,fontWeight: FontWeight.normal
    //                                                       ),
    //                                                     ),
                                                         
    //                                                   ]
    //                                                 )),  
    //                                                 ),
    //                                               // SizedBox(height:5),  
                                                    
    //                                             ],
    //                                           ),
    //                                         ),
    //                                         SizedBox(
    //                                         width:5,
    //                                         ),
    //                                         //PreviewBox of Selected Decoration
    //                                         Container(
    //                                           height:76,
    //                                           width:58,  
    //                                           padding: EdgeInsets.only(right:3),
    //                                           child: 
    //                                           buildDecoratedContainer(
    //                                             decorationIndex==-1? sheetListItem.listDecoration :SuperDecoration(id: 'yo',
    //                                             itemDecorationList: [...sheetListItem.listDecoration.itemDecorationList.sublist(0,(decorationIndex+1).clamp(0, sheetListItem.listDecoration.itemDecorationList.length))]
    //                                             ), 
    //                                             SizedBox(width:30,height:30), 
    //                                             true),
                                                                            
                                              
    //                                            )
    //                                       ]
    //                                     ),
    //                                   ],
    //                                 ),
                                        
    //                               ),
    //                               SizedBox(
    //                                 width:2
    //                               ),
                          
    //                             ],
    //                           ), 
    //                         ],
    //                       )
    //                       ),
    //                   ),
    //                 ),
          
    //                 //TreeView of Properties per layer
    //                 AnimatedPositioned(
    //                   duration:Durations.medium4,
    //                   curve: Curves.easeInBack,
    //                   left:showDecorationLayers?48:12,
    //                   top: 138,
    //                   right: 16, 
    //                   bottom: 18,
    //                   child: Builder(
    //                     builder: (context) {
    //                       var style =GoogleFonts.lexend(
    //                                     fontSize:13,
    //                                     color: defaultPalette.extras[0]
    //                                   );
    //                       var childStyle = style.copyWith(fontSize: 11);
    //                       var iconColor = defaultPalette.extras[0];
    //                       double childPinSize = 18;
    //                       return ClipRRect(
    //                         borderRadius: BorderRadius.circular(9).copyWith(bottomLeft: Radius.circular(showDecorationLayers?10:25), bottomRight:Radius.circular(20)  ),
                              
    //                         child: ScrollConfiguration(
    //                           behavior: ScrollBehavior()
    //                               .copyWith(scrollbars: false),
    //                           child: DynMouseScroll(
    //                               durationMS: 500,
    //                               scrollSpeed: 1,
    //                               builder: (context, controller, physics) {
    //                                 // print('inside dynscroll of treeview: '+(sheetListItem.listDecoration.itemDecorationList[decorationIndex] as ItemDecoration).pinned['padding']['isPinned'].toString());
    //                               return SingleChildScrollView(
    //                                 controller: controller,
    //                                 physics: physics,
    //                                 child: Column(
    //                                   children: [
    //                                     Container(  
    //                                       decoration:BoxDecoration(color:defaultPalette.transparent, borderRadius: BorderRadius.circular(6)),
    //                                       child:
    //                                          decorationIndex !=-1 ? sheetListItem.listDecoration.itemDecorationList[decorationIndex] is ItemDecoration ?
    //                                         TreeView<String>( 
    //                                         showSelectAll: true,
    //                                         showExpandCollapseButton: true,
                                        
    //                                         width:showDecorationLayers?width-30: width,
    //                                         onSelectionChanged: (p0) {
    //                                           // print(p0);
    //                                           setState(() {
    //                                             sheetListItem.listDecoration.itemDecorationList[decorationIndex] = (sheetListItem.listDecoration.itemDecorationList[decorationIndex] as ItemDecoration)
    //                                             .copyWith(
    //                                               pinned: {
    //                                                 'padding': {
    //                                                   'isPinned': p0[1],
    //                                                   'top': p0[2],
    //                                                   'bottom': p0[3],
    //                                                   'left': p0[4],
    //                                                   'right': p0[5],
    //                                                 },
    //                                                 'margin': {
    //                                                   'isPinned': p0[6],
    //                                                   'top': p0[7],
    //                                                   'bottom': p0[8],
    //                                                   'left': p0[9],
    //                                                   'right': p0[10],
    //                                                 },
    //                                                 'decoration': {
    //                                                   'isPinned': p0[11],
    //                                                   'color': p0[12],
    //                                                   'border': p0[13],
    //                                                   'borderRadius': p0[14],
    //                                                   'boxShadow': p0[15],
    //                                                   'image': {
    //                                                     'isPinned': p0[16],
    //                                                     'bytes': p0[17],
    //                                                     'fit': p0[18],
    //                                                     'repeat': p0[19],
    //                                                     'alignment': p0[20],
    //                                                     'scale': p0[21],
    //                                                     'opacity': p0[22],
    //                                                     'filterQuality': p0[23],
    //                                                     'invertColors': p0[24],
    //                                                   }, 
    //                                                   'backgroundBlendMode': p0[25],
    //                                                 },
    //                                                 'foregroundDecoration': {
    //                                                   'isPinned': p0[26],
    //                                                   'color': p0[27],
    //                                                   'border': p0[28],
    //                                                   'borderRadius': p0[29],
    //                                                   'boxShadow': p0[30],
    //                                                   'image': {
    //                                                     'isPinned': p0[31],
    //                                                     'bytes': p0[32],
    //                                                     'fit': p0[33],
    //                                                     'repeat': p0[34],
    //                                                     'alignment': p0[35],
    //                                                     'scale': p0[36],
    //                                                     'opacity': p0[37],
    //                                                     'filterQuality': p0[38],
    //                                                     'invertColors': p0[39],
    //                                                   }, 
    //                                                   'backgroundBlendMode': p0[40],
    //                                                 }, 
    //                                                 'transform': {
    //                                                   'isPinned': p0[41],
    //                                                 },
    //                                               }
                                        
    //                                               );
    //                                             // sheetListItem.listDecoration.toSuperDecorationBox().save();
    //                                           });  
    //                                         },
    //                                         onExpansionChanged: (e0) {
    //                                           setState(() {
    //                                             expansionLevels = [
    //                                               e0[1], e0[6], e0[11],e0[16], e0[26],e0[31]
    //                                             ];
    //                                           });
    //                                         },
    //                                         nodes:[
    //                                         TreeNode( 
    //                                           indentSize: 2,
    //                                           selectable: false,
    //                                           alternateChildren: true,
    //                                           isExpanded: true,                
    //                                           children:[
    //                                             //padding
    //                                             TreeNode(
    //                                               isExpanded: expansionLevels[0],
    //                                               label: Text('padding' , style: style),
    //                                               isSelected: (sheetListItem.listDecoration.itemDecorationList[decorationIndex] as ItemDecoration).pinned['padding']['isPinned'],
    //                                               icon: Icon(TablerIcons.box_padding, size:16,color:iconColor),
    //                                               indentSize: 8,
    //                                               alternateChildren: false,
    //                                               checkboxSize: 20,
                                        
    //                                               children: [
    //                                                 TreeNode<String>(label: Text('top', style: childStyle),
    //                                                   icon: Transform.rotate(angle: pi,child: Icon(TablerIcons.layout_bottombar_inactive, size:15)),
    //                                                   checkboxSize: childPinSize,
    //                                                   isSelected: (sheetListItem.listDecoration.itemDecorationList[decorationIndex] as ItemDecoration).pinned['padding']['top'],
                                                  
    //                                               ),
    //                                                 TreeNode<String>(label: Text('bottom', style: childStyle),
    //                                                   icon: Icon(TablerIcons.layout_bottombar_inactive, size:15),
    //                                                   checkboxSize: childPinSize,isSelected: (sheetListItem.listDecoration.itemDecorationList[decorationIndex] as ItemDecoration).pinned['padding']['bottom'],
    //                                               ),
    //                                                 TreeNode<String>(label: Text('left', style:childStyle),
    //                                                   icon: Icon(TablerIcons.layout_sidebar_inactive, size:15),
    //                                                   checkboxSize: childPinSize, isSelected: (sheetListItem.listDecoration.itemDecorationList[decorationIndex] as ItemDecoration).pinned['padding']['left'],
    //                                               ),
    //                                                 TreeNode<String>(label: Text('right', style:childStyle),
    //                                                   icon: Icon(TablerIcons.layout_sidebar_right_inactive, size:15),
    //                                                   checkboxSize: childPinSize,isSelected: (sheetListItem.listDecoration.itemDecorationList[decorationIndex] as ItemDecoration).pinned['padding']['right'],
    //                                               )
                                                              
    //                                                 ]
    //                                               ),
    //                                             //margin
    //                                             TreeNode(
    //                                               label: Text('margin' , style: style),
    //                                               isExpanded: expansionLevels[1],
    //                                               icon: Icon(TablerIcons.box_margin, size:16,color: iconColor),
    //                                               indentSize: 8,
    //                                               alternateChildren: false,
    //                                               checkboxSize: 20,
    //                                               isSelected: (sheetListItem.listDecoration.itemDecorationList[decorationIndex] as ItemDecoration).pinned['margin']['isPinned'],
    //                                               children: [
    //                                                 TreeNode<String>(label: Text('top', style:childStyle),
    //                                                   icon: Icon(TablerIcons.box_align_bottom, size:15),
    //                                                   checkboxSize: childPinSize, isSelected: (sheetListItem.listDecoration.itemDecorationList[decorationIndex] as ItemDecoration).pinned['margin']['top'],
    //                                               ),
    //                                                 TreeNode<String>(label: Text('bottom', style:childStyle),
    //                                                   icon: Icon(TablerIcons.box_align_top, size:15),
    //                                                   checkboxSize: childPinSize,isSelected: (sheetListItem.listDecoration.itemDecorationList[decorationIndex] as ItemDecoration).pinned['margin']['bottom'],),
    //                                                 TreeNode<String>(label: Text('left', style:childStyle),
    //                                                   icon: Icon(TablerIcons.box_align_right, size:15),
    //                                                   checkboxSize: childPinSize,isSelected: (sheetListItem.listDecoration.itemDecorationList[decorationIndex] as ItemDecoration).pinned['margin']['left'],),
    //                                                 TreeNode<String>(label: Text('right', style:childStyle),
    //                                                   icon: Icon(TablerIcons.box_align_left, size:15),
    //                                                   checkboxSize: childPinSize,isSelected: (sheetListItem.listDecoration.itemDecorationList[decorationIndex] as ItemDecoration).pinned['margin']['right'],)
                                                              
    //                                               ] 
    //                                             ),
    //                                             //decoration
    //                                             for(int i =0; i<2; i++)
    //                                             TreeNode(
    //                                               isExpanded: expansionLevels[i==0?2:4],
    //                                               label: Text(i==0?'decor':'foreground' , style: style),
    //                                               icon: Icon(TablerIcons.palette, size:16,color: iconColor),
    //                                               indentSize: 8,
    //                                               alternateChildren: false,
    //                                               checkboxSize: 20,
    //                                               isSelected: (sheetListItem.listDecoration.itemDecorationList[decorationIndex] as ItemDecoration).pinned[i==0?'decoration':'foregroundDecoration']['isPinned'],
    //                                               children: [
    //                                                 TreeNode<String>(label: Text('color', style:childStyle),
    //                                                   icon: Icon(TablerIcons.color_swatch, size:15),
    //                                                   checkboxSize: childPinSize,isSelected: (sheetListItem.listDecoration.itemDecorationList[decorationIndex] as ItemDecoration).pinned[i==0?'decoration':'foregroundDecoration']['color'],
    //                                               ),
    //                                                 TreeNode<String>(label: Text('border', style:childStyle),
    //                                                   icon: Icon(TablerIcons.border_sides, size:15),
    //                                                   checkboxSize: childPinSize,isSelected: (sheetListItem.listDecoration.itemDecorationList[decorationIndex] as ItemDecoration).pinned[i==0?'decoration':'foregroundDecoration']['border'],),
    //                                                 TreeNode<String>(label: Text('cornerRadius', style:childStyle),
    //                                                   icon: Icon(TablerIcons.border_corners, size:15),
    //                                                   checkboxSize: childPinSize,isSelected: (sheetListItem.listDecoration.itemDecorationList[decorationIndex] as ItemDecoration).pinned[i==0?'decoration':'foregroundDecoration']['borderRadius'],),
    //                                                 TreeNode<String>(label: Text('boxShadow', style:childStyle),
    //                                                   icon: Icon(TablerIcons.shadow, size:15),
    //                                                   checkboxSize: childPinSize,isSelected: (sheetListItem.listDecoration.itemDecorationList[decorationIndex] as ItemDecoration).pinned[i==0?'decoration':'foregroundDecoration']['boxShadow'],),
    //                                                 TreeNode<String>(label: Text('image', style:childStyle),
    //                                                   isExpanded: expansionLevels[i==0?3:5],
    //                                                   icon: Icon(TablerIcons.photo, size:15),
    //                                                   checkboxSize: childPinSize,
    //                                                   alternateChildren: false,
    //                                                   indentSize: 5,
    //                                                   isSelected: (sheetListItem.listDecoration.itemDecorationList[decorationIndex] as ItemDecoration).pinned[i==0?'decoration':'foregroundDecoration']['image']['isPinned'],
    //                                                   children: [
    //                                                     TreeNode<String>(label: Text('file', style:childStyle),
    //                                                   icon: Icon(TablerIcons.file_type_jpg, size:15),
    //                                                   checkboxSize: childPinSize, isSelected: (sheetListItem.listDecoration.itemDecorationList[decorationIndex] as ItemDecoration).pinned[i==0?'decoration':'foregroundDecoration']['image']['bytes'],),
    //                                                   TreeNode<String>(label: Text('fit', style:childStyle),
    //                                                   icon: Icon(TablerIcons.artboard, size:15),
    //                                                   checkboxSize: childPinSize,isSelected: (sheetListItem.listDecoration.itemDecorationList[decorationIndex] as ItemDecoration).pinned[i==0?'decoration':'foregroundDecoration']['image']['fit'],
    //                                                   ),
    //                                                   TreeNode<String>(label: Text('repeat', style:childStyle),
    //                                                   icon: Icon(TablerIcons.layout_grid, size:15),
    //                                                   checkboxSize: childPinSize,isSelected: (sheetListItem.listDecoration.itemDecorationList[decorationIndex] as ItemDecoration).pinned[i==0?'decoration':'foregroundDecoration']['image']['repeat'],
    //                                                   ),
    //                                                   TreeNode<String>(label: Text('align', style:childStyle),
    //                                                   icon: Icon(TablerIcons.align_box_left_stretch, size:15),
    //                                                   checkboxSize: childPinSize,isSelected: (sheetListItem.listDecoration.itemDecorationList[decorationIndex] as ItemDecoration).pinned[i==0?'decoration':'foregroundDecoration']['image']['alignment'],
    //                                                   ),
    //                                                   TreeNode<String>(label: Text('scale', style:childStyle),
    //                                                   icon: Icon(TablerIcons.scale, size:15),
    //                                                   checkboxSize: childPinSize,isSelected: (sheetListItem.listDecoration.itemDecorationList[decorationIndex] as ItemDecoration).pinned[i==0?'decoration':'foregroundDecoration']['image']['scale'],
    //                                                   ),
    //                                                   TreeNode<String>(label: Text('opacity', style:childStyle),
    //                                                   icon: Icon(TablerIcons.square_toggle, size:15),
    //                                                   checkboxSize: childPinSize,isSelected: (sheetListItem.listDecoration.itemDecorationList[decorationIndex] as ItemDecoration).pinned[i==0?'decoration':'foregroundDecoration']['image']['opacity'],
    //                                                   ),
    //                                                   TreeNode<String>(label: Text('quality', style:childStyle),
    //                                                   icon: Icon(TablerIcons.michelin_star, size:15),
    //                                                   checkboxSize: childPinSize,isSelected: (sheetListItem.listDecoration.itemDecorationList[decorationIndex] as ItemDecoration).pinned[i==0?'decoration':'foregroundDecoration']['image']['filterQuality'],
    //                                                   ),
    //                                                   TreeNode<String>(label: Text('invert', style:childStyle),
    //                                                   icon: Icon(TablerIcons.brightness_2, size:15),
    //                                                   checkboxSize: childPinSize,isSelected: (sheetListItem.listDecoration.itemDecorationList[decorationIndex] as ItemDecoration).pinned[i==0?'decoration':'foregroundDecoration']['image']['invertColors'],
    //                                                   ),
                                        
    //                                                   ]
                                                      
    //                                                   ),
    //                                                 TreeNode<String>(label: Text('blendMode', style:childStyle),
    //                                                   icon: Icon(TablerIcons.blend_mode, size:15),
    //                                                   checkboxSize: childPinSize,isSelected: (sheetListItem.listDecoration.itemDecorationList[decorationIndex] as ItemDecoration).pinned[i==0?'decoration':'foregroundDecoration']['backgroundBlendMode'],),
                                                              
    //                                               ]
    //                                             ),
                                                
    //                                             //transform
    //                                             TreeNode( 
    //                                               label: Text('transform' , style: style),
    //                                               icon: Icon(TablerIcons.transform_point, size:16,color: iconColor),
    //                                               indentSize: 17,
    //                                               alternateChildren: false, 
    //                                               checkboxSize: 20,isSelected: (sheetListItem.listDecoration.itemDecorationList[decorationIndex] as ItemDecoration).pinned['transform']['isPinned'],
                                                              
    //                                             ),
                                                              
    //                                         ]
                                         
    //                                         )
                                            
    //                                         ]):null:null,
    //                                     ),
    //                                     if(decorationIndex !=-1)
    //                                     if(sheetListItem.listDecoration.itemDecorationList[decorationIndex] is ItemDecoration)
    //                                     ...buildDecorationEditor((sheetListItem.listDecoration.itemDecorationList[decorationIndex] as ItemDecoration))
                            
                            
    //                                   ],
    //                                 ),
    //                               );
    //                             }
    //                           ),
    //                         ),
    //                       );
    //                     }
    //                   ),
    //                 ),
                  
          
    //                 //BLACK STRIP ANIMATED OF DECORATION LAYERs BACKGRGOUND
    //                 AnimatedPositioned(
    //                   duration: Durations.medium1,
    //                   curve: Curves.easeOut,
    //                   bottom:32,
    //                   left:showDecorationLayers?12.5:12,
    //                   child:AnimatedContainer(
    //                     duration:Durations.medium4,
    //                     curve: Curves.easeInOut,
    //                     height:showDecorationLayers?(sHeight*0.9)-240:0,
    //                     width:25,
    //                     padding: EdgeInsets.only(left:5),
    //                     alignment: Alignment.bottomCenter,
    //                     decoration: BoxDecoration(
    //                       color: defaultPalette.extras[0],
    //                       borderRadius: BorderRadius.circular(showDecorationLayers?50:0).copyWith(bottomLeft: Radius.circular(0)),
    //                     ),
    //                     child: Text('Decor \n\nLayers \n \n     ', style: GoogleFonts.bungee(
    //                       color: defaultPalette.primary.withAlpha(100),
    //                       fontSize:10
    //                       ) ),
    //                   ), 
    //                 ),
    //                 //LAYERS OF DECORATION AS TILES REORDERABLE 
    //                 AnimatedPositioned(
    //                   duration: Durations.medium3,
    //                   curve: Curves.easeInBack,
    //                   bottom:30,
    //                   left:showDecorationLayers?6.5:-50,
    //                   child:ClipRRect(
    //                     borderRadius: BorderRadius.circular(0).copyWith(topRight: Radius.circular(5), bottomRight: Radius.circular(5)),
                          
    //                     child: AnimatedContainer(
    //                       duration:Durations.medium1,
    //                       curve: Curves.easeInOut,
    //                       height: (sHeight*0.9)-250,
    //                       width:38,
    //                       padding: EdgeInsets.only(bottom:10),
    //                       decoration: BoxDecoration(
    //                         // color: defaultPalette.secondary,
    //                         borderRadius: BorderRadius.circular(50).copyWith(bottomLeft: Radius.circular(0), bottomRight: Radius.circular(0)),
    //                       ),
    //                       child: ScrollConfiguration(
    //                             behavior: ScrollBehavior()
    //                                 .copyWith(scrollbars: false),
    //                             child: DynMouseScroll(
    //                                 durationMS: 500,
    //                                 scrollSpeed: 1,
    //                                 builder: (context, controller, physics) {
    //                             return ScrollbarUltima.semicircle (
    //                               alwaysShowThumb: true, 
    //                               controller: controller,
    //                               scrollbarPosition: ScrollbarPosition.left, 
    //                               backgroundColor: defaultPalette.extras[0],
    //                               scrollbarLength: (sHeight*0.9)-270, 
    //                               isDraggable: true, 
    //                               thumbCrossAxisSize: 5,
    //                               // thumbMainAxisSize: 80,
          
    //                               elevation: 0,
    //                               arrowsColor: defaultPalette.primary, 
    //                               child: Padding(
    //                                 padding: const EdgeInsets.only(left:8.0),
    //                                 child: ReorderableListView(
    //                                 onReorder: (oldIndex, newIndex) {
    //                                   setState(() {
    //                                     final itemList = sheetListItem.listDecoration.itemDecorationList;
          
    //                                     final int reversedOldIndex = itemList.length - 1 - oldIndex;
    //                                     int reversedNewIndex = itemList.length - 1 - newIndex;
          
    //                                     // Fix: clamp new index to minimum 0
    //                                     if (reversedOldIndex < reversedNewIndex) {
    //                                       reversedNewIndex = reversedNewIndex.clamp(0, itemList.length);
    //                                     } else {
    //                                       reversedNewIndex = reversedNewIndex.clamp(0, itemList.length);
    //                                     }
          
    //                                     final item = itemList.removeAt(reversedOldIndex);
    //                                     itemList.insert(reversedNewIndex, item);
    //                                   });
    //                                 },
    //                                 proxyDecorator: (child, index, animation) {
    //                                   return child;
    //                                 },
    //                                 buildDefaultDragHandles: false,
    //                                 physics: physics,
    //                                 scrollController: controller,
    //                                 children: [
    //                                   for (final entry in sheetListItem.listDecoration.itemDecorationList.asMap().entries.toList().reversed)
    //                                     ReorderableDragStartListener(
    //                                       index: sheetListItem.listDecoration.itemDecorationList.length - 1 - entry.key,
    //                                       key: ValueKey(entry.value),
    //                                       child: Stack(
    //                                         children: [
    //                                           //tiny layer body of decoration
    //                                           AnimatedContainer(
    //                                             duration: Duration(
    //                                              milliseconds: (500 + 
    //                                              (300/(
    //                                               (sheetListItem.listDecoration.itemDecorationList.length==1
    //                                               ? 2
    //                                               : sheetListItem.listDecoration.itemDecorationList.length) - 1)) 
    //                                               * entry.key).round()  
    //                                             ),
    //                                             curve: Curves.easeIn,
    //                                             height:(((sHeight*0.9)-250)/(decorationIndex == entry.key?8:10.3)).clamp(0, decorationIndex == entry.key?70:50),
    //                                             alignment: Alignment.topCenter, // Set pivot to bottom-left
    //                                               transform: Matrix4.identity()
    //                                                 ..translate(showDecorationLayers?0.0:(-((sHeight*0.9)-250)/10).clamp(double.negativeInfinity, 50))
    //                                                 ..rotateZ(showDecorationLayers?0: -math.pi / 2),
    //                                             margin: EdgeInsets.only(bottom: 5, right:showDecorationLayers? 0: (10*entry.key)+1),
    //                                             padding: EdgeInsets.only(top: 4, left:15),
    //                                             decoration: BoxDecoration(
    //                                               color: entry.value is ItemDecoration? decorationIndex == entry.key? defaultPalette.extras[0]: defaultPalette.tertiary:defaultPalette.extras[1] ,
    //                                               borderRadius: BorderRadius.circular(showDecorationLayers? 5:500).copyWith(
    //                                                 // bottomRight: Radius.circular(0),
    //                                                 // bottomLeft: Radius.circular(0),
    //                                                 // topRight: Radius.circular(30),
    //                                               ), 
                                                   
    //                                             ),
    //                                              ),
                                              
                                              
    //                                           //Border for when tapped 
    //                                           AnimatedOpacity(duration: Duration(
    //                                                milliseconds: (500 + 
    //                                              (300/(
    //                                               (sheetListItem.listDecoration.itemDecorationList.length==1
    //                                               ? 2
    //                                               : sheetListItem.listDecoration.itemDecorationList.length) - 1)) 
    //                                               * entry.key).round()  
    //                                               ), opacity: decorationIndex == entry.key?1:0,
    //                                             child: AnimatedContainer(
    //                                               duration: Duration(
    //                                                milliseconds: 600
    //                                               ),
    //                                               curve: Curves.easeIn,
    //                                               height:(((sHeight*0.9)-250)/(decorationIndex == entry.key?8:10.3)).clamp(0,decorationIndex == entry.key?70: 50),
    //                                               alignment: Alignment.topLeft, // Set pivot to bottom-left
    //                                                 transform: Matrix4.identity()
    //                                                   ..translate(showDecorationLayers?0.0:(-((sHeight*0.9)-250)/10).clamp(double.negativeInfinity, 50))
    //                                                   ..rotateZ(showDecorationLayers?0: -math.pi / 2),
    //                                               margin: EdgeInsets.only(bottom: 5, right:showDecorationLayers? 0: (10*entry.key)+1),
    //                                               padding: EdgeInsets.all( 1),
    //                                               decoration: BoxDecoration(
    //                                                 // color: entry.value is ItemDecoration? defaultPalette.tertiary:defaultPalette.extras[1] ,
    //                                                 borderRadius: BorderRadius.circular(showDecorationLayers? 5:500), 
    //                                                 border: Border( 
    //                                                   right: BorderSide(color: defaultPalette.tertiary,
    //                                                   width: 2),
    //                                                    left: BorderSide(color: defaultPalette.tertiary,
    //                                                   width: 2),
    //                                                    top: BorderSide(color: defaultPalette.tertiary,
    //                                                   width: 2),
    //                                                    bottom: BorderSide(color: defaultPalette.tertiary,
    //                                                   width: 20),
                                                      
    //                                                 )
    //                                               ),
    //                                               child:  buildDecoratedContainer(SuperDecoration(id: 'id', itemDecorationList: [sheetListItem.listDecoration.itemDecorationList[entry.key]]), SizedBox(height: 10,width: 10,),true) ,
                                             
    //                                             ),
    //                                           ),
                                              
    //                                           //onTap onHover Functions
    //                                           Padding(
    //                                             padding: const EdgeInsets.all(2.0),
    //                                             child: ClipRRect(
    //                                               borderRadius: BorderRadius.circular(showDecorationLayers? 5:500),
    //                                               child: Material(
    //                                                 color: defaultPalette.transparent,
    //                                                 child: InkWell(
    //                                                   hoverColor:decorationIndex == entry.key?defaultPalette.transparent: defaultPalette.primary ,
    //                                                   highlightColor:decorationIndex == entry.key?defaultPalette.transparent: defaultPalette.primary,
    //                                                   splashColor:decorationIndex == entry.key?defaultPalette.transparent: defaultPalette.extras[0],
    //                                                   onTap: () {
    //                                                     setState(() {
    //                                                       if (decorationIndex != entry.key) {
    //                                                         decorationIndex = entry.key;
    //                                                         // decorTreeViewKey.currentState?.setState(() {
    //                                                         decorationNameController.text = sheetListItem.listDecoration.itemDecorationList[decorationIndex].name;
    //                                                         // });
                                                           
    //                                                       }
                                                  
    //                                                     });
    //                                                   },
    //                                                   child:SizedBox(
    //                                                     width: 40,
    //                                                     height:(((sHeight*0.9)-250)/10.3).clamp(0, 50)-4,
    //                                                   )
    //                                                 ),
    //                                               ),
    //                                             ),
    //                                           ),
                                              
                                              
    //                                           //Numbering on the right of the tiny layer box
    //                                           AnimatedPositioned(
    //                                             duration: Duration(
    //                                              milliseconds: (500 + 
    //                                              (300/(
    //                                               (sheetListItem.listDecoration.itemDecorationList.length==1
    //                                               ? 2
    //                                               : sheetListItem.listDecoration.itemDecorationList.length) - 1)) 
    //                                               * entry.key).round()  
    //                                             ),
    //                                             bottom:showDecorationLayers?decorationIndex == entry.key?5:(((sHeight*0.9)-250)/10).clamp(0, 50)/2.5:0,
    //                                             right:decorationIndex == entry.key?8: 2,
    //                                             child: CountingAnimation(
    //                                               value: (entry.key).toString(),
    //                                               mainAlignment: MainAxisAlignment.end,
    //                                               singleScollDuration: Durations.short1,
    //                                               scrollCount: 2,
    //                                               textStyle: GoogleFonts.bungee(
    //                                                 fontSize:decorationIndex == entry.key?15:10,
    //                                                 color: decorationIndex == entry.key? defaultPalette.primary : defaultPalette.extras[0], 
    //                                               ),
    //                                             ),
    //                                           ),
    //                                         ],
    //                                       ),
    //                                     ),
    //                                     SizedBox(
    //                                       key: ValueKey('rty'),
    //                                       height:10)
    //                                 ],
    //                               ),
          
    //                               ),
    //                             );
    //                                                           }
    //                                                         ),
    //                       )
                        
    //                     ),
    //                   ), 
    //                 ),
    //                 //BUTTON SHOW LAYER OF DECORATION
    //                 Positioned(
    //                   bottom:17,
    //                   left:12,
    //                   child: //minimize button
    //                     ElevatedLayerButton(
    //                       // isTapped: false,
    //                       // toggleOnTap: true,
    //                       subfac: 3,
    //                       depth: 3,
    //                       onClick: () {
    //                         // Future.delayed(Duration.zero)
    //                         //     .then((y) {
    //                         //   appWindow.minimize();
    //                         // });
    //                         setState(() {
    //                           showDecorationLayers = !showDecorationLayers;
    //                         });
    //                       },
    //                       buttonHeight: 35,
    //                       buttonWidth: 35,
    //                       borderRadius:
    //                           BorderRadius.circular(30),
    //                       animationDuration:
    //                           const Duration(milliseconds: 10),
    //                       animationCurve: Curves.ease,
    //                       topDecoration: BoxDecoration(
    //                         color: Colors.white,
    //                         border: Border.all(),
    //                       ),
    //                       topLayerChild: Icon(
    //                         TablerIcons.stack_2,
    //                         size: 18,
    //                         // color: defaultPalette.tertiary
    //                         // color: Colors.blue,
    //                       ),
    //                       baseDecoration: BoxDecoration(
    //                         color: defaultPalette.extras[0],
    //                         border: Border.all(),
    //                       ),
    //                     ),
    //                 ),
                    
    //               ],
    //               // Positioned.fill(child: Center(child: Text(sheetListItem.id))),
    //               // Left and Right adjustments
    //             ],
    //           );
    //         },
    //       ),
    //     ),
        
    //     Transform.translate(
    //       offset:Offset(whichPropertyTabIsClicked==1?0: sWidth,0),
    //       child: AppinioSwiper(
    //                 backgroundCardCount: 1,
    //                 backgroundCardOffset: Offset(4, 4),
    //                 duration: Duration(milliseconds: 150),
    //                 backgroundCardScale: 1,
    //                 loop: true,
    //                 cardCount: spreadSheetList.length < 2 ? 2 : spreadSheetList.length,
    //                 allowUnSwipe: true,
    //                 allowUnlimitedUnSwipe: true,
    //                 initialIndex: currentPageIndex,
    //                 controller: propertyCardsController,
    //                 onCardPositionChanged: (position) {
    //                   setState(() {
    //                     _cardPosition = position.offset.dx.abs() + position.offset.dy.abs();
    //                   });
    //                 },
    //                 onSwipeEnd: (a, b, direction) {
    //                   // print(direction.toString());
    //                   setState(() {
    //                     ref.read(propertyCardIndexProvider.notifier).update((s) => s = b);
    //                     if (_cardPosition > 50) {
    //       currentPageIndex = (currentPageIndex + 1) % pageCount;
    //       _renderPagePreviewOnProperties();
    //                     }
    //                     // _currentCardIndex = b;
    //                     _cardPosition = 0;
    //                   });
    //                 },
    //                 onSwipeCancelled: (activity) {},
    //                 cardBuilder: (BuildContext context, int index) {
    //                   int currentCardIndex = ref.watch(propertyCardIndexProvider);
    //                   int ind = pageCount <= 1 ? 0 : index;
    //                   TextEditingController pgHexController = TextEditingController(
    //       text: '#${colorToHex(documentPropertiesList[ind].pageColor)}');
    //                   return Stack(
    //                     children: [
    //       Positioned.fill(
    //         child: AnimatedContainer(
    //           duration: Durations.short3,
    //           margin: EdgeInsets.all(10).copyWith(left: 5, right: 8),
    //           alignment: Alignment.center,
    //           decoration: BoxDecoration(
    //             color: Colors.white,
    //             border: Border.all(width: 2),
    //             borderRadius: BorderRadius.circular(25),
    //           ),
    //         ),
    //       ),
                    
    //       Positioned.fill(
    //         child: AnimatedOpacity(
    //           opacity: currentCardIndex == index
    //               ? 0
    //               : index >= (currentCardIndex + 2) % 10
    //                   ? 1
    //                   : (1 - (_cardPosition / 200).clamp(0.0, 1.0)),
    //           duration: Duration(milliseconds: 300),
    //           child: AnimatedContainer(
    //             duration: Duration(milliseconds: 300),
    //             margin: EdgeInsets.all(10).copyWith(left: 5, right: 8),
    //             alignment: Alignment.center,
    //             decoration: BoxDecoration(
    //               color: index == (currentCardIndex + 1) % 10
    //                   ? defaultPalette.extras[0]
    //                   : index == (currentCardIndex + 2) % 10
    //                       ? defaultPalette.extras[0]
    //                       : defaultPalette.extras[0],
    //               border: Border.all(width: 2),
    //               borderRadius: BorderRadius.circular(25),
    //             ),
    //           ),
    //         ),
    //       ),
                    
    //       // PROPERTIES Tab Parent
    //       Positioned(
    //         top: 0,
    //         height: (sHeight * 0.9) - 20,
    //         width: sWidth * wH2DividerPosition,
    //         child: Container(
    //           padding:
    //               EdgeInsets.only(top: 5, left: 0, right: 0, bottom: 70),
    //           decoration: BoxDecoration(
    //             borderRadius: BorderRadius.circular(25),
    //             color: defaultPalette.transparent,
    //           ),
    //           margin: EdgeInsets.all(15),
    //           child: ClipRRect(
    //             borderRadius: BorderRadius.circular(15),
    //             child: PieCanvas(
    //               child: ScrollConfiguration(
    //                 behavior: ScrollBehavior().copyWith(scrollbars: false),
    //                 child: SingleChildScrollView(
    //                   physics:
    //                       const CustomScrollPhysics(scrollFactor: 0.01),
    //                   child: Column(
    //                     crossAxisAlignment: CrossAxisAlignment.center,
    //                     children: [
    //                       //MINI PREVIEW AND PAGE NUMBER AND NEXTPREV PARENT PARENT
    //                       Row(
    //                         mainAxisAlignment:
    //                             MainAxisAlignment.spaceBetween,
    //                         children: [
    //                           //PAGE PROPERTIES FOR {{{MINI PAGE RENDER}}}
    //                           Container(
    //                             height: 120,
    //                             width: 95,
    //                             alignment: Alignment.center,
    //                             child: Stack(
    //                               children: [
    //                                 //{{{GRAPH}}}
    //                                 ClipRRect(
    //                                   borderRadius:
    //                                       BorderRadius.circular(25),
    //                                   child: Container(
    //                                     height: 120,
    //                                     // width: ((sWidth * wH2DividerPosition)/2)<150?100:((sWidth * wH2DividerPosition)/2),
    //                                     width: 95,
    //                                     decoration: BoxDecoration(
    //                                         borderRadius:
    //                                             BorderRadius.circular(25),
    //                                         border: Border.all(),
    //                                         color: defaultPalette.extras[0]
    //                                             .withOpacity(0.1)),
    //                                     child: Opacity(
    //                                       opacity: 1,
    //                                       child: LineChart(LineChartData(
    //                                           lineBarsData: [
    //                                             LineChartBarData()
    //                                           ],
    //                                           titlesData: const FlTitlesData(
    //                                               show: false),
    //                                           gridData: FlGridData(
    //                                               getDrawingVerticalLine: (value) => FlLine(
    //                                                   color: defaultPalette
    //                                                       .extras[0]
    //                                                       .withOpacity(0.3),
    //                                                   dashArray: [5, 5],
    //                                                   strokeWidth: 1),
    //                                               getDrawingHorizontalLine: (value) => FlLine(
    //                                                   color: defaultPalette
    //                                                       .extras[0]
    //                                                       .withOpacity(0.3),
    //                                                   dashArray: [5, 5],
    //                                                   strokeWidth: 1),
    //                                               show: true,
    //                                               horizontalInterval: 5,
    //                                               verticalInterval: 30),
    //                                           borderData:
    //                                               FlBorderData(show: false),
    //                                           minY: 0,
    //                                           maxY: 50,
    //                                           maxX: dateTimeNow.millisecondsSinceEpoch
    //                                                       .ceilToDouble() /
    //                                                   500 +
    //                                               250,
    //                                           minX: dateTimeNow.millisecondsSinceEpoch.ceilToDouble() / 500)),
    //                                     ),
    //                                   ),
    //                                 ),
    //                                 //{{{MINI PAGE}}}
    //                                 GestureDetector(
    //                                   onTap: () {
    //                                     _renderPagePreviewOnProperties();
    //                                   },
    //                                   child: Container(
    //                                     height: documentPropertiesList[
    //                                                     currentPageIndex]
    //                                                 .orientationController ==
    //                                             pw.PageOrientation.portrait
    //                                         ? 100
    //                                         : 60,
    //                                     width: documentPropertiesList[
    //                                                     currentPageIndex]
    //                                                 .orientationController ==
    //                                             pw.PageOrientation.portrait
    //                                         ? 80
    //                                         : 80,
    //                                     margin: const EdgeInsets.only(
    //                                         top: 10, left: 8),
    //                                     decoration: BoxDecoration(
    //                                       image: cachedImageData != null
    //                                           ? DecorationImage(
    //                                               image: MemoryImage(
    //                                                   cachedImageData!),
    //                                               fit: documentPropertiesList[
    //                                                               currentPageIndex]
    //                                                           .orientationController ==
    //                                                       pw.PageOrientation
    //                                                           .portrait
    //                                                   ? BoxFit.fitHeight
    //                                                   : BoxFit.fitWidth,
    //                                             )
    //                                           : null,
    //                                     ),
    //                                     child: cachedImageData == null
    //                                         ? Center(
    //                                             child:
    //                                                 CircularProgressIndicator(),
    //                                           )
    //                                         : null,
    //                                   ),
    //                                 ),
    //                               ],
    //                             ),
    //                           ),
    //                           //PAGE NUMBER AND DELETE AND NEXT-PREV
    //                           Column(
    //                             crossAxisAlignment:
    //                                 CrossAxisAlignment.center,
    //                             // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //                             children: [
    //                               if (((sWidth * wH2DividerPosition) -
    //                                       145) >
    //                                   66)
    //                                 Container(
    //                                     height: 90,
    //                                     width:
    //                                         (sWidth * wH2DividerPosition) -
    //                                             150,
    //                                     alignment: Alignment.center,
    //                                     child: CountingAnimation(
    //                                         value: (currentPageIndex + 1)
    //                                             .toString(),
    //                                         scrollCount: 3,
    //                                         textStyle:
    //                                             GoogleFonts.pressStart2p(
    //                                                 color: defaultPalette
    //                                                     .extras[0],
    //                                                 fontSize: 50))),
    //                               Container(
    //                                 width:
    //                                     (sWidth * wH2DividerPosition) - 145,
    //                                 height: (sWidth * wH2DividerPosition) -
    //                                             145 >
    //                                         66
    //                                     ? 20
    //                                     : 120,
    //                                 child: Flex(
    //                                   direction:
    //                                       (sWidth * wH2DividerPosition) -
    //                                                   145 >
    //                                               66
    //                                           ? Axis.horizontal
    //                                           : Axis.vertical,
    //                                   mainAxisAlignment:
    //                                       MainAxisAlignment.spaceAround,
    //                                   crossAxisAlignment:
    //                                       (sWidth * wH2DividerPosition) -
    //                                                   145 >
    //                                               66
    //                                           ? CrossAxisAlignment.start
    //                                           : CrossAxisAlignment.center,
    //                                   children: [
    //                                     if ((sWidth * wH2DividerPosition) -
    //                                             145 <
    //                                         66)
    //                                       CountingAnimation(
    //                                           value: documentPropertiesList[
    //                                                   currentPageIndex]
    //                                               .pageNumberController
    //                                               .text,
    //                                           scrollCount: 3,
    //                                           textStyle:
    //                                               GoogleFonts.pressStart2p(
    //                                                   color: defaultPalette
    //                                                       .extras[0],
    //                                                   fontSize: 20)),
    //                                     //{{PREVIOUS PAGE BUTTON}}
    //                                     GestureDetector(
    //                                       onTap: () {
    //                                         setState(() {
    //                                           if (currentPageIndex == 0) {
    //                                             // pdfScrollController.animateTo(
    //                                             //     currentPageIndex *
    //                                             //         ((1.41428571429 *
    //                                             //                 ((sWidth *
    //                                             //                     (1 -
    //                                             //                         vDividerPosition)))) +
    //                                             //             16),
    //                                             //     duration:
    //                                             //         const Duration(
    //                                             //             milliseconds:
    //                                             //                 100),
    //                                             //     curve: Curves.easeIn);
    //                                             _renderPagePreviewOnProperties();
    //                                             return;
    //                                           }
    //                                           currentPageIndex--;
    //                                           propertyCardsController
    //                                               .setCardIndex(
    //                                                   currentPageIndex);
                    
    //                                           propertyCardsController
    //                                               .animateTo(Offset(1, 1),
    //                                                   duration:
    //                                                       Durations.short1,
    //                                                   curve: Curves.linear);
                    
    //                                           // pdfScrollController.animateTo(
    //                                           //     currentPageIndex *
    //                                           //         ((1.41428571429 *
    //                                           //                 ((sWidth *
    //                                           //                     (1 -
    //                                           //                         vDividerPosition)))) +
    //                                           //             16),
    //                                           //     duration: const Duration(
    //                                           //         milliseconds: 100),
    //                                           //     curve: Curves.easeIn);
    //                                           _renderPagePreviewOnProperties();
    //                                         });
    //                                       },
    //                                       child: Icon(
    //                                         TablerIcons
    //                                             .arrow_badge_left_filled,
    //                                         color: defaultPalette.extras[0],
    //                                         size: 23,
    //                                       ),
    //                                     ),
    //                                     //{{DELETE PAGE BUTTON}}
    //                                     GestureDetector(
    //                                       onTap: () {
    //                                         _confirmDeleteLayout(
    //                                             deletePage: true);
    //                                         // pdfScrollController.animateTo(
    //                                         //     currentPageIndex *
    //                                         //         ((1.41428571429 *
    //                                         //                 ((sWidth *
    //                                         //                     (1 -
    //                                         //                         vDividerPosition)))) +
    //                                         //             16),
    //                                         //     duration: const Duration(
    //                                         //         milliseconds: 100),
    //                                         //     curve: Curves.easeIn);
    //                                       },
    //                                       child: Icon(
    //                                         TablerIcons.trash,
    //                                         color: defaultPalette.black,
    //                                         size: 20,
    //                                       ),
    //                                     ),
    //                                     //{{NEXT PAGE BUTTON}}
    //                                     GestureDetector(
    //                                       onTap: () {
    //                                         setState(() {
    //                                           if (pageCount ==
    //                                               (currentPageIndex + 1)) {
    //                                             _addPdfPage();
    //                                             currentPageIndex++;
    //                                             propertyCardsController
    //                                                 .setCardIndex(
    //                                                     currentPageIndex);
    //                                             propertyCardsController
    //                                                 .animateTo(Offset(1, 1),
    //                                                     duration: Durations
    //                                                         .short1,
    //                                                     curve:
    //                                                         Curves.linear);
                    
    //                                             // pdfScrollController.animateTo(
    //                                             //     currentPageIndex *
    //                                             //         ((1.41428571429 *
    //                                             //                 ((sWidth *
    //                                             //                         (1 -
    //                                             //                             vDividerPosition)) -
    //                                             //                     6)) +
    //                                             //             6),
    //                                             //     duration:
    //                                             //         const Duration(
    //                                             //             milliseconds:
    //                                             //                 100),
    //                                             //     curve: Curves.easeIn);
    //                                             _renderPagePreviewOnProperties();
    //                                             return;
    //                                           }
    //                                           currentPageIndex++;
    //                                           propertyCardsController
    //                                               .setCardIndex(
    //                                                   currentPageIndex);
    //                                           propertyCardsController
    //                                               .animateTo(Offset(1, 1),
    //                                                   duration:
    //                                                       Durations.short1,
    //                                                   curve: Curves.linear);
                    
    //                                           // pdfScrollController.animateTo(
    //                                           //     currentPageIndex *
    //                                           //         ((1.41428571429 *
    //                                           //                 ((sWidth *
    //                                           //                         (1 -
    //                                           //                             vDividerPosition)) -
    //                                           //                     6)) +
    //                                           //             6),
    //                                           //     duration: const Duration(
    //                                           //         milliseconds: 100),
    //                                           //     curve: Curves.easeIn);
    //                                           _renderPagePreviewOnProperties();
    //                                         });
    //                                       },
    //                                       child: Icon(
    //                                         TablerIcons
    //                                             .arrow_badge_right_filled,
    //                                         color: defaultPalette.extras[0],
    //                                         size: 23,
    //                                       ),
    //                                     ),
    //                                   ],
    //                                 ),
    //                               ),
    //                             ],
    //                           )
    //                         ],
    //                       ),
    //                       //FORMATS TITLE
                    
    //                       Container(
    //                         width: sWidth * wH2DividerPosition - 45,
    //                         height: 15,
    //                         alignment: Alignment.topCenter,
    //                         margin: EdgeInsets.only(top: 10, right: 5),
    //                         decoration: BoxDecoration(
    //                             // color: defaultPalette.extras[0],
    //                             borderRadius: BorderRadius.circular(5),
    //                             border: Border.all(width: 0.1)),
    //                         child: Text(
    //                           'FORMATS',
    //                           style: GoogleFonts.bungee(fontSize: 10),
    //                         ),
    //                       ),
                    
    //                       //ORIENTATIONS BUTTONS
    //                       Padding(
    //                         padding: const EdgeInsets.only(right: 5.0),
    //                         child: Row(
    //                           mainAxisAlignment:
    //                               MainAxisAlignment.spaceEvenly,
    //                           children: [
    //                             //PORTRAIT BUTTON
    //                             GestureDetector(
    //                               onTap: () {
    //                                 setState(() {
    //                                   addToTheLeft = true;
                    
    //                                   documentPropertiesList[
    //                                               currentPageIndex]
    //                                           .orientationController =
    //                                       pw.PageOrientation.portrait;
    //                                 });
    //                                 _renderPagePreviewOnProperties();
    //                                 Future.delayed(Durations.short1)
    //                                     .then((onValue) {
    //                                   setState(() {
    //                                     addToTheLeft = false;
    //                                   });
    //                                   _renderPagePreviewOnProperties();
    //                                 });
    //                               },
    //                               onTapDown: (d) {
    //                                 setState(() {
    //                                   addToTheLeft = true;
    //                                 });
    //                               },
    //                               onTapUp: (d) {
    //                                 setState(() {
    //                                   addToTheLeft = false;
    //                                 });
    //                               },
    //                               child: Stack(
    //                                 children: [
    //                                   Container(
    //                                     width:
    //                                         (sWidth * wH2DividerPosition -
    //                                                 65) /
    //                                             2,
    //                                     height: 30,
    //                                     alignment: Alignment.topCenter,
    //                                     margin: EdgeInsets.only(top: 10),
    //                                     decoration: BoxDecoration(
    //                                         color: defaultPalette.extras[0],
    //                                         borderRadius:
    //                                             BorderRadius.circular(5),
    //                                         border: Border.all(
    //                                             width: 1,
    //                                             strokeAlign: BorderSide
    //                                                 .strokeAlignOutside)),
    //                                   ),
    //                                   AnimatedContainer(
    //                                     duration: addToTheLeft
    //                                         ? Duration.zero
    //                                         : Duration.zero,
    //                                     width: (sWidth *
    //                                                 wH2DividerPosition -
    //                                             (addToTheLeft ? 65 : 69)) /
    //                                         2,
    //                                     height: addToTheLeft ? 30 : 28,
    //                                     alignment: Alignment.topLeft,
    //                                     margin: EdgeInsets.only(
    //                                         top: addToTheLeft ? 10 : 12,
    //                                         left: addToTheLeft ? 0 : 2),
    //                                     padding: EdgeInsets.only(left: 0),
    //                                     decoration: BoxDecoration(
    //                                         color: defaultPalette.primary,
    //                                         borderRadius: BorderRadius.only(
    //                                             topRight: Radius.circular(
    //                                                 addToTheLeft ? 5 : 0),
    //                                             topLeft: Radius.circular(5),
    //                                             bottomRight:
    //                                                 Radius.circular(5),
    //                                             bottomLeft: Radius.circular(
    //                                                 addToTheLeft ? 5 : 0)),
    //                                         border: Border.all(width: 0.1)),
    //                                     child: Column(
    //                                       children: [
    //                                         Text(
    //                                           ' Port',
    //                                           style: GoogleFonts.bungee(
    //                                               fontSize: 12),
    //                                         ),
    //                                         Text(
    //                                           'rait ',
    //                                           style: GoogleFonts.bungee(
    //                                               fontSize: 7),
    //                                         ),
    //                                       ],
    //                                     ),
    //                                   ),
    //                                   Positioned(
    //                                     right: 0,
    //                                     top: 15,
    //                                     child: Transform.flip(
    //                                       flipX: true,
    //                                       child: Icon(
    //                                         TablerIcons.building_estate,
    //                                         color: defaultPalette.extras[0]
    //                                             .withOpacity(0.2),
    //                                         size: 20,
    //                                       ),
    //                                     ),
    //                                   )
    //                                 ],
    //                               ),
    //                             ),
    //                             //LANDSCAPE BUTTON
    //                             SizedBox(width: 5),
    //                             GestureDetector(
    //                               onTap: () {
    //                                 setState(() {
    //                                   addToTheRight = true;
                    
    //                                   documentPropertiesList[
    //                                               currentPageIndex]
    //                                           .orientationController =
    //                                       pw.PageOrientation.landscape;
    //                                 });
    //                                 _renderPagePreviewOnProperties();
    //                                 Future.delayed(Durations.short1)
    //                                     .then((onValue) {
    //                                   setState(() {
    //                                     addToTheRight = false;
    //                                   });
    //                                   _renderPagePreviewOnProperties();
    //                                 });
    //                               },
    //                               onTapDown: (d) {
    //                                 setState(() {
    //                                   addToTheRight = true;
    //                                 });
    //                               },
    //                               onTapUp: (d) {
    //                                 setState(() {
    //                                   addToTheRight = false;
    //                                 });
    //                               },
    //                               child: Stack(
    //                                 children: [
    //                                   Container(
    //                                     width:
    //                                         (sWidth * wH2DividerPosition -
    //                                                 55) /
    //                                             2,
    //                                     height: 30,
    //                                     alignment: Alignment.topCenter,
    //                                     margin: EdgeInsets.only(top: 10),
    //                                     decoration: BoxDecoration(
    //                                         color: defaultPalette.extras[0],
    //                                         borderRadius:
    //                                             BorderRadius.circular(5),
    //                                         border: Border.all(
    //                                             width: 1,
    //                                             strokeAlign: BorderSide
    //                                                 .strokeAlignOutside)),
    //                                   ),
    //                                   AnimatedContainer(
    //                                     duration: Duration.zero,
    //                                     width: (sWidth *
    //                                                 wH2DividerPosition -
    //                                             (addToTheRight ? 55 : 60)) /
    //                                         2,
    //                                     height: addToTheRight ? 30 : 28,
    //                                     alignment: Alignment.topRight,
    //                                     margin: EdgeInsets.only(
    //                                         top: addToTheRight ? 10 : 12,
    //                                         left: addToTheRight ? 0 : 2),
    //                                     padding: EdgeInsets.only(left: 0),
    //                                     decoration: BoxDecoration(
    //                                         color: defaultPalette.primary,
    //                                         boxShadow: [
    //                                           BoxShadow(
    //                                             color: Colors.black
    //                                                 .withOpacity(0.2),
    //                                             offset: Offset(2,
    //                                                 2), // Position of the shadow
    //                                             blurRadius: 5,
    //                                             spreadRadius:
    //                                                 -5, // Negative to create inward shadow
    //                                           ),
    //                                           BoxShadow(
    //                                             color: Colors.white
    //                                                 .withOpacity(0.7),
    //                                             offset: Offset(-2,
    //                                                 -2), // Highlight for a 3D effect
    //                                             blurRadius: 5,
    //                                             spreadRadius: -5,
    //                                           ),
    //                                         ],
    //                                         borderRadius: BorderRadius.only(
    //                                             topRight: Radius.circular(
    //                                                 addToTheRight ? 5 : 0),
    //                                             topLeft: Radius.circular(5),
    //                                             bottomRight:
    //                                                 Radius.circular(5),
    //                                             bottomLeft: Radius.circular(
    //                                                 addToTheRight ? 5 : 0)),
    //                                         border: Border.all(width: 0.1)),
    //                                     child: Column(
    //                                       crossAxisAlignment:
    //                                           CrossAxisAlignment.end,
    //                                       children: [
    //                                         Text(
    //                                           'Land ',
    //                                           style: GoogleFonts.bungee(
    //                                               fontSize: 12),
    //                                         ),
    //                                         Text(
    //                                           'Scape  ',
    //                                           style: GoogleFonts.bungee(
    //                                               fontSize: 7),
    //                                         ),
    //                                       ],
    //                                     ),
    //                                   ),
    //                                   Positioned(
    //                                     left: 5,
    //                                     top: 15,
    //                                     child: Icon(
    //                                       TablerIcons.sunset_2,
    //                                       color: defaultPalette.extras[0]
    //                                           .withOpacity(0.2),
    //                                       size: 20,
    //                                     ),
    //                                   )
    //                                 ],
    //                               ),
    //                             ),
    //                           ],
    //                         ),
    //                       ),
                    
    //                       //
    //                       //OPERATIONS BUTTONS
    //                       Padding(
    //                         padding: const EdgeInsets.only(right: 5.0),
    //                         child: Row(
    //                           mainAxisAlignment:
    //                               MainAxisAlignment.spaceBetween,
    //                           children: [
    //                             SizedBox(
    //                               width:
    //                                   (sWidth * wH2DividerPosition - 65) /
    //                                       2,
    //                               child: Row(
    //                                 mainAxisAlignment:
    //                                     MainAxisAlignment.spaceBetween,
    //                                 children: [
    //                                   //ADD PAGE BUTTON
    //                                   PieMenu(
    //                                     controller: opsAddPieController,
    //                                     actions: [
    //                                       getPieActionForAddMove(
    //                                           'LEFT', true),
    //                                       getPieActionForAddMove(
    //                                           'RIGHT', true)
    //                                     ],
    //                                     onToggle: (menuOpen) {
    //                                       if (!menuOpen) {
    //                                         opsAddPieController.closeMenu();
    //                                         opsMovePieController
    //                                             .closeMenu();
    //                                         opsCopyPieController
    //                                             .closeMenu();
    //                                         opsFormatPieController
    //                                             .closeMenu();
    //                                       }
    //                                     },
    //                                     theme: PieTheme(
    //                                         rightClickShowsMenu: true,
    //                                         buttonSize:
    //                                             ((sWidth * wH2DividerPosition -
    //                                                         65) /
    //                                                     3)
    //                                                 .clamp(40, 100),
    //                                         spacing: 5,
    //                                         radius:
    //                                             ((sWidth * wH2DividerPosition -
    //                                                         65) /
    //                                                     2)
    //                                                 .clamp(50, 100),
    //                                         customAngle: -20,
    //                                         menuAlignment: Alignment.center,
    //                                         pointerSize: 20,
    //                                         menuDisplacement: Offset(0, 4),
    //                                         tooltipPadding:
    //                                             EdgeInsets.all(5),
    //                                         tooltipTextStyle:
    //                                             GoogleFonts.bungee(
    //                                                 fontSize: 20),
    //                                         buttonTheme: PieButtonTheme(
    //                                             backgroundColor:
    //                                                 defaultPalette.tertiary,
    //                                             iconColor:
    //                                                 defaultPalette.primary,
    //                                             decoration: BoxDecoration(
    //                                               border:
    //                                                   Border.all(width: 1),
    //                                               borderRadius:
    //                                                   BorderRadius.circular(
    //                                                       200),
    //                                               color: defaultPalette
    //                                                   .extras[0],
    //                                             ))),
    //                                     child: Container(
    //                                       margin: const EdgeInsets.only(
    //                                           top: 8.0),
    //                                       // padding: const EdgeInsets.all(1),
    //                                       child: IconButton.filled(
    //                                           style: IconButton.styleFrom(
    //                                             backgroundColor:
    //                                                 defaultPalette.extras[
    //                                                     0], // Background color
    //                                             foregroundColor: defaultPalette
    //                                                 .primary, // Icon color
    //                                             // Elevation of the button
    //                                             padding: EdgeInsets.symmetric(
    //                                                 vertical: 10.0,
    //                                                 horizontal:
    //                                                     2), // Padding around the icon
    //                                             shape:
    //                                                 RoundedRectangleBorder(
    //                                               // Custom button shape
    //                                               borderRadius:
    //                                                   BorderRadius.circular(
    //                                                       5.0),
    //                                             ),
    //                                           ),
    //                                           constraints: BoxConstraints(
    //                                             minWidth: (sWidth *
    //                                                         wH2DividerPosition -
    //                                                     65) /
    //                                                 6,
    //                                             minHeight: 42,
    //                                           ), // Reduces the overall size further
    //                                           visualDensity:
    //                                               VisualDensity.compact,
    //                                           iconSize: 12,
    //                                           onPressed: () {
    //                                             opsAddPieController
    //                                                 .openMenu();
    //                                           },
    //                                           icon: Icon(TablerIcons.plus)),
    //                                     ),
    //                                   ),
    //                                   //MOVE PAGE BUTTON
    //                                   PieMenu(
    //                                     controller: opsMovePieController,
    //                                     actions: [
    //                                       getPieActionForAddMove(
    //                                           'LEFT', false),
    //                                       getPieActionForAddMove(
    //                                           'RIGHT', false),
    //                                     ],
    //                                     onToggle: (menuOpen) {
    //                                       if (!menuOpen) {
    //                                         opsAddPieController.closeMenu();
    //                                         opsMovePieController
    //                                             .closeMenu();
    //                                         opsCopyPieController
    //                                             .closeMenu();
    //                                         opsFormatPieController
    //                                             .closeMenu();
    //                                       }
    //                                     },
    //                                     theme: PieTheme(
    //                                         rightClickShowsMenu: true,
    //                                         buttonSize:
    //                                             ((sWidth * wH2DividerPosition -
    //                                                         65) /
    //                                                     3)
    //                                                 .clamp(40, 100),
    //                                         spacing: 10,
    //                                         radius:
    //                                             ((sWidth * wH2DividerPosition -
    //                                                         65) /
    //                                                     2)
    //                                                 .clamp(50, 100),
    //                                         customAngle: -20,
    //                                         menuAlignment: Alignment.center,
    //                                         pointerSize: 20,
    //                                         menuDisplacement: Offset(0, 4),
    //                                         tooltipPadding:
    //                                             EdgeInsets.all(0),
    //                                         tooltipTextStyle:
    //                                             GoogleFonts.bungee(
    //                                                 fontSize: 20),
    //                                         buttonTheme: PieButtonTheme(
    //                                             backgroundColor:
    //                                                 defaultPalette.tertiary,
    //                                             iconColor:
    //                                                 defaultPalette.primary,
    //                                             decoration: BoxDecoration(
    //                                               border:
    //                                                   Border.all(width: 1),
    //                                               borderRadius:
    //                                                   BorderRadius.circular(
    //                                                       200),
    //                                               color: defaultPalette
    //                                                   .extras[0],
    //                                             ))),
    //                                     child: Container(
    //                                       margin: const EdgeInsets.only(
    //                                           top: 8.0),
    //                                       // padding: const EdgeInsets.all(1),
    //                                       child: IconButton.filled(
    //                                           style: IconButton.styleFrom(
    //                                             backgroundColor:
    //                                                 defaultPalette.extras[
    //                                                     0], // Background color
    //                                             foregroundColor: defaultPalette
    //                                                 .primary, // Icon color
    //                                             // Elevation of the button
    //                                             padding: EdgeInsets.symmetric(
    //                                                 vertical:
    //                                                     10.0), // Padding around the icon
    //                                             shape:
    //                                                 RoundedRectangleBorder(
    //                                               // Custom button shape
    //                                               borderRadius:
    //                                                   BorderRadius.circular(
    //                                                       5.0),
    //                                             ),
    //                                           ),
    //                                           constraints: BoxConstraints(
    //                                             minWidth: (sWidth *
    //                                                         wH2DividerPosition -
    //                                                     65) /
    //                                                 6.3,
    //                                             minHeight: 42,
    //                                           ), // Reduces the overall size further
    //                                           visualDensity:
    //                                               VisualDensity.compact,
    //                                           iconSize: 15,
    //                                           onPressed: () {
    //                                             opsMovePieController
    //                                                 .openMenu();
    //                                           },
    //                                           icon: Icon(TablerIcons
    //                                               .arrows_move_vertical)),
    //                                     ),
    //                                   ),
    //                                   //Duplicate PAGE BUTTON
    //                                   PieMenu(
    //                                     actions: [
    //                                       getPieActionForDuplicate('LEFT'),
    //                                       getPieActionForDuplicate('RIGHT')
    //                                     ],
    //                                     controller: opsCopyPieController,
    //                                     onToggle: (menuOpen) {
    //                                       if (!menuOpen) {
    //                                         opsAddPieController.closeMenu();
    //                                         opsMovePieController
    //                                             .closeMenu();
    //                                         opsCopyPieController
    //                                             .closeMenu();
    //                                         opsFormatPieController
    //                                             .closeMenu();
    //                                       }
    //                                     },
    //                                     theme: PieTheme(
    //                                         rightClickShowsMenu: true,
    //                                         buttonSize:
    //                                             ((sWidth * wH2DividerPosition -
    //                                                         65) /
    //                                                     3)
    //                                                 .clamp(40, 100),
    //                                         spacing: 5,
    //                                         radius:
    //                                             ((sWidth * wH2DividerPosition -
    //                                                         65) /
    //                                                     2)
    //                                                 .clamp(50, 100),
    //                                         customAngle: 20,
    //                                         menuAlignment: Alignment.center,
    //                                         pointerSize: 20,
    //                                         menuDisplacement: Offset(0, 4),
    //                                         tooltipPadding:
    //                                             EdgeInsets.all(5),
    //                                         tooltipTextStyle:
    //                                             GoogleFonts.bungee(
    //                                                 fontSize: 20),
    //                                         buttonTheme: PieButtonTheme(
    //                                             backgroundColor:
    //                                                 defaultPalette.tertiary,
    //                                             iconColor:
    //                                                 defaultPalette.primary,
    //                                             decoration: BoxDecoration(
    //                                               border:
    //                                                   Border.all(width: 1),
    //                                               borderRadius:
    //                                                   BorderRadius.circular(
    //                                                       200),
    //                                               color: defaultPalette
    //                                                   .extras[0],
    //                                             ))),
    //                                     child: Container(
    //                                       margin: const EdgeInsets.only(
    //                                           top: 8.0),
    //                                       child: IconButton.filled(
    //                                           style: IconButton.styleFrom(
    //                                             backgroundColor:
    //                                                 defaultPalette
    //                                                     .extras[0],
    //                                             foregroundColor:
    //                                                 defaultPalette.primary,
    //                                             padding: const EdgeInsets
    //                                                 .symmetric(
    //                                                 vertical: 10.0),
    //                                             shape:
    //                                                 RoundedRectangleBorder(
    //                                               borderRadius:
    //                                                   BorderRadius.circular(
    //                                                       5.0),
    //                                             ),
    //                                           ),
    //                                           constraints: BoxConstraints(
    //                                             minWidth: (sWidth *
    //                                                         wH2DividerPosition -
    //                                                     65) /
    //                                                 5.5,
    //                                             minHeight: 42,
    //                                           ), // Reduces the overall size further
    //                                           visualDensity:
    //                                               VisualDensity.compact,
    //                                           iconSize: 15,
    //                                           onPressed: () {
    //                                             opsCopyPieController
    //                                                 .openMenu();
    //                                           },
    //                                           icon: const Icon(TablerIcons
    //                                               .dots_vertical)),
    //                                     ),
    //                                   ),
    //                                 ],
    //                               ),
    //                             ),
    //                             PieMenu(
    //                               controller: currentPageIndex == index
    //                                   ? opsFormatPieController
    //                                   : null,
    //                               actions: [
    //                                 getPieAction('A3'),
    //                                 getPieAction('A4'),
    //                                 getPieAction('A5'),
    //                                 getPieAction('A6'),
    //                                 getPieAction('Letter'),
    //                                 getPieAction('Legal'),
    //                               ],
    //                               theme: PieTheme(
    //                                   rightClickShowsMenu: true,
    //                                   buttonSize:
    //                                       ((sWidth * wH2DividerPosition -
    //                                                   65) /
    //                                               6)
    //                                           .clamp(40, 400),
    //                                   spacing: 1,
    //                                   radius:
    //                                       ((sWidth * wH2DividerPosition -
    //                                                   65) /
    //                                               4)
    //                                           .clamp(50, 400),
    //                                   customAngle: -180,
    //                                   menuAlignment: Alignment.center,
    //                                   menuDisplacement: Offset(
    //                                       -(sWidth * wH2DividerPosition -
    //                                               38) /
    //                                           6,
    //                                       4),
    //                                   tooltipPadding: EdgeInsets.all(0),
    //                                   tooltipTextStyle:
    //                                       GoogleFonts.bungee(fontSize: 20),
    //                                   buttonTheme: PieButtonTheme(
    //                                       backgroundColor:
    //                                           defaultPalette.primary,
    //                                       iconColor:
    //                                           defaultPalette.extras[0],
    //                                       decoration: BoxDecoration(
    //                                         border: Border.all(width: 3),
    //                                         borderRadius:
    //                                             BorderRadius.circular(200),
    //                                         color: defaultPalette.extras[0],
    //                                       ))),
    //                               child: Padding(
    //                                 padding:
    //                                     const EdgeInsets.only(top: 8.0),
    //                                 child: IconButton.filled(
    //                                     style: IconButton.styleFrom(
    //                                       backgroundColor:
    //                                           defaultPalette.extras[
    //                                               0], // Background color
    //                                       foregroundColor: defaultPalette
    //                                           .primary, // Icon color
    //                                       // Elevation of the button
    //                                       padding: EdgeInsets.symmetric(
    //                                           vertical:
    //                                               10.0), // Padding around the icon
    //                                       shape: RoundedRectangleBorder(
    //                                         // Custom button shape
    //                                         borderRadius:
    //                                             BorderRadius.circular(5.0),
    //                                       ),
    //                                     ),
    //                                     constraints: BoxConstraints(
    //                                       minWidth:
    //                                           (sWidth * wH2DividerPosition -
    //                                                   38) /
    //                                               2,
    //                                       minHeight: 42,
    //                                     ), // Reduces the overall size further
    //                                     visualDensity:
    //                                         VisualDensity.compact,
    //                                     iconSize: 20,
    //                                     onPressed: () {
    //                                       opsFormatPieController.openMenu();
    //                                     },
    //                                     icon: SizedBox(
    //                                       width:
    //                                           (sWidth * wH2DividerPosition -
    //                                                   52) /
    //                                               2,
    //                                       child: Row(
    //                                         mainAxisAlignment:
    //                                             MainAxisAlignment
    //                                                 .spaceAround,
    //                                         children: [
    //                                           Icon(TablerIcons.file_smile),
    //                                           Text(
    //                                             getPageFormatString(
    //                                                 documentPropertiesList[
    //                                                         currentPageIndex]
    //                                                     .pageFormatController),
    //                                             style: GoogleFonts.bungee(
    //                                                 color: defaultPalette
    //                                                     .primary),
    //                                           ),
    //                                         ],
    //                                       ),
    //                                     )),
    //                               ),
    //                             )
    //                           ],
    //                         ),
    //                       ),
                    
    //                       //STYLES TITLE
    //                       Container(
    //                         width: sWidth * wH2DividerPosition - 45,
    //                         height: 15,
    //                         alignment: Alignment.topCenter,
    //                         margin: EdgeInsets.only(top: 10, right: 5),
    //                         decoration: BoxDecoration(
    //                             // color: defaultPalette.extras[0],
    //                             borderRadius: BorderRadius.circular(5),
    //                             border: Border.all(width: 0.1)),
    //                         child: Text(
    //                           'Styles',
    //                           style: GoogleFonts.bungee(fontSize: 10),
    //                         ),
    //                       ),
                    
    //                       const SizedBox(
    //                         height: 10,
    //                       ),
                    
    //                       // MARGIN Main
    //                       Column(
    //                         children: [
    //                           //Margin TiTle
    //                           SizedBox(
    //                             height: textFieldHeight / 2,
    //                             child: Row(
    //                               children: [
    //                                 Expanded(
    //                                   child: Text(
    //                                     'Margin',
    //                                     style: GoogleFonts.bungee(
    //                                         fontSize: 13),
    //                                   ),
    //                                 ),
                    
    //                                 const SizedBox(
    //                                   width: 5,
    //                                 ),
    //                                 //Margin ONE Field
    //                                 Expanded(
    //                                   child: TextFormField(
    //                                     onTapOutside: (event) {
    //                                       marginAllFocus.unfocus();
    //                                     },
    //                                     obscureText: documentPropertiesList[
    //                                             currentPageIndex]
    //                                         .useIndividualMargins,
    //                                     focusNode: marginAllFocus,
    //                                     controller: documentPropertiesList[
    //                                             currentPageIndex]
    //                                         .marginAllController,
    //                                     inputFormatters: [
    //                                       NumericInputFormatter(
    //                                           maxValue: documentPropertiesList[
    //                                                       currentPageIndex]
    //                                                   .pageFormatController
    //                                                   .width /
    //                                               2.001)
    //                                     ],
    //                                     textAlignVertical:
    //                                         TextAlignVertical.top,
    //                                     textAlign: TextAlign.center,
    //                                     decoration: InputDecoration(
    //                                       contentPadding:
    //                                           const EdgeInsets.all(0),
    //                                       floatingLabelAlignment:
    //                                           FloatingLabelAlignment.center,
    //                                       labelStyle: GoogleFonts.lexend(
    //                                           color: defaultPalette.black),
    //                                       filled: true,
    //                                       fillColor:
    //                                           !documentPropertiesList[
    //                                                       currentPageIndex]
    //                                                   .useIndividualMargins
    //                                               ? defaultPalette.primary
    //                                               : defaultPalette.primary
    //                                                   .withOpacity(0.5),
    //                                       border: OutlineInputBorder(
    //                                         // borderSide: BorderSide(width: 5, color: defaultPalette.black),
    //                                         borderRadius: BorderRadius.circular(
    //                                             5.0), // Replace with your desired radius
    //                                       ),
    //                                       enabledBorder: OutlineInputBorder(
    //                                         borderSide: BorderSide(
    //                                             width: 1.2,
    //                                             color:
    //                                                 defaultPalette.black),
    //                                         borderRadius:
    //                                             BorderRadius.circular(
    //                                                 5.0), // Same as border
    //                                       ),
    //                                       focusedBorder: OutlineInputBorder(
    //                                         borderSide: BorderSide(
    //                                             width: 1.5,
    //                                             color: defaultPalette
    //                                                 .tertiary),
    //                                         borderRadius:
    //                                             BorderRadius.circular(
    //                                                 5.0), // Same as border
    //                                       ),
    //                                     ),
    //                                     keyboardType: TextInputType.number,
    //                                     style: GoogleFonts.bungee(
    //                                         // fontStyle: FontStyle.italic,
    //                                         fontSize: 12,
    //                                         color: defaultPalette.black),
    //                                     onChanged: (value) {
    //                                       // setState(() {
                    
    //                                       documentPropertiesList[
    //                                               currentPageIndex]
    //                                           .marginTopController
    //                                           .text = value;
    //                                       documentPropertiesList[
    //                                               currentPageIndex]
    //                                           .marginBottomController
    //                                           .text = value;
    //                                       documentPropertiesList[
    //                                               currentPageIndex]
    //                                           .marginLeftController
    //                                           .text = value;
    //                                       documentPropertiesList[
    //                                               currentPageIndex]
    //                                           .marginRightController
    //                                           .text = value;
    //                                       // _updatePdfPreview(
    //                                       //     '');
    //                                       // });
    //                                     },
    //                                     enabled: !documentPropertiesList[
    //                                             currentPageIndex]
    //                                         .useIndividualMargins,
    //                                   ),
    //                                 ),
                    
    //                                 const SizedBox(
    //                                   width: 5,
    //                                 ),
    //                                 //Increase Decrease
    //                                 Column(
    //                                   children: [
    //                                     //Margin increment button
    //                                     GestureDetector(
    //                                       onTap: () {
    //                                         setState(() {
    //                                           documentPropertiesList[
    //                                                   currentPageIndex]
    //                                               .marginAllController
    //                                               .text = (double.parse(
    //                                                       documentPropertiesList[
    //                                                               currentPageIndex]
    //                                                           .marginAllController
    //                                                           .text) +
    //                                                   1)
    //                                               .toString();
    //                                           documentPropertiesList[
    //                                                       currentPageIndex]
    //                                                   .marginTopController
    //                                                   .text =
    //                                               documentPropertiesList[
    //                                                       currentPageIndex]
    //                                                   .marginAllController
    //                                                   .text;
    //                                           documentPropertiesList[
    //                                                       currentPageIndex]
    //                                                   .marginBottomController
    //                                                   .text =
    //                                               documentPropertiesList[
    //                                                       currentPageIndex]
    //                                                   .marginAllController
    //                                                   .text;
    //                                           documentPropertiesList[
    //                                                       currentPageIndex]
    //                                                   .marginLeftController
    //                                                   .text =
    //                                               documentPropertiesList[
    //                                                       currentPageIndex]
    //                                                   .marginAllController
    //                                                   .text;
    //                                           documentPropertiesList[
    //                                                       currentPageIndex]
    //                                                   .marginRightController
    //                                                   .text =
    //                                               documentPropertiesList[
    //                                                       currentPageIndex]
    //                                                   .marginAllController
    //                                                   .text;
    //                                         });
                    
    //                                         // _updatePdfPreview('');
    //                                       },
    //                                       child: const Icon(
    //                                         IconsaxPlusLinear.arrow_up_1,
    //                                         size: 10,
    //                                       ),
    //                                     ),
    //                                     //Margin decrement button
    //                                     GestureDetector(
    //                                       onTap: () {
    //                                         setState(() {
    //                                           var value =
    //                                               documentPropertiesList[
    //                                                       currentPageIndex]
    //                                                   .marginAllController
    //                                                   .text;
    //                                           documentPropertiesList[
    //                                                       currentPageIndex]
    //                                                   .marginAllController
    //                                                   .text =
    //                                               (double.parse(value) - 1)
    //                                                   .abs()
    //                                                   .toString();
    //                                           documentPropertiesList[
    //                                                       currentPageIndex]
    //                                                   .marginTopController
    //                                                   .text =
    //                                               documentPropertiesList[
    //                                                       currentPageIndex]
    //                                                   .marginAllController
    //                                                   .text;
    //                                           documentPropertiesList[
    //                                                       currentPageIndex]
    //                                                   .marginBottomController
    //                                                   .text =
    //                                               documentPropertiesList[
    //                                                       currentPageIndex]
    //                                                   .marginAllController
    //                                                   .text;
    //                                           documentPropertiesList[
    //                                                       currentPageIndex]
    //                                                   .marginLeftController
    //                                                   .text =
    //                                               documentPropertiesList[
    //                                                       currentPageIndex]
    //                                                   .marginAllController
    //                                                   .text;
    //                                           documentPropertiesList[
    //                                                       currentPageIndex]
    //                                                   .marginRightController
    //                                                   .text =
    //                                               documentPropertiesList[
    //                                                       currentPageIndex]
    //                                                   .marginAllController
    //                                                   .text;
    //                                         });
    //                                         // _updatePdfPreview('');
    //                                       },
    //                                       child: const Icon(
    //                                         IconsaxPlusLinear.arrow_down,
    //                                         size: 10,
    //                                       ),
    //                                     ),
    //                                   ],
    //                                 ),
    //                                 ////INDIVIDUAL MARGINS BUTTON
    //                                 IconButton(
    //                                     padding: const EdgeInsets.all(0),
    //                                     onPressed: () {
    //                                       setState(() {
    //                                         documentPropertiesList[
    //                                                     currentPageIndex]
    //                                                 .useIndividualMargins =
    //                                             !documentPropertiesList[
    //                                                     currentPageIndex]
    //                                                 .useIndividualMargins;
    //                                         if (documentPropertiesList[
    //                                                     currentPageIndex]
    //                                                 .useIndividualMargins ==
    //                                             false) {
    //                                           documentPropertiesList[
    //                                                       currentPageIndex]
    //                                                   .marginTopController
    //                                                   .text =
    //                                               documentPropertiesList[
    //                                                       currentPageIndex]
    //                                                   .marginAllController
    //                                                   .text;
    //                                           documentPropertiesList[
    //                                                       currentPageIndex]
    //                                                   .marginBottomController
    //                                                   .text =
    //                                               documentPropertiesList[
    //                                                       currentPageIndex]
    //                                                   .marginAllController
    //                                                   .text;
    //                                           documentPropertiesList[
    //                                                       currentPageIndex]
    //                                                   .marginLeftController
    //                                                   .text =
    //                                               documentPropertiesList[
    //                                                       currentPageIndex]
    //                                                   .marginAllController
    //                                                   .text;
    //                                           documentPropertiesList[
    //                                                       currentPageIndex]
    //                                                   .marginRightController
    //                                                   .text =
    //                                               documentPropertiesList[
    //                                                       currentPageIndex]
    //                                                   .marginAllController
    //                                                   .text;
    //                                         }
    //                                       });
    //                                     },
    //                                     icon: documentPropertiesList[
    //                                                 currentPageIndex]
    //                                             .useIndividualMargins
    //                                         ? const Icon(
    //                                             IconsaxPlusBold.maximize_1,
    //                                             size: 20,
    //                                           )
    //                                         : const Icon(
    //                                             IconsaxPlusLinear
    //                                                 .maximize_2,
    //                                             size: 20,
    //                                           ))
    //                                 // Text(
    //                                 //     'Use Individual Margins'),
    //                               ],
    //                             ),
    //                           ),
                    
    //                           if (documentPropertiesList[currentPageIndex]
    //                               .useIndividualMargins)
    //                             Column(
    //                               children: [
    //                                 const SizedBox(
    //                                   height: 10,
    //                                 ),
    //                                 //TOP AND BOTTOM Margin TiTle
                    
    //                                 Row(
    //                                   children: [
    //                                     //Top Margin text
    //                                     Expanded(
    //                                       flex: 2,
    //                                       child: SizedBox(
    //                                         height: textFieldHeight / 2,
    //                                         child: Row(
    //                                           children: [
    //                                             Expanded(
    //                                               flex: 1,
    //                                               child: Text(
    //                                                 'Top',
    //                                                 style:
    //                                                     GoogleFonts.bungee(
    //                                                         fontSize: 11),
    //                                               ),
    //                                             ),
                    
    //                                             const SizedBox(
    //                                               width: 5,
    //                                             ),
    //                                             //TOP Margin ONE Field
    //                                             Expanded(
    //                                               flex: 1,
    //                                               child: TextFormField(
    //                                                 onTapOutside: (event) {
    //                                                   marginTopFocus
    //                                                       .unfocus();
    //                                                 },
    //                                                 focusNode:
    //                                                     marginTopFocus,
    //                                                 controller: documentPropertiesList[
    //                                                         currentPageIndex]
    //                                                     .marginTopController,
    //                                                 inputFormatters: [
    //                                                   // FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
    //                                                   NumericInputFormatter(
    //                                                       maxValue: (documentPropertiesList[
    //                                                                       currentPageIndex]
    //                                                                   .pageFormatController
    //                                                                   .height /
    //                                                               1.11 -
    //                                                           double.parse(documentPropertiesList[
    //                                                                   currentPageIndex]
    //                                                               .marginBottomController
    //                                                               .text))),
    //                                                 ],
    //                                                 cursorColor:
    //                                                     defaultPalette
    //                                                         .secondary,
    //                                                 textAlign:
    //                                                     TextAlign.center,
    //                                                 textAlignVertical:
    //                                                     TextAlignVertical
    //                                                         .top,
    //                                                 decoration:
    //                                                     InputDecoration(
    //                                                   contentPadding:
    //                                                       const EdgeInsets
    //                                                           .all(0),
    //                                                   filled: true,
    //                                                   fillColor:
    //                                                       defaultPalette
    //                                                           .primary,
    //                                                   border:
    //                                                       OutlineInputBorder(
    //                                                     // borderSide: BorderSide(width: 5, color: defaultPalette.black),
    //                                                     borderRadius:
    //                                                         BorderRadius
    //                                                             .circular(
    //                                                                 5.0), // Replace with your desired radius
    //                                                   ),
    //                                                   enabledBorder:
    //                                                       OutlineInputBorder(
    //                                                     borderSide: BorderSide(
    //                                                         width: 1.2,
    //                                                         color:
    //                                                             defaultPalette
    //                                                                 .black),
    //                                                     borderRadius:
    //                                                         BorderRadius
    //                                                             .circular(
    //                                                                 5.0), // Same as border
    //                                                   ),
    //                                                   focusedBorder:
    //                                                       OutlineInputBorder(
    //                                                     borderSide: BorderSide(
    //                                                         width: 3,
    //                                                         color: defaultPalette
    //                                                             .tertiary),
    //                                                     borderRadius:
    //                                                         BorderRadius
    //                                                             .circular(
    //                                                                 5.0), // Same as border
    //                                                   ),
    //                                                 ),
    //                                                 keyboardType:
    //                                                     TextInputType
    //                                                         .number,
    //                                                 style:
    //                                                     GoogleFonts.bungee(
    //                                                         // fontStyle: FontStyle.italic,
    //                                                         fontSize: 12,
    //                                                         color:
    //                                                             defaultPalette
    //                                                                 .black),
    //                                                 onChanged: (value) {
    //                                                   // setState(() {
    //                                                   if (value.isEmpty) {
    //                                                     documentPropertiesList[
    //                                                             currentPageIndex]
    //                                                         .marginTopController
    //                                                         .text = '0';
    //                                                   }
    //                                                   setState(() {});
    //                                                   // _updatePdfPreview(
    //                                                   //     '');
    //                                                   // });
    //                                                 },
    //                                                 enabled: documentPropertiesList[
    //                                                         currentPageIndex]
    //                                                     .useIndividualMargins,
    //                                               ),
    //                                             ),
                    
    //                                             const SizedBox(
    //                                               width: 5,
    //                                             ),
    //                                             //Increase Decrease
    //                                             Column(
    //                                               children: [
    //                                                 //Margin increment button
    //                                                 GestureDetector(
    //                                                   onTap: () {
    //                                                     setState(() {
    //                                                       documentPropertiesList[
    //                                                               currentPageIndex]
    //                                                           .marginTopController
    //                                                           .text = (double.parse(documentPropertiesList[
    //                                                                       currentPageIndex]
    //                                                                   .marginTopController
    //                                                                   .text) +
    //                                                               1)
    //                                                           .toInt()
    //                                                           .toString();
    //                                                     });
                    
    //                                                     // _updatePdfPreview('');
    //                                                   },
    //                                                   child: const Icon(
    //                                                     IconsaxPlusLinear
    //                                                         .arrow_up_1,
    //                                                     size: 10,
    //                                                   ),
    //                                                 ),
    //                                                 //Margin decrement button
    //                                                 GestureDetector(
    //                                                   onTap: () {
    //                                                     setState(() {
    //                                                       documentPropertiesList[
    //                                                               currentPageIndex]
    //                                                           .marginTopController
    //                                                           .text = (double.parse(documentPropertiesList[
    //                                                                       currentPageIndex]
    //                                                                   .marginTopController
    //                                                                   .text) -
    //                                                               1)
    //                                                           .abs()
    //                                                           .toInt()
    //                                                           .toString();
    //                                                     });
                    
    //                                                     // _updatePdfPreview('');
    //                                                   },
    //                                                   child: const Icon(
    //                                                     IconsaxPlusLinear
    //                                                         .arrow_down,
    //                                                     size: 10,
    //                                                   ),
    //                                                 ),
    //                                               ],
    //                                             ),
    //                                           ],
    //                                         ),
    //                                       ),
    //                                     ),
                    
    //                                     const SizedBox(
    //                                       width: 10,
    //                                     ),
    //                                     //Bottom Margin text
    //                                     Expanded(
    //                                       flex: 3,
    //                                       child: SizedBox(
    //                                         height: textFieldHeight / 2,
    //                                         child: Row(
    //                                           children: [
    //                                             Expanded(
    //                                               flex: 3,
    //                                               child: Text(
    //                                                 'Bottom',
    //                                                 style:
    //                                                     GoogleFonts.bungee(
    //                                                         fontSize: 11),
    //                                               ),
    //                                             ),
                    
    //                                             const SizedBox(
    //                                               width: 5,
    //                                             ),
    //                                             //Bottom Margin ONE Field
    //                                             Expanded(
    //                                               flex: 2,
    //                                               child: TextFormField(
    //                                                 onTapOutside: (event) {
    //                                                   marginBottomFocus
    //                                                       .unfocus();
    //                                                 },
    //                                                 focusNode:
    //                                                     marginBottomFocus,
    //                                                 controller: documentPropertiesList[
    //                                                         currentPageIndex]
    //                                                     .marginBottomController,
    //                                                 inputFormatters: [
    //                                                   // FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
    //                                                   NumericInputFormatter(
    //                                                       maxValue: (documentPropertiesList[
    //                                                                       currentPageIndex]
    //                                                                   .pageFormatController
    //                                                                   .height /
    //                                                               1.11 -
    //                                                           double.parse(documentPropertiesList[
    //                                                                   currentPageIndex]
    //                                                               .marginTopController
    //                                                               .text))),
    //                                                 ],
    //                                                 cursorColor:
    //                                                     defaultPalette
    //                                                         .secondary,
    //                                                 textAlign:
    //                                                     TextAlign.center,
    //                                                 textAlignVertical:
    //                                                     TextAlignVertical
    //                                                         .top,
    //                                                 decoration:
    //                                                     InputDecoration(
    //                                                   contentPadding:
    //                                                       const EdgeInsets
    //                                                           .all(0),
    //                                                   filled: true,
    //                                                   fillColor:
    //                                                       defaultPalette
    //                                                           .primary,
    //                                                   border:
    //                                                       OutlineInputBorder(
    //                                                     // borderSide: BorderSide(width: 5, color: defaultPalette.black),
    //                                                     borderRadius:
    //                                                         BorderRadius
    //                                                             .circular(
    //                                                                 5.0), // Replace with your desired radius
    //                                                   ),
    //                                                   enabledBorder:
    //                                                       OutlineInputBorder(
    //                                                     borderSide: BorderSide(
    //                                                         width: 1.2,
    //                                                         color:
    //                                                             defaultPalette
    //                                                                 .black),
    //                                                     borderRadius:
    //                                                         BorderRadius
    //                                                             .circular(
    //                                                                 5.0), // Same as border
    //                                                   ),
    //                                                   focusedBorder:
    //                                                       OutlineInputBorder(
    //                                                     borderSide: BorderSide(
    //                                                         width: 3,
    //                                                         color: defaultPalette
    //                                                             .tertiary),
    //                                                     borderRadius:
    //                                                         BorderRadius
    //                                                             .circular(
    //                                                                 5.0), // Same as border
    //                                                   ),
    //                                                 ),
    //                                                 keyboardType:
    //                                                     TextInputType
    //                                                         .number,
    //                                                 style:
    //                                                     GoogleFonts.bungee(
    //                                                         // fontStyle: FontStyle.italic,
    //                                                         fontSize: 12,
    //                                                         color:
    //                                                             defaultPalette
    //                                                                 .black),
    //                                                 onChanged: (value) {
    //                                                   // setState(() {
    //                                                   if (value.isEmpty) {
    //                                                     documentPropertiesList[
    //                                                             currentPageIndex]
    //                                                         .marginBottomController
    //                                                         .text = '0';
    //                                                   }
    //                                                   setState(() {});
    //                                                   // _updatePdfPreview(
    //                                                   //     '');
    //                                                   // });
    //                                                 },
    //                                                 enabled: documentPropertiesList[
    //                                                         currentPageIndex]
    //                                                     .useIndividualMargins,
    //                                               ),
    //                                             ),
                    
    //                                             const SizedBox(
    //                                               width: 5,
    //                                             ),
    //                                             //Increase Decrease
    //                                             Column(
    //                                               children: [
    //                                                 //Margin increment button
    //                                                 GestureDetector(
    //                                                   onTap: () {
    //                                                     setState(() {
    //                                                       documentPropertiesList[
    //                                                               currentPageIndex]
    //                                                           .marginBottomController
    //                                                           .text = (double.parse(documentPropertiesList[
    //                                                                       currentPageIndex]
    //                                                                   .marginBottomController
    //                                                                   .text) +
    //                                                               1)
    //                                                           .toInt()
    //                                                           .toString();
    //                                                     });
                    
    //                                                     // _updatePdfPreview('');
    //                                                   },
    //                                                   child: const Icon(
    //                                                     IconsaxPlusLinear
    //                                                         .arrow_up_1,
    //                                                     size: 10,
    //                                                   ),
    //                                                 ),
    //                                                 //Margin decrement button
    //                                                 GestureDetector(
    //                                                   onTap: () {
    //                                                     setState(() {
    //                                                       documentPropertiesList[
    //                                                               currentPageIndex]
    //                                                           .marginBottomController
    //                                                           .text = (double.parse(documentPropertiesList[
    //                                                                       currentPageIndex]
    //                                                                   .marginBottomController
    //                                                                   .text) -
    //                                                               1)
    //                                                           .abs()
    //                                                           .toInt()
    //                                                           .toString();
    //                                                     });
                    
    //                                                     // _updatePdfPreview('');
    //                                                   },
    //                                                   child: const Icon(
    //                                                     IconsaxPlusLinear
    //                                                         .arrow_down,
    //                                                     size: 10,
    //                                                   ),
    //                                                 ),
    //                                               ],
    //                                             ),
                    
    //                                             const SizedBox(
    //                                               width: 10,
    //                                             ),
    //                                           ],
    //                                         ),
    //                                       ),
    //                                     ),
    //                                   ],
    //                                 ),
    //                                 const SizedBox(
    //                                   height: 10,
    //                                 ),
    //                                 // LEFT AND RIGHT Margin Title
    //                                 Row(
    //                                   children: [
    //                                     //Left Margin text
    //                                     Expanded(
    //                                       flex: 10,
    //                                       child: SizedBox(
    //                                         height: textFieldHeight / 2,
    //                                         child: Row(
    //                                           children: [
    //                                             Expanded(
    //                                               child: Text(
    //                                                 'Left',
    //                                                 style:
    //                                                     GoogleFonts.bungee(
    //                                                         fontSize: 11),
    //                                               ),
    //                                             ),
                    
    //                                             const SizedBox(
    //                                               width: 5,
    //                                             ),
    //                                             //Left Margin ONE Field
    //                                             Expanded(
    //                                               child: TextFormField(
    //                                                 onTapOutside: (event) {
    //                                                   marginBottomFocus
    //                                                       .unfocus();
    //                                                 },
    //                                                 focusNode:
    //                                                     marginLeftFocus,
    //                                                 controller: documentPropertiesList[
    //                                                         currentPageIndex]
    //                                                     .marginLeftController,
    //                                                 inputFormatters: [
    //                                                   // FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
    //                                                   NumericInputFormatter(
    //                                                       maxValue: (documentPropertiesList[
    //                                                                       currentPageIndex]
    //                                                                   .pageFormatController
    //                                                                   .height /
    //                                                               1.11 -
    //                                                           double.parse(documentPropertiesList[
    //                                                                   currentPageIndex]
    //                                                               .marginRightController
    //                                                               .text))),
    //                                                 ],
    //                                                 cursorColor:
    //                                                     defaultPalette
    //                                                         .secondary,
    //                                                 textAlign:
    //                                                     TextAlign.center,
    //                                                 textAlignVertical:
    //                                                     TextAlignVertical
    //                                                         .top,
    //                                                 decoration:
    //                                                     InputDecoration(
    //                                                   contentPadding:
    //                                                       const EdgeInsets
    //                                                           .all(0),
    //                                                   filled: true,
    //                                                   fillColor:
    //                                                       defaultPalette
    //                                                           .primary,
    //                                                   border:
    //                                                       OutlineInputBorder(
    //                                                     // borderSide: BorderSide(width: 5, color: defaultPalette.black),
    //                                                     borderRadius:
    //                                                         BorderRadius
    //                                                             .circular(
    //                                                                 5.0), // Replace with your desired radius
    //                                                   ),
    //                                                   enabledBorder:
    //                                                       OutlineInputBorder(
    //                                                     borderSide: BorderSide(
    //                                                         width: 1.2,
    //                                                         color:
    //                                                             defaultPalette
    //                                                                 .black),
    //                                                     borderRadius:
    //                                                         BorderRadius
    //                                                             .circular(
    //                                                                 5.0), // Same as border
    //                                                   ),
    //                                                   focusedBorder:
    //                                                       OutlineInputBorder(
    //                                                     borderSide: BorderSide(
    //                                                         width: 3,
    //                                                         color: defaultPalette
    //                                                             .tertiary),
    //                                                     borderRadius:
    //                                                         BorderRadius
    //                                                             .circular(
    //                                                                 5.0), // Same as border
    //                                                   ),
    //                                                 ),
    //                                                 keyboardType:
    //                                                     TextInputType
    //                                                         .number,
    //                                                 style:
    //                                                     GoogleFonts.bungee(
    //                                                         // fontStyle: FontStyle.italic,
    //                                                         fontSize: 12,
    //                                                         color:
    //                                                             defaultPalette
    //                                                                 .black),
    //                                                 onChanged: (value) {
    //                                                   // setState(() {
    //                                                   if (value.isEmpty) {
    //                                                     documentPropertiesList[
    //                                                             currentPageIndex]
    //                                                         .marginLeftController
    //                                                         .text = '0';
    //                                                   }
    //                                                   setState(() {});
    //                                                   // _updatePdfPreview(
    //                                                   //     '');
    //                                                   // });
    //                                                 },
    //                                                 enabled: documentPropertiesList[
    //                                                         currentPageIndex]
    //                                                     .useIndividualMargins,
    //                                               ),
    //                                             ),
                    
    //                                             const SizedBox(
    //                                               width: 5,
    //                                             ),
    //                                             //Increase Decrease
    //                                             Column(
    //                                               children: [
    //                                                 //Margin increment button
    //                                                 GestureDetector(
    //                                                   onTap: () {
    //                                                     setState(() {
    //                                                       documentPropertiesList[
    //                                                               currentPageIndex]
    //                                                           .marginLeftController
    //                                                           .text = (double.parse(documentPropertiesList[
    //                                                                       currentPageIndex]
    //                                                                   .marginLeftController
    //                                                                   .text) +
    //                                                               1)
    //                                                           .toInt()
    //                                                           .toString();
    //                                                     });
                    
    //                                                     // _updatePdfPreview('');
    //                                                   },
    //                                                   child: const Icon(
    //                                                     IconsaxPlusLinear
    //                                                         .arrow_up_1,
    //                                                     size: 10,
    //                                                   ),
    //                                                 ),
    //                                                 //Margin decrement button
    //                                                 GestureDetector(
    //                                                   onTap: () {
    //                                                     setState(() {
    //                                                       documentPropertiesList[
    //                                                               currentPageIndex]
    //                                                           .marginLeftController
    //                                                           .text = (double.parse(documentPropertiesList[
    //                                                                       currentPageIndex]
    //                                                                   .marginLeftController
    //                                                                   .text) -
    //                                                               1)
    //                                                           .abs()
    //                                                           .toInt()
    //                                                           .toString();
    //                                                     });
                    
    //                                                     // _updatePdfPreview('');
    //                                                   },
    //                                                   child: const Icon(
    //                                                     IconsaxPlusLinear
    //                                                         .arrow_down,
    //                                                     size: 10,
    //                                                   ),
    //                                                 ),
    //                                               ],
    //                                             ),
                    
    //                                             const SizedBox(
    //                                               width: 10,
    //                                             ),
    //                                           ],
    //                                         ),
    //                                       ),
    //                                     ),
    //                                     const SizedBox(
    //                                       width: 5,
    //                                     ),
    //                                     //Right Margin text
    //                                     Expanded(
    //                                       flex: 11,
    //                                       child: SizedBox(
    //                                         height: textFieldHeight / 2,
    //                                         child: Row(
    //                                           children: [
    //                                             Expanded(
    //                                               flex: 2,
    //                                               child: Text(
    //                                                 'Right',
    //                                                 style:
    //                                                     GoogleFonts.bungee(
    //                                                         fontSize: 11),
    //                                               ),
    //                                             ),
                    
    //                                             const SizedBox(
    //                                               width: 5,
    //                                             ),
    //                                             //Right Margin ONE Field
    //                                             Expanded(
    //                                               child: TextFormField(
    //                                                 onTapOutside: (event) {
    //                                                   marginBottomFocus
    //                                                       .unfocus();
    //                                                 },
    //                                                 focusNode:
    //                                                     marginRightFocus,
    //                                                 controller: documentPropertiesList[
    //                                                         currentPageIndex]
    //                                                     .marginRightController,
    //                                                 inputFormatters: [
    //                                                   // FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
    //                                                   NumericInputFormatter(
    //                                                       maxValue: (documentPropertiesList[
    //                                                                       currentPageIndex]
    //                                                                   .pageFormatController
    //                                                                   .height /
    //                                                               1.11 -
    //                                                           double.parse(documentPropertiesList[
    //                                                                   currentPageIndex]
    //                                                               .marginLeftController
    //                                                               .text))),
    //                                                 ],
    //                                                 cursorColor:
    //                                                     defaultPalette
    //                                                         .secondary,
    //                                                 textAlign:
    //                                                     TextAlign.center,
    //                                                 textAlignVertical:
    //                                                     TextAlignVertical
    //                                                         .top,
    //                                                 decoration:
    //                                                     InputDecoration(
    //                                                   contentPadding:
    //                                                       const EdgeInsets
    //                                                           .all(0),
    //                                                   filled: true,
    //                                                   fillColor:
    //                                                       defaultPalette
    //                                                           .primary,
    //                                                   border:
    //                                                       OutlineInputBorder(
    //                                                     // borderSide: BorderSide(width: 5, color: defaultPalette.black),
    //                                                     borderRadius:
    //                                                         BorderRadius
    //                                                             .circular(
    //                                                                 5.0), // Replace with your desired radius
    //                                                   ),
    //                                                   enabledBorder:
    //                                                       OutlineInputBorder(
    //                                                     borderSide: BorderSide(
    //                                                         width: 1.2,
    //                                                         color:
    //                                                             defaultPalette
    //                                                                 .black),
    //                                                     borderRadius:
    //                                                         BorderRadius
    //                                                             .circular(
    //                                                                 5.0), // Same as border
    //                                                   ),
    //                                                   focusedBorder:
    //                                                       OutlineInputBorder(
    //                                                     borderSide: BorderSide(
    //                                                         width: 3,
    //                                                         color: defaultPalette
    //                                                             .tertiary),
    //                                                     borderRadius:
    //                                                         BorderRadius
    //                                                             .circular(
    //                                                                 5.0), // Same as border
    //                                                   ),
    //                                                 ),
    //                                                 keyboardType:
    //                                                     TextInputType
    //                                                         .number,
    //                                                 style:
    //                                                     GoogleFonts.bungee(
    //                                                         // fontStyle: FontStyle.italic,
    //                                                         fontSize: 12,
    //                                                         color:
    //                                                             defaultPalette
    //                                                                 .black),
    //                                                 onChanged: (value) {
    //                                                   // setState(() {
    //                                                   if (value.isEmpty) {
    //                                                     documentPropertiesList[
    //                                                             currentPageIndex]
    //                                                         .marginRightController
    //                                                         .text = '0';
    //                                                   }
    //                                                   setState(() {});
    //                                                   // _updatePdfPreview(
    //                                                   //     '');
    //                                                   // });
    //                                                 },
    //                                                 enabled: documentPropertiesList[
    //                                                         currentPageIndex]
    //                                                     .useIndividualMargins,
    //                                               ),
    //                                             ),
                    
    //                                             const SizedBox(
    //                                               width: 5,
    //                                             ),
    //                                             //Increase Decrease (Right Margin)
    //                                             Column(
    //                                               children: [
    //                                                 //Margin increment button
    //                                                 GestureDetector(
    //                                                   onTap: () {
    //                                                     setState(() {
    //                                                       documentPropertiesList[
    //                                                               currentPageIndex]
    //                                                           .marginRightController
    //                                                           .text = (double.parse(documentPropertiesList[
    //                                                                       currentPageIndex]
    //                                                                   .marginRightController
    //                                                                   .text) +
    //                                                               1)
    //                                                           .toInt()
    //                                                           .toString();
    //                                                     });
                    
    //                                                     // _updatePdfPreview('');
    //                                                   },
    //                                                   child: const Icon(
    //                                                     IconsaxPlusLinear
    //                                                         .arrow_up_1,
    //                                                     size: 10,
    //                                                   ),
    //                                                 ),
    //                                                 //Margin decrement button
    //                                                 GestureDetector(
    //                                                   onTap: () {
    //                                                     setState(() {
    //                                                       documentPropertiesList[
    //                                                               currentPageIndex]
    //                                                           .marginRightController
    //                                                           .text = (double.parse(documentPropertiesList[
    //                                                                       currentPageIndex]
    //                                                                   .marginRightController
    //                                                                   .text) -
    //                                                               1)
    //                                                           .abs()
    //                                                           .toInt()
    //                                                           .toString();
    //                                                     });
                    
    //                                                     // _updatePdfPreview('');
    //                                                   },
    //                                                   child: const Icon(
    //                                                     IconsaxPlusLinear
    //                                                         .arrow_down,
    //                                                     size: 10,
    //                                                   ),
    //                                                 ),
    //                                               ],
    //                                             ),
                    
    //                                             const SizedBox(
    //                                               width: 10,
    //                                             ),
    //                                           ],
    //                                         ),
    //                                       ),
    //                                     ),
    //                                   ],
    //                                 ),
    //                                 const SizedBox(
    //                                   height: 0,
    //                                 )
    //                               ],
    //                             ),
    //                           // Divider(),
    //                         ],
    //                       ),
    //                       //HEX TITLE
    //                       Container(
    //                         width: sWidth * wH2DividerPosition - 45,
    //                         height: 15,
    //                         alignment: Alignment.topCenter,
    //                         margin: EdgeInsets.only(top: 10, right: 5),
    //                         padding: EdgeInsets.only(left: 5, right: 5),
    //                         decoration: BoxDecoration(
    //                             // color: defaultPalette.extras[0],
    //                             borderRadius: BorderRadius.circular(5),
    //                             border: Border.all(width: 0.1)),
    //                         child: Row(
    //                           mainAxisAlignment:
    //                               MainAxisAlignment.spaceBetween,
    //                           crossAxisAlignment: CrossAxisAlignment.start,
    //                           children: [
    //                             Expanded(
    //                               flex: 5,
    //                               child: Text(
    //                                 'PAGE HEX',
    //                                 style: GoogleFonts.bungee(fontSize: 10),
    //                               ),
    //                             ),
    //                             Expanded(
    //                               flex: 3,
    //                               child: TextFormField(
    //                                 onTapOutside: (event) {},
    //                                 controller: pgHexController,
    //                                 inputFormatters: [
    //                                   HexColorInputFormatter()
    //                                 ],
    //                                 onFieldSubmitted: (value) {
    //                                   setState(() {
    //                                     documentPropertiesList[ind]
    //                                         .pageColor = hexToColor(value);
    //                                   });
    //                                 },
    //                                 style: GoogleFonts.bungee(fontSize: 10),
    //                                 cursorColor: defaultPalette.tertiary,
    //                                 textAlign: TextAlign.center,
    //                                 textAlignVertical:
    //                                     TextAlignVertical.center,
    //                                 decoration: InputDecoration(
    //                                   contentPadding:
    //                                       const EdgeInsets.all(0),
    //                                   border: InputBorder.none,
    //                                   enabledBorder: OutlineInputBorder(
    //                                     borderSide: BorderSide(
    //                                         width: 2,
    //                                         color:
    //                                             defaultPalette.transparent),
    //                                     borderRadius:
    //                                         BorderRadius.circular(12.0),
    //                                   ),
    //                                   focusedBorder: OutlineInputBorder(
    //                                     borderSide: BorderSide(
    //                                         width: 3,
    //                                         color:
    //                                             defaultPalette.transparent),
    //                                     borderRadius:
    //                                         BorderRadius.circular(10.0),
    //                                   ),
    //                                 ),
    //                                 keyboardType: TextInputType.number,
    //                               ),
    //                             ),
    //                           ],
    //                         ),
    //                       ),
                    
    //                       //COLOR SWATCH And WHEEL FOR PAGE COLOR
    //                       Stack(
    //                         children: [
    //                           SizedBox(
    //                               width:
    //                                   ((sWidth * wH2DividerPosition - 115)),
    //                               height: 140),
    //                           //COLOR WHEEL FOR PAGE COLOR
    //                           Positioned(
    //                             right: 8,
    //                             height: 140,
    //                             width: 120,
    //                             top: 4,
    //                             child: Column(
    //                               crossAxisAlignment:
    //                                   CrossAxisAlignment.end,
    //                               children: [
    //                                 //COLOR WHEEL FOR PAGE COLOR
    //                                 SizedBox(
    //                                   height: 100,
    //                                   width: 90,
    //                                   child: fl.ColorWheelPicker(
    //                                     color: documentPropertiesList[ind]
    //                                         .pageColor,
    //                                     onChanged: (c) {
    //                                       setState(() {
    //                                         documentPropertiesList[ind]
    //                                             .pageColor = c;
    //                                       });
    //                                     },
    //                                     onChangeEnd: (value) {
    //                                       _renderPagePreviewOnProperties();
    //                                     },
    //                                     onWheel: (bool value) {},
    //                                     wheelSquarePadding: 5,
    //                                     wheelWidth: 5,
    //                                     hasBorder: true,
    //                                     shouldUpdate: true,
    //                                   ),
    //                                 ),
    //                                 SizedBox(
    //                                   height: 0,
    //                                 ),
                    
    //                                 //Name of PAGE COLOR
    //                                 Text(
    //                                     fl.ColorTools.nameThatColor(
    //                                       documentPropertiesList[ind]
    //                                           .pageColor,
    //                                     ),
    //                                     style: GoogleFonts.bungee(
    //                                         fontSize: 12)),
    //                               ],
    //                             ),
    //                           ),
    //                           //COLOR SWATCH FOR PAGE COLOR
                    
    //                           fl.ColorPicker(
    //                               color:
    //                                   documentPropertiesList[ind].pageColor,
    //                               pickersEnabled: const {
    //                                 fl.ColorPickerType.both: false,
    //                                 fl.ColorPickerType.primary: false,
    //                                 fl.ColorPickerType.accent: false,
    //                                 fl.ColorPickerType.bw: false,
    //                                 fl.ColorPickerType.custom: true,
    //                                 fl.ColorPickerType.wheel: false
    //                               },
    //                               enableTooltips: true,
    //                               showColorName: false,
    //                               //  ((sWidth *
    //                               //           wH2DividerPosition) -
    //                               //       145) >
    //                               //   66? true:false,
    //                               // showColorCode: true,
    //                               // enableOpacity: true,
    //                               customColorSwatchesAndNames: {
    //                                 createSwatch(
    //                                     documentPropertiesList[ind]
    //                                         .pageColor,
    //                                     12): ''
    //                               },
    //                               colorCodeHasColor: true,
    //                               enableShadesSelection: true,
    //                               colorCodeReadOnly: false,
    //                               height:
    //                                   ((sWidth * wH2DividerPosition - 145) /
    //                                           3)
    //                                       .clamp(15, 30),
    //                               width:
    //                                   ((sWidth * wH2DividerPosition - 145) /
    //                                           4)
    //                                       .clamp(15, 30),
    //                               runSpacing: 2,
    //                               shadesSpacing: 0,
    //                               spacing: 1,
    //                               borderRadius: 5,
    //                               hasBorder: false,
    //                               borderColor: ui.Color(0xFFD9D9D9),
    //                               colorNameTextStyle:
    //                                   GoogleFonts.bungee(fontSize: 10),
    //                               colorCodeTextStyle:
    //                                   GoogleFonts.bungee(fontSize: 8),
    //                               colorCodePrefixStyle:
    //                                   GoogleFonts.bungee(fontSize: 8),
    //                               columnSpacing: 5,
    //                               crossAxisAlignment:
    //                                   CrossAxisAlignment.start,
    //                               toolbarSpacing: 0,
    //                               selectedColorIcon: TablerIcons.circle,
    //                               editIcon: TablerIcons.circle,
    //                               padding:
    //                                   EdgeInsets.only(right: 115, top: 10),
    //                               wheelWidth: 5,
    //                               wheelSquarePadding: 8,
    //                               wheelDiameter: 120,
    //                               wheelSquareBorderRadius: 8,
    //                               opacityThumbRadius: 12,
    //                               opacityTrackHeight: 12,
    //                               wheelHasBorder: true,
    //                               onColorChangeEnd: (value) {
    //                                 _renderPagePreviewOnProperties();
    //                               },
    //                               onColorChanged: (c) {
    //                                 setState(() {
    //                                   documentPropertiesList[ind]
    //                                       .pageColor = c;
    //                                 });
                    
    //                                 // _renderPagePreviewOnProperties();
    //                               }),
    //                         ],
    //                       ),
                    
    //                       const SizedBox(
    //                         height: 30,
    //                       )
    //                     ],
    //                   ),
    //                 ),
    //               ),
    //             ),
    //           ),
    //         ),
    //       ),
    //                     ],
    //                   );
    //                 },
    //       ),
    //     ), 
    //   ],
    // );
