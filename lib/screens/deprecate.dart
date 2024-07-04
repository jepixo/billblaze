// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:collection/collection.dart';

import 'package:billblaze/colors.dart';
import 'package:billblaze/components/printing.dart'
    if (dart.library.html) 'package:printing/printing.dart';
// import 'package:printing/printing.dart';
import 'package:billblaze/components/spread_sheet.dart';
import 'package:billblaze/components/spread_sheet_lib/drag_drop_state.dart';
import 'package:billblaze/components/spread_sheet_lib/sheet_list.dart';
import 'package:billblaze/components/spread_sheet_lib/text_editor_item.dart';
import 'package:billblaze/models/DocumentPropertiesModel.dart';
import 'package:billblaze/models/TextFieldControllerModel.dart';
import 'package:billblaze/models/WidgetNodeModel.dart';
import 'package:billblaze/util/HexColorInputFormatter.dart';
import 'package:billblaze/util/numeric_input_filter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart' as hsv;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// import 'package:pdf/widgets.dart';
import 'package:simple_animated_button/simple_animated_button.dart';
import 'dart:math' as math;

import 'package:uuid/uuid.dart';

class LayoutDesigner extends StatefulWidget {
  const LayoutDesigner({super.key});

  @override
  State<LayoutDesigner> createState() => _LayoutDesignerState();
}

class _LayoutDesignerState extends State<LayoutDesigner> {
  double hDividerPosition = 0.5;
  double vDividerPosition = 0.5;
  bool isExpanded = false;
  // int selectedIndex = -1;
  int pageCount = 0;
  int currentPageIndex = 0;
  bool isReordering = false;
  bool isColorPickerExpanded = false;
  bool useIndividualMargins = false;
  pw.Document? _pdfDocument;
  List<TextFieldController> textFieldControllers = [];
  List<DocumentProperties> documentPropertiesList = [];
  List<int> selectedIndex = [];
  PageController pagePropertiesViewController = PageController();
  PageController pageViewIndicatorController = PageController();
  PageController pageTextFieldsController = PageController();
  ScrollController pdfScrollController = ScrollController();
  LayoutWidgetNode widgetNodes = LayoutWidgetNode(page: []);
  // ParchmentDocument document = ParchmentDocument();
  // FleatherController controller = FleatherController(
  //   document: ParchmentDocument.fromJson([
  //     {"insert": "Enter Text Here !\n"}
  //   ]),
  // );
  QuillController _controller = QuillController.basic();

  @override
  void initState() {
    super.initState();
    // animateToPage(currentPageIndex);
    _addPdfPage();
    _updatePdfPreview('');
  }

  @override
  void dispose() {
    pagePropertiesViewController.dispose();
    pageViewIndicatorController.dispose();
    super.dispose();
  }

  List<TextFieldController> initializeTextFieldControllers() {
    TextEditingController controller = TextEditingController();
    TextEditingController hintController =
        TextEditingController(text: 'New Text Field');
    FocusNode hintFocusNode = FocusNode();
    TextEditingController hintSizeController =
        TextEditingController(text: '14');
    FocusNode hintSizeFocusNode = FocusNode();
    TextEditingController colorController =
        TextEditingController(text: '#000000');
    FocusNode colorFocusNode = FocusNode();
    FocusNode focusNode = FocusNode();
    TextAlign textAlign = TextAlign.start;

    var textFieldController = TextFieldController(
      id: Uuid(),
      textController: controller,
      hintController: hintController,
      hintFocusController: hintFocusNode,
      hintSizeController: hintSizeController,
      hintSizeFocusController: hintSizeFocusNode,
      colorController: colorController,
      colorFocusController: colorFocusNode,
      focusController: focusNode,
      decoration: InputDecoration(
        hintText: 'New Text Field',
      ),
      style: TextStyle(color: Colors.black, fontSize: 14),
      textAlign: textAlign,
    );

    documentPropertiesList[currentPageIndex]
        .textFieldControllers
        .add(textFieldController);
    // widgetNodes[currentPageIndex]
    //     .nodeFieldProperties
    //     .add(textFieldController);
    return documentPropertiesList[currentPageIndex].textFieldControllers;
  }

  void _updateTextFieldProperties(String key, dynamic value) {
    setState(() {
      if (key == 'textStyle') {
        TextStyle currentStyle = documentPropertiesList[currentPageIndex]
            .textFieldControllers[selectedIndex[currentPageIndex]]
            .style;

        documentPropertiesList[currentPageIndex]
            .textFieldControllers[selectedIndex[currentPageIndex]]
            .style = currentStyle.copyWith(
          color: value['color'] ?? currentStyle.color,
          fontSize: value['fontSize'] ?? currentStyle.fontSize,
          fontWeight: value['fontWeight'] ?? currentStyle.fontWeight,
          fontStyle: value['fontStyle'] ?? currentStyle.fontStyle,
          decoration: value['decoration'] ?? currentStyle.decoration,
        );
      } else {
        // Update other properties
        switch (key) {
          case 'hintText':
            documentPropertiesList[currentPageIndex]
                    .textFieldControllers[selectedIndex[currentPageIndex]]
                    .decoration =
                documentPropertiesList[currentPageIndex]
                    .textFieldControllers[selectedIndex[currentPageIndex]]
                    .decoration
                    .copyWith(hintText: value);
            break;
          case 'labelText':
            documentPropertiesList[currentPageIndex]
                    .textFieldControllers[selectedIndex[currentPageIndex]]
                    .decoration =
                documentPropertiesList[currentPageIndex]
                    .textFieldControllers[selectedIndex[currentPageIndex]]
                    .decoration
                    .copyWith(labelText: value);
            break;
          case 'hintTextSize':
            documentPropertiesList[currentPageIndex]
                .textFieldControllers[selectedIndex[currentPageIndex]]
                .hintSizeController
                .text = value.toString();
            break;
          default:
            break;
        }
      }
    });
  }

  void _addTextField() {
    setState(() {
      initializeTextFieldControllers();
      isExpanded = false;
    });
  }

