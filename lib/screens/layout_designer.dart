// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'package:billblaze/components/tab_container/tab_controller.dart';
import 'package:billblaze/util/HexColorInputFormatter.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart'
    show ColorPicker, MaterialPicker;
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:billblaze/colors.dart';
import 'package:billblaze/components/printing.dart'
    if (dart.library.html) 'package:printing/printing.dart';
import 'package:billblaze/components/simple_grid/simple_grid.dart';
import 'package:billblaze/components/simple_grid/sp_order.dart';
// import 'package:printing/printing.dart';
import 'package:billblaze/components/spread_sheet.dart';
import 'package:billblaze/components/spread_sheet_lib/sheet_list.dart';
import 'package:billblaze/components/spread_sheet_lib/text_editor_item.dart';
import 'package:billblaze/models/DocumentPropertiesModel.dart';
import 'package:billblaze/screens/deprecate.dart';
import 'package:billblaze/util/numeric_input_filter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/extensions.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:standard_markdown/standard_markdown.dart';
import 'package:text_style_editor/text_style_editor.dart';
// import 'package:reorderable_staggered_scroll_view/reorderable_staggered_scroll_view.dart';
// import 'package:pdf/widgets.dart';
// import 'package:simple_animated_button/simple_animated_button.dart';
import 'dart:math' as math;

import 'package:uuid/uuid.dart';

import '../components/elevated_button.dart';

class SelectedIndex {
  // int pageIndex;
  String id;
  List<int> selectedIndexes;
  SelectedIndex({
    // required this.pageIndex,
    required this.id,
    required this.selectedIndexes,
  });
  SelectedIndex copyWith({
    String? id,
    List<int>? selectedIndexes,
  }) {
    return SelectedIndex(
      id: id ?? this.id,
      selectedIndexes: selectedIndexes ?? this.selectedIndexes,
    );
  }
}

//
//
//
//
//
//
//

//
//
//
//
//
//
//
//
//
//
class LayoutDesigner3 extends StatefulWidget {
  const LayoutDesigner3({super.key});

  @override
  State<LayoutDesigner3> createState() => _LayoutDesigner3State();
}

class _LayoutDesigner3State extends State<LayoutDesigner3>
    with SingleTickerProviderStateMixin {
  double hDividerPosition = 0.5;
  double vDividerPosition = 0.5;
  double appbarHeight = 0.065;
  DateTime dateTimeNow = DateTime.now();
  int pageCount = 0;
  int currentPageIndex = 0;
  bool isReordering = false;
  pw.Document? _pdfDocument;
  List<DocumentProperties2> documentPropertiesList = [];
  List<SelectedIndex> selectedIndex = [];
  PanelIndex panelIndex = PanelIndex(id: '', panelIndex: -1);
  PageController pagePropertiesViewController = PageController();
  PageController pageViewIndicatorController = PageController();
  PageController pageTextFieldsController = PageController();
  ScrollController pdfScrollController = ScrollController();
  List<SheetList> spreadSheetList = [];
  double textFieldHeight = 40;
  double presuConstraintsMinW = 20;
  FocusNode marginAllFocus = FocusNode();
  FocusNode marginTopFocus = FocusNode();
  FocusNode marginBottomFocus = FocusNode();
  FocusNode marginLeftFocus = FocusNode();
  FocusNode marginRightFocus = FocusNode();
  bool pickColor = false;
  TextEditingController mdCunt = TextEditingController();
  late TabController tabcunt;
  List<String> fonts = [
    'Billabong',
    'AlexBrush',
    'Allura',
    'Arizonia',
    'ChunkFive',
    'GrandHotel',
    'GreatVibes',
    'Lobster',
    'OpenSans',
    'OstrichSans',
    'Oswald',
    'Pacifico',
    'Quicksand',
    'Roboto',
    'SEASRN',
    'Windsong',
  ];
  List<Color> paletteColors = [
    Colors.black,
    Colors.white,
    Color(int.parse('0xffEA2027')),
    Color(int.parse('0xff006266')),
    Color(int.parse('0xff1B1464')),
    Color(int.parse('0xff5758BB')),
    Color(int.parse('0xff6F1E51')),
    Color(int.parse('0xffB53471')),
    Color(int.parse('0xffEE5A24')),
    Color(int.parse('0xff009432')),
    Color(int.parse('0xff0652DD')),
    Color(int.parse('0xff9980FA')),
    Color(int.parse('0xff833471')),
    Color(int.parse('0xff112CBC4')),
    Color(int.parse('0xffFDA7DF')),
    Color(int.parse('0xffED4C67')),
    Color(int.parse('0xffF79F1F')),
    Color(int.parse('0xffA3CB38')),
    Color(int.parse('0xff1289A7')),
    Color(int.parse('0xffD980FA'))
  ];
  TextStyle textStyle = TextStyle(
    fontSize: 15,
    color: Colors.white,
    fontFamily: 'OpenSans',
  );
  TextAlign textAlign = TextAlign.left;
  //
  //
  //
  //
  @override
  void initState() {
    super.initState();
    // animateToPage(currentPageIndex);
    _addPdfPage();
    _updatePdfPreview('');
    tabcunt = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    pagePropertiesViewController.dispose();
    pageViewIndicatorController.dispose();
    super.dispose();
  }

  // initializeDocNSheets() {

  // }

  void _addTextField({String id = ''}) {
    var textController = QuillController.basic();
    var index = spreadSheetList[currentPageIndex].length;

    setState(() {
      if (id == '') {
        String newId = Uuid().v4();
        id = newId;
        var textEditorConfigurations = QuillEditorConfigurations(
          padding: EdgeInsets.all(2),
          controller: textController,
          placeholder: 'Enter Text',
          // onTapOutside: (event, focusNode) {
          //   focusNode.unfocus();
          // },
          // expands: true,
          builder: (context, rawEditor) {
            return Container(
                // duration: Durations.short4,
                // height: !expand ? null : 40,
                padding:
                    EdgeInsets.only(top: 4, bottom: 8, left: 20, right: 20),
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: defaultPalette.primary,
                    border: Border.all(width: 2),
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(bottom: 4),
                      child: Text(
                        'id : $id',
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ),
                    Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: defaultPalette.black.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10)),
                        child: rawEditor),
                  ],
                ));
          },
          onTapDown: (details, p1) {
            setState(() {
              panelIndex = PanelIndex(id: newId, panelIndex: index);
              if (hDividerPosition > 0.48) {
                hDividerPosition = 0.4;
              }
            });
            print('clicked');

            print(panelIndex);
            return false;
          },
        );
        spreadSheetList[currentPageIndex].add(TextEditorItem(
          textEditorController: textController,
          textEditorConfigurations: textEditorConfigurations,
          id: newId,
          parentId: spreadSheetList[currentPageIndex].id,
          // initialValue: 'Enter Text.'
        ));
        return;
      } else {
        String newId = Uuid().v4();
        SheetList resultList =
            _sheetListIterator(id, spreadSheetList[currentPageIndex]);
        resultList.add(TextEditorItem(
            id: newId, parentId: spreadSheetList[currentPageIndex].id));
      }
    });
  }

  SheetList _sheetListIterator(String id, SheetList sheetList) {
    for (var i = 0; i < sheetList.length; i++) {
      if (sheetList[i].id == id) {
        return sheetList[i] as SheetList;
      }
      if (sheetList[i] is SheetList) {
        try {
          return _sheetListIterator(id, sheetList[i] as SheetList);
        } catch (e) {
          // Continue searching in the remaining items
        }
      }
    }
    throw Exception('SheetList with id $id not found');
  }

  SheetItem _sheetItemIterator(String id, SheetList sheetList) {
    for (var i = 0; i < sheetList.length; i++) {
      if (sheetList[i] is TextEditorItem && sheetList[i].id == id) {
        return sheetList[i];
      }
      if (sheetList[i] is SheetList) {
        try {
          return _sheetItemIterator(id, sheetList[i] as SheetList);
        } catch (e) {
          // Continue searching in the remaining items
        }
      }
    }
    throw Exception('SheetItem with id $id not found');
  }

  void _updatehDividerPosition(double newPosition) {
    setState(() {
      hDividerPosition = newPosition;
    });
  }

  void _updatevDividerPosition(double newPosition) {
    setState(() {
      vDividerPosition = newPosition;
    });
  }

  void _selectTextField(int index) {
    setState(() {
      // selectedIndex[currentPageIndex] = index;/
    });
  }

  void _deselectTextField() {
    // setState(() {
    //   if (selectedIndex != []) {
    //     selectedIndex[currentPageIndex] = 9999999;
    //   }
    // });
  }

  void _confirmDeleteLayout({bool deletePage = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('This will delete the current layout. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('No'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                // documentPropertiesList[currentPageIndex]
                //     .textFieldControllers
                //     .clear();
                _deselectTextField();

                if (deletePage) {
                  pageCount--;
                  documentPropertiesList.removeAt(currentPageIndex);
                  spreadSheetList.removeAt(currentPageIndex);
                  currentPageIndex--;
                  panelIndex = PanelIndex(
                      id: spreadSheetList[currentPageIndex].id, panelIndex: -1);
                  return;
                }
                spreadSheetList[currentPageIndex].sheetList = [];
                panelIndex = PanelIndex(id: panelIndex.id, panelIndex: -1);
              });
              Navigator.of(context).pop();
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _duplicateTextField() {
    // print(selectedIndex[currentPageIndex]);
  }

  void _removeTextField() {}

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    for (int i = 0; i < pageCount; i++) {
      var doc = documentPropertiesList[i];
      var sheetList = spreadSheetList[i];
      pdf.addPage(
        pw.MultiPage(
          margin: pw.EdgeInsets.only(
            top: double.parse(doc.marginTopController.text),
            bottom: double.parse(doc.marginBottomController.text),
            left: double.parse(doc.marginLeftController.text),
            right: double.parse(doc.marginRightController.text),
          ),
          orientation: doc.orientationController,
          pageFormat: doc.pageFormatController,
          build: (pw.Context context) {
            return [
              pw.ListView.builder(
                itemBuilder: (pw.Context context, int index) {
                  final item = sheetList.sheetList[index];
                  if (item is TextEditorItem) {
                    final delta = item.getTextEditorDocumentAsDelta();
                    return convertDeltaToPdfWidget(delta);
                  } else if (item is SheetList) {
                    // Recursively handle nested SheetList items if needed
                    return _buildSheetListPdf(item);
                  }
                  return pw.Container();
                },
                itemCount: sheetList.sheetList.length,
              ),
            ];
          },
        ),
      );
    }

    return pdf.save();
  }

  pw.Widget _buildSheetListPdf(SheetList sheetList) {
    print('________buildSheetListPdf STARTED LD_________');
    return pw.ListView.builder(
      itemBuilder: (pw.Context context, int index) {
        final item = sheetList[index];
        if (item is TextEditorItem) {
          print('textitem');
          final delta = item.getTextEditorDocumentAsDelta();
          return convertDeltaToPdfWidget(delta);
        } else if (item is SheetList) {
          // Recursively handle nested SheetList items if needed
          print('listitem');
          return _buildSheetListPdf(item);
        }
        return pw.Container();
      },
      itemCount: sheetList.sheetList.length,
    );
  }

  pw.Widget convertDeltaToPdfWidget(Delta delta) {
    print('________convertDELTA STARTED LD_________');
    PdfColor pdfColorFromHex(String hexColor) {
      final buffer = StringBuffer();
      if (hexColor.length == 6 || hexColor.length == 7) buffer.write('ff');
      buffer.write(hexColor.replaceFirst('#', ''));
      final color = int.parse(buffer.toString(), radix: 16);
      return PdfColor.fromInt(color);
    }

    pw.Widget buildCheckbox(bool checked) {
      return pw.Container(
        width: 15,
        height: 15,
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.black),
        ),
        child: pw.Container(
          width: 13,
          height: 13,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(
              color: PdfColors.black,
              width: 1.5,
            ),
            color: checked ? PdfColors.amber : pdfColorFromHex('#00FFFFFF'),
          ),
          child: checked
              ? pw.Center(
                  child: pw.Text(
                    'X',
                    style: pw.TextStyle(
                      color: PdfColors.black,
                      fontSize: 13 - 4,
                    ),
                  ),
                )
              : null,
        ),
      );
    }

    final List<pw.InlineSpan> textSpans = [];
    pw.Widget checkbox = pw.Container();
    pw.TextAlign textAlign = pw.TextAlign.left;
    pw.TextDirection alignment = pw.TextDirection.ltr;
    for (var op in delta.toList()) {
      if (op.value is String) {
        var text = op.value.toString();
        Map<String, dynamic>? attributes = op.attributes;
        pw.EdgeInsets? padding;
        pw.TextStyle textStyle = pw.TextStyle();
        PdfColor? backgroundColor;
        if (attributes != null) {
          if (attributes.containsKey('bold')) {
            textStyle = textStyle.copyWith(fontWeight: pw.FontWeight.bold);
          }
          if (attributes.containsKey('italic')) {
            textStyle = textStyle.copyWith(fontStyle: pw.FontStyle.italic);
          }
          if (attributes.containsKey('underline')) {
            textStyle =
                textStyle.copyWith(decoration: pw.TextDecoration.underline);
          }
          if (attributes.containsKey('strike')) {
            textStyle =
                textStyle.copyWith(decoration: pw.TextDecoration.lineThrough);
          }
          if (attributes.containsKey('code')) {
            // Use a monospace font for inline cod
            // print('sdbfvihierlgvberiugvbjbnveaiefikfnmewiugbr5bgrjgintgmripg');
            textStyle = textStyle.copyWith(
              font: pw.Font.courier(),
              color: pdfColorFromHex('#FF000000'),
              background: pw.BoxDecoration(
                  color: pdfColorFromHex('#FFFFFFFF'),
                  border: pw.Border.all(
                      color: pdfColorFromHex('#FFFFFFFF'), width: 4)),
            );
          }

          if (attributes.containsKey('color')) {
            textStyle =
                textStyle.copyWith(color: pdfColorFromHex(attributes['color']));
          }
          if (attributes.containsKey('background')) {
            backgroundColor = pdfColorFromHex(attributes['background']);
            textStyle = textStyle.copyWith(
                background: pw.BoxDecoration(color: backgroundColor));
          }
          if (attributes.containsKey('size')) {
            double fontSize = double.parse(attributes['size'].toString());
            textStyle = textStyle.copyWith(fontSize: fontSize);
          }
          if (attributes.containsKey('header')) {
            int level = attributes['header'];
            switch (level) {
              case 1:
                textStyle = textStyle.copyWith(
                    fontSize: 24, fontWeight: pw.FontWeight.bold);
                break;
              case 2:
                textStyle = textStyle.copyWith(
                    fontSize: 20, fontWeight: pw.FontWeight.bold);
                break;
              case 3:
                textStyle = textStyle.copyWith(
                    fontSize: 18, fontWeight: pw.FontWeight.bold);
                break;
              default:
                textStyle = textStyle.copyWith(
                    fontSize: 16, fontWeight: pw.FontWeight.bold);
            }
          }
          if (attributes.containsKey('indent')) {
            int level = attributes['indent'];
            padding = pw.EdgeInsets.only(left: 20.0 * level);
          }
          if (attributes.containsKey('align')) {
            switch (attributes['align']) {
              case 'center':
                textAlign = pw.TextAlign.center;
                break;
              case 'right':
                textAlign = pw.TextAlign.right;
                break;
              case 'justify':
                textAlign = pw.TextAlign.justify;
                break;
              default:
                textAlign = pw.TextAlign.left;
            }
          }

          if (attributes.containsKey('code-block')) {
            textStyle = textStyle.copyWith(
              font: pw.Font.courier(),
              color: pdfColorFromHex('#FF000000'),
              background: pw.BoxDecoration(color: pdfColorFromHex('#FFEEEEEE')),
            );
          }
          if (attributes.containsKey('blockquote')) {
            textStyle = textStyle.copyWith(
              fontStyle: pw.FontStyle.italic,
              background: pw.BoxDecoration(color: pdfColorFromHex('#FFEFEFEF')),
            );
          }
          if (attributes.containsKey('direction')) {
            if (attributes['direction'] == 'rtl') {
              alignment = pw.TextDirection.rtl;
            } else {
              alignment = pw.TextDirection.ltr;
            }
          }

          if (attributes.containsKey('link')) {
            final link = attributes['link'];
            textSpans.add(
              pw.TextSpan(
                text: text,
                style: textStyle.copyWith(
                  color: PdfColors.blue,
                  decoration: pw.TextDecoration.underline,
                ),
                annotation: pw.AnnotationUrl(link),
              ),
            );
            continue;
          }
          if (attributes.containsKey('list')) {
            String listType = attributes['list'];
            // checkbox = pw.Checkbox(name: 'yes', value: false);
            switch (listType) {
              case 'checked':
                // if (text == '') {
                //   // text = 'no ';
                //   break;
                // }
                // if (text == null) {
                //   // text = 'no ';
                //   checkbox = null;
                //   break;
                // }
                // Unicode character for checked box
                // text = '\n${text.replaceAll('\n', 'yo  ')}';
                checkbox = buildCheckbox(true);
                break;
              case 'unchecked':
                // if (text == null) {
                //   // text = 'no ';
                //   checkbox = null;
                //   break;
                // }

                checkbox =
                    buildCheckbox(false); // Unicode character for unchecked box
                break;
            }
          } else {
            checkbox = pw.Container();
          }
        }
        print('count');
        // textSpans.add(pw.WidgetSpan(
        //   child: pw.Row(children: [
        //     checkbox,
        //     pw.SizedBox(width: 5),
        //     pw.SizedBox(
        //       width: double.maxFinite,
        //       child: pw.Text(
        //         text.toString().replaceAll('\n', ''),
        //         style: textStyle,
        //       ),
        //     ),
        //   ]),
        // ));
        textSpans.addAll([
          pw.TextSpan(text: '\n'),
          pw.WidgetSpan(child: checkbox),
          // pw.TextSpan(text: '${text.replaceAll('\n', '')}', style: textStyle)
        ]);
        textSpans.add(pw.TextSpan(
            text: '${text.replaceAll('\n', '')}', style: textStyle));
      }
    }

    print('________END convertDELTA LD_________');
    return
        // pw.Row(children: [
        //   if (checkbox != null) ...[checkbox, pw.SizedBox(width: 5)],
        pw.RichText(
      text: pw.TextSpan(
        children: textSpans,
      ),
      textAlign: textAlign,
      textDirection: alignment,
    );
    // ]);
  }

  void _updatePdfPreview(String text) {
    setState(() {
      _pdfDocument = pw.Document();

      _pdfDocument!.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Text(text),
            );
          },
        ),
      );
    });
  }

  void _addPdfPage() {
    setState(() {
      print('pageCount in addpage: $pageCount');
      documentPropertiesList.add(
        DocumentProperties2(
          pageNumberController:
              TextEditingController(text: (++pageCount).toString()),
          marginAllController: TextEditingController(text: '10'),
          marginLeftController: TextEditingController(text: '10'),
          marginRightController: TextEditingController(text: '10'),
          marginBottomController: TextEditingController(text: '10'),
          marginTopController: TextEditingController(text: '10'),
          orientationController: pw.PageOrientation.portrait,
          pageFormatController: PdfPageFormat.a4,
        ),
      );
      var id = Uuid().v4();
      spreadSheetList.add(SheetList(id: id, parentId: parentId, sheetList: []));
      print('pageCount in addpage after: $pageCount');
      selectedIndex.add(SelectedIndex(id: id, selectedIndexes: []));
      print('id : $id');
      print(selectedIndex);
      // pageCount++;
    });
  }

  void animateToPage(int page) {
    var duration = Duration(milliseconds: 300);
    var curve = Curves.easeIn;
    pageViewIndicatorController.animateToPage(page,
        duration: duration, curve: curve);
  }

  @override
  Widget build(BuildContext context) {
    print('________BUILD LAYOUT STARTED LD_________');
    double sHeight = MediaQuery.of(context).size.height;
    double sWidth = MediaQuery.of(context).size.width;
    Duration sideBarPosDuration = Duration(milliseconds: 300);
    Duration defaultDuration = Duration(milliseconds: 300);
    double topPadPosDistance = sHeight / 10;
    double leftPadPosDistance = sWidth / 15;
    double titleFontSize = sHeight / 11;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          color: defaultPalette.white,
          child: Stack(
            children: [
              Container(
                height: sHeight,
                width: sWidth,
                color: Colors.transparent,
              ),
              AnimatedPositioned(
                duration: Duration(milliseconds: 300),
                child: Column(
                  children: [
                    Expanded(
                      flex: (appbarHeight * 10000).round(),
                      child: Container(
                        height: sHeight * 0.1,
                      ),
                    ),
                    Expanded(
                      flex: (hDividerPosition * 10000).round(),
                      child: Stack(
                        children: [
                          //Graph
                          IgnorePointer(
                            ignoring: true,
                            child: AnimatedContainer(
                              duration: Durations.extralong1,
                              height: sHeight,
                              width: sWidth,
                              alignment: Alignment.centerRight,
                              color: Colors.black.withOpacity(0.06),
                              padding: EdgeInsets.only(
                                top: 0,
                              ),
                              //layGraph
                              child: LineChart(LineChartData(
                                  lineBarsData: [LineChartBarData()],
                                  titlesData: FlTitlesData(show: false),
                                  gridData: FlGridData(
                                      show: true,
                                      horizontalInterval: 10,
                                      verticalInterval: 30),
                                  borderData: FlBorderData(show: false),
                                  minY: 0,
                                  maxY: 50,
                                  maxX: dateTimeNow.millisecondsSinceEpoch
                                              .ceilToDouble() /
                                          500 +
                                      250,
                                  minX: dateTimeNow.millisecondsSinceEpoch
                                          .ceilToDouble() /
                                      500)),
                            ),
                          ),

                          AnimatedPositioned(
                            duration: Duration(milliseconds: 300),
                            // left: panelIndex.panelIndex == -1
                            //     ? (sWidth * vDividerPosition)
                            //     : 0,
                            child: Row(
                              children: [
                                /////////////////////LEFT
                                Expanded(
                                    flex: (vDividerPosition * 10000).toInt(),
                                    child: SafeArea(
                                      child: Stack(
                                        children: [
                                          Container(
                                            height: sHeight * hDividerPosition,
                                            color: Colors.transparent,
                                          ),

                                          ///LEFT TITLE PAGE PROPS
                                          AnimatedPositioned(
                                            duration: Durations.short4,
                                            top: 0,
                                            left: panelIndex.panelIndex != -1
                                                ? -sWidth * vDividerPosition
                                                : 0,
                                            height:
                                                (sHeight) * (hDividerPosition),
                                            width: sWidth * vDividerPosition,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child:

                                                  ///LEFT TITLE PAGE PROPS
                                                  Material(
                                                color:
                                                    defaultPalette.transparent,
                                                child: SingleChildScrollView(
                                                  physics:
                                                      BouncingScrollPhysics(),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Stack(
                                                        children: [
                                                          Container(
                                                            height: 55,
                                                            width: sWidth *
                                                                vDividerPosition,
                                                          ),
                                                          //LeftScreen tilte
                                                          Container(
                                                            height: 55,
                                                            margin:
                                                                EdgeInsets.only(
                                                                    left: 10,
                                                                    top: 8,
                                                                    bottom: 5),
                                                            width: sWidth *
                                                                vDividerPosition *
                                                                0.4,
                                                            child: Text(
                                                                'Page Properties',
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .fade,
                                                                style: TextStyle(
                                                                    color: defaultPalette
                                                                        .black,
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold)),
                                                          ),
                                                          //nextprev buittons
                                                          Positioned(
                                                            right: 0,
                                                            top: 12,
                                                            child: Container(
                                                              color:
                                                                  defaultPalette
                                                                      .tertiary,
                                                              margin: EdgeInsets
                                                                  .only(top: 5),
                                                              height: 30,
                                                              width: 50,
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceAround,
                                                                children: [
                                                                  GestureDetector(
                                                                    child: Icon(
                                                                      Icons
                                                                          .keyboard_arrow_left_sharp,
                                                                      color: defaultPalette
                                                                          .black,
                                                                    ),
                                                                    onTap: () {
                                                                      setState(
                                                                          () {
                                                                        print(
                                                                            '________PREV PAGE STARTED LD_________');
                                                                        if (currentPageIndex ==
                                                                            0) {
                                                                          pdfScrollController.animateTo(
                                                                              currentPageIndex * ((1.41428571429 * ((sWidth * (1 - vDividerPosition)))) + 16),
                                                                              duration: Duration(milliseconds: 100),
                                                                              curve: Curves.easeIn);
                                                                          return;
                                                                        }
                                                                        currentPageIndex--;

                                                                        pdfScrollController.animateTo(
                                                                            currentPageIndex *
                                                                                ((1.41428571429 * ((sWidth * (1 - vDividerPosition)))) + 16),
                                                                            duration: Duration(milliseconds: 100),
                                                                            curve: Curves.easeIn);
                                                                      });
                                                                      print(
                                                                          '________END PREV PAGE LD_________');
                                                                    },
                                                                  ),
                                                                  GestureDetector(
                                                                    child: Icon(
                                                                      Icons
                                                                          .keyboard_arrow_right_sharp,
                                                                      color: defaultPalette
                                                                          .black,
                                                                    ),
                                                                    onTap: () {
                                                                      setState(
                                                                          () {
                                                                        print(
                                                                            '________NEXT PAGE STARTED LD_________');
                                                                        if (pageCount ==
                                                                            (currentPageIndex +
                                                                                1)) {
                                                                          _addPdfPage();

                                                                          currentPageIndex++;
                                                                          pdfScrollController.animateTo(
                                                                              currentPageIndex * ((1.41428571429 * ((sWidth * (1 - vDividerPosition)) - 6)) + 6),
                                                                              duration: Duration(milliseconds: 100),
                                                                              curve: Curves.easeIn);

                                                                          print(
                                                                              '________END NEXT PAGE LD_________');
                                                                          return;
                                                                        }

                                                                        currentPageIndex++;

                                                                        pdfScrollController.animateTo(
                                                                            currentPageIndex *
                                                                                ((1.41428571429 * ((sWidth * (1 - vDividerPosition)) - 6)) + 6),
                                                                            duration: Duration(milliseconds: 100),
                                                                            curve: Curves.easeIn);
                                                                        // ref.read(panelIndexProvider.notifier).state = PanelIndex(
                                                                        //     id: ref
                                                                        //         .read(sheetListProviderFamily(ref.read(spreadSheetProvider.select((p) => p[ref.read(currentPageIndexProvider)]
                                                                        //             .id))))
                                                                        //         .id,
                                                                        //     panelIndex:
                                                                        //         0);
                                                                        print(
                                                                            '________END NEXT PAGE LD_________');
                                                                      });
                                                                    },
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      //pageNumber textfiwld
                                                      SizedBox(
                                                        height: textFieldHeight,
                                                        width: sWidth *
                                                            vDividerPosition,

                                                        ///Stack For Delete
                                                        child: Stack(
                                                          children: [
                                                            ///PAGE COUNT TEXT
                                                            TextFormField(
                                                              cursorColor:
                                                                  defaultPalette
                                                                      .tertiary,
                                                              controller: documentPropertiesList[
                                                                      currentPageIndex]
                                                                  .pageNumberController,
                                                              inputFormatters: [
                                                                FilteringTextInputFormatter
                                                                    .allow(RegExp(
                                                                        r'^\d*\.?\d*$'))
                                                              ],
                                                              textAlignVertical:
                                                                  TextAlignVertical
                                                                      .top,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              decoration:
                                                                  InputDecoration(
                                                                suffixIcon: //Delete page
                                                                    GestureDetector(
                                                                  onTap: () {},
                                                                  child: Icon(
                                                                    Icons
                                                                        .delete_outline_rounded,
                                                                    color: defaultPalette
                                                                        .transparent,
                                                                  ),
                                                                ),
                                                                labelText:
                                                                    'Page Number',
                                                                labelStyle:
                                                                    TextStyle(
                                                                  color:
                                                                      defaultPalette
                                                                          .black,
                                                                  fontSize: 15,
                                                                ),
                                                                floatingLabelAlignment:
                                                                    FloatingLabelAlignment
                                                                        .start,
                                                                filled: true,
                                                                fillColor:
                                                                    defaultPalette
                                                                        .primary,
                                                                border:
                                                                    OutlineInputBorder(
                                                                  // borderSide: BorderSide(width: 5, color: defaultPalette.black),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10.0), // Replace with your desired radius
                                                                ),
                                                                enabledBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          width:
                                                                              2,
                                                                          color:
                                                                              defaultPalette.black),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              12.0), // Same as border
                                                                ),
                                                                disabledBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          width:
                                                                              2,
                                                                          color:
                                                                              defaultPalette.black),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              12.0), // Same as border
                                                                ),
                                                                focusedBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          width:
                                                                              3,
                                                                          color:
                                                                              defaultPalette.tertiary),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10.0), // Same as border
                                                                ),
                                                              ),
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              style: TextStyle(
                                                                  color:
                                                                      defaultPalette
                                                                          .black,
                                                                  fontSize: 15),
                                                              enabled: false,
                                                              // onChanged:
                                                              //     (value) {
                                                              //   _updatePdfPreview;
                                                              //   _addPdfPage();
                                                              // }
                                                            ),
                                                            //DELETE ICON
                                                            Positioned(
                                                              right: 15 / 2,
                                                              top:
                                                                  (textFieldHeight /
                                                                          2) -
                                                                      25 / 2,
                                                              child:
                                                                  GestureDetector(
                                                                onTap: () {
                                                                  _confirmDeleteLayout(
                                                                      deletePage:
                                                                          true);
                                                                  pdfScrollController.animateTo(
                                                                      currentPageIndex *
                                                                          ((1.41428571429 * ((sWidth * (1 - vDividerPosition)))) +
                                                                              16),
                                                                      duration: Duration(
                                                                          milliseconds:
                                                                              100),
                                                                      curve: Curves
                                                                          .easeIn);
                                                                },
                                                                child: Icon(
                                                                  Icons
                                                                      .delete_outline_rounded,
                                                                  color:
                                                                      defaultPalette
                                                                          .black,
                                                                  size: 25,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),

                                                      //LEFT SIDE MARGIN , ORIENTATION, FORMAT
                                                      Column(
                                                        children: [
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child: SizedBox(
                                                                  height:
                                                                      textFieldHeight,
                                                                  child: // TO STACK THE INCREMENT BUTTONS
                                                                      Stack(
                                                                    children: [
                                                                      //MARGIN ALL TEXT
                                                                      TextFormField(
                                                                        onTapOutside:
                                                                            (event) {
                                                                          marginAllFocus
                                                                              .unfocus();
                                                                        },
                                                                        obscureText:
                                                                            documentPropertiesList[currentPageIndex].useIndividualMargins,
                                                                        focusNode:
                                                                            marginAllFocus,
                                                                        controller:
                                                                            documentPropertiesList[currentPageIndex].marginAllController,
                                                                        inputFormatters: [
                                                                          NumericInputFormatter(
                                                                              maxValue: documentPropertiesList[currentPageIndex].pageFormatController.width / 2.001)
                                                                        ],
                                                                        textAlignVertical:
                                                                            TextAlignVertical.top,
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          // alignLabelWithHint:
                                                                          //     true,
                                                                          contentPadding:
                                                                              EdgeInsets.all(0),
                                                                          floatingLabelAlignment:
                                                                              FloatingLabelAlignment.center,
                                                                          labelText:
                                                                              'Margin',
                                                                          labelStyle:
                                                                              GoogleFonts.lexend(color: defaultPalette.black),
                                                                          filled:
                                                                              true,
                                                                          fillColor: !documentPropertiesList[currentPageIndex].useIndividualMargins
                                                                              ? defaultPalette.primary
                                                                              : defaultPalette.primary.withOpacity(0.5),
                                                                          border:
                                                                              OutlineInputBorder(
                                                                            // borderSide: BorderSide(width: 5, color: defaultPalette.black),
                                                                            borderRadius:
                                                                                BorderRadius.circular(10.0), // Replace with your desired radius
                                                                          ),
                                                                          enabledBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(width: 2, color: defaultPalette.black),
                                                                            borderRadius:
                                                                                BorderRadius.circular(12.0), // Same as border
                                                                          ),
                                                                          focusedBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(width: 3, color: defaultPalette.tertiary),
                                                                            borderRadius:
                                                                                BorderRadius.circular(10.0), // Same as border
                                                                          ),
                                                                        ),
                                                                        keyboardType:
                                                                            TextInputType.number,
                                                                        style: TextStyle(
                                                                            // fontStyle: FontStyle.italic,
                                                                            color: defaultPalette.black),
                                                                        onChanged:
                                                                            (value) {
                                                                          // setState(() {

                                                                          documentPropertiesList[currentPageIndex]
                                                                              .marginTopController
                                                                              .text = value;
                                                                          documentPropertiesList[currentPageIndex]
                                                                              .marginBottomController
                                                                              .text = value;
                                                                          documentPropertiesList[currentPageIndex]
                                                                              .marginLeftController
                                                                              .text = value;
                                                                          documentPropertiesList[currentPageIndex]
                                                                              .marginRightController
                                                                              .text = value;
                                                                          _updatePdfPreview(
                                                                              '');
                                                                          // });
                                                                        },
                                                                        enabled:
                                                                            !documentPropertiesList[currentPageIndex].useIndividualMargins,
                                                                      ),

                                                                      Positioned(
                                                                        top: (textFieldHeight /
                                                                                2) -
                                                                            15 /
                                                                                2,
                                                                        left: (textFieldHeight /
                                                                                2) -
                                                                            15 /
                                                                                2,
                                                                        child:
                                                                            GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            setState(() {
                                                                              var value = documentPropertiesList[currentPageIndex].marginAllController.text;
                                                                              documentPropertiesList[currentPageIndex].marginAllController.text = (double.parse(value) - 1).abs().toString();
                                                                              documentPropertiesList[currentPageIndex].marginTopController.text = documentPropertiesList[currentPageIndex].marginAllController.text;
                                                                              documentPropertiesList[currentPageIndex].marginBottomController.text = documentPropertiesList[currentPageIndex].marginAllController.text;
                                                                              documentPropertiesList[currentPageIndex].marginLeftController.text = documentPropertiesList[currentPageIndex].marginAllController.text;
                                                                              documentPropertiesList[currentPageIndex].marginRightController.text = documentPropertiesList[currentPageIndex].marginAllController.text;
                                                                            });
                                                                            _updatePdfPreview('');
                                                                          },
                                                                          child:
                                                                              Icon(
                                                                            IconsaxPlusLinear.arrow_left_1,
                                                                            size:
                                                                                15,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Positioned(
                                                                        top: (textFieldHeight /
                                                                                2) -
                                                                            15 /
                                                                                2,
                                                                        right: (textFieldHeight /
                                                                                2) -
                                                                            15 /
                                                                                2,
                                                                        child:
                                                                            GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            setState(() {
                                                                              documentPropertiesList[currentPageIndex].marginAllController.text = (double.parse(documentPropertiesList[currentPageIndex].marginAllController.text) + 1).toString();
                                                                              documentPropertiesList[currentPageIndex].marginTopController.text = documentPropertiesList[currentPageIndex].marginAllController.text;
                                                                              documentPropertiesList[currentPageIndex].marginBottomController.text = documentPropertiesList[currentPageIndex].marginAllController.text;
                                                                              documentPropertiesList[currentPageIndex].marginLeftController.text = documentPropertiesList[currentPageIndex].marginAllController.text;
                                                                              documentPropertiesList[currentPageIndex].marginRightController.text = documentPropertiesList[currentPageIndex].marginAllController.text;
                                                                            });

                                                                            _updatePdfPreview('');
                                                                          },
                                                                          child:
                                                                              Icon(
                                                                            IconsaxPlusLinear.arrow_right_3,
                                                                            size:
                                                                                15,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              ////INDIVIDUAL MARGINS BUTTON
                                                              IconButton(
                                                                  onPressed:
                                                                      () {
                                                                    setState(
                                                                        () {
                                                                      documentPropertiesList[
                                                                              currentPageIndex]
                                                                          .useIndividualMargins = !documentPropertiesList[
                                                                              currentPageIndex]
                                                                          .useIndividualMargins;
                                                                      if (documentPropertiesList[currentPageIndex]
                                                                              .useIndividualMargins ==
                                                                          false) {
                                                                        documentPropertiesList[currentPageIndex]
                                                                            .marginTopController
                                                                            .text = documentPropertiesList[
                                                                                currentPageIndex]
                                                                            .marginAllController
                                                                            .text;
                                                                        documentPropertiesList[currentPageIndex]
                                                                            .marginBottomController
                                                                            .text = documentPropertiesList[
                                                                                currentPageIndex]
                                                                            .marginAllController
                                                                            .text;
                                                                        documentPropertiesList[currentPageIndex]
                                                                            .marginLeftController
                                                                            .text = documentPropertiesList[
                                                                                currentPageIndex]
                                                                            .marginAllController
                                                                            .text;
                                                                        documentPropertiesList[currentPageIndex]
                                                                            .marginRightController
                                                                            .text = documentPropertiesList[
                                                                                currentPageIndex]
                                                                            .marginAllController
                                                                            .text;
                                                                      }
                                                                    });
                                                                  },
                                                                  icon: documentPropertiesList[
                                                                              currentPageIndex]
                                                                          .useIndividualMargins
                                                                      ? Icon(
                                                                          IconsaxPlusBold
                                                                              .maximize_1,
                                                                          size:
                                                                              30,
                                                                        )
                                                                      : Icon(
                                                                          IconsaxPlusLinear
                                                                              .maximize_2,
                                                                          size:
                                                                              30,
                                                                        ))
                                                              // Text(
                                                              //     'Use Individual Margins'),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          if (documentPropertiesList[
                                                                  currentPageIndex]
                                                              .useIndividualMargins)
                                                            Column(
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    //TOP MARGIN
                                                                    Expanded(
                                                                      child:
                                                                          //TOP MARGIN TEXT
                                                                          SizedBox(
                                                                        height:
                                                                            textFieldHeight,
                                                                        child:
                                                                            Stack(
                                                                          children: [
                                                                            TextFormField(
                                                                              onTapOutside: (event) {
                                                                                marginTopFocus.unfocus();
                                                                              },
                                                                              focusNode: marginTopFocus,
                                                                              controller: documentPropertiesList[currentPageIndex].marginTopController,
                                                                              inputFormatters: [
                                                                                // FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                                                                                NumericInputFormatter(maxValue: (documentPropertiesList[currentPageIndex].pageFormatController.height / 1.11 - double.parse(documentPropertiesList[currentPageIndex].marginBottomController.text))),
                                                                              ],
                                                                              style: TextStyle(color: defaultPalette.black),
                                                                              cursorColor: defaultPalette.secondary,
                                                                              textAlign: TextAlign.center,
                                                                              textAlignVertical: TextAlignVertical.top,
                                                                              decoration: InputDecoration(
                                                                                contentPadding: EdgeInsets.all(0),
                                                                                labelText: 'Top',
                                                                                labelStyle: TextStyle(color: defaultPalette.black, fontSize: 20),
                                                                                floatingLabelAlignment: FloatingLabelAlignment.center,
                                                                                prefixIconConstraints: BoxConstraints(minWidth: presuConstraintsMinW),
                                                                                suffixIconConstraints: BoxConstraints(minWidth: presuConstraintsMinW),
                                                                                filled: true,
                                                                                fillColor: defaultPalette.primary,
                                                                                border: OutlineInputBorder(
                                                                                  // borderSide: BorderSide(width: 5, color: defaultPalette.black),
                                                                                  borderRadius: BorderRadius.circular(10.0), // Replace with your desired radius
                                                                                ),
                                                                                enabledBorder: OutlineInputBorder(
                                                                                  borderSide: BorderSide(width: 2, color: defaultPalette.black),
                                                                                  borderRadius: BorderRadius.circular(12.0), // Same as border
                                                                                ),
                                                                                focusedBorder: OutlineInputBorder(
                                                                                  borderSide: BorderSide(width: 3, color: defaultPalette.tertiary),
                                                                                  borderRadius: BorderRadius.circular(10.0), // Same as border
                                                                                ),
                                                                              ),
                                                                              keyboardType: TextInputType.number,
                                                                              onChanged: (value) => _updatePdfPreview(''),
                                                                            ),
                                                                            Positioned(
                                                                              top: (textFieldHeight / 2) - 15 / 2,
                                                                              left: 15 / 2,
                                                                              child: GestureDetector(
                                                                                onTap: () {
                                                                                  setState(() {
                                                                                    documentPropertiesList[currentPageIndex].marginTopController.text = (double.parse(documentPropertiesList[currentPageIndex].marginTopController.text) - 1).abs().toString();
                                                                                  });
                                                                                  _updatePdfPreview('');
                                                                                },
                                                                                child: Icon(
                                                                                  IconsaxPlusLinear.arrow_left_1,
                                                                                  size: 15,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Positioned(
                                                                              top: (textFieldHeight / 2) - 15 / 2,
                                                                              right: 15 / 2,
                                                                              child: GestureDetector(
                                                                                onTap: () {
                                                                                  setState(() {
                                                                                    documentPropertiesList[currentPageIndex].marginTopController.text = (double.parse(documentPropertiesList[currentPageIndex].marginTopController.text) + 1).toString();
                                                                                  });

                                                                                  _updatePdfPreview('');
                                                                                },
                                                                                child: Icon(
                                                                                  IconsaxPlusLinear.arrow_right_3,
                                                                                  size: 15,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    //BOTTOM MARGIN TEXT
                                                                    Expanded(
                                                                      child:
                                                                          SizedBox(
                                                                        height:
                                                                            textFieldHeight,
                                                                        child:
                                                                            //STACK FOR INCREDECRE
                                                                            Stack(
                                                                          children: [
                                                                            //BOTTOM TEXT FIELD
                                                                            TextFormField(
                                                                              onTapOutside: (event) {
                                                                                marginBottomFocus.unfocus();
                                                                              },
                                                                              focusNode: marginBottomFocus,
                                                                              controller: documentPropertiesList[currentPageIndex].marginBottomController,
                                                                              inputFormatters: [
                                                                                NumericInputFormatter(maxValue: documentPropertiesList[currentPageIndex].pageFormatController.height / 1.11 - double.parse(documentPropertiesList[currentPageIndex].marginTopController.text))
                                                                              ],
                                                                              style: TextStyle(color: defaultPalette.black),
                                                                              cursorColor: defaultPalette.secondary,
                                                                              textAlign: TextAlign.center,
                                                                              textAlignVertical: TextAlignVertical.top,

                                                                              ///INPUT DECORATION
                                                                              decoration: InputDecoration(
                                                                                contentPadding: EdgeInsets.all(0),
                                                                                labelText: 'Bottom',
                                                                                labelStyle: TextStyle(color: defaultPalette.black, fontSize: 20),
                                                                                floatingLabelAlignment: FloatingLabelAlignment.center,
                                                                                filled: true,
                                                                                fillColor: defaultPalette.primary,
                                                                                border: OutlineInputBorder(
                                                                                  // borderSide: BorderSide(width: 5, color: defaultPalette.black),
                                                                                  borderRadius: BorderRadius.circular(10.0), // Replace with your desired radius
                                                                                ),
                                                                                enabledBorder: OutlineInputBorder(
                                                                                  borderSide: BorderSide(width: 2, color: defaultPalette.black),
                                                                                  borderRadius: BorderRadius.circular(12.0), // Same as border
                                                                                ),
                                                                                focusedBorder: OutlineInputBorder(
                                                                                  borderSide: BorderSide(width: 3, color: defaultPalette.tertiary),
                                                                                  borderRadius: BorderRadius.circular(10.0), // Same as border
                                                                                ),
                                                                              ),
                                                                              keyboardType: TextInputType.number,
                                                                              onChanged: (value) => _updatePdfPreview(''),
                                                                            ),
                                                                            //BOTTOM DECREMENT
                                                                            Positioned(
                                                                              top: (textFieldHeight / 2) - 15 / 2,
                                                                              left: 15 / 2,
                                                                              child: GestureDetector(
                                                                                onTap: () {
                                                                                  setState(() {
                                                                                    documentPropertiesList[currentPageIndex].marginBottomController.text = (double.parse(documentPropertiesList[currentPageIndex].marginBottomController.text) - 1).abs().toString();
                                                                                  });
                                                                                  _updatePdfPreview('');
                                                                                },
                                                                                child: Icon(
                                                                                  IconsaxPlusLinear.arrow_left_1,
                                                                                  size: 15,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            //BOTTOM INCREMENT
                                                                            Positioned(
                                                                              top: (textFieldHeight / 2) - 15 / 2,
                                                                              right: 15 / 2,
                                                                              child: GestureDetector(
                                                                                onTap: () {
                                                                                  setState(() {
                                                                                    documentPropertiesList[currentPageIndex].marginBottomController.text = (double.parse(documentPropertiesList[currentPageIndex].marginBottomController.text) + 1).toString();
                                                                                  });

                                                                                  _updatePdfPreview('');
                                                                                },
                                                                                child: Icon(
                                                                                  IconsaxPlusLinear.arrow_right_3,
                                                                                  size: 15,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height: 15,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    //Left MARGIN WIDGET
                                                                    Expanded(
                                                                      child:
                                                                          SizedBox(
                                                                        height:
                                                                            textFieldHeight,
                                                                        child:
                                                                            Stack(
                                                                          children: [
                                                                            TextFormField(
                                                                              onTapOutside: (event) {
                                                                                marginLeftFocus.unfocus();
                                                                              },
                                                                              focusNode: marginLeftFocus,
                                                                              controller: documentPropertiesList[currentPageIndex].marginLeftController,
                                                                              inputFormatters: [
                                                                                NumericInputFormatter(maxValue: documentPropertiesList[currentPageIndex].pageFormatController.width / 1.11 - double.parse(documentPropertiesList[currentPageIndex].marginRightController.text))
                                                                              ],
                                                                              style: TextStyle(color: defaultPalette.black),
                                                                              cursorColor: defaultPalette.black,
                                                                              textAlign: TextAlign.center,
                                                                              textAlignVertical: TextAlignVertical.top,
                                                                              decoration: InputDecoration(
                                                                                contentPadding: EdgeInsets.all(0),
                                                                                labelText: 'Left',
                                                                                labelStyle: TextStyle(color: defaultPalette.black, fontSize: 20),
                                                                                floatingLabelAlignment: FloatingLabelAlignment.center,
                                                                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                                                                filled: true,
                                                                                fillColor: defaultPalette.primary,
                                                                                border: OutlineInputBorder(
                                                                                  // borderSide: BorderSide(width: 5, color: defaultPalette.black),
                                                                                  borderRadius: BorderRadius.circular(10.0), // Replace with your desired radius
                                                                                ),
                                                                                enabledBorder: OutlineInputBorder(
                                                                                  borderSide: BorderSide(width: 2, color: defaultPalette.black),
                                                                                  borderRadius: BorderRadius.circular(12.0), // Same as border
                                                                                ),
                                                                                focusedBorder: OutlineInputBorder(
                                                                                  borderSide: BorderSide(width: 3, color: defaultPalette.tertiary),
                                                                                  borderRadius: BorderRadius.circular(10.0), // Same as border
                                                                                ),
                                                                              ),
                                                                              keyboardType: TextInputType.number,
                                                                              onChanged: (value) => {
                                                                                _updatePdfPreview('')
                                                                              },
                                                                            ),
                                                                            Positioned(
                                                                              top: (textFieldHeight / 2) - 15 / 2,
                                                                              left: 15 / 2,
                                                                              child: GestureDetector(
                                                                                onTap: () {
                                                                                  setState(() {
                                                                                    documentPropertiesList[currentPageIndex].marginLeftController.text = (double.parse(documentPropertiesList[currentPageIndex].marginLeftController.text) - 1).abs().toString();
                                                                                  });
                                                                                  _updatePdfPreview('');
                                                                                },
                                                                                child: Icon(
                                                                                  IconsaxPlusLinear.arrow_left_1,
                                                                                  size: 15,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Positioned(
                                                                              top: (textFieldHeight / 2) - 15 / 2,
                                                                              right: 15 / 2,
                                                                              child: GestureDetector(
                                                                                onTap: () {
                                                                                  setState(() {
                                                                                    documentPropertiesList[currentPageIndex].marginLeftController.text = (double.parse(documentPropertiesList[currentPageIndex].marginLeftController.text) + 1).toString();
                                                                                  });

                                                                                  _updatePdfPreview('');
                                                                                },
                                                                                child: Icon(
                                                                                  IconsaxPlusLinear.arrow_right_3,
                                                                                  size: 15,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    //RIGHT MARGIN TEXT
                                                                    Expanded(
                                                                      child:
                                                                          SizedBox(
                                                                        height:
                                                                            textFieldHeight,
                                                                        child:
                                                                            Stack(
                                                                          children: [
                                                                            TextFormField(
                                                                              onTapOutside: (event) {
                                                                                marginRightFocus.unfocus();
                                                                              },
                                                                              focusNode: marginRightFocus,
                                                                              controller: documentPropertiesList[currentPageIndex].marginRightController,
                                                                              style: TextStyle(color: defaultPalette.black),
                                                                              cursorColor: defaultPalette.secondary,
                                                                              inputFormatters: [
                                                                                NumericInputFormatter(maxValue: documentPropertiesList[currentPageIndex].pageFormatController.width / 1.11 - double.parse(documentPropertiesList[currentPageIndex].marginLeftController.text))
                                                                              ],
                                                                              textAlign: TextAlign.center,
                                                                              textAlignVertical: TextAlignVertical.top,
                                                                              decoration: InputDecoration(
                                                                                contentPadding: EdgeInsets.all(0),
                                                                                labelText: 'Right',
                                                                                labelStyle: TextStyle(color: defaultPalette.black, fontSize: 20),
                                                                                floatingLabelAlignment: FloatingLabelAlignment.center,
                                                                                filled: true,
                                                                                fillColor: defaultPalette.primary,
                                                                                border: OutlineInputBorder(
                                                                                  // borderSide: BorderSide(width: 5, color: defaultPalette.black),
                                                                                  borderRadius: BorderRadius.circular(10.0), // Replace with your desired radius
                                                                                ),
                                                                                enabledBorder: OutlineInputBorder(
                                                                                  borderSide: BorderSide(width: 2, color: defaultPalette.black),
                                                                                  borderRadius: BorderRadius.circular(12.0), // Same as border
                                                                                ),
                                                                                focusedBorder: OutlineInputBorder(
                                                                                  borderSide: BorderSide(width: 3, color: defaultPalette.tertiary),
                                                                                  borderRadius: BorderRadius.circular(10.0), // Same as border
                                                                                ),
                                                                              ),
                                                                              keyboardType: TextInputType.number,
                                                                              onChanged: (value) => _updatePdfPreview,
                                                                            ),
                                                                            Positioned(
                                                                              top: (textFieldHeight / 2) - 15 / 2,
                                                                              left: 15 / 2,
                                                                              child: GestureDetector(
                                                                                onTap: () {
                                                                                  setState(() {
                                                                                    documentPropertiesList[currentPageIndex].marginRightController.text = (double.parse(documentPropertiesList[currentPageIndex].marginRightController.text) - 1).abs().toString();
                                                                                  });
                                                                                  _updatePdfPreview('');
                                                                                },
                                                                                child: Icon(
                                                                                  IconsaxPlusLinear.arrow_left_1,
                                                                                  size: 15,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Positioned(
                                                                              top: (textFieldHeight / 2) - 15 / 2,
                                                                              right: 15 / 2,
                                                                              child: GestureDetector(
                                                                                onTap: () {
                                                                                  setState(() {
                                                                                    documentPropertiesList[currentPageIndex].marginRightController.text = (double.parse(documentPropertiesList[currentPageIndex].marginRightController.text) + 1).toString();
                                                                                  });

                                                                                  _updatePdfPreview('');
                                                                                },
                                                                                child: Icon(
                                                                                  IconsaxPlusLinear.arrow_right_3,
                                                                                  size: 15,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height: 10,
                                                                )
                                                              ],
                                                            ),

                                                          SizedBox(
                                                            height:
                                                                textFieldHeight +
                                                                    10,
                                                            child:
                                                                CustomDropdown(
                                                              hintText:
                                                                  'Orientation',
                                                              items: [
                                                                'Portrait',
                                                                'Landscape'
                                                              ],
                                                              closedHeaderPadding:
                                                                  EdgeInsets
                                                                      .all(10),
                                                              initialItem: documentPropertiesList[
                                                                              currentPageIndex]
                                                                          .orientationController ==
                                                                      pw.PageOrientation
                                                                          .portrait
                                                                  ? 'Portrait'
                                                                  : 'Landscape',
                                                              onChanged:
                                                                  (value) {
                                                                documentPropertiesList[
                                                                        currentPageIndex]
                                                                    .orientationController = value ==
                                                                        'Portrait'
                                                                    ? pw.PageOrientation
                                                                        .portrait
                                                                    : pw.PageOrientation
                                                                        .landscape;
                                                                _updatePdfPreview(
                                                                    '');
                                                              },
                                                              listItemBuilder:
                                                                  (context,
                                                                      item,
                                                                      isSelected,
                                                                      onItemSelect) {
                                                                return Row(
                                                                  children: [
                                                                    Icon(
                                                                      item == 'Portrait'
                                                                          ? Icons
                                                                              .crop_portrait
                                                                          : Icons
                                                                              .crop_3_2_sharp,
                                                                      size: 20,
                                                                    ),
                                                                    SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Text(item)
                                                                  ],
                                                                );
                                                              },
                                                              decoration:
                                                                  CustomDropdownDecoration(
                                                                prefixIcon:
                                                                    Icon(
                                                                  documentPropertiesList[currentPageIndex]
                                                                              .orientationController ==
                                                                          pw.PageOrientation
                                                                              .portrait
                                                                      ? Icons
                                                                          .crop_portrait_outlined
                                                                      : Icons
                                                                          .crop_3_2_sharp,
                                                                  size: 20,
                                                                ),
                                                                closedBorderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12),
                                                                closedBorder:
                                                                    Border.all(
                                                                        color:
                                                                            defaultPalette
                                                                                .black,
                                                                        width:
                                                                            2),
                                                                expandedBorder:
                                                                    Border.all(
                                                                        color: defaultPalette
                                                                            .tertiary,
                                                                        width:
                                                                            3),
                                                                closedFillColor:
                                                                    defaultPalette
                                                                        .primary,
                                                                hintStyle:
                                                                    TextStyle(
                                                                  color:
                                                                      defaultPalette
                                                                          .black,
                                                                ),
                                                                headerStyle:
                                                                    TextStyle(
                                                                  color:
                                                                      defaultPalette
                                                                          .black,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(height: 5),
                                                          SizedBox(
                                                            height:
                                                                textFieldHeight,
                                                            child:
                                                                CustomDropdown
                                                                    .search(
                                                              hintText:
                                                                  'Page Format',
                                                              items: [
                                                                'A4',
                                                                'A3',
                                                                'A5',
                                                                'A6',
                                                                'Letter',
                                                                'Legal',
                                                                'Standard',
                                                                // 'Roll 57',
                                                                // 'Roll 80',
                                                              ],
                                                              initialItem: getPageFormatString(
                                                                  documentPropertiesList[
                                                                          currentPageIndex]
                                                                      .pageFormatController),
                                                              onChanged:
                                                                  (value) {
                                                                documentPropertiesList[
                                                                            currentPageIndex]
                                                                        .pageFormatController =
                                                                    getPageFormatFromString(
                                                                        value ??
                                                                            '');
                                                                _updatePdfPreview(
                                                                    '');
                                                              },
                                                              closedHeaderPadding:
                                                                  EdgeInsets
                                                                      .all(10),
                                                              decoration:
                                                                  CustomDropdownDecoration(
                                                                closedBorderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12),
                                                                closedBorder:
                                                                    Border.all(
                                                                        color:
                                                                            defaultPalette
                                                                                .black,
                                                                        width:
                                                                            2),
                                                                expandedBorder:
                                                                    Border.all(
                                                                        color: defaultPalette
                                                                            .tertiary,
                                                                        width:
                                                                            3),
                                                                closedFillColor:
                                                                    defaultPalette
                                                                        .primary,
                                                                hintStyle: TextStyle(
                                                                    color: defaultPalette
                                                                        .black),
                                                                headerStyle: TextStyle(
                                                                    color: defaultPalette
                                                                        .black),
                                                              ),
                                                            ),
                                                          ),
                                                          // Divider(),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 30,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          //Text Styling
                                          AnimatedPositioned(
                                            duration: Durations.short4,
                                            left: panelIndex.panelIndex == -1
                                                ? sWidth * vDividerPosition
                                                : 0,
                                            child: Container(
                                              // color: defaultPalette.white,
                                              height:
                                                  sHeight * hDividerPosition,
                                              width: sWidth * vDividerPosition,
                                              child: Flex(
                                                direction: Axis.vertical,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                          flex: 2,
                                                          child: Text(
                                                            'Text Properties',
                                                            style: GoogleFonts
                                                                .josefinSans(
                                                                    fontSize:
                                                                        20),
                                                          )),
                                                      Expanded(
                                                        child: IconButton(
                                                            onPressed: () {
                                                              var item = _sheetItemIterator(
                                                                      panelIndex.id,
                                                                      spreadSheetList[
                                                                          currentPageIndex])
                                                                  as TextEditorItem;
                                                              item.focusNode
                                                                  .unfocus();
                                                              setState(() {
                                                                panelIndex = PanelIndex(
                                                                    id: panelIndex
                                                                        .id,
                                                                    panelIndex:
                                                                        -1);
                                                              });
                                                            },
                                                            icon: Icon(
                                                                IconsaxPlusLinear
                                                                    .arrow_left)),
                                                      ),
                                                    ],
                                                  ),
                                                  panelIndex.panelIndex == -1
                                                      ? Container()
                                                      : Expanded(
                                                          child: PageView(
                                                            allowImplicitScrolling:
                                                                false,
                                                            physics:
                                                                NeverScrollableScrollPhysics(),
                                                            controller:
                                                                pagePropertiesViewController,
                                                            children: [
                                                              for (int i = 0;
                                                                  i <
                                                                      spreadSheetList[
                                                                              currentPageIndex]
                                                                          .length;
                                                                  i++)
                                                                Container(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              5),
                                                                  child:
                                                                      Builder(
                                                                    builder:
                                                                        (context) {
                                                                      var item = _sheetItemIterator(
                                                                          spreadSheetList[currentPageIndex][i]
                                                                              .id,
                                                                          spreadSheetList[
                                                                              currentPageIndex]) as TextEditorItem;

                                                                      bool _getIsToggled(
                                                                          Map<String, Attribute>
                                                                              attrs,
                                                                          Attribute
                                                                              attribute) {
                                                                        if (attribute.key == Attribute.list.key ||
                                                                            attribute.key ==
                                                                                Attribute.header.key ||
                                                                            attribute.key == Attribute.script.key ||
                                                                            attribute.key == Attribute.align.key) {
                                                                          final currentAttribute =
                                                                              attrs[attribute.key];
                                                                          if (currentAttribute ==
                                                                              null) {
                                                                            print('returning false');
                                                                            return false;
                                                                          }
                                                                          print(
                                                                              'returning ${currentAttribute.value == attribute.value}');
                                                                          return currentAttribute.value ==
                                                                              attribute.value;
                                                                        }
                                                                        print(
                                                                            'returning ${attrs.containsKey(attribute.key)}');
                                                                        return attrs
                                                                            .containsKey(attribute.key);
                                                                      }

                                                                      Widget
                                                                          buildElevatedLayerButton({
                                                                        required double
                                                                            buttonHeight,
                                                                        required double
                                                                            buttonWidth,
                                                                        required Duration
                                                                            animationDuration,
                                                                        required Curve
                                                                            animationCurve,
                                                                        required void
                                                                                Function()
                                                                            onClick,
                                                                        required BoxDecoration
                                                                            baseDecoration,
                                                                        required BoxDecoration
                                                                            topDecoration,
                                                                        required Widget
                                                                            topLayerChild,
                                                                        required BorderRadius
                                                                            borderRadius,
                                                                        bool toggleOnTap =
                                                                            false,
                                                                        bool isTapped =
                                                                            false,
                                                                      }) {
                                                                        var down =
                                                                            isTapped;
                                                                        void _handleTapDown(
                                                                            TapDownDetails
                                                                                details) {
                                                                          onClick();

                                                                          setState(
                                                                              () {
                                                                            down =
                                                                                true;
                                                                            print(down);
                                                                          });
                                                                        }

                                                                        void _handleTapUp(
                                                                            TapUpDetails
                                                                                details) {
                                                                          if (!toggleOnTap &&
                                                                              down) {
                                                                            setState(() {
                                                                              down = !down;
                                                                            });
                                                                          }
                                                                        }

                                                                        void
                                                                            _handleTapCancel() {}

                                                                        return GestureDetector(
                                                                          onTap:
                                                                              () {},
                                                                          onTapDown:
                                                                              _handleTapDown,
                                                                          onTapUp:
                                                                              _handleTapUp,
                                                                          onTapCancel:
                                                                              _handleTapCancel,
                                                                          child:
                                                                              SizedBox(
                                                                            height:
                                                                                buttonHeight,
                                                                            width:
                                                                                buttonWidth,
                                                                            child:
                                                                                Stack(
                                                                              alignment: Alignment.bottomRight,
                                                                              children: [
                                                                                Positioned(
                                                                                  bottom: 0,
                                                                                  right: 0,
                                                                                  child: Container(
                                                                                    width: buttonWidth - 10,
                                                                                    height: buttonHeight - 10,
                                                                                    decoration: baseDecoration.copyWith(
                                                                                      borderRadius: borderRadius,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                AnimatedPositioned(
                                                                                  duration: animationDuration,
                                                                                  curve: animationCurve,
                                                                                  bottom: !down ? 4 : 0,
                                                                                  right: !down ? 4 : 0,
                                                                                  child: Container(
                                                                                    width: buttonWidth - 10,
                                                                                    height: buttonHeight - 10,
                                                                                    alignment: Alignment.center,
                                                                                    decoration: topDecoration.copyWith(
                                                                                      borderRadius: borderRadius,
                                                                                    ),
                                                                                    child: topLayerChild,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        );
                                                                      }

                                                                      var width =
                                                                          sWidth *
                                                                              vDividerPosition;
                                                                      var iconHeight =
                                                                          50.0;
                                                                      TextEditingController
                                                                          hexController =
                                                                          TextEditingController()
                                                                            ..text =
                                                                                '${item.textEditorController.getSelectionStyle().attributes['color']?.value}';
                                                                      TextEditingController
                                                                          bghexController =
                                                                          TextEditingController()
                                                                            ..text =
                                                                                '${item.textEditorController.getSelectionStyle().attributes['background']?.value}';

                                                                      return SingleChildScrollView(
                                                                        child:
                                                                            AnimatedContainer(
                                                                          duration: pickColor
                                                                              ? Duration.zero
                                                                              : Durations.medium2,
                                                                          height:
                                                                              200 + (pickColor ? 400 : 140),
                                                                          child:
                                                                              Stack(
                                                                            children: [
                                                                              GridView.builder(
                                                                                physics: NeverScrollableScrollPhysics(),
                                                                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                                                  crossAxisCount: width < (width / vDividerPosition) / 2.1
                                                                                      ? 3
                                                                                      : width < (width / vDividerPosition) / 1.7
                                                                                          ? 4
                                                                                          : width < (width / vDividerPosition) / 1.38
                                                                                              ? 5
                                                                                              : width < (width / vDividerPosition) / 1.2
                                                                                                  ? 6
                                                                                                  : 7,
                                                                                  crossAxisSpacing: 2,
                                                                                  mainAxisSpacing: 2,
                                                                                ),
                                                                                itemCount: 12,
                                                                                itemBuilder: (context, index) {
                                                                                  switch (index) {
                                                                                    case 0:
                                                                                      //UNDO
                                                                                      return buildElevatedLayerButton(
                                                                                        toggleOnTap: false,
                                                                                        buttonHeight: iconHeight,
                                                                                        buttonWidth: iconHeight,
                                                                                        animationDuration: const Duration(milliseconds: 100),
                                                                                        animationCurve: Curves.ease,
                                                                                        onClick: () {
                                                                                          if (item.textEditorController.hasUndo) {
                                                                                            item.textEditorController.undo();
                                                                                          }
                                                                                        },
                                                                                        baseDecoration: BoxDecoration(
                                                                                          color: Colors.green,
                                                                                          border: Border.all(),
                                                                                        ),
                                                                                        topDecoration: BoxDecoration(
                                                                                          color: Colors.black,
                                                                                          border: Border.all(),
                                                                                        ),
                                                                                        topLayerChild: Icon(
                                                                                          IconsaxPlusLinear.undo,
                                                                                          color: Colors.white,
                                                                                          size: 20,
                                                                                        ),
                                                                                        borderRadius: BorderRadius.circular(10),
                                                                                      );
                                                                                    case 1:
                                                                                      //REDO
                                                                                      return buildElevatedLayerButton(
                                                                                        toggleOnTap: false,
                                                                                        buttonHeight: iconHeight,
                                                                                        buttonWidth: iconHeight,
                                                                                        animationDuration: const Duration(milliseconds: 100),
                                                                                        animationCurve: Curves.ease,
                                                                                        onClick: () {
                                                                                          if (item.textEditorController.hasRedo) {
                                                                                            item.textEditorController.redo();
                                                                                          }
                                                                                        },
                                                                                        baseDecoration: BoxDecoration(
                                                                                          color: Colors.green,
                                                                                          border: Border.all(),
                                                                                        ),
                                                                                        topDecoration: BoxDecoration(
                                                                                          color: Colors.black,
                                                                                          border: Border.all(),
                                                                                        ),
                                                                                        topLayerChild: Icon(
                                                                                          IconsaxPlusLinear.redo,
                                                                                          color: Colors.white,
                                                                                          size: 20,
                                                                                        ),
                                                                                        borderRadius: BorderRadius.circular(10),
                                                                                      );
                                                                                    case 2:
                                                                                      //BOLD
                                                                                      return buildElevatedLayerButton(
                                                                                        buttonHeight: iconHeight,
                                                                                        buttonWidth: iconHeight,
                                                                                        toggleOnTap: true,
                                                                                        isTapped: _getIsToggled(item.textEditorController.getSelectionStyle().attributes, Attribute.bold),
                                                                                        animationDuration: const Duration(milliseconds: 100),
                                                                                        animationCurve: Curves.ease,
                                                                                        onClick: () {
                                                                                          final currentValue = item.textEditorController.getSelectionStyle().attributes.containsKey(Attribute.bold.key);
                                                                                          item.textEditorController.formatSelection(
                                                                                            currentValue ? Attribute.clone(Attribute.bold, null) : Attribute.bold,
                                                                                          );
                                                                                        },
                                                                                        baseDecoration: BoxDecoration(
                                                                                          color: Colors.green,
                                                                                          border: Border.all(),
                                                                                        ),
                                                                                        topDecoration: BoxDecoration(
                                                                                          color: Colors.black,
                                                                                          border: Border.all(),
                                                                                        ),
                                                                                        topLayerChild: Icon(
                                                                                          IconsaxPlusLinear.text_bold,
                                                                                          color: Colors.white,
                                                                                          size: 20,
                                                                                        ),
                                                                                        borderRadius: BorderRadius.circular(10),
                                                                                      );
                                                                                    case 3:
                                                                                      //ITALIC
                                                                                      return buildElevatedLayerButton(
                                                                                        buttonHeight: iconHeight,
                                                                                        buttonWidth: iconHeight,
                                                                                        toggleOnTap: true,
                                                                                        isTapped: _getIsToggled(item.textEditorController.getSelectionStyle().attributes, Attribute.italic),
                                                                                        animationDuration: const Duration(milliseconds: 100),
                                                                                        animationCurve: Curves.ease,
                                                                                        onClick: () {
                                                                                          final currentValue = item.textEditorController.getSelectionStyle().attributes.containsKey(Attribute.italic.key);
                                                                                          item.textEditorController.formatSelection(
                                                                                            currentValue ? Attribute.clone(Attribute.italic, null) : Attribute.italic,
                                                                                          );
                                                                                        },
                                                                                        baseDecoration: BoxDecoration(
                                                                                          color: Colors.green,
                                                                                          border: Border.all(),
                                                                                        ),
                                                                                        topDecoration: BoxDecoration(
                                                                                          color: Colors.black,
                                                                                          border: Border.all(),
                                                                                        ),
                                                                                        topLayerChild: Icon(
                                                                                          IconsaxPlusLinear.text_italic,
                                                                                          color: Colors.white,
                                                                                          size: 20,
                                                                                        ),
                                                                                        borderRadius: BorderRadius.circular(10),
                                                                                      );
                                                                                    case 4:
                                                                                      //UNDERLINE
                                                                                      return buildElevatedLayerButton(
                                                                                        buttonHeight: iconHeight,
                                                                                        buttonWidth: iconHeight,
                                                                                        toggleOnTap: true,
                                                                                        isTapped: _getIsToggled(item.textEditorController.getSelectionStyle().attributes, Attribute.underline),
                                                                                        animationDuration: const Duration(milliseconds: 100),
                                                                                        animationCurve: Curves.ease,
                                                                                        onClick: () {
                                                                                          final currentValue = item.textEditorController.getSelectionStyle().attributes.containsKey(Attribute.underline.key);
                                                                                          item.textEditorController.formatSelection(
                                                                                            currentValue ? Attribute.clone(Attribute.underline, null) : Attribute.underline,
                                                                                          );
                                                                                        },
                                                                                        baseDecoration: BoxDecoration(
                                                                                          color: Colors.green,
                                                                                          border: Border.all(),
                                                                                        ),
                                                                                        topDecoration: BoxDecoration(
                                                                                          color: Colors.black,
                                                                                          border: Border.all(),
                                                                                        ),
                                                                                        topLayerChild: Icon(
                                                                                          IconsaxPlusLinear.text_underline,
                                                                                          color: Colors.white,
                                                                                          size: 20,
                                                                                        ),
                                                                                        borderRadius: BorderRadius.circular(10),
                                                                                      );
                                                                                    case 5:
                                                                                      //STRIKETHRU
                                                                                      return buildElevatedLayerButton(
                                                                                        buttonHeight: iconHeight,
                                                                                        buttonWidth: iconHeight,
                                                                                        toggleOnTap: true,
                                                                                        isTapped: _getIsToggled(item.textEditorController.getSelectionStyle().attributes, Attribute.strikeThrough),
                                                                                        animationDuration: const Duration(milliseconds: 100),
                                                                                        animationCurve: Curves.ease,
                                                                                        onClick: () {
                                                                                          final currentValue = item.textEditorController.getSelectionStyle().attributes.containsKey(Attribute.strikeThrough.key);
                                                                                          item.textEditorController.formatSelection(
                                                                                            currentValue ? Attribute.clone(Attribute.strikeThrough, null) : Attribute.strikeThrough,
                                                                                          );
                                                                                        },
                                                                                        baseDecoration: BoxDecoration(
                                                                                          color: Colors.green,
                                                                                          border: Border.all(),
                                                                                        ),
                                                                                        topDecoration: BoxDecoration(
                                                                                          color: Colors.black,
                                                                                          border: Border.all(),
                                                                                        ),
                                                                                        topLayerChild: Icon(
                                                                                          CupertinoIcons.strikethrough,
                                                                                          color: Colors.white,
                                                                                          size: 20,
                                                                                        ),
                                                                                        borderRadius: BorderRadius.circular(10),
                                                                                      );
                                                                                    case 6:
                                                                                      //SUBSCRIPT
                                                                                      return buildElevatedLayerButton(
                                                                                        buttonHeight: iconHeight,
                                                                                        buttonWidth: iconHeight,
                                                                                        toggleOnTap: true,
                                                                                        isTapped: _getIsToggled(item.textEditorController.getSelectionStyle().attributes, Attribute.subscript),
                                                                                        animationDuration: const Duration(milliseconds: 100),
                                                                                        animationCurve: Curves.ease,
                                                                                        onClick: () {
                                                                                          var currentValue = _getIsToggled(item.textEditorController.getSelectionStyle().attributes, Attribute.subscript);
                                                                                          item.textEditorController.formatSelection(
                                                                                            currentValue ? Attribute.clone(Attribute.subscript, null) : Attribute.subscript,
                                                                                          );
                                                                                          final uncurrentValue = item.textEditorController.getSelectionStyle().attributes.containsKey(Attribute.superscript.key);
                                                                                          if (uncurrentValue && currentValue) {
                                                                                            item.textEditorController.formatSelection(
                                                                                              Attribute.clone(Attribute.subscript, null),
                                                                                            );
                                                                                            currentValue = _getIsToggled(item.textEditorController.getSelectionStyle().attributes, Attribute.subscript);
                                                                                          }
                                                                                          print('$uncurrentValue && $currentValue');
                                                                                          if (uncurrentValue && !currentValue) {
                                                                                            print('un');
                                                                                            print(uncurrentValue);
                                                                                            item.textEditorController.formatSelection(Attribute.clone(Attribute.superscript, null));
                                                                                            item.textEditorController.formatSelection(
                                                                                              Attribute.subscript,
                                                                                            );
                                                                                            setState(() {
                                                                                              currentValue = _getIsToggled(item.textEditorController.getSelectionStyle().attributes, Attribute.subscript);
                                                                                            });
                                                                                            print('cu');
                                                                                            print(currentValue);
                                                                                            return;
                                                                                          }
                                                                                          item.textEditorController.formatSelection(
                                                                                            currentValue ? Attribute.clone(Attribute.subscript, null) : Attribute.subscript,
                                                                                          );
                                                                                        },
                                                                                        baseDecoration: BoxDecoration(
                                                                                          color: Colors.green,
                                                                                          border: Border.all(),
                                                                                        ),
                                                                                        topDecoration: BoxDecoration(
                                                                                          color: Colors.black,
                                                                                          border: Border.all(),
                                                                                        ),
                                                                                        topLayerChild: Icon(
                                                                                          Icons.subscript,
                                                                                          color: Colors.white,
                                                                                          size: 20,
                                                                                        ),
                                                                                        borderRadius: BorderRadius.circular(10),
                                                                                      );
                                                                                    case 7:
                                                                                      //SUPERSCIPT
                                                                                      return buildElevatedLayerButton(
                                                                                        buttonHeight: iconHeight,
                                                                                        buttonWidth: iconHeight,
                                                                                        toggleOnTap: true,
                                                                                        isTapped: _getIsToggled(item.textEditorController.getSelectionStyle().attributes, Attribute.superscript),
                                                                                        animationDuration: const Duration(milliseconds: 100),
                                                                                        animationCurve: Curves.ease,
                                                                                        onClick: () {
                                                                                          var currentValue = _getIsToggled(item.textEditorController.getSelectionStyle().attributes, Attribute.superscript);
                                                                                          item.textEditorController.formatSelection(
                                                                                            currentValue ? Attribute.clone(Attribute.superscript, null) : Attribute.superscript,
                                                                                          );
                                                                                          final uncurrentValue = item.textEditorController.getSelectionStyle().attributes.containsKey(Attribute.subscript.key);
                                                                                          if (uncurrentValue && currentValue) {
                                                                                            item.textEditorController.formatSelection(
                                                                                              Attribute.clone(Attribute.superscript, null),
                                                                                            );
                                                                                            currentValue = _getIsToggled(item.textEditorController.getSelectionStyle().attributes, Attribute.superscript);
                                                                                          }
                                                                                          print('$uncurrentValue && $currentValue');
                                                                                          if (uncurrentValue && !currentValue) {
                                                                                            print('un');
                                                                                            print(uncurrentValue);
                                                                                            item.textEditorController.formatSelection(Attribute.clone(Attribute.subscript, null));
                                                                                            item.textEditorController.formatSelection(
                                                                                              Attribute.superscript,
                                                                                            );
                                                                                            setState(() {
                                                                                              currentValue = _getIsToggled(item.textEditorController.getSelectionStyle().attributes, Attribute.superscript);
                                                                                            });
                                                                                            print('cu');
                                                                                            print(currentValue);
                                                                                            return;
                                                                                          }
                                                                                          item.textEditorController.formatSelection(
                                                                                            currentValue ? Attribute.clone(Attribute.superscript, null) : Attribute.superscript,
                                                                                          );
                                                                                        },
                                                                                        baseDecoration: BoxDecoration(
                                                                                          color: Colors.green,
                                                                                          border: Border.all(),
                                                                                        ),
                                                                                        topDecoration: BoxDecoration(
                                                                                          color: Colors.black,
                                                                                          border: Border.all(),
                                                                                        ),
                                                                                        topLayerChild: Icon(
                                                                                          Icons.superscript,
                                                                                          color: Colors.white,
                                                                                          size: 20,
                                                                                        ),
                                                                                        borderRadius: BorderRadius.circular(10),
                                                                                      );
                                                                                    case 8:
                                                                                      //CODE INLINE
                                                                                      return buildElevatedLayerButton(
                                                                                        buttonHeight: iconHeight,
                                                                                        buttonWidth: iconHeight,
                                                                                        toggleOnTap: true,
                                                                                        isTapped: _getIsToggled(item.textEditorController.getSelectionStyle().attributes, Attribute.inlineCode),
                                                                                        animationDuration: const Duration(milliseconds: 100),
                                                                                        animationCurve: Curves.ease,
                                                                                        onClick: () {
                                                                                          var currentValue = item.textEditorController.getSelectionStyle().attributes.containsKey(Attribute.inlineCode.key);
                                                                                          // item.textEditorController.formatSelection(ColorAttribute(null));
                                                                                          // item.textEditorController.formatSelection(BackgroundAttribute(null));
                                                                                          item.textEditorController.formatSelection(
                                                                                            currentValue ? Attribute.clone(Attribute.inlineCode, null) : Attribute.inlineCode,
                                                                                          );
                                                                                        },
                                                                                        baseDecoration: BoxDecoration(
                                                                                          color: Colors.green,
                                                                                          border: Border.all(),
                                                                                        ),
                                                                                        topDecoration: BoxDecoration(
                                                                                          color: Colors.black,
                                                                                          border: Border.all(),
                                                                                        ),
                                                                                        topLayerChild: Icon(
                                                                                          IconsaxPlusLinear.code,
                                                                                          color: Colors.white,
                                                                                          size: 25,
                                                                                        ),
                                                                                        borderRadius: BorderRadius.circular(10),
                                                                                      );
                                                                                    case 9:
                                                                                      //OOLLLOOOLLLL
                                                                                      return buildElevatedLayerButton(
                                                                                        buttonHeight: iconHeight,
                                                                                        buttonWidth: iconHeight,
                                                                                        toggleOnTap: true,
                                                                                        isTapped: _getIsToggled(item.textEditorController.getSelectionStyle().attributes, Attribute.ol),
                                                                                        animationDuration: const Duration(milliseconds: 100),
                                                                                        animationCurve: Curves.ease,
                                                                                        onClick: () {
                                                                                          var currentValue = _getIsToggled(item.textEditorController.getSelectionStyle().attributes, Attribute.ol);
                                                                                          item.textEditorController.formatSelection(
                                                                                            currentValue ? Attribute.clone(Attribute.ol, null) : Attribute.ol,
                                                                                          );
                                                                                          final uncurrentValue = item.textEditorController.getSelectionStyle().attributes.containsKey(Attribute.ul.key);
                                                                                          if (uncurrentValue && currentValue) {
                                                                                            item.textEditorController.formatSelection(
                                                                                              Attribute.clone(Attribute.ol, null),
                                                                                            );
                                                                                            currentValue = _getIsToggled(item.textEditorController.getSelectionStyle().attributes, Attribute.ol);
                                                                                          }
                                                                                          print('$uncurrentValue && $currentValue');
                                                                                          if (uncurrentValue && !currentValue) {
                                                                                            print('un');
                                                                                            print(uncurrentValue);
                                                                                            item.textEditorController.formatSelection(Attribute.clone(Attribute.ul, null));
                                                                                            item.textEditorController.formatSelection(
                                                                                              Attribute.ol,
                                                                                            );
                                                                                            setState(() {
                                                                                              currentValue = _getIsToggled(item.textEditorController.getSelectionStyle().attributes, Attribute.ol);
                                                                                            });
                                                                                            print('cu');
                                                                                            print(currentValue);
                                                                                            return;
                                                                                          }
                                                                                          item.textEditorController.formatSelection(
                                                                                            currentValue ? Attribute.clone(Attribute.ol, null) : Attribute.ol,
                                                                                          );
                                                                                        },
                                                                                        baseDecoration: BoxDecoration(
                                                                                          color: Colors.green,
                                                                                          border: Border.all(),
                                                                                        ),
                                                                                        topDecoration: BoxDecoration(
                                                                                          color: Colors.black,
                                                                                          border: Border.all(),
                                                                                        ),
                                                                                        topLayerChild: Icon(
                                                                                          TablerIcons.list_numbers,
                                                                                          color: Colors.white,
                                                                                          size: 25,
                                                                                        ),
                                                                                        borderRadius: BorderRadius.circular(10),
                                                                                      );
                                                                                    case 10:
                                                                                      //ULLLLLUUULLLLL
                                                                                      return buildElevatedLayerButton(
                                                                                        buttonHeight: iconHeight,
                                                                                        buttonWidth: iconHeight,
                                                                                        toggleOnTap: true,
                                                                                        isTapped: _getIsToggled(item.textEditorController.getSelectionStyle().attributes, Attribute.ul),
                                                                                        animationDuration: const Duration(milliseconds: 100),
                                                                                        animationCurve: Curves.ease,
                                                                                        onClick: () {
                                                                                          var currentValue = _getIsToggled(item.textEditorController.getSelectionStyle().attributes, Attribute.ul);
                                                                                          item.textEditorController.formatSelection(
                                                                                            currentValue ? Attribute.clone(Attribute.ul, null) : Attribute.ul,
                                                                                          );
                                                                                          final uncurrentValue = item.textEditorController.getSelectionStyle().attributes.containsKey(Attribute.ol.key);
                                                                                          if (uncurrentValue && currentValue) {
                                                                                            item.textEditorController.formatSelection(
                                                                                              Attribute.clone(Attribute.ul, null),
                                                                                            );
                                                                                            currentValue = _getIsToggled(item.textEditorController.getSelectionStyle().attributes, Attribute.ul);
                                                                                          }
                                                                                          print('$uncurrentValue && $currentValue');
                                                                                          if (uncurrentValue && !currentValue) {
                                                                                            print('un');
                                                                                            print(uncurrentValue);
                                                                                            item.textEditorController.formatSelection(Attribute.clone(Attribute.ol, null));
                                                                                            item.textEditorController.formatSelection(
                                                                                              Attribute.ul,
                                                                                            );
                                                                                            setState(() {
                                                                                              currentValue = _getIsToggled(item.textEditorController.getSelectionStyle().attributes, Attribute.ul);
                                                                                            });
                                                                                            print('cu');
                                                                                            print(currentValue);
                                                                                            return;
                                                                                          }
                                                                                          item.textEditorController.formatSelection(
                                                                                            currentValue ? Attribute.clone(Attribute.ul, null) : Attribute.ul,
                                                                                          );
                                                                                        },
                                                                                        baseDecoration: BoxDecoration(
                                                                                          color: Colors.green,
                                                                                          border: Border.all(),
                                                                                        ),
                                                                                        topDecoration: BoxDecoration(
                                                                                          color: Colors.black,
                                                                                          border: Border.all(),
                                                                                        ),
                                                                                        topLayerChild: Icon(
                                                                                          TablerIcons.list_details,
                                                                                          color: Colors.white,
                                                                                          size: 25,
                                                                                        ),
                                                                                        borderRadius: BorderRadius.circular(10),
                                                                                      );
                                                                                    case 11:
                                                                                      bool _getIsToggledList(Map<String, Attribute> attrs, Attribute attribute) {
                                                                                        var attr = item.textEditorController.toolbarButtonToggler[attribute.key];

                                                                                        if (attr == null) {
                                                                                          attr = attrs[attribute.key];
                                                                                        } else {
                                                                                          item.textEditorController.toolbarButtonToggler.remove(attribute.key);
                                                                                        }

                                                                                        if (attr == null) {
                                                                                          return false;
                                                                                        }
                                                                                        return attr.value == Attribute.unchecked.value || attr.value == Attribute.checked.value;
                                                                                      }
                                                                                      bool currentValue = _getIsToggledList(item.textEditorController.getSelectionStyle().attributes, Attribute.list);
                                                                                      void _toggleAttribute(Attribute attribute, Attribute toggledAttribute) {
                                                                                        item.textEditorController
                                                                                          ..formatSelection(
                                                                                            currentValue ? Attribute.clone(toggledAttribute, null) : toggledAttribute,
                                                                                          );
                                                                                      }
                                                                                      return UtilityWidgets.maybeTooltip(
                                                                                        message: 'CheckList',
                                                                                        child: buildElevatedLayerButton(
                                                                                          buttonHeight: iconHeight,
                                                                                          buttonWidth: iconHeight,
                                                                                          toggleOnTap: true,
                                                                                          isTapped: currentValue,
                                                                                          animationDuration: const Duration(milliseconds: 100),
                                                                                          animationCurve: Curves.ease,
                                                                                          onClick: () {
                                                                                            _toggleAttribute(Attribute.list, Attribute.unchecked);
                                                                                            // afterButtonPressed?.call();
                                                                                          },
                                                                                          baseDecoration: BoxDecoration(
                                                                                            color: Colors.green,
                                                                                            border: Border.all(),
                                                                                          ),
                                                                                          topDecoration: BoxDecoration(
                                                                                            color: Colors.black,
                                                                                            border: Border.all(),
                                                                                          ),
                                                                                          topLayerChild: Icon(
                                                                                            Icons.format_list_bulleted,
                                                                                            color: Colors.white,
                                                                                            size: 25,
                                                                                          ),
                                                                                          borderRadius: BorderRadius.circular(10),
                                                                                        ),
                                                                                      );
                                                                                    default:
                                                                                      return Container(); // Fallback if index is out of range
                                                                                  }
                                                                                },
                                                                              ),
                                                                              //COLORR AND BGCOLORRRR
                                                                              Positioned(
                                                                                top: width < (width / vDividerPosition) / 2.1
                                                                                    ? 250
                                                                                    : width < (width / vDividerPosition) / 1.7
                                                                                        ? 180
                                                                                        : width < (width / vDividerPosition) / 1.38
                                                                                            ? 180
                                                                                            : width < (width / vDividerPosition) / 1.2
                                                                                                ? 130
                                                                                                : 120,
                                                                                left: 4,
                                                                                child: AnimatedContainer(
                                                                                  duration: Durations.short4,
                                                                                  height: pickColor ? 370 : 106,
                                                                                  width: width - 16,
                                                                                  decoration: BoxDecoration(color: defaultPalette.white, borderRadius: BorderRadius.circular(12), border: Border.all(width: 2)),
                                                                                  child: Stack(
                                                                                    children: [
                                                                                      TabContainer(
                                                                                          controller: tabcunt,
                                                                                          tabEdge: TabEdge.top,
                                                                                          tabsStart: 0.35,
                                                                                          tabExtent: 50,
                                                                                          childPadding: EdgeInsets.symmetric(vertical: 8),
                                                                                          colors: [
                                                                                            hexToColor(item.textEditorController.getSelectionStyle().attributes['color']?.value),
                                                                                            hexToColor(item.textEditorController.getSelectionStyle().attributes['background']?.value),
                                                                                          ],
                                                                                          selectedTextStyle: GoogleFonts.lexend(
                                                                                            color: defaultPalette.primary,
                                                                                            fontSize: 14,
                                                                                          ),
                                                                                          unselectedTextStyle: const TextStyle(
                                                                                            color: Colors.black,
                                                                                            fontSize: 13.0,
                                                                                          ),
                                                                                          // borderRadius: BorderRadius.circular(20),
                                                                                          // tabBorderRadius: BorderRadius.circular(20),
                                                                                          tabs: [
                                                                                            Text(
                                                                                              'Font',
                                                                                            ),
                                                                                            Text('Bg')
                                                                                          ],
                                                                                          children: [
                                                                                            //FONT COLOR
                                                                                            DefaultTabController(
                                                                                              length: 2,
                                                                                              child: SingleChildScrollView(
                                                                                                physics: NeverScrollableScrollPhysics(),
                                                                                                child: AnimatedContainer(
                                                                                                  duration: Duration.zero,
                                                                                                  height: pickColor ? 290 : 37,
                                                                                                  width: width,
                                                                                                  child: Stack(
                                                                                                    children: [
                                                                                                      TabBar(
                                                                                                        dividerHeight: 0,
                                                                                                        indicatorSize: TabBarIndicatorSize.label,
                                                                                                        indicatorColor: defaultPalette.transparent,
                                                                                                        labelColor: defaultPalette.black,
                                                                                                        labelPadding: EdgeInsets.all(0),
                                                                                                        tabs: [
                                                                                                          //FONT COLOR
                                                                                                          Tab(
                                                                                                            height: 30,
                                                                                                            child: Container(
                                                                                                              padding: EdgeInsets.all(2),
                                                                                                              margin: EdgeInsets.only(left: 5, right: 5),
                                                                                                              height: 30,
                                                                                                              width: width,
                                                                                                              alignment: Alignment.center,
                                                                                                              decoration: BoxDecoration(color: defaultPalette.primary.withOpacity(0.7), borderRadius: BorderRadius.circular(10)),
                                                                                                              child: Text(
                                                                                                                'Picker',
                                                                                                                style: GoogleFonts.abrilFatface(),
                                                                                                              ),
                                                                                                            ),
                                                                                                          ), //FONT COLOR
                                                                                                          Tab(
                                                                                                            height: 30,
                                                                                                            child: Container(
                                                                                                              padding: EdgeInsets.all(2),
                                                                                                              margin: EdgeInsets.only(right: 5, left: 5),
                                                                                                              alignment: Alignment.center,
                                                                                                              height: 30,
                                                                                                              width: width,
                                                                                                              decoration: BoxDecoration(color: defaultPalette.primary.withOpacity(0.7), borderRadius: BorderRadius.circular(10)),
                                                                                                              child: Text(
                                                                                                                'Palette',
                                                                                                                style: GoogleFonts.abrilFatface(),
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                        ],
                                                                                                      ), //FONT COLOR
                                                                                                      //PICKER ND EVERYHTING
                                                                                                      Positioned(
                                                                                                        top: 35,
                                                                                                        width: width - 16,
                                                                                                        height: 320,
                                                                                                        child: TabBarView(
                                                                                                          physics: NeverScrollableScrollPhysics(),
                                                                                                          children: [
                                                                                                            SingleChildScrollView(
                                                                                                              physics: NeverScrollableScrollPhysics(),
                                                                                                              child: Padding(
                                                                                                                padding: const EdgeInsets.all(8),
                                                                                                                child: ColorPicker(
                                                                                                                  portraitOnly: true,
                                                                                                                  pickerAreaBorderRadius: BorderRadius.circular(12),
                                                                                                                  colorPickerWidth: 300,
                                                                                                                  labelTypes: [],
                                                                                                                  pickerColor: hexToColor(item.textEditorController.getSelectionStyle().attributes['color']?.value),
                                                                                                                  onColorChanged: (color) {
                                                                                                                    item.textEditorController.formatSelection(
                                                                                                                      ColorAttribute('#${colorToHex(color)}'),
                                                                                                                    );
                                                                                                                    setState(() {
                                                                                                                      hexController.text = '${item.textEditorController.getSelectionStyle().attributes['color']?.value}';
                                                                                                                    });
                                                                                                                  },
                                                                                                                  pickerAreaHeightPercent: 0.4,
                                                                                                                ),
                                                                                                              ),
                                                                                                            ), //FONT COLOR
                                                                                                            SingleChildScrollView(
                                                                                                              physics: NeverScrollableScrollPhysics(),
                                                                                                              child: Padding(
                                                                                                                padding: const EdgeInsets.all(8.0),
                                                                                                                child: MaterialPicker(
                                                                                                                  pickerColor: hexToColor(item.textEditorController.getSelectionStyle().attributes['color']?.value),
                                                                                                                  onColorChanged: (color) {
                                                                                                                    item.textEditorController.formatSelection(
                                                                                                                      ColorAttribute('#${colorToHex(color)}'),
                                                                                                                    );
                                                                                                                    setState(() {
                                                                                                                      hexController.text = '${item.textEditorController.getSelectionStyle().attributes['color']?.value}';
                                                                                                                    });
                                                                                                                  },
                                                                                                                ),
                                                                                                              ),
                                                                                                            ),
                                                                                                          ],
                                                                                                        ),
                                                                                                      ),
                                                                                                      //FONT COLOR
                                                                                                      //HEX TEXT FIEKLD
                                                                                                      Positioned(
                                                                                                        bottom: 0,
                                                                                                        left: 0,
                                                                                                        width: width - 16,
                                                                                                        child: Container(
                                                                                                          padding: EdgeInsets.only(left: 4, right: 8, top: 8),
                                                                                                          height: textFieldHeight + 5,
                                                                                                          child: TextFormField(
                                                                                                            controller: hexController,
                                                                                                            onTapOutside: (event) {},
                                                                                                            // initialValue: '${item.textEditorController.getSelectionStyle().attributes['color']?.value}',
                                                                                                            onChanged: (value) {
                                                                                                              final color = hexToColor(value);
                                                                                                              // setState(() {
                                                                                                              hexController.text = value;
                                                                                                              // });
                                                                                                              item.textEditorController.formatSelection(
                                                                                                                ColorAttribute('#${colorToHex(color)}'),
                                                                                                              );
                                                                                                            }, //FONT COLOR
                                                                                                            onFieldSubmitted: (value) {
                                                                                                              final color = hexToColor(value);

                                                                                                              item.textEditorController.formatSelection(
                                                                                                                ColorAttribute('#${colorToHex(color)}'),
                                                                                                              );
                                                                                                            },
                                                                                                            inputFormatters: [HexColorInputFormatter()],
                                                                                                            textAlignVertical: TextAlignVertical.top,
                                                                                                            decoration: InputDecoration(
                                                                                                              prefixIcon: Icon(IconsaxPlusBroken.text),
                                                                                                              prefixIconColor: hexToColor(hexController.text),
                                                                                                              suffixIcon: GestureDetector(
                                                                                                                onTap: () {
                                                                                                                  setState(() {
                                                                                                                    hexController.text = 'null';
                                                                                                                    item.textEditorController.formatSelection(
                                                                                                                      ColorAttribute(null),
                                                                                                                    );
                                                                                                                  });
                                                                                                                },
                                                                                                                child: Icon(
                                                                                                                  TablerIcons.x,
                                                                                                                  size: 15,
                                                                                                                ),
                                                                                                              ),
                                                                                                              filled: true,
                                                                                                              fillColor: defaultPalette.primary.withOpacity(1),
                                                                                                              border: OutlineInputBorder(
                                                                                                                borderRadius: BorderRadius.circular(10.0), // Replace with your desired radius
                                                                                                              ),
                                                                                                              enabledBorder: OutlineInputBorder(
                                                                                                                borderSide: BorderSide(width: 2, color: defaultPalette.transparent),
                                                                                                                borderRadius: BorderRadius.circular(12.0), // Same as border
                                                                                                              ),
                                                                                                              disabledBorder: OutlineInputBorder(
                                                                                                                borderSide: BorderSide(width: 2, color: defaultPalette.black),
                                                                                                                borderRadius: BorderRadius.circular(12.0), // Same as border
                                                                                                              ),
                                                                                                              focusedBorder: OutlineInputBorder(
                                                                                                                borderSide: BorderSide(width: 3, color: defaultPalette.transparent),
                                                                                                                borderRadius: BorderRadius.circular(10.0), // Same as border
                                                                                                              ),
                                                                                                            ),
                                                                                                            cursorColor: defaultPalette.tertiary,
                                                                                                            //FONT COLOR

                                                                                                            style: TextStyle(color: defaultPalette.black, fontSize: 15),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            //Background color
                                                                                            DefaultTabController(
                                                                                              length: 2,
                                                                                              child: SingleChildScrollView(
                                                                                                physics: NeverScrollableScrollPhysics(),
                                                                                                child: AnimatedContainer(
                                                                                                  duration: Duration.zero,
                                                                                                  height: pickColor ? 290 : 37,
                                                                                                  child: Stack(
                                                                                                    children: [
                                                                                                      TabBar(
                                                                                                        dividerHeight: 0,
                                                                                                        indicatorSize: TabBarIndicatorSize.label,
                                                                                                        indicatorColor: defaultPalette.transparent,
                                                                                                        labelColor: defaultPalette.black,
                                                                                                        labelPadding: EdgeInsets.all(0),
                                                                                                        tabs: [
                                                                                                          //BG COLOR
                                                                                                          Tab(
                                                                                                            height: 30,
                                                                                                            child: Container(
                                                                                                              padding: EdgeInsets.all(2),
                                                                                                              margin: EdgeInsets.only(left: 5, right: 5),
                                                                                                              height: 30,
                                                                                                              width: width,
                                                                                                              alignment: Alignment.center,
                                                                                                              decoration: BoxDecoration(color: defaultPalette.primary.withOpacity(0.7), borderRadius: BorderRadius.circular(10)),
                                                                                                              child: Text(
                                                                                                                'Picker',
                                                                                                                style: GoogleFonts.abrilFatface(),
                                                                                                              ),
                                                                                                            ),
                                                                                                          ), //BG COLOR
                                                                                                          Tab(
                                                                                                            height: 30,
                                                                                                            child: Container(
                                                                                                              padding: EdgeInsets.all(2),
                                                                                                              margin: EdgeInsets.only(right: 5, left: 5),
                                                                                                              alignment: Alignment.center,
                                                                                                              height: 30,
                                                                                                              width: width,
                                                                                                              decoration: BoxDecoration(color: defaultPalette.primary.withOpacity(0.7), borderRadius: BorderRadius.circular(10)),
                                                                                                              child: Text(
                                                                                                                'Palette',
                                                                                                                style: GoogleFonts.abrilFatface(),
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                        ],
                                                                                                      ), //BG COLOR
                                                                                                      //PALLETETEPICKER
                                                                                                      Positioned(
                                                                                                        top: 35,
                                                                                                        width: width - 16,
                                                                                                        height: 210,
                                                                                                        child: TabBarView(
                                                                                                          physics: NeverScrollableScrollPhysics(),
                                                                                                          children: [
                                                                                                            SingleChildScrollView(
                                                                                                              physics: NeverScrollableScrollPhysics(),
                                                                                                              child: Padding(
                                                                                                                padding: const EdgeInsets.all(8),
                                                                                                                child: ColorPicker(
                                                                                                                  portraitOnly: true,
                                                                                                                  pickerAreaBorderRadius: BorderRadius.circular(12),
                                                                                                                  colorPickerWidth: 300,
                                                                                                                  labelTypes: [],
                                                                                                                  pickerColor: hexToColor(item.textEditorController.getSelectionStyle().attributes['background']?.value),
                                                                                                                  onColorChanged: (color) {
                                                                                                                    item.textEditorController.formatSelection(
                                                                                                                      BackgroundAttribute('#${colorToHex(color)}'),
                                                                                                                    );
                                                                                                                    setState(() {
                                                                                                                      bghexController.text = '${item.textEditorController.getSelectionStyle().attributes['background']?.value}';
                                                                                                                    });
                                                                                                                  },
                                                                                                                  pickerAreaHeightPercent: 0.4,
                                                                                                                ),
                                                                                                              ),
                                                                                                            ), //BG COLOR
                                                                                                            SingleChildScrollView(
                                                                                                              physics: NeverScrollableScrollPhysics(),
                                                                                                              child: Padding(
                                                                                                                padding: const EdgeInsets.all(8.0),
                                                                                                                child: MaterialPicker(
                                                                                                                  pickerColor: hexToColor(item.textEditorController.getSelectionStyle().attributes['background']?.value),
                                                                                                                  onColorChanged: (color) {
                                                                                                                    item.textEditorController.formatSelection(
                                                                                                                      BackgroundAttribute('#${colorToHex(color)}'),
                                                                                                                    );
                                                                                                                    setState(() {
                                                                                                                      bghexController.text = '${item.textEditorController.getSelectionStyle().attributes['background']?.value}';
                                                                                                                    });
                                                                                                                  },
                                                                                                                ),
                                                                                                              ),
                                                                                                            ),
                                                                                                          ], //BG COLOR
                                                                                                        ),
                                                                                                      ),
                                                                                                      //BG HEX TEXT LEFT
                                                                                                      Positioned(
                                                                                                        bottom: 0,
                                                                                                        width: width - 16,
                                                                                                        child: Container(
                                                                                                          padding: EdgeInsets.only(left: 5, right: 8, top: 8),
                                                                                                          height: textFieldHeight + 5, // Adjust this height according to your design
                                                                                                          child: TextFormField(
                                                                                                            controller: bghexController,
                                                                                                            onTapOutside: (event) {},
                                                                                                            onChanged: (value) {
                                                                                                              final color = hexToColor(value);

                                                                                                              item.textEditorController.formatSelection(
                                                                                                                BackgroundAttribute('#${colorToHex(color)}'),
                                                                                                              );
                                                                                                            }, //BG COLOR
                                                                                                            onFieldSubmitted: (value) {
                                                                                                              final color = hexToColor(value);

                                                                                                              item.textEditorController.formatSelection(
                                                                                                                BackgroundAttribute('#${colorToHex(color)}'),
                                                                                                              );
                                                                                                            },
                                                                                                            inputFormatters: [HexColorInputFormatter()], //BG COLOR
                                                                                                            textAlignVertical: TextAlignVertical.top,
                                                                                                            decoration: InputDecoration(
                                                                                                              prefixIcon: Icon(
                                                                                                                IconsaxPlusBold.text,
                                                                                                                size: 30,
                                                                                                              ),
                                                                                                              prefixIconColor: hexToColor(bghexController.text),
                                                                                                              suffixIcon: GestureDetector(
                                                                                                                onTap: () {
                                                                                                                  setState(() {
                                                                                                                    bghexController.text = 'null';
                                                                                                                    item.textEditorController.formatSelection(
                                                                                                                      BackgroundAttribute(null),
                                                                                                                    );
                                                                                                                  });
                                                                                                                },
                                                                                                                child: Icon(
                                                                                                                  TablerIcons.x,
                                                                                                                  size: 15,
                                                                                                                ),
                                                                                                              ),
                                                                                                              filled: true,
                                                                                                              fillColor: defaultPalette.primary.withOpacity(1),
                                                                                                              border: OutlineInputBorder(
                                                                                                                borderRadius: BorderRadius.circular(10.0),
                                                                                                              ),
                                                                                                              enabledBorder: OutlineInputBorder(
                                                                                                                borderSide: BorderSide(width: 2, color: defaultPalette.transparent),
                                                                                                                borderRadius: BorderRadius.circular(12.0),
                                                                                                              ),
                                                                                                              disabledBorder: OutlineInputBorder(
                                                                                                                borderSide: BorderSide(width: 2, color: Colors.black),
                                                                                                                borderRadius: BorderRadius.circular(12.0),
                                                                                                              ),
                                                                                                              focusedBorder: OutlineInputBorder(
                                                                                                                borderSide: BorderSide(width: 3, color: Colors.transparent),
                                                                                                                borderRadius: BorderRadius.circular(10.0),
                                                                                                              ), //BG COLOR
                                                                                                            ),
                                                                                                            cursorColor: hexToColor(item.textEditorController.getSelectionStyle().attributes['background']?.value),
                                                                                                            style: TextStyle(color: Colors.black, fontSize: 15),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ], //BG COLOR
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            )
                                                                                          ]),
                                                                                      //
                                                                                      buildElevatedLayerButton(
                                                                                        buttonHeight: 45,
                                                                                        buttonWidth: 45,
                                                                                        isTapped: pickColor,
                                                                                        animationDuration: const Duration(milliseconds: 100),
                                                                                        animationCurve: Curves.ease,
                                                                                        baseDecoration: BoxDecoration(
                                                                                          color: Colors.green,
                                                                                          border: Border.all(),
                                                                                        ),
                                                                                        topDecoration: BoxDecoration(
                                                                                          color: Colors.black,
                                                                                          border: Border.all(),
                                                                                        ),
                                                                                        topLayerChild: Icon(
                                                                                          Icons.color_lens,
                                                                                          color: Colors.white,
                                                                                          size: 20,
                                                                                        ),
                                                                                        borderRadius: BorderRadius.circular(10),
                                                                                        onClick: () {
                                                                                          setState(() {
                                                                                            pickColor = !pickColor;
                                                                                          });
                                                                                        },
                                                                                        toggleOnTap: true,
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              // QuillSimpleToolbar(configurations: item.toolBarConfigurations)
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                  ),
                                                                )
                                                            ],
                                                          ),
                                                        ),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    )),

                                ////////////////////RIGHT SCREEN PDF PREVIEW

                                Expanded(
                                  flex:
                                      ((1 - vDividerPosition) * 10000).toInt(),
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 300),
                                    // color: Colors.green,
                                    child: Center(
                                      child: PdfPreview(
                                        controller: pdfScrollController,
                                        build: (format) => _generatePdf(format),
                                        enableScrollToPage: true,
                                        allowSharing: true,
                                        allowPrinting: true,
                                        canChangeOrientation: false,
                                        canChangePageFormat: false,
                                        canDebug: true,
                                        actionBarTheme: PdfActionBarTheme(
                                          height: 55, // Reduced height
                                          actionSpacing: 2,
                                          backgroundColor:
                                              defaultPalette.transparent,
                                          alignment: WrapAlignment.end,
                                          iconColor: defaultPalette.black,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.end,
                                          runAlignment: WrapAlignment.end,
                                          elevation: 50,
                                        ),
                                        previewPageMargin: EdgeInsets.all(5),
                                        scrollViewDecoration: BoxDecoration(
                                            color: defaultPalette.transparent),
                                        useActions: true,
                                      ),
                                      //
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ///////////VERTICAL GRIP
                          Positioned(
                            left: vDividerPosition * sWidth + 12,
                            top: 20,
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 50),
                              width: 24,
                              height: 24,
                              color: Colors.transparent,
                              child: GestureDetector(
                                onPanUpdate: (details) {
                                  double newPosition = (vDividerPosition +
                                          details.delta.dx /
                                              context.size!.width)
                                      .clamp(0.4, 0.85);
                                  _updatevDividerPosition(newPosition);
                                },
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.drag_handle,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //////////Spread SHEET Layout
                    Expanded(
                      flex: (((1 - appbarHeight) - hDividerPosition) * 10000)
                          .round(),
                      child: Column(
                        children: [
                          ////////TOP TOOL BAR
                          Container(
                            height: sHeight / 20,
                            width: sWidth,
                            color: defaultPalette.white,
                            ///////TOP TOOL BAR
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ///Resize handle
                                GestureDetector(
                                    onPanUpdate: (details) {
                                      double newPosition = (hDividerPosition +
                                              details.delta.dy /
                                                  context.size!.height)
                                          .clamp(0.2, 0.85);
                                      _updatehDividerPosition(newPosition);
                                    },
                                    child: Transform.rotate(
                                      angle: math.pi / 2,
                                      child: Container(
                                        color: defaultPalette.tertiary,
                                        // padding: EdgeInsets.all(1),
                                        width: sWidth / 10,
                                        // height: 10,
                                        child: Icon(
                                          Icons.code_outlined,
                                          color: defaultPalette.primary,
                                          size: 25,
                                        ),
                                      ),
                                    )),

                                ///clearLayout Button
                                IconButton(
                                    onPressed: () {
                                      FocusScope.of(context).unfocus();
                                      if (panelIndex.panelIndex != -1) {
                                        final TextEditorItem textEditorItem =
                                            _sheetItemIterator(
                                                    panelIndex.id,
                                                    spreadSheetList[
                                                        currentPageIndex])
                                                as TextEditorItem;
                                        textEditorItem.focusNode.unfocus();
                                      }
                                      _confirmDeleteLayout(deletePage: false);
                                    },
                                    icon: Transform.rotate(
                                      angle: math.pi / 4,
                                      child: Icon(
                                        IconsaxPlusLinear.add,

                                        // size: 40,
                                        color: defaultPalette.black,
                                      ),
                                    )),
                                //ADD TEXT
                                IconButton(
                                    onPressed: () {
                                      print(
                                          '________addText pressed LD_________');
                                      // print(
                                      //     'panelId from addtextfield: ${panelIndex.id}');
                                      _addTextField();
                                    },
                                    icon: Icon(
                                      CupertinoIcons.plus_bubble,
                                      // size: 40,
                                      color: defaultPalette.black,
                                    )),
                                //Add Image
                                IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      IconsaxPlusLinear.gallery_add,
                                      // size: 40,
                                      color: defaultPalette.black,
                                    )),
                                //Add table
                                IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      CupertinoIcons.table,
                                      // size: 40,
                                      color: defaultPalette.black,
                                    )),
                                //Duplpicate
                                IconButton(
                                    onPressed: () => _duplicateTextField(),
                                    icon: Icon(
                                      CupertinoIcons.plus_square_on_square,
                                      // size: 40,
                                      color: defaultPalette.black,
                                    )),
                                IconButton(
                                    onPressed: () => _removeTextField(),
                                    icon: Icon(
                                      Icons.delete,
                                      // size: 40,
                                      color: defaultPalette.black,
                                    )),
                                Container(
                                  height: 25,
                                  width: sWidth / 7,
                                  color: defaultPalette.black,
                                  // margin: EdgeInsets.only(top: 10, bottom: 20),
                                  child: PageView(
                                    allowImplicitScrolling: true,
                                    physics: BouncingScrollPhysics(),
                                    scrollBehavior:
                                        const MaterialScrollBehavior(),
                                    controller: pageViewIndicatorController,
                                    onPageChanged: (value) {
                                      pagePropertiesViewController.jumpToPage(
                                        value,
                                        // duration:
                                        //     Duration(milliseconds: 500),
                                        // curve: Curves.easeIn
                                      );
                                      currentPageIndex = value;
                                    },
                                    children: [
                                      for (int i = 0; i < pageCount; i++)
                                        Center(
                                          child: Text(
                                            documentPropertiesList[i]
                                                .pageNumberController
                                                .text,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: defaultPalette.primary,
                                                fontSize: 20),
                                          ),
                                        )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ////// SPREADSHEET
                          Expanded(
                            flex: (8 * 10000),
                            child: Container(
                              // height: sHeight / 20,
                              width: sWidth,
                              color: defaultPalette.tertiary,
                              child: Stack(
                                children: [
                                  Builder(builder: (context) {
                                    List<Widget> widgetList = [];
                                    for (int index = 0;
                                        index <
                                            spreadSheetList[currentPageIndex]
                                                .length;
                                        index++) {
                                      if (spreadSheetList[currentPageIndex]
                                          [index] is TextEditorItem) {
                                        var textEditorItem =
                                            spreadSheetList[currentPageIndex]
                                                [index] as TextEditorItem;
                                        print(
                                            'editorID in buildWidget: ${spreadSheetList[currentPageIndex][index].id} ');
                                        widgetList.add(QuillEditor(
                                            configurations: textEditorItem
                                                .textEditorConfigurations,
                                            focusNode: textEditorItem.focusNode,
                                            scrollController: textEditorItem
                                                .scrollController));
                                      }
                                    }
                                    return Flex(
                                      direction: Axis.vertical,
                                      children: widgetList,
                                    );
                                  }),
                                  // StandardMarkdown(
                                  //     oninit: (config) {},
                                  //     mode: 0,
                                  //     toolbar: true,
                                  //     selectable: true,
                                  //     data: mdCunt),
                                  TextField(
                                    // 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                                    style: textStyle,
                                    textAlign: textAlign,
                                    maxLines: 10,
                                  ),
                                  TextStyleEditor(
                                    fonts: fonts,
                                    paletteColors: paletteColors,
                                    textStyle: textStyle,
                                    textAlign: textAlign,
                                    initialTool:
                                        EditorToolbarAction.fontFamilyTool,
                                    onTextAlignEdited: (align) {
                                      setState(() {
                                        textAlign = align;
                                      });
                                    },
                                    onTextStyleEdited: (style) {
                                      setState(() {
                                        textStyle = textStyle.merge(style);
                                      });
                                    },
                                    onCpasLockTaggle: (caps) {
                                      print(caps);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              //
              //BILLBLAZE MAIN TITLE
              AnimatedPositioned(
                duration: defaultDuration,
                top: topPadPosDistance - (topPadPosDistance / 1.1),
                left: leftPadPosDistance + (sWidth / 25),
                child: AnimatedTextKit(
                  // key: ValueKey(appinioLoop),
                  animatedTexts: [
                    TypewriterAnimatedText("Bill\nBlaze.",
                        textStyle: GoogleFonts.abrilFatface(
                            fontSize: titleFontSize / 4,
                            color: Color(0xFF000000).withOpacity(0.8),
                            height: 0.9),
                        speed: Duration(milliseconds: 100)),
                    TypewriterAnimatedText("Bill\nBlaze.",
                        textStyle: GoogleFonts.zcoolKuaiLe(
                            fontSize: titleFontSize / 4,
                            color: Color(0xFF000000).withOpacity(0.8),
                            height: 0.9),
                        speed: Duration(milliseconds: 100)),
                    TypewriterAnimatedText("Bill\nBlaze.",
                        textStyle: GoogleFonts.splash(
                            fontSize: titleFontSize / 4,
                            color: Color(0xFF000000).withOpacity(0.8),
                            height: 0.9),
                        speed: Duration(milliseconds: 100)),
                    TypewriterAnimatedText("Bill\nBlaze",
                        textStyle: GoogleFonts.libreBarcode39ExtendedText(
                            fontSize: titleFontSize / 4,
                            letterSpacing: 0,
                            height: 1),
                        speed: Duration(milliseconds: 100)),
                    TypewriterAnimatedText("Bill\nBlaze.",
                        textStyle: GoogleFonts.redactedScript(
                            fontSize: titleFontSize / 4,
                            color: Color(0xFF000000).withOpacity(0.8),
                            height: 0.9),
                        speed: Duration(milliseconds: 100)),
                    TypewriterAnimatedText("Bill\nBlaze.",
                        textStyle: GoogleFonts.fascinateInline(
                            fontSize: titleFontSize / 4,
                            color: Color(0xFF000000).withOpacity(0.8),
                            height: 0.9),
                        speed: Duration(milliseconds: 100)),
                    TypewriterAnimatedText("Bill\nBlaze.",
                        textStyle: GoogleFonts.nabla(
                            fontSize: titleFontSize / 4,
                            color: Color(0xFF000000).withOpacity(0.8),
                            height: 0.9),
                        speed: Duration(milliseconds: 100)),
                  ],
                  // totalRepeatCount: 1,
                  repeatForever: true,
                  pause: const Duration(milliseconds: 30000),
                  displayFullTextOnTap: true,
                  stopPauseOnTap: true,
                ),
              ),
              //
              //SIDE BAR BUTTON
              AnimatedPositioned(
                duration: sideBarPosDuration,
                top: (sHeight / 20) - (sHeight / 18),
                left: (sWidth / 40) - (sWidth / 12),
                child: ElevatedLayerButton(
                  onClick: () {},
                  buttonHeight: 60,
                  buttonWidth: 60,
                  borderRadius: BorderRadius.circular(100),
                  animationDuration: const Duration(milliseconds: 200),
                  animationCurve: Curves.ease,
                  topDecoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(),
                  ),
                  topLayerChild: Icon(
                    IconsaxPlusLinear.element_3,
                    size: 20,
                  ),
                  baseDecoration: BoxDecoration(
                    color: Colors.green,
                    border: Border.all(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildSpreadSheet(SheetList sheetList, int c) {
    List<Widget> widgetList = [];
    print('___builDSPREADsheet started___');
    print('sheelist id: ${sheetList.id}');

    print('_______END BUILD SPREADSHEET__________');
    return widgetList;
  }

  String getPageFormatString(PdfPageFormat format) {
    if (format == PdfPageFormat.a4) return 'A4';
    if (format == PdfPageFormat.a3) return 'A3';
    if (format == PdfPageFormat.letter) return 'Letter';
    if (format == PdfPageFormat.legal) return 'Legal';
    if (format == PdfPageFormat.roll57) return 'Roll 57';
    if (format == PdfPageFormat.roll80) return 'Roll 80';
    if (format == PdfPageFormat.a5) return 'A5';
    if (format == PdfPageFormat.a6) return 'A6';
    if (format == PdfPageFormat.standard) return 'Standard';
    return 'Unknown';
  }

  PdfPageFormat getPageFormatFromString(String format) {
    switch (format) {
      case 'A4':
        return PdfPageFormat.a4;
      case 'A3':
        return PdfPageFormat.a3;
      case 'A5':
        return PdfPageFormat.a5;
      case 'A6':
        return PdfPageFormat.a6;
      case 'Letter':
        return PdfPageFormat.letter;
      case 'Legal':
        return PdfPageFormat.legal;
      case 'Standard':
        return PdfPageFormat.standard;
      case 'Roll 57':
        return PdfPageFormat.roll57;
      case 'Roll 80':
        return PdfPageFormat.roll80;
      default:
        return PdfPageFormat.a4;
    }
  }

  //
}

class TextEditorButtonConfig {
  final IconData icon;
  final Function(TextEditorItem) onClick;
  final bool isTapped;

  TextEditorButtonConfig({
    required this.icon,
    required this.onClick,
    required this.isTapped,
  });
}

class ColorPickerButton extends StatefulWidget {
  final double buttonHeight;
  final double buttonWidth;
  final Duration animationDuration;
  final Curve animationCurve;
  final BoxDecoration baseDecoration;
  final BoxDecoration topDecoration;
  final Widget topLayerChild;
  final BorderRadius borderRadius;
  final void Function(Color) onColorChanged;
  final bool toggleOnTap;

  const ColorPickerButton({
    required this.buttonHeight,
    required this.buttonWidth,
    required this.animationDuration,
    required this.animationCurve,
    required this.baseDecoration,
    required this.topDecoration,
    required this.topLayerChild,
    required this.borderRadius,
    required this.onColorChanged,
    this.toggleOnTap = false,
  });

  @override
  _ColorPickerButtonState createState() => _ColorPickerButtonState();
}

class _ColorPickerButtonState extends State<ColorPickerButton> {
  bool _isPickerVisible = false;

  void _toggleColorPicker() {
    setState(() {
      _isPickerVisible = !_isPickerVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: widget.toggleOnTap ? _toggleColorPicker : null,
          onTapDown: widget.toggleOnTap ? (_) => setState(() {}) : null,
          onTapUp: widget.toggleOnTap ? (_) => setState(() {}) : null,
          onTapCancel: widget.toggleOnTap ? () => setState(() {}) : null,
          child: SizedBox(
            height: widget.buttonHeight,
            width: widget.buttonWidth,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: widget.buttonWidth - 10,
                    height: widget.buttonHeight - 10,
                    decoration: widget.baseDecoration.copyWith(
                      borderRadius: widget.borderRadius,
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: widget.animationDuration,
                  curve: widget.animationCurve,
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: widget.buttonWidth - 10,
                    height: widget.buttonHeight - 10,
                    alignment: Alignment.center,
                    decoration: widget.topDecoration.copyWith(
                      borderRadius: widget.borderRadius,
                    ),
                    child: widget.topLayerChild,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedContainer(
          duration: widget.animationDuration,
          curve: widget.animationCurve,
          height: _isPickerVisible ? 200 : 0, // Adjust the height as needed
          child: ColorPicker(
            pickerColor: Colors.black,
            onColorChanged: widget.onColorChanged,
            showLabel: false,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
      ],
    );
  }
}