  void _toggleColorPicker() {
    setState(() {
      isColorPickerExpanded = !isColorPickerExpanded;
    });
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
      selectedIndex[currentPageIndex] = index;
    });
  }

  void _deselectTextField() {
    setState(() {
      if (selectedIndex != []) {
        selectedIndex[currentPageIndex] = 9999999;
      }
    });
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
                documentPropertiesList[currentPageIndex]
                    .textFieldControllers
                    .clear();
                _deselectTextField();
                if (deletePage) {
                  if (currentPageIndex == documentPropertiesList.length - 1) {
                    Future.delayed(Duration(milliseconds: 20)).then(
                      (value) => _deletePage(),
                    );
                  } else {
                    _deletePage();
                  }
                }
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
    FocusNode hintFocusNode = FocusNode();
    FocusNode hintSizeFocusNode = FocusNode();
    FocusNode colorFocusNode = FocusNode();
    FocusNode focusNode = FocusNode();
    if (selectedIndex[currentPageIndex] != 9999999) {
      setState(() {
        final controller = documentPropertiesList[currentPageIndex]
            .textFieldControllers[selectedIndex[currentPageIndex]];
        final newController = TextFieldController(
            textController:
                TextEditingController(text: controller.textController.text),
            hintController:
                TextEditingController(text: controller.hintController.text),
            hintSizeController:
                TextEditingController(text: controller.hintSizeController.text),
            colorController:
                TextEditingController(text: controller.colorController.text),
            style: controller.style,
            focusController: focusNode,
            colorFocusController: colorFocusNode,
            decoration: controller.decoration,
            hintFocusController: hintFocusNode,
            hintSizeFocusController: hintSizeFocusNode,
            textAlign: controller.textAlign,
            id: Uuid());
        documentPropertiesList[currentPageIndex]
            .textFieldControllers
            .insert(selectedIndex[currentPageIndex] + 1, newController);
        selectedIndex[currentPageIndex]++;
      });
    }
  }

  void _removeTextField() {
    if (selectedIndex[currentPageIndex] != 999999) {
      setState(() {
        documentPropertiesList[currentPageIndex]
            .textFieldControllers
            .removeAt(selectedIndex[currentPageIndex]);
        if (selectedIndex[currentPageIndex] >=
            documentPropertiesList[currentPageIndex]
                .textFieldControllers
                .length) {
          selectedIndex[currentPageIndex] =
              documentPropertiesList[currentPageIndex]
                      .textFieldControllers
                      .length -
                  1;
        }
      });
    }
  }

  Widget buildHead(String _color) {
    Color color;
    try {
      color = Color(int.parse(_color));
      setState(() {
        _updateTextFieldProperties('labelText', '');
      });
      _updateTextFieldProperties('textStyle', {'color': color});
    } catch (e) {
      setState(() {
        _updateTextFieldProperties('labelText', 'Invalid color');
      });
      color = Color(0xff00000);
    }
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTap: _toggleColorPicker,
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                border: Border.fromBorderSide(
                  BorderSide(color: Colors.black26),
                ),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: const Border.fromBorderSide(
                    BorderSide(color: Colors.white, width: 3),
                  ),
                  color: color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    for (int i = 0; i < pageCount; i++) {
      var doc = documentPropertiesList[i];

      pdf.addPage(
        pw.MultiPage(
          margin: pw.EdgeInsets.only(
            top: double.parse(doc.marginTopController.text),
            bottom: double.parse(doc.marginBottomController.text),
            left: double.parse(doc.marginLeftController.text),
            right: double.parse(doc.marginRightController.text),
          ),
          build: (pw.Context context) {
            return [
              pw.Column(
                children: [
                  for (int j = 0; j < doc.textFieldControllers.length; j++)
                    if (double.parse(doc
                            .textFieldControllers[j].hintSizeController.text) !=
                        0)
                      pw.Center(
                        child: pw.Text(
                          doc.textFieldControllers[j].textController.text
                                  .isEmpty
                              ? 'No text entered'
                              : doc.textFieldControllers[j].textController.text,
                          style: pw.TextStyle(
                            color: PdfColor.fromInt(
                              doc.textFieldControllers[j].style.color?.value ??
                                  0xff000000,
                            ),
                            fontSize: double.parse(doc.textFieldControllers[j]
                                .hintSizeController.text),
                          ),
                        ),
                      ),
                ],
              ),
            ];
          },
        ),
      );
    }

    return pdf.save();
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
        DocumentProperties(
            pageNumberController:
                TextEditingController(text: (++pageCount).toString()),
            marginAllController: TextEditingController(text: '10'),
            marginLeftController: TextEditingController(text: '10'),
            marginRightController: TextEditingController(text: '10'),
            marginBottomController: TextEditingController(text: '10'),
            marginTopController: TextEditingController(text: '10'),
            orientationController: TextEditingController(text: 'portrait'),
            pageFormatController: TextEditingController(text: 'A4'),
            textFieldControllers: []),
      );
      print('pageCount in addpage after: $pageCount');
      selectedIndex.add(9999999);
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

  void _deletePage() {
    if (documentPropertiesList[currentPageIndex].textFieldControllers.isEmpty) {
      if (currentPageIndex == 0) {
        // If the deleted page is the last page
        return;
      }
      pdfScrollController.animateTo(
          (currentPageIndex - 1) *
              ((1.41428571429 *
                      ((MediaQuery.of(context).size.width *
                              (1 - vDividerPosition)) -
                          16)) +
                  16),
          duration: Duration(milliseconds: 100),
          curve: Curves.easeIn);
      pagePropertiesViewController.animateToPage(currentPageIndex - 1,
          duration: Duration(milliseconds: 200), curve: Curves.easeIn);
      pageTextFieldsController.animateToPage(currentPageIndex - 1,
          duration: Duration(milliseconds: 200), curve: Curves.easeIn);

      pageCount--;
      documentPropertiesList.removeAt(currentPageIndex);

      // Renumber the remaining pages
      for (int i = currentPageIndex; i < documentPropertiesList.length; i++) {
        documentPropertiesList[i].pageNumberController.text =
            (int.parse(documentPropertiesList[i].pageNumberController.text) - 1)
                .toString();
      }
    } else {
      _confirmDeleteLayout(deletePage: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    double sHeight = MediaQuery.of(context).size.height;
    double sWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Container(
          color: defaultPalette.secondary,
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
                      flex: (hDividerPosition * 10000).round(),
                      child: Stack(
                        children: [
                          AnimatedPositioned(
                            duration: Duration(milliseconds: 300),
                            child: Row(
                              children: [
                                /////////////////////LEFT
                                Expanded(
                                    flex: (vDividerPosition * 10000).toInt(),
                                    child: SafeArea(
                                      child: Stack(
                                        children: [
                                          Container(
                                            // duration: Duration(milliseconds: 100),
                                            height: sHeight * hDividerPosition,
                                            color: defaultPalette.primary,
                                          ),
                                          Positioned(
                                            // duration: Duration(milliseconds: 100),
                                            top: 0,
                                            left: selectedIndex[
                                                        currentPageIndex] !=
                                                    9999999
                                                ? sWidth * vDividerPosition
                                                : 0,
                                            height: sHeight * hDividerPosition,
                                            width: sWidth * vDividerPosition,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: Material(
                                                color: defaultPalette.primary,
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
                                                                'Document Properties',
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .fade,
                                                                style: TextStyle(
                                                                    color: defaultPalette
                                                                        .secondary,
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold)),
                                                          ),
                                                          //nextprev buittons
                                                          Positioned(
                                                            right: 0,
                                                            child: Container(
                                                              color: defaultPalette
                                                                  .black
                                                                  .withOpacity(
                                                                      0.4),
                                                              margin: EdgeInsets
                                                                  .only(top: 5),
                                                              height: 45,
                                                              width: 80,
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
                                                                          .secondary,
                                                                    ),
                                                                    onTap: () {
                                                                      setState(
                                                                          () {
                                                                        if (currentPageIndex ==
                                                                            0) {
                                                                          return;
                                                                        }

                                                                        currentPageIndex--;

                                                                        pagePropertiesViewController.animateToPage(
                                                                            currentPageIndex,
                                                                            duration:
                                                                                Duration(milliseconds: 100),
                                                                            curve: Curves.easeIn);
                                                                        pageViewIndicatorController.animateToPage(
                                                                            currentPageIndex,
                                                                            duration:
                                                                                Duration(milliseconds: 100),
                                                                            curve: Curves.easeIn);
                                                                        pdfScrollController.animateTo(
                                                                            currentPageIndex *
                                                                                ((1.41428571429 * ((sWidth * (1 - vDividerPosition)) - 16)) + 16),
                                                                            duration: Duration(milliseconds: 100),
                                                                            curve: Curves.easeIn);
                                                                      });
                                                                    },
                                                                  ),
                                                                  GestureDetector(
                                                                    child: Icon(
                                                                      Icons
                                                                          .keyboard_arrow_right_sharp,
                                                                      color: defaultPalette
                                                                          .secondary,
                                                                    ),
                                                                    onTap: () {
                                                                      setState(
                                                                          () {
                                                                        if (pageCount ==
                                                                            (currentPageIndex +
                                                                                1)) {
                                                                          _addPdfPage();
                                                                        }

                                                                        currentPageIndex++;

                                                                        pdfScrollController.animateTo(
                                                                            currentPageIndex *
                                                                                ((1.41428571429 * ((sWidth * (1 - vDividerPosition)) - 16)) + 16),
                                                                            duration: Duration(milliseconds: 100),
                                                                            curve: Curves.easeIn);
                                                                        pagePropertiesViewController.animateToPage(
                                                                            currentPageIndex,
                                                                            duration:
                                                                                Duration(milliseconds: 100),
                                                                            curve: Curves.easeIn);
                                                                        pageViewIndicatorController.animateToPage(
                                                                            currentPageIndex,
                                                                            duration:
                                                                                Duration(milliseconds: 100),
                                                                            curve: Curves.easeIn);
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
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: SizedBox(
                                                              height: 55,
                                                              child:
                                                                  TextFormField(
                                                                      onTapOutside:
                                                                          (event) {
                                                                        FocusScope.of(context)
                                                                            .unfocus();
                                                                      },
                                                                      cursorColor:
                                                                          defaultPalette
                                                                              .secondary,
                                                                      controller:
                                                                          documentPropertiesList[currentPageIndex]
                                                                              .pageNumberController,
                                                                      inputFormatters: [
                                                                        FilteringTextInputFormatter.allow(
                                                                            RegExp(r'^\d*\.?\d*$'))
                                                                      ],
                                                                      decoration: InputDecoration(
                                                                          labelText:
                                                                              'Page Number',
                                                                          labelStyle: TextStyle(
                                                                              color: defaultPalette
                                                                                  .secondary),
                                                                          filled:
                                                                              true,
                                                                          fillColor: Colors
                                                                              .black38,
                                                                          border: InputBorder
                                                                              .none),
                                                                      keyboardType:
                                                                          TextInputType
                                                                              .number,
                                                                      style: TextStyle(
                                                                          color: defaultPalette
                                                                              .secondary),
                                                                      enabled:
                                                                          false,
                                                                      onChanged:
                                                                          (value) {
                                                                        _updatePdfPreview;
                                                                        _addPdfPage();
                                                                      }),
                                                            ),
                                                          ),
                                                          GestureDetector(
                                                            child: IconButton(
                                                              icon: Icon(
                                                                Icons
                                                                    .delete_outline_rounded,
                                                                color: defaultPalette
                                                                    .secondary,
                                                              ),
                                                              onPressed: () {
                                                                _deletePage();
                                                              },
                                                            ),
                                                          )
                                                        ],
                                                      ),

                                                      //pageview leftside document props
                                                      SingleChildScrollView(
                                                        child: Container(
                                                          width: sWidth *
                                                                  vDividerPosition -
                                                              20,
                                                          height: sHeight *
                                                                  hDividerPosition -
                                                              20,
                                                          child: PageView(
                                                            allowImplicitScrolling:
                                                                true,
                                                            physics:
                                                                BouncingScrollPhysics(),
                                                            scrollBehavior:
                                                                const MaterialScrollBehavior(),
                                                            controller:
                                                                pagePropertiesViewController,
                                                            onPageChanged:
                                                                (value) {
                                                              setState(() {
                                                                currentPageIndex =
                                                                    value;
                                                                pageViewIndicatorController.animateToPage(
                                                                    value,
                                                                    duration: Duration(
                                                                        milliseconds:
                                                                            100),
                                                                    curve: Curves
                                                                        .easeIn);
                                                                pageTextFieldsController.animateToPage(
                                                                    value,
                                                                    duration: Duration(
                                                                        milliseconds:
                                                                            100),
                                                                    curve: Curves
                                                                        .easeIn);
                                                              });
                                                            },
                                                            children: [
                                                              for (int i = 0;
                                                                  i < pageCount;
                                                                  i++)
                                                                SingleChildScrollView(
                                                                  child: Column(
                                                                    children: [
                                                                      SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Expanded(
                                                                            child:
                                                                                TextFormField(
                                                                              onTapOutside: (event) {
                                                                                FocusScope.of(context).unfocus();
                                                                              },
                                                                              controller: documentPropertiesList[i].marginAllController,
                                                                              inputFormatters: [
                                                                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))
                                                                              ],
                                                                              decoration: InputDecoration(labelText: 'Margin', labelStyle: TextStyle(color: defaultPalette.secondary), filled: true, fillColor: !useIndividualMargins ? Colors.black38 : Colors.black12.withOpacity(0.2), border: InputBorder.none),
                                                                              keyboardType: TextInputType.number,
                                                                              style: TextStyle(
                                                                                  // fontStyle: FontStyle.italic,
                                                                                  color: defaultPalette.secondary),
                                                                              onChanged: (value) {
                                                                                _updatePdfPreview;
                                                                                documentPropertiesList[i].marginTopController.text = value;
                                                                                documentPropertiesList[i].marginBottomController.text = value;
                                                                                documentPropertiesList[i].marginLeftController.text = value;
                                                                                documentPropertiesList[i].marginRightController.text = value;
                                                                              },
                                                                              enabled: !useIndividualMargins,
                                                                            ),
                                                                          ),
                                                                          IconButton(
                                                                              onPressed: () {
                                                                                setState(() {
                                                                                  useIndividualMargins = !useIndividualMargins;
                                                                                  if (useIndividualMargins == false) {
                                                                                    documentPropertiesList[i].marginTopController.text = documentPropertiesList[i].marginAllController.text;
                                                                                    documentPropertiesList[i].marginBottomController.text = documentPropertiesList[i].marginAllController.text;
                                                                                    documentPropertiesList[i].marginLeftController.text = documentPropertiesList[i].marginAllController.text;
                                                                                    documentPropertiesList[i].marginRightController.text = documentPropertiesList[i].marginAllController.text;
                                                                                  }
                                                                                });
                                                                              },
                                                                              icon: Icon(Icons.expand_outlined))
                                                                          // Text(
                                                                          //     'Use Individual Margins'),
                                                                        ],
                                                                      ),
                                                                      if (useIndividualMargins)
                                                                        Column(
                                                                          children: [
                                                                            Row(
                                                                              children: [
                                                                                Expanded(
                                                                                  child: TextFormField(
                                                                                    onTapOutside: (event) {
                                                                                      FocusScope.of(context).unfocus();
                                                                                    },
                                                                                    controller: documentPropertiesList[i].marginTopController,
                                                                                    inputFormatters: [
                                                                                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))
                                                                                    ],
                                                                                    style: TextStyle(color: defaultPalette.secondary),
                                                                                    cursorColor: defaultPalette.secondary,
                                                                                    decoration: InputDecoration(labelText: 'Top', labelStyle: TextStyle(color: defaultPalette.secondary), filled: true, fillColor: Colors.black38, border: InputBorder.none),
                                                                                    keyboardType: TextInputType.number,
                                                                                    onChanged: (value) => _updatePdfPreview,
                                                                                  ),
                                                                                ),
                                                                                Expanded(
                                                                                  child: TextFormField(
                                                                                    onTapOutside: (event) {
                                                                                      FocusScope.of(context).unfocus();
                                                                                    },
                                                                                    controller: documentPropertiesList[i].marginBottomController,
                                                                                    inputFormatters: [
                                                                                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))
                                                                                    ],
                                                                                    style: TextStyle(color: defaultPalette.secondary),
                                                                                    cursorColor: defaultPalette.secondary,
                                                                                    decoration: InputDecoration(labelText: 'Bottom', labelStyle: TextStyle(color: defaultPalette.secondary), filled: true, fillColor: Colors.black38, border: InputBorder.none),
                                                                                    keyboardType: TextInputType.number,
                                                                                    onChanged: (value) => _updatePdfPreview,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            Row(
                                                                              children: [
                                                                                Expanded(
                                                                                  child: TextFormField(
                                                                                    onTapOutside: (event) {
                                                                                      FocusScope.of(context).unfocus();
                                                                                    },
                                                                                    controller: documentPropertiesList[i].marginLeftController,
                                                                                    inputFormatters: [
                                                                                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))
                                                                                    ],
                                                                                    style: TextStyle(color: defaultPalette.secondary),
                                                                                    cursorColor: defaultPalette.secondary,
                                                                                    decoration: InputDecoration(labelText: 'Left', labelStyle: TextStyle(color: defaultPalette.secondary), filled: true, fillColor: Colors.black38, border: InputBorder.none),
                                                                                    keyboardType: TextInputType.number,
                                                                                    onChanged: (value) => {
                                                                                      _updatePdfPreview
                                                                                    },
                                                                                  ),
                                                                                ),
                                                                                Expanded(
                                                                                  child: TextFormField(
                                                                                    onTapOutside: (event) {
                                                                                      FocusScope.of(context).unfocus();
                                                                                    },
                                                                                    controller: documentPropertiesList[i].marginRightController,
                                                                                    style: TextStyle(color: defaultPalette.secondary),
                                                                                    cursorColor: defaultPalette.secondary,
                                                                                    inputFormatters: [
                                                                                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))
                                                                                    ],
                                                                                    decoration: InputDecoration(labelText: 'Right', labelStyle: TextStyle(color: defaultPalette.secondary), filled: true, fillColor: Colors.black38, border: InputBorder.none),
                                                                                    keyboardType: TextInputType.number,
                                                                                    onChanged: (value) => _updatePdfPreview,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        ),

                                                                      SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      TextFormField(
                                                                        onTapOutside:
                                                                            (event) {
                                                                          FocusScope.of(context)
                                                                              .unfocus();
                                                                        },
                                                                        controller:
                                                                            documentPropertiesList[i].orientationController,
                                                                        style: TextStyle(
                                                                            color:
                                                                                defaultPalette.secondary),
                                                                        cursorColor:
                                                                            defaultPalette.secondary,
                                                                        decoration: InputDecoration(
                                                                            labelText:
                                                                                'Orientation',
                                                                            labelStyle:
                                                                                TextStyle(color: defaultPalette.secondary),
                                                                            filled: true,
                                                                            fillColor: Colors.black38,
                                                                            border: InputBorder.none),
                                                                        onChanged:
                                                                            (value) =>
                                                                                _updatePdfPreview,
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      TextFormField(
                                                                        onTapOutside:
                                                                            (event) {
                                                                          FocusScope.of(context)
                                                                              .unfocus();
                                                                        },
                                                                        cursorColor:
                                                                            defaultPalette.secondary,
                                                                        controller:
                                                                            documentPropertiesList[i].pageFormatController,
                                                                        style: TextStyle(
                                                                            color:
                                                                                defaultPalette.secondary),
                                                                        decoration: InputDecoration(
                                                                            labelText:
                                                                                'Page Format',
                                                                            labelStyle:
                                                                                TextStyle(color: defaultPalette.secondary),
                                                                            filled: true,
                                                                            fillColor: Colors.black38,
                                                                            border: InputBorder.none),
                                                                        onChanged:
                                                                            (value) =>
                                                                                _updatePdfPreview,
                                                                      ),

                                                                      // Divider(),
                                                                    ],
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            // duration: Duration(milliseconds: 10),
                                            top: 0,
                                            left: selectedIndex[
                                                        currentPageIndex] ==
                                                    9999999
                                                ? sWidth * vDividerPosition
                                                : 0,
                                            child: Material(
                                              child: AnimatedContainer(
                                                duration:
                                                    Duration(milliseconds: 100),
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    hDividerPosition,
                                                width:
                                                    sWidth * vDividerPosition,
                                                color: defaultPalette.primary,
                                                child: selectedIndex[
                                                            currentPageIndex] ==
                                                        9999999
                                                    ? Text('data')
                                                    : SingleChildScrollView(
                                                        physics:
                                                            BouncingScrollPhysics(),
                                                        child: SafeArea(
                                                          child: Column(
                                                            children: [
                                                              Container(
                                                                height: 60,
                                                                width: sWidth *
                                                                    vDividerPosition,
                                                                child: Stack(
                                                                  children: [
                                                                    SizedBox(
                                                                      width: sWidth *
                                                                          vDividerPosition,
                                                                      height:
                                                                          60,
                                                                    ),
                                                                    IconButton(
                                                                        // iconSize: sWidth*vDividerPosition*0.4,
                                                                        onPressed:
                                                                            () {
                                                                          _deselectTextField();
                                                                        },
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .arrow_back_ios,
                                                                          color:
                                                                              defaultPalette.secondary,
                                                                          size:
                                                                              20,
                                                                        )),
                                                                    Positioned(
                                                                      left: 40,
                                                                      top: 12,
                                                                      child:
                                                                          Text(
                                                                        'Text Properties',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                18,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color: defaultPalette.secondary),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                              Container(
                                                                color: Colors
                                                                    .transparent,
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        // vertical: 10,
                                                                        horizontal:
                                                                            8),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    /////////////////////////HINT TEXT

                                                                    TextFormField(
                                                                      scrollPhysics:
                                                                          BouncingScrollPhysics(),
                                                                      onTapOutside:
                                                                          (d) {
                                                                        documentPropertiesList[currentPageIndex]
                                                                            .textFieldControllers[selectedIndex[currentPageIndex]]
                                                                            .hintFocusController
                                                                            .unfocus();
                                                                      },
                                                                      focusNode: documentPropertiesList[
                                                                              currentPageIndex]
                                                                          .textFieldControllers[
                                                                              selectedIndex[currentPageIndex]]
                                                                          .hintFocusController,
                                                                      onChanged:
                                                                          (value) {
                                                                        _updateTextFieldProperties(
                                                                            'hintText',
                                                                            value);
                                                                      },
                                                                      controller: documentPropertiesList[
                                                                              currentPageIndex]
                                                                          .textFieldControllers[
                                                                              selectedIndex[currentPageIndex]]
                                                                          .hintController,
                                                                      style: TextStyle(
                                                                          color:
                                                                              defaultPalette.secondary),
                                                                      decoration: InputDecoration(
                                                                          labelText:
                                                                              'Label Text',
                                                                          labelStyle: TextStyle(
                                                                              color: defaultPalette
                                                                                  .secondary),
                                                                          filled:
                                                                              true,
                                                                          fillColor: Colors
                                                                              .black38,
                                                                          border:
                                                                              InputBorder.none),
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            10),
                                                                    //////////////////////////////SIZE

                                                                    ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              0),
                                                                      child:
                                                                          TextFormField(
                                                                        scrollPhysics:
                                                                            BouncingScrollPhysics(),
                                                                        onTapOutside:
                                                                            (d) {
                                                                          documentPropertiesList[currentPageIndex]
                                                                              .textFieldControllers[selectedIndex[currentPageIndex]]
                                                                              .hintSizeFocusController
                                                                              .unfocus();
                                                                        },
                                                                        focusNode: documentPropertiesList[currentPageIndex]
                                                                            .textFieldControllers[selectedIndex[currentPageIndex]]
                                                                            .hintSizeFocusController,
                                                                        inputFormatters: [
                                                                          FilteringTextInputFormatter.allow(
                                                                              RegExp(r'^\d*\.?\d*$')),
                                                                          TextInputFormatter.withFunction((oldValue,
                                                                              newValue) {
                                                                            if (newValue.text.isEmpty) {
                                                                              return TextEditingValue(
                                                                                text: '0',
                                                                                selection: TextSelection.fromPosition(
                                                                                  TextPosition(offset: 1),
                                                                                ),
                                                                              );
                                                                            }

                                                                            final newText =
                                                                                newValue.text.replaceAll(RegExp(r'^0+(?=\d)'), '');

                                                                            return newValue.copyWith(
                                                                              text: newText,
                                                                              selection: TextSelection.fromPosition(
                                                                                TextPosition(offset: newText.length),
                                                                              ),
                                                                            );
                                                                          }),
                                                                        ],
                                                                        onChanged:
                                                                            (value) {
                                                                          value == ''
                                                                              ? value = '0'
                                                                              : value = value;
                                                                          try {
                                                                            _updateTextFieldProperties('textStyle', {
                                                                              'fontSize': double.parse(value)
                                                                            });
                                                                          } on Exception {
                                                                            return;
                                                                          }
                                                                        },
                                                                        controller: documentPropertiesList[currentPageIndex]
                                                                            .textFieldControllers[selectedIndex[currentPageIndex]]
                                                                            .hintSizeController,
                                                                        keyboardType:
                                                                            TextInputType.number,
                                                                        style: TextStyle(
                                                                            color:
                                                                                defaultPalette.secondary),
                                                                        decoration: InputDecoration(
                                                                            labelText:
                                                                                'Font Size',
                                                                            labelStyle:
                                                                                TextStyle(color: defaultPalette.secondary),
                                                                            filled: true,
                                                                            fillColor: Colors.black38,
                                                                            border: InputBorder.none),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            10),
                                                                    /////////////////////////////////////Color Chooose Left
                                                                    Text(
                                                                      'Color',
                                                                      style:
                                                                          TextStyle(
                                                                        color: defaultPalette
                                                                            .secondary,
                                                                      ),
                                                                    ),
                                                                    SingleChildScrollView(
                                                                      scrollDirection:
                                                                          Axis.horizontal,
                                                                      physics:
                                                                          NeverScrollableScrollPhysics(),
                                                                      child:
                                                                          AnimatedContainer(
                                                                        duration:
                                                                            Duration(milliseconds: 20),
                                                                        width: sWidth * vDividerPosition - 16 <=
                                                                                0
                                                                            ? 50
                                                                            : sWidth * vDividerPosition -
                                                                                16,
                                                                        // height: 40,
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(right: 6.65),
                                                                              child: buildHead(documentPropertiesList[currentPageIndex].textFieldControllers[selectedIndex[currentPageIndex]].colorController.text.replaceFirst('#', '0xff')),
                                                                            ),
                                                                            // vDividerPosition>=sWidth*vDividerPosition?
                                                                            Expanded(
                                                                              child: ClipRRect(
                                                                                borderRadius: BorderRadius.circular(0),
                                                                                child: TextFormField(
                                                                                  inputFormatters: [
                                                                                    HexColorInputFormatter()
                                                                                  ],
                                                                                  scrollPhysics: BouncingScrollPhysics(),
                                                                                  onTapOutside: (d) {
                                                                                    documentPropertiesList[currentPageIndex].textFieldControllers[selectedIndex[currentPageIndex]].colorFocusController.unfocus();
                                                                                  },
                                                                                  focusNode: documentPropertiesList[currentPageIndex].textFieldControllers[selectedIndex[currentPageIndex]].colorFocusController,
                                                                                  onChanged: (value) {
                                                                                    String hexColor = value.replaceFirst('#', '0xff');
                                                                                    Color color = Color(0xff0000000);
                                                                                    try {
                                                                                      color = Color(int.parse(hexColor));
                                                                                      // Clear the error message if color is valid
                                                                                      setState(() {
                                                                                        _updateTextFieldProperties('labelText', '');
                                                                                      });
                                                                                    } catch (e) {
                                                                                      // Show error message if color is invalid
                                                                                      setState(() {
                                                                                        _updateTextFieldProperties('labelText', 'Invalid color');
                                                                                      });
                                                                                    }

                                                                                    _updateTextFieldProperties('textStyle', {
                                                                                      'color': color
                                                                                    });
                                                                                  },
                                                                                  style: TextStyle(
                                                                                    color: defaultPalette.secondary,
                                                                                  ),
                                                                                  decoration: InputDecoration(
                                                                                    labelText: documentPropertiesList[currentPageIndex].textFieldControllers[selectedIndex[currentPageIndex]].decoration.labelText == '' ? null : documentPropertiesList[currentPageIndex].textFieldControllers[selectedIndex[currentPageIndex]].decoration.labelText,
                                                                                    filled: true,
                                                                                    fillColor: Colors.black38,
                                                                                    border: InputBorder.none,
                                                                                  ),
                                                                                  controller: documentPropertiesList[currentPageIndex].textFieldControllers[selectedIndex[currentPageIndex]].colorController,
                                                                                ),
                                                                              ),
                                                                            )
                                                                            // :
                                                                            // SizedBox(),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    AnimatedContainer(
                                                                      duration: Duration(
                                                                          milliseconds:
                                                                              300),
                                                                      height: isColorPickerExpanded
                                                                          ? 300
                                                                          : 0,
                                                                      child:
                                                                          SingleChildScrollView(
                                                                        physics:
                                                                            NeverScrollableScrollPhysics(),
                                                                        child: hsv
                                                                            .ColorPicker(
                                                                          paletteHeight:
                                                                              150,
                                                                          pickerOrientation: hsv
                                                                              .PickerOrientation
                                                                              .portrait,
                                                                          initialPicker: hsv
                                                                              .Picker
                                                                              .paletteHue,
                                                                          color: Color(int.parse(documentPropertiesList[currentPageIndex]
                                                                              .textFieldControllers[selectedIndex[currentPageIndex]]
                                                                              .colorController
                                                                              .text
                                                                              .replaceFirst("#", "0xff"))),
                                                                          onChanged:
                                                                              (color) {
                                                                            setState(() {
                                                                              String hexColor = color.value.toRadixString(16).toUpperCase().padLeft(8, '0');
                                                                              documentPropertiesList[currentPageIndex].textFieldControllers[selectedIndex[currentPageIndex]].colorController.text = '#${hexColor.substring(2)}'; // Skip the alpha value in the text
                                                                              _updateTextFieldProperties('textStyle', {
                                                                                'color': color
                                                                              });
                                                                            });
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                ////////////////////RIGHT SCREEN

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
                                          iconColor: defaultPalette.tertiary,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.end,
                                          runAlignment: WrapAlignment.end,
                                          elevation: 20,
                                        ),
                                        previewPageMargin: EdgeInsets.all(8),
                                        scrollViewDecoration: BoxDecoration(
                                            color: defaultPalette.transparent),
                                        useActions: true,
                                        // actions: [
                                        //   PdfPreviewAction(
                                        //     icon: Icon(Icons.add,),
                                        //     onPressed: (c, y, u) {
                                        //       return;
                                        //     },
                                        //   ),
                                        // ],
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
                            left: vDividerPosition * sWidth - 12,
                            top: 0,
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 50),
                              width: 24,
                              height: sHeight * (hDividerPosition * 1.8),
                              color: Colors.transparent,
                              child: GestureDetector(
                                onPanUpdate: (details) {
                                  double newPosition = (vDividerPosition +
                                          details.delta.dx /
                                              context.size!.width)
                                      .clamp(0.18, 0.95);
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
                    //////////TEXTLayout
                    Expanded(
                      flex: ((1 - hDividerPosition) * 10000).round(),
                      child: Column(
                        children: [
                          ///////////text top bar
                          AnimatedContainer(
                            duration: Duration(milliseconds: 120),
                            decoration: BoxDecoration(
                              color: defaultPalette.black.withOpacity(0.9),
                            ),
                            height: 45,
                            width: sWidth,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ///Resize handle
                                GestureDetector(
                                    onPanUpdate: (details) {
                                      double newPosition = (hDividerPosition +
                                              details.delta.dy /
                                                  context.size!.height)
                                          .clamp(0.1, 0.85);
                                      _updatehDividerPosition(newPosition);
                                    },
                                    child: Transform.rotate(
                                      angle: math.pi / 2,
                                      child: Container(
                                        color: defaultPalette.primary,
                                        // padding: EdgeInsets.all(1),
                                        width: sWidth / 10,
                                        // height: 10,
                                        child: Icon(
                                          Icons.code_outlined,
                                          color: defaultPalette.secondary,
                                          size: 25,
                                        ),
                                      ),
                                    )),

                                ///clearLayout Button
                                IconButton(
                                    onPressed: _confirmDeleteLayout,
                                    icon: Icon(
                                      Icons.close,
                                      // size: 40,
                                      color: defaultPalette.secondary,
                                    )),
                                IconButton(
                                    onPressed: _addTextField,
                                    icon: Icon(
                                      Icons.add_comment_rounded,
                                      // size: 40,
                                      color: defaultPalette.secondary,
                                    )),
                                IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      Icons.add_photo_alternate_outlined,
                                      // size: 40,
                                      color: defaultPalette.secondary,
                                    )),
                                IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      Icons.table_chart_rounded,
                                      // size: 40,
                                      color: defaultPalette.secondary,
                                    )),
                                IconButton(
                                    onPressed: _duplicateTextField,
                                    icon: Icon(
                                      Icons.copy_all_rounded,
                                      // size: 40,
                                      color: defaultPalette.secondary,
                                    )),
                                IconButton(
                                    onPressed: _removeTextField,
                                    icon: Icon(
                                      Icons.delete,
                                      // size: 40,
                                      color: defaultPalette.secondary,
                                    )),
                                Container(
                                  height: 25,
                                  width: sWidth / 7,
                                  color:
                                      defaultPalette.secondary.withOpacity(0.8),
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
                          ///////////////text list main bag
                          Expanded(
                            child: PageView(
                              allowImplicitScrolling: true,
                              physics: BouncingScrollPhysics(),
                              scrollBehavior: const MaterialScrollBehavior(),
                              controller: pageTextFieldsController,
                              onPageChanged: (value) {
                                _deselectTextField();
                                Future.delayed(Duration(milliseconds: 200), () {
                                  animateToPage(value);
                                  setState(() {
                                    currentPageIndex = value;
                                  });
                                });
                              },
                              children: [
                                for (int i = 0; i < pageCount; i++)
                                  GestureDetector(
                                    onTap: () {
                                      _deselectTextField();
                                      var val = currentPageIndex;
                                      Future.delayed(Duration(milliseconds: 10),
                                          () {
                                        pageViewIndicatorController
                                            .jumpToPage(val);
                                      });
                                    },
                                    child: AnimatedContainer(
                                      color: defaultPalette.primary,
                                      duration: Duration(milliseconds: 100),
                                      height: sHeight * hDividerPosition,
                                      padding: EdgeInsets.all(5),
                                      child: ReorderableListView(
                                        onReorderStart: (index) {
                                          if (selectedIndex[currentPageIndex] !=
                                              index) {
                                            _selectTextField(index);
                                          }
                                          setState(() {
                                            isReordering = true;
                                          });
                                        },
                                        onReorderEnd: (index) {
                                          setState(() {
                                            isReordering = false;
                                          });
                                        },
                                        onReorder: (oldIndex, newIndex) {
                                          setState(() {
                                            isReordering = true;

                                            // Correcting the index if the new index is greater than the old index
                                            if (newIndex > oldIndex) {
                                              newIndex -= 1;
                                            }

                                            if (selectedIndex[
                                                    currentPageIndex] ==
                                                oldIndex) {
                                              _selectTextField(newIndex);
                                            }

                                            final textFieldController =
                                                documentPropertiesList[i]
                                                    .textFieldControllers
                                                    .removeAt(oldIndex);
                                            documentPropertiesList[i]
                                                .textFieldControllers
                                                .insert(newIndex,
                                                    textFieldController);

                                            // Ensure the state is updated to reflect the end of reordering
                                            isReordering = false;
                                          });
                                        },
                                        children: [
                                          for (int index = 0;
                                              index <
                                                  documentPropertiesList[i]
                                                      .textFieldControllers
                                                      .length;
                                              index++)
                                            Material(
                                              // Tile Color
                                              color: defaultPalette.white
                                                  .withOpacity(0.9),
                                              key: Key('$index'),
                                              child: GestureDetector(
                                                onTap: () {
                                                  if (selectedIndex[
                                                          currentPageIndex] !=
                                                      index) {
                                                    _selectTextField(index);
                                                  }
                                                  if (documentPropertiesList[i]
                                                      .textFieldControllers[
                                                          selectedIndex[
                                                              currentPageIndex]]
                                                      .focusController
                                                      .hasFocus) {
                                                    documentPropertiesList[i]
                                                        .textFieldControllers[
                                                            selectedIndex[
                                                                currentPageIndex]]
                                                        .focusController
                                                        .requestFocus();
                                                  }
                                                },
                                                child: AnimatedContainer(
                                                  duration:
                                                      Duration(microseconds: 1),
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 5),
                                                  decoration: BoxDecoration(
                                                    color: Colors.transparent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: IgnorePointer(
                                                    ignoring: false,
                                                    // !documentPropertiesList[i]
                                                    //     .textFieldControllers[
                                                    //         index]
                                                    //     .focusController
                                                    //     .hasFocus,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Builder(
                                                            builder: (context) {
                                                          double textfieldSize =
                                                              (double.parse(documentPropertiesList[
                                                                              i]
                                                                          .textFieldControllers[
                                                                              index]
                                                                          .hintSizeController
                                                                          .text)
                                                                      .clamp(12,
                                                                          20) +
                                                                  45);
                                                          double tileHeightX =
                                                              textfieldSize
                                                                      .clamp(45,
                                                                          92) +
                                                                  20;
                                                          double tileHeight =
                                                              tileHeightX -
                                                                  (textfieldSize /
                                                                      2);
                                                          double buttonsSize =
                                                              50;
                                                          Duration
                                                              positionedDur =
                                                              Duration(
                                                                  milliseconds:
                                                                      300);
                                                          // Duration opacityDur = Duration(
                                                          //     milliseconds:
                                                          //         (positionedDur
                                                          //                     .inMilliseconds /
                                                          //                 3)
                                                          //             .round());

                                                          return Stack(
                                                            children: [
                                                              AnimatedContainer(
                                                                duration: Duration(
                                                                    milliseconds:
                                                                        200),
                                                                height: selectedIndex[
                                                                            currentPageIndex] ==
                                                                        index
                                                                    ? tileHeightX
                                                                    : tileHeight,
                                                                width: sWidth *
                                                                    0.8,
                                                              ),

                                                              ///individual Textfield
                                                              AnimatedPositioned(
                                                                top: selectedIndex[
                                                                            currentPageIndex] ==
                                                                        index
                                                                    ? (tileHeightX /
                                                                            2) -
                                                                        tileHeight /
                                                                            2
                                                                    : 0,
                                                                duration: Duration(
                                                                    milliseconds:
                                                                        200),
                                                                left: ((sWidth *
                                                                            0.8) /
                                                                        2) -
                                                                    75,
                                                                child:
                                                                    AnimatedContainer(
                                                                  duration: Duration(
                                                                      milliseconds:
                                                                          200),
                                                                  width: 150,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .transparent,
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: isReordering
                                                                          ? Colors
                                                                              .transparent
                                                                          : (selectedIndex[currentPageIndex] == index
                                                                              ? defaultPalette.primary
                                                                              : Colors.transparent),
                                                                      width: 2,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                  child:
                                                                      TextFormField(
                                                                    maxLines:
                                                                        null,
                                                                    focusNode: documentPropertiesList[
                                                                            i]
                                                                        .textFieldControllers[
                                                                            index]
                                                                        .focusController,
                                                                    onTap: () {
                                                                      documentPropertiesList[
                                                                              i]
                                                                          .textFieldControllers[
                                                                              index]
                                                                          .focusController
                                                                          .requestFocus();
                                                                      _selectTextField(
                                                                          index);
                                                                    },
                                                                    onTapOutside:
                                                                        (d) {
                                                                      documentPropertiesList[
                                                                              i]
                                                                          .textFieldControllers[
                                                                              index]
                                                                          .focusController
                                                                          .unfocus();
                                                                    },
                                                                    controller: documentPropertiesList[
                                                                            i]
                                                                        .textFieldControllers[
                                                                            index]
                                                                        .textController,
                                                                    onChanged:
                                                                        (value) {
                                                                      setState(
                                                                          () {});
                                                                    },
                                                                    decoration:
                                                                        InputDecoration(
                                                                      filled:
                                                                          true,
                                                                      fillColor:
                                                                          defaultPalette
                                                                              .secondary,
                                                                      contentPadding:
                                                                          EdgeInsets.all(
                                                                              10),
                                                                      hintText: documentPropertiesList[
                                                                              i]
                                                                          .textFieldControllers[
                                                                              index]
                                                                          .hintController
                                                                          .text,
                                                                      hintStyle:
                                                                          TextStyle(
                                                                        fontSize: double.parse(documentPropertiesList[i].textFieldControllers[index].hintSizeController.text) >
                                                                                25
                                                                            ? 20
                                                                            : double.parse(documentPropertiesList[i].textFieldControllers[index].hintSizeController.text),
                                                                        color: Color(int.parse(documentPropertiesList[i]
                                                                            .textFieldControllers[
                                                                                index]
                                                                            .colorController
                                                                            .text
                                                                            .replaceFirst('#',
                                                                                '0xff'))),
                                                                      ),
                                                                      border: InputBorder
                                                                          .none,
                                                                    ),
                                                                    style:
                                                                        TextStyle(
                                                                      color: documentPropertiesList[
                                                                              i]
                                                                          .textFieldControllers[
                                                                              index]
                                                                          .style
                                                                          .color,
                                                                      fontSize: documentPropertiesList[i].textFieldControllers[index].style.fontSize! >
                                                                              25
                                                                          ? 20
                                                                          : documentPropertiesList[i]
                                                                              .textFieldControllers[index]
                                                                              .style
                                                                              .fontSize,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),

                                                              // // Left side button
                                                              buildAnimatedPositioned(
                                                                selectedIndex:
                                                                    selectedIndex[
                                                                        currentPageIndex],
                                                                currentPageIndex:
                                                                    currentPageIndex,
                                                                index: index,
                                                                top: (tileHeightX /
                                                                        2) -
                                                                    buttonsSize /
                                                                        2,
                                                                left: ((sWidth *
                                                                            0.8) /
                                                                        2) -
                                                                    125,
                                                                initialTop: 0,
                                                                initialLeft:
                                                                    -(sWidth *
                                                                            0.8) /
                                                                        2,
                                                                width: 90,
                                                                height:
                                                                    buttonsSize,
                                                                opacity: 1,
                                                                duration:
                                                                    positionedDur,
                                                                containerHeight:
                                                                    25,
                                                                containerWidth:
                                                                    25,
                                                                containerColor:
                                                                    defaultPalette
                                                                        .primary,
                                                                iconColor:
                                                                    defaultPalette
                                                                        .secondary,
                                                              ),
                                                              // Right side button
                                                              buildAnimatedPositioned(
                                                                selectedIndex:
                                                                    selectedIndex[
                                                                        currentPageIndex],
                                                                currentPageIndex:
                                                                    currentPageIndex,
                                                                index: index,
                                                                top: (tileHeightX /
                                                                        2) -
                                                                    (buttonsSize /
                                                                        2),
                                                                left: ((sWidth *
                                                                            0.8) /
                                                                        2) +
                                                                    35,
                                                                initialTop: 0,
                                                                initialLeft:
                                                                    sWidth *
                                                                        0.8,
                                                                width: 90,
                                                                height: 50,
                                                                opacity: 1,
                                                                duration:
                                                                    positionedDur,
                                                                containerHeight:
                                                                    25,
                                                                containerWidth:
                                                                    25,
                                                                containerColor:
                                                                    defaultPalette
                                                                        .primary,
                                                                iconColor:
                                                                    defaultPalette
                                                                        .secondary,
                                                              ),
                                                              // North side button
                                                              buildAnimatedPositioned(
                                                                selectedIndex:
                                                                    selectedIndex[
                                                                        currentPageIndex],
                                                                currentPageIndex:
                                                                    currentPageIndex,
                                                                index: index,
                                                                top: (tileHeightX / 2) -
                                                                    (tileHeight /
                                                                        2) -
                                                                    (buttonsSize /
                                                                        2),
                                                                left: ((sWidth *
                                                                            0.8) /
                                                                        2) -
                                                                    45,
                                                                initialTop:
                                                                    -tileHeightX,
                                                                initialLeft:
                                                                    ((sWidth * 0.8) /
                                                                            2) -
                                                                        45,
                                                                width: 90,
                                                                height: 50,
                                                                opacity: 1,
                                                                duration:
                                                                    positionedDur,
                                                                containerHeight:
                                                                    25,
                                                                containerWidth:
                                                                    25,
                                                                containerColor:
                                                                    defaultPalette
                                                                        .primary,
                                                                iconColor:
                                                                    defaultPalette
                                                                        .secondary,
                                                              ),
                                                              // South side button
                                                              buildAnimatedPositioned(
                                                                selectedIndex:
                                                                    selectedIndex[
                                                                        currentPageIndex],
                                                                currentPageIndex:
                                                                    currentPageIndex,
                                                                index: index,
                                                                top: (tileHeightX / 2) +
                                                                    (tileHeight /
                                                                        2) -
                                                                    (buttonsSize /
                                                                        2),
                                                                left: ((sWidth *
                                                                            0.8) /
                                                                        2) -
                                                                    45,
                                                                initialTop:
                                                                    tileHeightX,
                                                                initialLeft:
                                                                    ((sWidth * 0.8) /
                                                                            2) -
                                                                        45,
                                                                width: 90,
                                                                height: 50,
                                                                opacity: 1,
                                                                duration:
                                                                    positionedDur,
                                                                containerHeight:
                                                                    25,
                                                                containerWidth:
                                                                    25,
                                                                containerColor:
                                                                    defaultPalette
                                                                        .primary,
                                                                iconColor:
                                                                    defaultPalette
                                                                        .secondary,
                                                              ),
                                                            ],
                                                          );
                                                        }),
                                                      ],
                                                    ),
                                                  ),
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
                          // QuillToolbar.simple(
                          //   configurations: QuillSimpleToolbarConfigurations(
                          //     controller: _controller,
                          //     multiRowsDisplay: false,
                          //     sharedConfigurations:
                          //         const QuillSharedConfigurations(
                          //       locale: Locale('en'),
                          //     ),
                          //   ),
                          // ),
                          // Expanded(
                          //   child: QuillEditor.basic(
                          //     configurations: QuillEditorConfigurations(
                          //       controller: _controller,
                          //       // readOnly: false,
                          //       sharedConfigurations:
                          //           const QuillSharedConfigurations(
                          //         locale: Locale('de'),
                          //       ),
                          //     ),
                          //   ),
                          // )
                          // FleatherToolbar.basic(
                          //   controller: controller,
                          // ),
                          // SizedBox(
                          //     width: sWidth,
                          //     // height: 400,
                          //     child: FleatherEditor(
                          //       controller: controller,
                          //     )),
                          // QuillToolbar.simple(
                          //   configurations: QuillSimpleToolbarConfigurations(
                          //     embedButtons: FlutterQuillEmbeds.toolbarButtons(),
                          //     buttonOptions: QuillSimpleToolbarButtonOptions(
                          //       base: QuillToolbarBaseButtonOptions(
                          //         // globalIconSize: 20,
                          //         // globalIconButtonFactor: 1.4,
                          //         childBuilder: (options, extraOptions) {
                          //           return SingleChildScrollView(
                          //             scrollDirection: Axis.horizontal,
                          //             child: Row(
                          //               children: [
                          //                 // IconButton(
                          //                 //   onPressed: () => context
                          //                 // .read<SettingsCubit>()
                          //                 //       .updateSettings(state.copyWith(
                          //                 //           useCustomQuillToolbar: false)),
                          //                 //   icon: const Icon(
                          //                 //     Icons.width_normal,
                          //                 //   ),
                          //                 // ),
                          //                 QuillToolbarHistoryButton(
                          //                   isUndo: true,
                          //                   controller: _controller,
                          //                 ),
                          //                 QuillToolbarHistoryButton(
                          //                   isUndo: false,
                          //                   controller: _controller,
                          //                 ),
                          //                 QuillToolbarToggleStyleButton(
                          //                   options:
                          //                       const QuillToolbarToggleStyleButtonOptions(),
                          //                   controller: _controller,
                          //                   attribute: Attribute.bold,
                          //                 ),
                          //                 QuillToolbarToggleStyleButton(
                          //                   options:
                          //                       const QuillToolbarToggleStyleButtonOptions(),
                          //                   controller: _controller,
                          //                   attribute: Attribute.italic,
                          //                 ),
                          //                 QuillToolbarToggleStyleButton(
                          //                   controller: _controller,
                          //                   attribute: Attribute.underline,
                          //                 ),
                          //                 QuillToolbarClearFormatButton(
                          //                   controller: _controller,
                          //                 ),
                          //                 const VerticalDivider(),
                          //                 QuillToolbarImageButton(
                          //                   controller: _controller,
                          //                 ),
                          //                 QuillToolbarCameraButton(
                          //                   controller: _controller,
                          //                 ),
                          //                 QuillToolbarVideoButton(
                          //                   controller: _controller,
                          //                 ),
                          //                 const VerticalDivider(),
                          //                 QuillToolbarColorButton(
                          //                   controller: _controller,
                          //                   isBackground: false,
                          //                 ),
                          //                 QuillToolbarColorButton(
                          //                   controller: _controller,
                          //                   isBackground: true,
                          //                 ),
                          //                 const VerticalDivider(),
                          //                 // QuillToolbarSelectHeaderStyleButton(
                          //                 //   controller: _controller,
                          //                 // ),
                          //                 const VerticalDivider(),
                          //                 QuillToolbarToggleCheckListButton(
                          //                   controller: _controller,
                          //                 ),
                          //                 QuillToolbarToggleStyleButton(
                          //                   controller: _controller,
                          //                   attribute: Attribute.ol,
                          //                 ),
                          //                 QuillToolbarToggleStyleButton(
                          //                   controller: _controller,
                          //                   attribute: Attribute.ul,
                          //                 ),
                          //                 QuillToolbarToggleStyleButton(
                          //                   controller: _controller,
                          //                   attribute: Attribute.inlineCode,
                          //                 ),
                          //                 QuillToolbarToggleStyleButton(
                          //                   controller: _controller,
                          //                   attribute: Attribute.blockQuote,
                          //                 ),
                          //                 QuillToolbarIndentButton(
                          //                   controller: _controller,
                          //                   isIncrease: true,
                          //                 ),
                          //                 QuillToolbarIndentButton(
                          //                   controller: _controller,
                          //                   isIncrease: false,
                          //                 ),
                          //                 const VerticalDivider(),
                          //                 QuillToolbarLinkStyleButton(
                          //                     controller: _controller),
                          //               ],
                          //             ),
                          //           );
                          //         },
                          //       ),
                          //     ),
                          //     controller: _controller,
                          //   ),
                          // ),
                          // SizedBox(
                          //   height: 500,
                          //   width: 200,
                          //   child: QuillToolbar.simple(
                          //     configurations: QuillSimpleToolbarConfigurations(
                          //       showDividers: false,
                          //       axis: Axis.horizontal,
                          //       buttonOptions:
                          //           QuillSimpleToolbarButtonOptions(),
                          //       decoration: BoxDecoration(),
                          //       showSmallButton: true,
                          //       showAlignmentButtons: true,
                          //       showDirection: true,
                          //       controller: _controller,
                          //       sharedConfigurations:
                          //           const QuillSharedConfigurations(
                          //         locale: Locale('en'),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          // Expanded(
                          //   child: QuillEditor.basic(
                          //     configurations: QuillEditorConfigurations(
                          //       controller: _controller,
                          //       sharedConfigurations:
                          //           const QuillSharedConfigurations(
                          //         locale: Locale('en'),
                          //       ),
                          //     ),
                          //   ),
                          // )
                          // Expanded(flex: 40, child: SpreadSheet())
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Function to create AnimatedPositioned widget with given parameters
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
class PanelIndex {
  String id;
  int panelIndex;
  PanelIndex({
    required this.id,
    required this.panelIndex,
  });

  PanelIndex copyWith({
    String? id,
    int? panelIndex,
  }) {
    return PanelIndex(
      id: id ?? this.id,
      panelIndex: panelIndex ?? this.panelIndex,
    );
  }

  @override
  String toString() => 'PanelIndex(id: $id, panelIndex: $panelIndex)';

  @override
  bool operator ==(covariant PanelIndex other) {
    if (identical(this, other)) return true;

    return other.id == id && other.panelIndex == panelIndex;
  }

  @override
  int get hashCode => id.hashCode ^ panelIndex.hashCode;
}

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

final pageCountProvider = StateProvider<int>((ref) {
  return 1;
});

final currentPageIndexProvider = StateProvider<int>((ref) {
  return 0;
});
//
// final selectedIndexProvider = StateProvider<SelectedIndex>((ref) {
//   return SelectedIndex(ids: [], selectedIndexes: [
//     [],
//   ]);
// });
//
final panelIndexProvider = StateProvider<PanelIndex>((ref) {
  return PanelIndex(id: parentId, panelIndex: -1);
});
//
final documentPropertiesProvider =
    StateProvider<List<DocumentProperties2>>((ref) {
  return [
    DocumentProperties2(
      pageNumberController: TextEditingController(text: (1).toString()),
      marginAllController: TextEditingController(text: '10'),
      marginLeftController: TextEditingController(text: '10'),
      marginRightController: TextEditingController(text: '10'),
      marginBottomController: TextEditingController(text: '10'),
      marginTopController: TextEditingController(text: '10'),
      orientationController: pw.PageOrientation.portrait,
      pageFormatController: PdfPageFormat.a4,
    )
  ];
});

final spreadSheetProvider = StateProvider<List<SheetList>>((ref) {
  var id = Uuid().v4();

  return [
    SheetList(id: id, parentId: parentId, sheetList: [
      // TextEditorItem(id: 'text1', parentId: id),
    ]),
  ];
});
//
final sheetItemProviderFamily = Provider.family<SheetItem, String>((ref, id) {
  final int currentPageIndex = ref.watch(currentPageIndexProvider);
  final SheetList currentSheetList =
      ref.watch(spreadSheetProvider.select((p) => p[currentPageIndex]));
  // final currentSheetList = spreadSheets[currentPageIndex];
  print('currentpageINdex in itemloop: ${ref.read(currentPageIndexProvider)}');
  print(currentSheetList.id);
  print(currentSheetList.length);
  for (int i = 0; i < currentSheetList.length; i++) {
    print(i);
    print("Item id in the loop from family: ${currentSheetList[i].id}");
    print("the $id being searched in itemloopfamily");
    if (currentSheetList[i].id == id) {
      return currentSheetList[i];
    }
  }
  print('item $id not found.');
  throw Exception('SheetItem with id $id not found');
});

final sheetListProviderFamily =
    StateNotifierProvider.family<SheetListNotifier, SheetList, String>(
        (ref, id) {
  final int currentPageIndex = ref.watch(currentPageIndexProvider);
  final List<SheetList> spreadSheets = ref.watch(spreadSheetProvider);

  final int pageCount = ref.watch(pageCountProvider);
  print('pageCount from listFamily: $pageCount');
  print(
      'currentpageINdex in listfamily: ${ref.read(currentPageIndexProvider)}');
  for (var v = 0; v < pageCount; v++) {
    final currentSheetList = spreadSheets[v];
    print('id from listfam loop: ${currentSheetList.id}');
    if (id == currentSheetList.id) {
      print('idfrom listfam searched for:$id');
      return SheetListNotifier(currentSheetList);
    }

    for (final item in currentSheetList.sheetList) {
      if (item is SheetList && item.id == id) {
        return SheetListNotifier(item);
      }
    }
  }
  print("SheetList $id not found.");
  throw Exception('SheetList with id $id not found');
});

class LayoutDesigner2 extends ConsumerStatefulWidget {
  const LayoutDesigner2({super.key});

  @override
  ConsumerState<LayoutDesigner2> createState() => _LayoutDesigner2State();
}

class _LayoutDesigner2State extends ConsumerState<LayoutDesigner2> {
  double hDividerPosition = 0.45;
  double vDividerPosition = 0.5;
  double appbarHeight = 0.065;
  bool isExpanded = false;
  DateTime dateTimeNow = DateTime.now();
  // Timer? _timer;

  pw.Document? _pdfDocument;
  PageController pagePropertiesViewController = PageController();
  PageController pageViewIndicatorController = PageController();
  ScrollController pdfScrollController = ScrollController();
  QuillController _controller = QuillController.basic();

  bool _firstPageAdded = false;

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

  @override
  void initState() {
    super.initState();
    // animateToPage(currentPageIndex);
    // _getTimer();
    print('________INIT STARTED LD_________');
    Future.delayed(Duration.zero, () {
      if (!_firstPageAdded) {
        //

        // _addPdfPage();
        _updatePdfPreview('');
        ref.read(panelIndexProvider.notifier).state = PanelIndex(
            id: ref.read(spreadSheetProvider
                .select((p) => p[ref.read(currentPageIndexProvider)].id)),
            panelIndex: -1);
        print('panelIndexId in init: ${ref.read(panelIndexProvider).id}');
        setState(() {
          _firstPageAdded = true;
        });
      }
    }).then((hn) {
      _updatePdfPreview('');
    });
    print('________INIT ended LD_________');
  }

  @override
  void dispose() {
    pagePropertiesViewController.dispose();
    pageViewIndicatorController.dispose();
    // _timer?.cancel();
    super.dispose();
  }

  // void _getTimer() {
  //   _timer = Timer.periodic(Durations.short2, (T) {
  //     setState(() {
  //       dateTimeNow = DateTime.now();
  //     });
  //   });
  // }

  Future<void> _addPdfPage() async {
    print('________addPdfPage STARTED_________');
    int pageCount = ref.read(pageCountProvider);
    print('pageCount in addpage: $pageCount');
    print('currentpageINdex in adpage: ${ref.read(currentPageIndexProvider)}');
    // Update documentPropertiesProvider
    ref.read(documentPropertiesProvider.notifier).update((state) {
      return [
        ...state,
        DocumentProperties2(
          pageNumberController: TextEditingController(
              text: (++ref.read(pageCountProvider.notifier).state).toString()),
          marginAllController: TextEditingController(text: '10'),
          marginLeftController: TextEditingController(text: '10'),
          marginRightController: TextEditingController(text: '10'),
          marginBottomController: TextEditingController(text: '10'),
          marginTopController: TextEditingController(text: '10'),
          orientationController: pw.PageOrientation.portrait,
          pageFormatController: PdfPageFormat.a4,
        )
      ];
    });
    print(
        'documentlist from after addPage: ${ref.read(documentPropertiesProvider).length}');
    // Generate a new ID for the sheet list
    String idloc = Uuid().v4();
    // print(idloc);
    // Add a new SheetList to spreadSheetProvider
    ref.read(spreadSheetProvider.notifier).update((state) {
      return [
        ...state,
        SheetList(id: idloc, parentId: parentId, sheetList: [
          // initializeTextEditor(),
        ]),
      ];
    });
    pageCount = ref.read(pageCountProvider);
    print('sheetlist from after addPage: ${ref.read(spreadSheetProvider)}');
    // Update selectedIndexProvider
    // ref.read(selectedIndexProvider.notifier).update((s) {
    //   return s.copyWith(
    //     ids: [...s.ids, idloc],
    //     selectedIndexes: [...s.selectedIndexes, []],
    //   );
    // });
    print('panelIndexId in --addPDFPage: ${ref.read(panelIndexProvider).id}');
    ref.read(panelIndexProvider.notifier).state =
        PanelIndex(id: idloc, panelIndex: 0);
    print('panelIndexId in ++addPDFPage: ${ref.read(panelIndexProvider).id}');
    ref.read(currentPageIndexProvider.notifier).state++;
    print(
        'currentpageINdex in after adpage: ${ref.read(currentPageIndexProvider)}');
    _updatePdfPreview('');
    print('pageCount in afteraddpage: $pageCount');
    print('________END addPdfPage LD_________');
  }

  Future<Uint8List> _generatePdf(WidgetRef ref, PdfPageFormat format) async {
    print('________generatePdf STARTED LD_________');
    final pdf = pw.Document();
    final List<SheetList> spreadSheet = ref.read(spreadSheetProvider);

    for (int i = 0; i < spreadSheet.length; i++) {
      print('calling sheetlist from generatePdf');
      final sheetList = ref.read(sheetListProviderFamily(spreadSheet[i].id));
      final doc = ref.read(documentPropertiesProvider.select((p) => p[i]));

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
    print('________END generatePdf_________');
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
    final List<pw.TextSpan> textSpans = [];

    for (var op in delta.toList()) {
      if (op.value is String) {
        String text = op.value;
        Map<String, dynamic>? attributes = op.attributes;

        pw.TextStyle textStyle = pw.TextStyle();

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
          if (attributes.containsKey('color')) {
            textStyle = textStyle.copyWith(
              color: PdfColor.fromHex(attributes['color']),
            );
          }
          if (attributes.containsKey('size')) {
            double fontSize = double.parse(attributes['size'].toString());
            textStyle = textStyle.copyWith(fontSize: fontSize);
          }
          if (attributes.containsKey('link')) {
            final link = attributes['link'];
            textSpans.add(
              pw.TextSpan(
                text: text,
                style: textStyle.copyWith(
                    color: PdfColors.blue,
                    decoration: pw.TextDecoration.underline),
                annotation: pw.AnnotationUrl(link),
              ),
            );
            continue;
          }
        }

        textSpans.add(pw.TextSpan(text: text, style: textStyle));
      }
    }
    print('________END convertDELTA LD_________');
    return pw.RichText(
      text: pw.TextSpan(
        children: textSpans,
      ),
    );
  }

  void _updatePdfPreview(String text) {
    print('________Update Preview STARTED LD_________');
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

  TextEditorItem initializeTextEditor() {
    print('________New TEXT STARTED LD_________');
    var textEditor = TextEditorItem(
      id: Uuid().v4(),
      parentId: parentId,
      initialValue: 'ENTER TEXT!',
      focusNode: FocusNode(),
      scrollController: ScrollController(),
    );
    print('text id: ${textEditor.id}');
    print('________NEW TEXT MADE LD_________');
    return textEditor;
  }

  void _addTextField(String id) {
    // Fetch the specific SheetListNotifier for the given id
    print('________ADD TEXT FIELD STARTED LD_________');
    print('calling sheetlist from addTextField');
    final sheetListNotifier = ref.read(sheetListProviderFamily(id).notifier);
    print(sheetListNotifier);
    // Create a new TextEditorItem
    // final newTextItem = TextEditorItem(id: UniqueKey().toString(), parentId: id);

    // Add the new TextEditorItem to the SheetList
    sheetListNotifier.add(initializeTextEditor());
    print('sheetlist id: ${ref.read(sheetListProviderFamily(id)).id}');
    print('sheetlist id: ${ref.read(sheetListProviderFamily(id)).sheetList}');
    _updatePdfPreview('');
    print('________END ADD TEXT FIELD LD_________');
  }

  // void _selectTextField(String id, int index) {
  //   // Read the current state of selectedIndexProvider
  //   final selectedIndex = ref.read(selectedIndexProvider);
  //   // Find the index of the provided id in the ids list
  //   final idIndex = selectedIndex.ids.indexOf(id);
  //   // If the id is not already in the ids list, add it
  //   if (idIndex == -1) {
  //     selectedIndex.ids.add(id);
  //     selectedIndex.selectedIndexes.add([index]);
  //   } else {
  //     // Check if the index is already in the selectedIndexes list for the found idIndex
  //     if (!selectedIndex.selectedIndexes[idIndex].contains(index)) {
  //       selectedIndex.selectedIndexes[idIndex].add(index);
  //     }
  //   }
  //   // Update the state
  //   ref.read(selectedIndexProvider.notifier).state = selectedIndex.copyWith(
  //     ids: selectedIndex.ids,
  //     selectedIndexes: selectedIndex.selectedIndexes,
  //   );
  // }
  // void _deselectTextField(WidgetRef ref, {String? id, int? index}) {
  //   // Read the current state of selectedIndexProvider
  //   final selectedIndex = ref.read(selectedIndexProvider);
  //   if (id == null) {
  //     // Clear all selected indexes for all ids if no id is provided
  //     for (int i = 0; i < selectedIndex.selectedIndexes.length; i++) {
  //       selectedIndex.selectedIndexes[i] = [];
  //     }
  //   } else {
  //     // Find the index of the provided id in the ids list
  //     final idIndex = selectedIndex.ids.indexOf(id);
  //     if (idIndex != -1) {
  //       if (index == null) {
  //         // Clear all selected indexes for the specific id
  //         selectedIndex.selectedIndexes[idIndex] = [];
  //       } else {
  //         // Remove the specific index from the selectedIndexes list for the found idIndex
  //         selectedIndex.selectedIndexes[idIndex].remove(index);
  //       }
  //     }
  //   }
  //   // Update the state
  //   ref.read(selectedIndexProvider.notifier).state = selectedIndex.copyWith(
  //     selectedIndexes: selectedIndex.selectedIndexes,
  //   );
  // }

  void _confirmDeleteLayout(BuildContext context, {bool deletePage = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('This will delete the current layout. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () {
              int currentPageIndex = ref.read(currentPageIndexProvider);

              if (!deletePage) {
                // Empty the sheet list at current pageIndex
                // final spreadsheet = ref.read(spreadSheetProvider);
                // // final documentProperties = ref.read(documentPropertiesProvider);
                // print(spreadsheet);
                print('calling sheetlist notifier from confirmdeleteLayoutPdf');
                final sheetListNotifier = ref.read(sheetListProviderFamily(ref
                        .read(spreadSheetProvider.notifier)
                        .state[currentPageIndex]
                        .id)
                    .notifier);
                sheetListNotifier.clear();

                _updatePdfPreview('');
                Navigator.pop(context);
                return;
              } else {
                // Remove the page and adjust currentPageIndex if deletePage is true
                final spreadsheet = ref.read(spreadSheetProvider);
                // final documentProperties = ref.read(documentPropertiesProvider);

                final currentPage = spreadsheet[currentPageIndex];
                currentPage.sheetList = [];

                // Remove the page and adjust currentPageIndex
                if (ref.read(pageCountProvider) == currentPageIndex + 1) {
                  ref.read(pageCountProvider.notifier).state--;
                }
                ref.read(documentPropertiesProvider.notifier).update((cb) {
                  cb.removeAt(currentPageIndex);
                  return cb;
                });
                ref.read(spreadSheetProvider.notifier).update(
                  (state) {
                    state.removeAt(currentPageIndex);
                    return state;
                  },
                );

                ref.read(currentPageIndexProvider.notifier).state--;
              }

              // Renumber the remaining pages and adjust UI
              final documentPropertiesList =
                  ref.read(documentPropertiesProvider);

              for (int i = currentPageIndex;
                  i < documentPropertiesList.length;
                  i++) {
                final pageNumberController =
                    documentPropertiesList[i].pageNumberController;

                pageNumberController.text =
                    (int.parse(pageNumberController.text) - 1).toString();

                // Scroll to the previous page
                pdfScrollController.animateTo(
                  (currentPageIndex - 1) *
                      ((1.41428571429 *
                              ((MediaQuery.of(context).size.width *
                                      (1 - vDividerPosition)) -
                                  6)) +
                          6),
                  duration: Duration(milliseconds: 100),
                  curve: Curves.easeIn,
                );

                // Animate to the previous page in the page view
                // pagePropertiesViewController.animateToPage(
                //   currentPageIndex - 1,
                //   duration: Duration(milliseconds: 200),
                //   curve: Curves.easeIn,
                // );

                // Decrease page count
                ref.read(pageCountProvider.notifier).state--;
              }
              Navigator.pop(context);
            },
            child: Text('Yes'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('No'),
          ),
        ],
      ),
    );
  }

  void _duplicateTextField(String id, int index) {
    // Obtain the SheetListNotifier for the given id
    if (index == -1) {
      return;
    }
    print('calling sheetlist from duplicateText');
    final sheetListNotifier = ref.read(sheetListProviderFamily(id).notifier);
    final newTextItem = ref.read(sheetItemProviderFamily(ref.read(
        sheetListProviderFamily(ref
                .read(spreadSheetProvider.notifier)
                .state[ref.read(currentPageIndexProvider)]
                .id)
            .select((p) => p[index].id))));

    // Create a new list with the duplicated item inserted at index + 1
    sheetListNotifier.insert(index + 1, newTextItem);
    _updatePdfPreview('');
  }

  void _removeTextField(String id, int index) {
    // Obtain the SheetListNotifier for the given id
    print('calling sheetlist from removeTextField');
    final sheetListNotifier = ref.read(sheetListProviderFamily(id).notifier);

    // Remove the item at the specified index using SheetListNotifier
    sheetListNotifier.removeAt(index);
  }

  void animateToPage(int page) {
    var duration = Duration(milliseconds: 300);
    var curve = Curves.easeIn;
    pageViewIndicatorController.animateToPage(page,
        duration: duration, curve: curve);
  }

  void _toggleUseIndividualMargins() {
    int currentPageIndex = ref.read(currentPageIndexProvider);

    // Get the current value
    bool currentUseIndividualMargins = ref.read(documentPropertiesProvider
        .select((p) => p[currentPageIndex].useIndividualMargins));

    // Update the state in documentPropertiesProvider
    ref.read(documentPropertiesProvider.notifier).update((state) {
      final List<DocumentProperties2> updatedState = List.from(state);
      updatedState[currentPageIndex] = updatedState[currentPageIndex].copyWith(
        useIndividualMargins: !currentUseIndividualMargins,
      );
      return updatedState;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('________BUILD LAYOUT STARTED LD_________');
    double sHeight = MediaQuery.of(context).size.height;
    double sWidth = MediaQuery.of(context).size.width;
    // SelectedIndex selectedIndex = ref.watch(selectedIndexProvider);
    PanelIndex panelIndex = ref.watch(panelIndexProvider);
    int currentPageIndex = ref.watch(currentPageIndexProvider);
    int draggingIndex =
        ref.watch(dragDropProvider.select((p) => p.draggingIndex));
    int potentialDropIndex =
        ref.watch(dragDropProvider.select((p) => p.potentialDropIndex));
    SheetList? draggingList =
        ref.watch(dragDropProvider.select((p) => p.draggingList as SheetList?));
    SheetList? potentialList = ref.watch(
        dragDropProvider.select((p) => p.potentialDropList as SheetList?));
    List<DocumentProperties2> documentPropertiesList =
        ref.watch(documentPropertiesProvider);
    int pageCount = ref.watch(pageCountProvider);
    bool useIndividualMargins = ref.watch(documentPropertiesProvider
        .select((p) => p[currentPageIndex].useIndividualMargins));
    SheetList currentSheet =
        ref.watch(spreadSheetProvider.select((p) => p[currentPageIndex]));
    Duration sideBarPosDuration = Duration(milliseconds: 300);
    Duration defaultDuration = Duration(milliseconds: 300);
    double topPadPosDistance = sHeight / 10;
    double leftPadPosDistance = sWidth / 15;
    double titleFontSize = sHeight / 11;

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                                          Positioned(
                                            top: 0,
                                            left:
                                                // panelIndex.panelIndex != -1
                                                // ?
                                                // sWidth * vDividerPosition
                                                // :
                                                0,
                                            height: sHeight * hDividerPosition,
                                            width: sWidth * vDividerPosition,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: Material(
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
                                                                      // setState(
                                                                      //     () {
                                                                      print(
                                                                          '________PREV PAGE STARTED LD_________');
                                                                      if (currentPageIndex ==
                                                                          0) {
                                                                        return;
                                                                      }
                                                                      ref
                                                                          .read(
                                                                              currentPageIndexProvider.notifier)
                                                                          .state--;

                                                                      pdfScrollController.animateTo(
                                                                          ref.watch(currentPageIndexProvider) *
                                                                              ((1.41428571429 * ((sWidth * (1 - vDividerPosition)))) +
                                                                                  16),
                                                                          duration: Duration(
                                                                              milliseconds:
                                                                                  100),
                                                                          curve:
                                                                              Curves.easeIn);
                                                                      ref.read(panelIndexProvider.notifier).state = PanelIndex(
                                                                          id: currentSheet
                                                                              .id,
                                                                          panelIndex:
                                                                              0);
                                                                      // });
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
                                                                      // setState(
                                                                      //     () {
                                                                      print(
                                                                          '________NEXT PAGE STARTED LD_________');
                                                                      if (pageCount ==
                                                                          (currentPageIndex +
                                                                              1)) {
                                                                        _addPdfPage()
                                                                            .then((ik) {
                                                                          // ref
                                                                          //     .read(currentPageIndexProvider.notifier)
                                                                          //     .state++;
                                                                          pdfScrollController.animateTo(
                                                                              ref.watch(currentPageIndexProvider) * ((1.41428571429 * ((sWidth * (1 - vDividerPosition)) - 6)) + 6),
                                                                              duration: Duration(milliseconds: 100),
                                                                              curve: Curves.easeIn);
                                                                          ref
                                                                              .read(currentPageIndexProvider.notifier)
                                                                              .state++;
                                                                          ref.read(panelIndexProvider.notifier).state = PanelIndex(
                                                                              id: currentSheet.id,
                                                                              panelIndex: 0);
                                                                        });
                                                                        print(
                                                                            '________END NEXT PAGE LD_________');
                                                                        return;
                                                                      }

                                                                      ref
                                                                          .read(
                                                                              currentPageIndexProvider.notifier)
                                                                          .state++;

                                                                      pdfScrollController.animateTo(
                                                                          ref.watch(currentPageIndexProvider) *
                                                                              ((1.41428571429 * ((sWidth * (1 - vDividerPosition)) - 6)) +
                                                                                  6),
                                                                          duration: Duration(
                                                                              milliseconds:
                                                                                  100),
                                                                          curve:
                                                                              Curves.easeIn);
                                                                      ref.read(panelIndexProvider.notifier).state = PanelIndex(
                                                                          id: ref
                                                                              .read(sheetListProviderFamily(ref.read(spreadSheetProvider.select((p) => p[ref.read(currentPageIndexProvider)]
                                                                                  .id))))
                                                                              .id,
                                                                          panelIndex:
                                                                              0);
                                                                      print(
                                                                          '________END NEXT PAGE LD_________');
                                                                      // pagePropertiesViewController.animateToPage(
                                                                      //     currentPageIndex,
                                                                      //     duration:
                                                                      //         Duration(milliseconds: 100),
                                                                      //     curve: Curves.easeIn);
                                                                      // pageViewIndicatorController.animateToPage(
                                                                      //     currentPageIndex,
                                                                      //     duration: Duration(milliseconds: 100),
                                                                      //     curve: Curves.easeIn);
                                                                      // });
                                                                    },
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      //pageNumber textfiwld
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: SizedBox(
                                                              height: 55,
                                                              child:
                                                                  TextFormField(
                                                                      onTapOutside:
                                                                          (event) {
                                                                        FocusScope.of(context)
                                                                            .unfocus();
                                                                      },
                                                                      cursorColor:
                                                                          defaultPalette
                                                                              .tertiary,
                                                                      controller:
                                                                          documentPropertiesList[ref.watch(currentPageIndexProvider)]
                                                                              .pageNumberController,
                                                                      inputFormatters: [
                                                                        FilteringTextInputFormatter.allow(
                                                                            RegExp(r'^\d*\.?\d*$'))
                                                                      ],
                                                                      decoration:
                                                                          InputDecoration(
                                                                        labelText:
                                                                            'Page Number',
                                                                        labelStyle:
                                                                            TextStyle(color: defaultPalette.black),
                                                                        filled:
                                                                            true,
                                                                        fillColor:
                                                                            defaultPalette.primary,
                                                                        border:
                                                                            OutlineInputBorder(
                                                                          // borderSide: BorderSide(width: 5, color: defaultPalette.black),
                                                                          borderRadius:
                                                                              BorderRadius.circular(10.0), // Replace with your desired radius
                                                                        ),
                                                                        enabledBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide: BorderSide(
                                                                              width: 2,
                                                                              color: defaultPalette.black),
                                                                          borderRadius:
                                                                              BorderRadius.circular(12.0), // Same as border
                                                                        ),
                                                                        disabledBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide: BorderSide(
                                                                              width: 2,
                                                                              color: defaultPalette.black),
                                                                          borderRadius:
                                                                              BorderRadius.circular(12.0), // Same as border
                                                                        ),
                                                                        focusedBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide: BorderSide(
                                                                              width: 3,
                                                                              color: defaultPalette.tertiary),
                                                                          borderRadius:
                                                                              BorderRadius.circular(10.0), // Same as border
                                                                        ),
                                                                      ),
                                                                      keyboardType:
                                                                          TextInputType
                                                                              .number,
                                                                      style: TextStyle(
                                                                          color: defaultPalette
                                                                              .black),
                                                                      enabled:
                                                                          false,
                                                                      onChanged:
                                                                          (value) {
                                                                        _updatePdfPreview;
                                                                        _addPdfPage();
                                                                      }),
                                                            ),
                                                          ),
                                                          //Delete page
                                                          GestureDetector(
                                                            child: IconButton(
                                                              icon: Icon(
                                                                Icons
                                                                    .delete_outline_rounded,
                                                                color:
                                                                    defaultPalette
                                                                        .black,
                                                              ),
                                                              onPressed: () {
                                                                _confirmDeleteLayout(
                                                                    context,
                                                                    deletePage:
                                                                        true);
                                                              },
                                                            ),
                                                          )
                                                        ],
                                                      ),

                                                      //pageview leftside document props
                                                      Column(
                                                        children: [
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    TextFormField(
                                                                  onTapOutside:
                                                                      (event) {
                                                                    FocusScope.of(
                                                                            context)
                                                                        .unfocus();
                                                                  },
                                                                  controller: documentPropertiesList[
                                                                          currentPageIndex]
                                                                      .marginAllController,
                                                                  inputFormatters: [
                                                                    NumericInputFormatter()
                                                                  ],
                                                                  decoration:
                                                                      InputDecoration(
                                                                    labelText:
                                                                        'Margin',
                                                                    labelStyle:
                                                                        TextStyle(
                                                                            color:
                                                                                defaultPalette.black),
                                                                    filled:
                                                                        true,
                                                                    fillColor: !useIndividualMargins
                                                                        ? defaultPalette
                                                                            .primary
                                                                        : defaultPalette
                                                                            .primary
                                                                            .withOpacity(0.5),
                                                                    border:
                                                                        OutlineInputBorder(
                                                                      // borderSide: BorderSide(width: 5, color: defaultPalette.black),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10.0), // Replace with your desired radius
                                                                    ),
                                                                    enabledBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide: BorderSide(
                                                                          width:
                                                                              2,
                                                                          color:
                                                                              defaultPalette.black),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              12.0), // Same as border
                                                                    ),
                                                                    focusedBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide: BorderSide(
                                                                          width:
                                                                              3,
                                                                          color:
                                                                              defaultPalette.tertiary),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10.0), // Same as border
                                                                    ),
                                                                  ),
                                                                  keyboardType:
                                                                      TextInputType
                                                                          .number,
                                                                  style: TextStyle(
                                                                      // fontStyle: FontStyle.italic,
                                                                      color: defaultPalette.black),
                                                                  onChanged:
                                                                      (value) {
                                                                    // setState(() {
                                                                    _updatePdfPreview;
                                                                    documentPropertiesList[
                                                                            currentPageIndex]
                                                                        .marginTopController
                                                                        .text = value;
                                                                    documentPropertiesList[
                                                                            currentPageIndex]
                                                                        .marginBottomController
                                                                        .text = value;
                                                                    documentPropertiesList[
                                                                            currentPageIndex]
                                                                        .marginLeftController
                                                                        .text = value;
                                                                    documentPropertiesList[
                                                                            currentPageIndex]
                                                                        .marginRightController
                                                                        .text = value;
                                                                    // });
                                                                  },
                                                                  enabled:
                                                                      !useIndividualMargins,
                                                                ),
                                                              ),
                                                              IconButton(
                                                                  onPressed:
                                                                      () {
                                                                    // setState(() {
                                                                    print(
                                                                        'haymana');
                                                                    _toggleUseIndividualMargins();
                                                                    if (useIndividualMargins ==
                                                                        false) {
                                                                      documentPropertiesList[
                                                                              currentPageIndex]
                                                                          .marginTopController
                                                                          .text = documentPropertiesList[
                                                                              currentPageIndex]
                                                                          .marginAllController
                                                                          .text;
                                                                      documentPropertiesList[
                                                                              currentPageIndex]
                                                                          .marginBottomController
                                                                          .text = documentPropertiesList[
                                                                              currentPageIndex]
                                                                          .marginAllController
                                                                          .text;
                                                                      documentPropertiesList[
                                                                              currentPageIndex]
                                                                          .marginLeftController
                                                                          .text = documentPropertiesList[
                                                                              currentPageIndex]
                                                                          .marginAllController
                                                                          .text;
                                                                      documentPropertiesList[
                                                                              currentPageIndex]
                                                                          .marginRightController
                                                                          .text = documentPropertiesList[
                                                                              currentPageIndex]
                                                                          .marginAllController
                                                                          .text;
                                                                    }
                                                                    // });
                                                                  },
                                                                  icon: Icon(Icons
                                                                      .expand_outlined))
                                                              // Text(
                                                              //     'Use Individual Margins'),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          if (useIndividualMargins)
                                                            Column(
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          TextFormField(
                                                                        onTapOutside:
                                                                            (event) {
                                                                          FocusScope.of(context)
                                                                              .unfocus();
                                                                        },
                                                                        controller:
                                                                            documentPropertiesList[currentPageIndex].marginTopController,
                                                                        inputFormatters: [
                                                                          // FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                                                                          NumericInputFormatter(),
                                                                        ],
                                                                        style: TextStyle(
                                                                            color:
                                                                                defaultPalette.black),
                                                                        cursorColor:
                                                                            defaultPalette.secondary,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          labelText:
                                                                              'Top',
                                                                          labelStyle: TextStyle(
                                                                              color: defaultPalette.black,
                                                                              fontSize: 20),
                                                                          filled:
                                                                              true,
                                                                          fillColor:
                                                                              defaultPalette.primary,
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
                                                                        onChanged:
                                                                            (value) =>
                                                                                _updatePdfPreview,
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Expanded(
                                                                      child:
                                                                          TextFormField(
                                                                        onTapOutside:
                                                                            (event) {
                                                                          FocusScope.of(context)
                                                                              .unfocus();
                                                                        },
                                                                        controller:
                                                                            documentPropertiesList[currentPageIndex].marginBottomController,
                                                                        inputFormatters: [
                                                                          NumericInputFormatter()
                                                                        ],
                                                                        style: TextStyle(
                                                                            color:
                                                                                defaultPalette.black),
                                                                        cursorColor:
                                                                            defaultPalette.secondary,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          labelText:
                                                                              'Bottom',
                                                                          labelStyle: TextStyle(
                                                                              color: defaultPalette.black,
                                                                              fontSize: 20),
                                                                          filled:
                                                                              true,
                                                                          fillColor:
                                                                              defaultPalette.primary,
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
                                                                        onChanged:
                                                                            (value) =>
                                                                                _updatePdfPreview,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height: 10,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          TextFormField(
                                                                        onTapOutside:
                                                                            (event) {
                                                                          FocusScope.of(context)
                                                                              .unfocus();
                                                                        },
                                                                        controller:
                                                                            documentPropertiesList[currentPageIndex].marginLeftController,
                                                                        inputFormatters: [
                                                                          NumericInputFormatter()
                                                                        ],
                                                                        style: TextStyle(
                                                                            color:
                                                                                defaultPalette.black),
                                                                        cursorColor:
                                                                            defaultPalette.black,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          labelText:
                                                                              'Left',
                                                                          labelStyle: TextStyle(
                                                                              color: defaultPalette.black,
                                                                              fontSize: 20),
                                                                          filled:
                                                                              true,
                                                                          fillColor:
                                                                              defaultPalette.primary,
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
                                                                        onChanged:
                                                                            (value) =>
                                                                                {
                                                                          _updatePdfPreview
                                                                        },
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Expanded(
                                                                      child:
                                                                          TextFormField(
                                                                        onTapOutside:
                                                                            (event) {
                                                                          FocusScope.of(context)
                                                                              .unfocus();
                                                                        },
                                                                        controller:
                                                                            documentPropertiesList[currentPageIndex].marginRightController,
                                                                        style: TextStyle(
                                                                            color:
                                                                                defaultPalette.black),
                                                                        cursorColor:
                                                                            defaultPalette.secondary,
                                                                        inputFormatters: [
                                                                          NumericInputFormatter()
                                                                        ],
                                                                        decoration:
                                                                            InputDecoration(
                                                                          labelText:
                                                                              'Right',
                                                                          labelStyle: TextStyle(
                                                                              color: defaultPalette.black,
                                                                              fontSize: 20),
                                                                          filled:
                                                                              true,
                                                                          fillColor:
                                                                              defaultPalette.primary,
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
                                                                        onChanged:
                                                                            (value) =>
                                                                                _updatePdfPreview,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          CustomDropdown(
                                                            hintText:
                                                                'Orientation',
                                                            items: [
                                                              'Portrait',
                                                              'Landscape'
                                                            ],
                                                            initialItem: documentPropertiesList[
                                                                            currentPageIndex]
                                                                        .orientationController ==
                                                                    pw.PageOrientation
                                                                        .portrait
                                                                ? 'Portrait'
                                                                : 'Landscape',
                                                            onChanged: (value) {
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
                                                            decoration:
                                                                CustomDropdownDecoration(
                                                              closedBorderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                              closedBorder: Border.all(
                                                                  color:
                                                                      defaultPalette
                                                                          .black,
                                                                  width: 2),
                                                              expandedBorder:
                                                                  Border.all(
                                                                      color: defaultPalette
                                                                          .tertiary,
                                                                      width: 3),
                                                              closedFillColor:
                                                                  defaultPalette
                                                                      .primary,
                                                              hintStyle: TextStyle(
                                                                  color:
                                                                      defaultPalette
                                                                          .black),
                                                              headerStyle: TextStyle(
                                                                  color:
                                                                      defaultPalette
                                                                          .black),
                                                            ),
                                                          ),
                                                          SizedBox(height: 10),
                                                          CustomDropdown.search(
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
                                                            onChanged: (value) {
                                                              documentPropertiesList[
                                                                          currentPageIndex]
                                                                      .pageFormatController =
                                                                  getPageFormatFromString(
                                                                      value ??
                                                                          '');
                                                              _updatePdfPreview(
                                                                  '');
                                                            },
                                                            decoration:
                                                                CustomDropdownDecoration(
                                                              closedBorderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                              closedBorder: Border.all(
                                                                  color:
                                                                      defaultPalette
                                                                          .black,
                                                                  width: 2),
                                                              expandedBorder:
                                                                  Border.all(
                                                                      color: defaultPalette
                                                                          .tertiary,
                                                                      width: 3),
                                                              closedFillColor:
                                                                  defaultPalette
                                                                      .primary,
                                                              hintStyle: TextStyle(
                                                                  color:
                                                                      defaultPalette
                                                                          .black),
                                                              headerStyle: TextStyle(
                                                                  color:
                                                                      defaultPalette
                                                                          .black),
                                                            ),
                                                          ),
                                                          // Divider(),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
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
                                        build: (format) =>
                                            _generatePdf(ref, format),
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
                                      .clamp(0.18, 0.95);
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
                    //////////TEXTLayout
                    Expanded(
                      flex: (((1 - appbarHeight) - hDividerPosition) * 10000)
                          .round(),
                      child: Column(
                        children: [
                          ////////TOP TOOL BAR
                          Expanded(
                            flex: (1 * 10000),
                            child: Container(
                              // height: sHeight / 20,
                              width: sWidth,
                              color: defaultPalette.white,
                              ///////TOP TOOL BAR
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  ///Resize handle
                                  GestureDetector(
                                      onPanUpdate: (details) {
                                        double newPosition = (hDividerPosition +
                                                details.delta.dy /
                                                    context.size!.height)
                                            .clamp(0.1, 0.85);
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
                                      onPressed: () => _confirmDeleteLayout(
                                          context,
                                          deletePage: false),
                                      icon: Icon(
                                        Icons.close,
                                        // size: 40,
                                        color: defaultPalette.black,
                                      )),
                                  IconButton(
                                      onPressed: () {
                                        print(
                                            '________addText pressed LD_________');
                                        print(
                                            'panelId from addtextfield: ${panelIndex.id}');
                                        _addTextField(panelIndex.id);
                                      },
                                      icon: Icon(
                                        Icons.add_comment_rounded,
                                        // size: 40,
                                        color: defaultPalette.black,
                                      )),
                                  IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.add_photo_alternate_outlined,
                                        // size: 40,
                                        color: defaultPalette.black,
                                      )),
                                  IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.table_chart_rounded,
                                        // size: 40,
                                        color: defaultPalette.black,
                                      )),
                                  IconButton(
                                      onPressed: () => _duplicateTextField(
                                          panelIndex.id, panelIndex.panelIndex),
                                      icon: Icon(
                                        Icons.copy_all_rounded,
                                        // size: 40,
                                        color: defaultPalette.black,
                                      )),
                                  IconButton(
                                      onPressed: () => _removeTextField(
                                          panelIndex.id, panelIndex.panelIndex),
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
                                  Flex(
                                    direction: Axis.vertical,
                                    children: _buildSpreadSheet(
                                        currentSheet, currentPageIndex),
                                  )
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
    for (int index = 0; index < sheetList.length; index++) {
      if (sheetList[index] is TextEditorItem) {
        print('editorID in buildWidget: ${sheetList[index].id} ');
        // widgetList.add(TextEditorWidget(
        //     isPhantom: false,
        //     id: sheetList[index].id,
        //     textEditorItem: sheetList[index] as TextEditorItem));
      }
    }
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
}

/// Function to create AnimatedPositioned widget with given parameters

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

class Test extends ConsumerStatefulWidget {
  final index;
  final currentPageIndex;
  final selectedIndex;
  final selectTextField;
  final documentPropertiesList;
  final i;
  final isReordering;
  const Test(
      this.index,
      this.currentPageIndex,
      this.selectedIndex,
      this.selectTextField,
      this.documentPropertiesList,
      this.i,
      this.isReordering,
      {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TestState();
}

class _TestState extends ConsumerState<Test> {
  get index => widget.index;
  get currentPageIndex => widget.currentPageIndex;
  get selectedIndex => widget.selectedIndex;
  get _selectTextField => widget.selectTextField;
  get i => widget.i;
  get documentPropertiesList => widget.documentPropertiesList;
  get isReordering => widget.isReordering;
  @override
  Widget build(BuildContext context) {
    // double sHeight = MediaQuery.of(context).size.height;
    double sWidth = MediaQuery.of(context).size.width;
    return Material(
      // Tile Color
      color: defaultPalette.white.withOpacity(0.9),
      key: Key('$index'),
      child: GestureDetector(
        onTap: () {
          if (selectedIndex[currentPageIndex] != index) {
            _selectTextField(index);
          }
          if (documentPropertiesList[i]
              .textFieldControllers[selectedIndex[currentPageIndex]]
              .focusController
              .hasFocus) {
            documentPropertiesList[i]
                .textFieldControllers[selectedIndex[currentPageIndex]]
                .focusController
                .requestFocus();
          }
        },
        child: AnimatedContainer(
          duration: Duration(microseconds: 1),
          padding: EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IgnorePointer(
            ignoring: false,
            // !documentPropertiesList[i]
            //     .textFieldControllers[
            //         index]
            //     .focusController
            //     .hasFocus,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Builder(builder: (context) {
                  double textfieldSize = (double.parse(documentPropertiesList[i]
                              .textFieldControllers[index]
                              .hintSizeController
                              .text)
                          .clamp(12, 20) +
                      45);
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
                        height: selectedIndex[currentPageIndex] == index
                            ? tileHeightX
                            : tileHeight,
                        width: sWidth * 0.8,
                      ),

                      ///individual Textfield
                      AnimatedPositioned(
                        top: selectedIndex[currentPageIndex] == index
                            ? (tileHeightX / 2) - tileHeight / 2
                            : 0,
                        duration: Duration(milliseconds: 200),
                        left: ((sWidth * 0.8) / 2) - 75,
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          width: 150,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                              color: isReordering
                                  ? Colors.transparent
                                  : (selectedIndex[currentPageIndex] == index
                                      ? defaultPalette.primary
                                      : Colors.transparent),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: QuillEditor(
                            configurations: QuillEditorConfigurations(
                                onTapUp: (details, p1) {
                                  documentPropertiesList[i]
                                      .textFieldControllers[index]
                                      .focusController
                                      .requestFocus();
                                  _selectTextField(index);
                                  return true;
                                },
                                onSingleLongTapStart: (details, p1) {
                                  documentPropertiesList[i]
                                      .textFieldControllers[index]
                                      .focusController
                                      .requestFocus();
                                  _selectTextField(index);
                                  return true;
                                },
                                onTapOutside: (event, focusNode) {
                                  focusNode.unfocus();
                                },
                                controller: QuillController(
                                  document: Document.fromDelta(Delta()
                                    ..insert(
                                        '${documentPropertiesList[i].textFieldControllers[index].hintController.text} \n')),
                                  selection:
                                      const TextSelection.collapsed(offset: 0),
                                  editorFocusNode: documentPropertiesList[i]
                                      .textFieldControllers[index]
                                      .focusController,
                                )),
                            focusNode: documentPropertiesList[i]
                                .textFieldControllers[index]
                                .focusController,
                            scrollController: ScrollController(),
                          ),

                          // TextFormField(
                          //   maxLines: null,
                          //   focusNode: documentPropertiesList[i]
                          //       .textFieldControllers[index]
                          //       .focusController,
                          //   onTap: () {
                          //     documentPropertiesList[i]
                          //         .textFieldControllers[index]
                          //         .focusController
                          //         .requestFocus();
                          //     _selectTextField(index);
                          //   },
                          //   onTapOutside: (d) {
                          //     documentPropertiesList[i]
                          //         .textFieldControllers[index]
                          //         .focusController
                          //         .unfocus();
                          //   },
                          //   controller: documentPropertiesList[i]
                          //       .textFieldControllers[index]
                          //       .textController,
                          //   onChanged: (value) {
                          //     setState(() {});
                          //   },
                          //   decoration: InputDecoration(
                          //     filled: true,
                          //     fillColor: defaultPalette.secondary,
                          //     contentPadding: EdgeInsets.all(10),
                          //     hintText: documentPropertiesList[i]
                          //         .textFieldControllers[index]
                          //         .hintController
                          //         .text,
                          //     hintStyle: TextStyle(
                          //       fontSize: double.parse(documentPropertiesList[i]
                          //                   .textFieldControllers[index]
                          //                   .hintSizeController
                          //                   .text) >
                          //               25
                          //           ? 20
                          //           : double.parse(documentPropertiesList[i]
                          //               .textFieldControllers[index]
                          //               .hintSizeController
                          //               .text),
                          //       color: Color(int.parse(documentPropertiesList[i]
                          //           .textFieldControllers[index]
                          //           .colorController
                          //           .text
                          //           .replaceFirst('#', '0xff'))),
                          //     ),
                          //     border: InputBorder.none,
                          //   ),
                          //   style: TextStyle(
                          //     color: documentPropertiesList[i]
                          //         .textFieldControllers[index]
                          //         .style
                          //         .color,
                          //     fontSize: documentPropertiesList[i]
                          //                 .textFieldControllers[index]
                          //                 .style
                          //                 .fontSize! >
                          //             25
                          //         ? 20
                          //         : documentPropertiesList[i]
                          //             .textFieldControllers[index]
                          //             .style
                          //             .fontSize,
                          //   ),
                          // ),
                        ),
                      ),

                      // // Left side button
                      buildAnimatedPositioned(
                        selectedIndex: selectedIndex[currentPageIndex],
                        currentPageIndex: currentPageIndex,
                        index: index,
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
                        selectedIndex: selectedIndex[currentPageIndex],
                        currentPageIndex: currentPageIndex,
                        index: index,
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
                        selectedIndex: selectedIndex[currentPageIndex],
                        currentPageIndex: currentPageIndex,
                        index: index,
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
                        selectedIndex: selectedIndex[currentPageIndex],
                        currentPageIndex: currentPageIndex,
                        index: index,
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
        ),
      ),
    );
  }
}
