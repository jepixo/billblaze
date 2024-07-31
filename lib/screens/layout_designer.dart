// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:billblaze/models/layout_model.dart';
import 'package:billblaze/providers/box_provider.dart';
import 'package:expandable_menu/expandable_menu.dart';
import 'package:path_provider/path_provider.dart';

import 'package:billblaze/components/flutter_balloon_slider.dart';
import 'package:billblaze/components/zoomable.dart';
import 'package:billblaze/components/tab_container/tab_controller.dart';
import 'package:billblaze/components/text_toolbar/list_item_model.dart';
import 'package:billblaze/components/text_toolbar/playable_toolbar_flutter.dart';
import 'package:billblaze/util/HexColorInputFormatter.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart'
    show ColorPicker, MaterialPicker;
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:billblaze/colors.dart';
import 'package:billblaze/components/printing.dart'
    if (dart.library.html) 'package:printing/printing.dart';
// import 'package:printing/printing.dart';
import 'package:billblaze/models/spread_sheet_lib/spread_sheet.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_list.dart';
import 'package:billblaze/models/spread_sheet_lib/text_editor_item.dart';
import 'package:billblaze/models/document_properties_model.dart';
import 'package:billblaze/util/numeric_input_filter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
// show
//     QuillEditor,
//     QuillController,
//     Attribute,
//     Document,
//     QuillEditorConfigurations;
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:math' as math;

import 'package:uuid/uuid.dart';

import '../components/elevated_button.dart';

class PanelIndex {
  String id;
  String parentId = '';
  int panelIndex;
  PanelIndex({required this.id, required this.panelIndex, parentId = ''});

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
  final int? id;
  final int? index;
  const LayoutDesigner3({
    Key? key,
    this.id = null,
    this.index = -1,
  }) : super(key: key);

  @override
  State<LayoutDesigner3> createState() => _LayoutDesigner3State();
}

class _LayoutDesigner3State extends State<LayoutDesigner3>
    with SingleTickerProviderStateMixin {
  double hDividerPosition = 0.5;
  double vDividerPosition = 0.55;
  double appbarHeight = 0.065;
  DateTime dateTimeNow = DateTime.now();
  int pageCount = 0;
  int currentPageIndex = 0;
  List<SelectedIndex> selectedIndex = [];
  PanelIndex panelIndex = PanelIndex(id: '', panelIndex: -1);
  PageController pageViewIndicatorController = PageController();
  // PageController pageTextFieldsController = PageController();
  PageController textStyleTabControler = PageController();
  ScrollController pdfScrollController = ScrollController();
  List<SheetList> spreadSheetList = [];
  List<DocumentProperties> documentPropertiesList = [];
  double textFieldHeight = 40;
  double presuConstraintsMinW = 20;
  FocusNode marginAllFocus = FocusNode();
  FocusNode marginTopFocus = FocusNode();
  FocusNode marginBottomFocus = FocusNode();
  FocusNode marginLeftFocus = FocusNode();
  FocusNode marginRightFocus = FocusNode();
  FocusNode fontSizeFocus = FocusNode();
  FocusNode letterSpaceFocus = FocusNode();
  FocusNode wordSpaceFocus = FocusNode();
  FocusNode lineSpaceFocus = FocusNode();

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

  List<bool> isTapped = [false, true, false, false, false];
  List<GlobalKey> globalKeys = [];
  List<dynamic> _images = [];
  late LayoutModel? lm;
  GlobalKey spreadSheetKey = GlobalKey();
  double get sWidth => MediaQuery.of(context).size.width;
  double get sHeight => MediaQuery.of(context).size.height;
  int key = 0;
  int keyIndex = 0;
  //
  //
  //
  //
  @override
  void initState() {
    super.initState();
    key = widget.id ?? -1;
    keyIndex = widget.index ?? -1;
    // animateToPage(currentPageIndex);
    var box = Boxes.getLayouts();
    if (key == -1) {
      print('create new layout');
      lm = LayoutModel(
          createdAt: DateTime.now(),
          modifiedAt: DateTime.now(),
          name: Boxes.getLayoutName(),
          docPropsList: [],
          spreadSheetList: [],
          id: Uuid().v4());

      key = Random().nextInt(100000);
      keyIndex = box.length;
      box.put(key, lm!);
      print(key);
      lm!.save();
      Future.delayed(Duration.zero).then(
        (value) {
          _addPdfPage();
        },
      ).then(
        (value) {
          print(Boxes.getLayouts().get(key)?.docPropsList);
        },
      );
    } else {
      // _addPdfPage();
      print('reaches else in init');
      print(key);
      lm = box.get(key);
      print(box.get(key));
      print(lm?.docPropsList);
      spreadSheetList = boxToSpreadSheet(lm?.spreadSheetList);
      documentPropertiesList = boxToDocProp(lm?.docPropsList);
      print(documentPropertiesList.isEmpty);
      if (documentPropertiesList.isEmpty) {
        _addPdfPage();
      }
    }

    // _updatePdfPreview('');
    tabcunt = TabController(length: 2, vsync: this);
    globalKeys = List.generate(1000, (_) => GlobalKey());
  }

  @override
  void dispose() {
    pageViewIndicatorController.dispose();
    textStyleTabControler.dispose();
    super.dispose();
  }

  List<DocumentProperties> boxToDocProp(docproplist) {
    List<DocumentProperties> listbox = [];

    for (DocumentPropertiesBox doc in docproplist) {
      print('doc num: ${doc.pageNumberController}');
      listbox.add(doc.toDocumentProperties());
      setState(() {
        pageCount++;
      });
    }
    return listbox;
  }

  List<DocumentPropertiesBox> docPropToBox(docproplist) {
    List<DocumentPropertiesBox> listbox = [];
    for (DocumentProperties doc in docproplist) {
      listbox.add(doc.toDocPropBox());
    }
    return listbox;
  }

  List<SheetListBox> spreadSheetToBox(spreadSheetList) {
    List<SheetListBox> listbox = [];
    for (SheetList sheetlist in spreadSheetList) {
      SheetListBox sheetListBox = SheetListBox(
          sheetList: [],
          direction: sheetlist.direction == Axis.vertical ? true : false,
          id: sheetlist.id,
          parentId: sheetlist.parentId);
      for (var i = 0; i < sheetlist.length; i++) {
        if (sheetlist[i] is TextEditorItem) {
          sheetListBox.sheetList
              .add(tEItemToteItemBox(sheetlist[i] as TextEditorItem));
        } else if (sheetlist[i] is SheetList) {
          sheetListBox.sheetList.add(sheetListtoBox(sheetlist[i] as SheetList));
        }
      }
      listbox.add(sheetListBox);
    }
    return listbox;
  }

  TextEditorItemBox tEItemToteItemBox(TextEditorItem item) {
    print(
        'conversion text: ${item.textEditorController.document.toDelta().toJson()}');
    return TextEditorItemBox(
        textEditorController:
            item.textEditorController.document.toDelta().toJson(),
        id: item.id,
        parentId: item.parentId);
  }

  SheetListBox sheetListtoBox(SheetList sheetlist) {
    SheetListBox sheetListBox = SheetListBox(
        sheetList: [],
        direction: sheetlist.direction == Axis.vertical ? true : false,
        id: sheetlist.id,
        parentId: sheetlist.parentId);
    for (var i = 0; i < sheetlist.length; i++) {
      if (sheetlist[i] is TextEditorItem) {
        sheetListBox.sheetList
            .add(tEItemToteItemBox(sheetlist[i] as TextEditorItem));
      } else if (sheetlist[i] is SheetList) {
        sheetListBox.sheetList.add(sheetListtoBox(sheetlist[i] as SheetList));
      }
    }
    return sheetListBox;
  }

  List<SheetList> boxToSpreadSheet(spreadsheetlist) {
    List<SheetList> listbox = [];
    for (SheetListBox e in spreadsheetlist) {
      SheetList sheetList =
          SheetList(id: e.id, parentId: e.parentId, sheetList: []);
      for (var item in e.sheetList) {
        if (item is TextEditorItemBox) {
          print('There is a TextEditorItemBox');
          TextEditorItem tEItem = _addTextField(
              shouldReturn: true,
              docString: item.textEditorController,
              id: item.id,
              parentId: item.parentId);
          tEItem = tEItem.copyWith(id: item.id, parentId: item.parentId);
          sheetList.sheetList.add(tEItem);
        } else if (item is SheetListBox) {
          sheetList.sheetList.add(boxToSheetList(item));
        }
      }

      listbox.add(sheetList);
    }
    return listbox;
  }

  SheetList boxToSheetList(SheetListBox sheetListBox) {
    SheetList sheetList = SheetList(
        id: sheetListBox.id, parentId: sheetListBox.parentId, sheetList: []);
    for (var item in sheetListBox.sheetList) {
      if (item is TextEditorItemBox) {
        TextEditorItem tEItem = _addTextField(
            shouldReturn: true,
            docString: item.textEditorController,
            id: item.id,
            parentId: item.parentId);
        tEItem = tEItem.copyWith(id: item.id, parentId: item.parentId);
        sheetList.sheetList.add(tEItem);
      } else if (item is SheetListBox) {
        sheetList.sheetList.add(boxToSheetList(item));
      }
    }
    return sheetList;
  }

  TextEditorItem _addTextField({
    String id = '',
    String parentId = '',
    bool shouldReturn = false,
    List<Map<String, dynamic>>?
        docString, // Use List<Map<String, dynamic>> directly
  }) {
    Delta delta;
    print('DocString: $docString');

    try {
      if (docString != null && docString.isNotEmpty) {
        // Convert List<Map<String, dynamic>> to Delta
        delta = Delta.fromJson(docString);
        // Check if delta is empty or not
        if (delta.isEmpty) {
          delta = Delta(); // Fallback to an empty Delta
        }
      } else {
        delta =
            Delta(); // Default to an empty Delta if docString is null or empty
      }
      print('Decoded Delta: $delta');
    } catch (e) {
      // Handle error if any occurs
      print('Error converting to Delta: $e');
      delta = Delta(); // Default to an empty Delta in case of error
    }

    // Initialize QuillController with the appropriate Document
    QuillController textController;
    if (delta.isEmpty) {
      textController = QuillController(
        document: Document(), // Use an empty document if delta is empty
        selection: TextSelection.collapsed(offset: 0),
        onSelectionChanged: (textSelection) {
          setState(() {});
        },
        onDelete: (cursorPosition, forward) {
          setState(() {});
        },
        onSelectionCompleted: () {
          setState(() {});
        },
      );
    } else {
      textController = QuillController(
        document: Document.fromDelta(delta), // Use delta to create the document
        selection: TextSelection.collapsed(offset: 0),
        onSelectionChanged: (textSelection) {
          setState(() {});
        },
        onDelete: (cursorPosition, forward) {
          setState(() {});
        },
        onSelectionCompleted: () {
          setState(() {});
        },
      );
    }

    String newId = id.isEmpty ? Uuid().v4() : id;
    var textEditorConfigurations = QuillEditorConfigurations(
      padding: EdgeInsets.all(2),
      controller: textController,
      placeholder: 'Enter Text',
      customStyleBuilder: (attribute) {
        // Handle custom styles
        if (attribute.key == 'letterSpacing') {
          String? letterSpacing = attribute.value as String?;
          return TextStyle(letterSpacing: double.parse(letterSpacing ?? '0'));
        }

        if (attribute.key == 'wordSpacing') {
          String? wordSpacing = attribute.value as String?;
          return TextStyle(wordSpacing: double.parse(wordSpacing ?? '0'));
        }

        if (attribute.key == 'lineHeight') {
          String? lineHeight = attribute.value as String?;
          return TextStyle(height: double.parse(lineHeight ?? '0'));
        }

        return TextStyle(); // Default style
      },
      builder: (context, rawEditor) {
        return Stack(
          children: [
            Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: defaultPalette.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: rawEditor),
          ],
        );
      },
      onTapDown: (details, p1) {
        var isTrue = panelIndex.id == newId;
        setState(() {
          var itemE =
              _sheetItemIterator(newId, spreadSheetList[currentPageIndex]);

          var index = _sheetListIterator(
                  itemE!.parentId, spreadSheetList[currentPageIndex])
              .indexOf(itemE);
          panelIndex = PanelIndex(
              id: itemE.id, panelIndex: index, parentId: itemE.parentId);

          if (hDividerPosition > 0.48) {
            hDividerPosition = 0.4;
          }
        });

        // Future.delayed(Duration.zero).then((_) {
        //   textStylePageController.jumpToPage(panelIndex.panelIndex);
        // });

        Future.delayed(Durations.short1).then((_) {
          if (!isTrue) {
            textStyleTabControler.animateToPage(0,
                curve: Curves.bounceIn, duration: Durations.short1);
            for (var i = 0; i < isTapped.length; i++) {
              setState(() {
                isTapped[i] = false;
              });
            }
            setState(() {
              isTapped[1] = true;
            });
          }
        });

        print('clicked');
        print(panelIndex);
        return false;
      },
    );

    if (!shouldReturn) {
      setState(() {
        spreadSheetList[currentPageIndex].add(TextEditorItem(
          textEditorController: textController,
          textEditorConfigurations: textEditorConfigurations,
          id: newId,
          parentId: spreadSheetList[currentPageIndex].id,
        ));

        var lm = Boxes.getLayouts().values.toList().cast<LayoutModel>();
        lm[keyIndex].spreadSheetList[currentPageIndex].sheetList.add(
            TextEditorItemBox(
                textEditorController:
                    textController.document.toDelta().toJson(),
                id: newId,
                parentId: spreadSheetList[currentPageIndex].id));
        lm[keyIndex].save();
      });
    }

    return TextEditorItem(
      textEditorController: textController,
      textEditorConfigurations: textEditorConfigurations,
      id: newId,
      parentId: parentId.isNotEmpty
          ? parentId
          : spreadSheetList[currentPageIndex].id, // Use parentId if not empty
    );
  }

  SheetList _sheetListIterator(String id, SheetList sheetList) {
    if (sheetList.id == id) {
      return sheetList;
    }
    for (var i = 0; i < sheetList.length; i++) {
      if (sheetList[i].id == id) {
        return sheetList[i] as SheetList;
      }
      if (sheetList[i] is SheetList) {
        if (_listIterator(id, sheetList[i] as SheetList) != null) {
          return _listIterator(id, sheetList[i] as SheetList)!;
        }
      }
    }
    throw Exception('SheetList with id $id not found');
  }

  SheetList? _listIterator(String id, SheetList sheetList) {
    if (sheetList.id == id) {
      return sheetList;
    }
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
    return null;
  }

  SheetItem _sheetItemIterator(String id, SheetList sheetList) {
    print('id for search: $id');
    for (var i = 0; i < sheetList.length; i++) {
      print('item id in iterator: ${sheetList[i].id}');
      print('item in iterator: ${sheetList[i]}');
      if (sheetList[i] is TextEditorItem && sheetList[i].id == id) {
        print('textitem id in iterator: ${sheetList[i].id}');
        return sheetList[i];
      }
      if (sheetList[i] is SheetList) {
        print('listitem id in iterator: ${sheetList[i].id}');
        if (_itemIterator(id, sheetList[i] as SheetList) != null) {
          return _itemIterator(id, sheetList[i] as SheetList)!;
        }
      }
    }
    throw throw Exception('SheetItem with id $id not found');
  }

  SheetItem? _itemIterator(String id, SheetList sheetList) {
    print('id for search: $id');
    for (var i = 0; i < sheetList.length; i++) {
      print('item id in iterator: ${sheetList[i].id}');
      print('item in iterator: ${sheetList[i]}');
      if (sheetList[i] is TextEditorItem && sheetList[i].id == id) {
        print('textitem id in iterator: ${sheetList[i].id}');
        return sheetList[i];
      }
      if (sheetList[i] is SheetList) {
        print('listitem id in iterator: ${sheetList[i].id}');
        return _sheetItemIterator(id, sheetList[i] as SheetList);
      }
    }
    return null;
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
                  if (pageCount == 1) {
                    spreadSheetList[currentPageIndex].sheetList = [];
                    panelIndex = PanelIndex(
                        id: panelIndex.id,
                        panelIndex: -1,
                        parentId: panelIndex.parentId);
                    return;
                  }
                  pageCount--;
                  documentPropertiesList.removeAt(currentPageIndex);
                  spreadSheetList.removeAt(currentPageIndex);
                  currentPageIndex--;
                  panelIndex = PanelIndex(
                      id: spreadSheetList[currentPageIndex].id,
                      panelIndex: -1,
                      parentId: spreadSheetList[currentPageIndex].parentId);
                  return;
                }
                spreadSheetList[currentPageIndex].sheetList = [];
                panelIndex = PanelIndex(
                    id: panelIndex.id,
                    panelIndex: -1,
                    parentId: panelIndex.parentId);
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
    setState(() {
      var itemField = _addTextField(shouldReturn: true);
      var controller = QuillController(
        document: (spreadSheetList[currentPageIndex][panelIndex.panelIndex]
                as TextEditorItem)
            .textEditorController
            .document,
        selection: (spreadSheetList[currentPageIndex][panelIndex.panelIndex]
                as TextEditorItem)
            .textEditorController
            .selection,
        onDelete: itemField.textEditorController.onDelete,
        onReplaceText: itemField.textEditorController.onReplaceText,
        onSelectionChanged: itemField.textEditorController.onSelectionChanged,
        onSelectionCompleted:
            itemField.textEditorController.onSelectionCompleted,
      );
      var editorConfig = QuillEditorConfigurations(
        controller: controller,
        builder: itemField.textEditorConfigurations.builder,
        customStyles: itemField.textEditorConfigurations.customStyles,
        onTapDown: itemField.textEditorConfigurations.onTapDown,
        placeholder: itemField.textEditorConfigurations.placeholder,
      );
      if (panelIndex.panelIndex != -1) {
        spreadSheetList[currentPageIndex].insert(
            panelIndex.panelIndex + 1,
            TextEditorItem(
              id: itemField.id,
              parentId: itemField.parentId,
              focusNode: itemField.focusNode,
              scrollController: itemField.scrollController,
              textEditorConfigurations: editorConfig,
              textEditorController: controller,
            ));
      }
    });
  }

  void _removeTextField() {
    setState(() {
      spreadSheetList[currentPageIndex].removeAt(panelIndex.panelIndex);
      panelIndex = PanelIndex(id: '', panelIndex: -1, parentId: '');
    });
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

    pw.TextAlign? getAlign() {
      if (delta.toList()[0].attributes?.containsKey('align') ?? true) {
        switch (delta.toList()[0].attributes?['align']) {
          case 'center':
            return pw.TextAlign.center;
          // break;
          case 'right':
            return pw.TextAlign.right;
          // break;
          case 'justify':
            return pw.TextAlign.justify;
          // break;
          case 'left':
            return pw.TextAlign.left;
        }
      }
      print('returning lol');
      return null;
    }

    final List<pw.Widget> textWidgets = [];
    // pw.Widget checkbox = pw.Container();
    pw.TextAlign? textAlign = getAlign();
    pw.TextDirection textDirection = pw.TextDirection.ltr;
    // pw.Widget lastWidget = pw.Container();
    for (var op in delta.toList()) {
      if (op.value is String) {
        var text = op.value.toString();
        Map<String, dynamic>? attributes = op.attributes;
        // pw.EdgeInsets? padding;
        pw.TextStyle textStyle = const pw.TextStyle();
        PdfColor? backgroundColor;
        if (attributes != null) {
          if (attributes.containsKey('bold')) {
            print('bold');
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
          if (attributes.containsKey('indent')) {}

          if (attributes.containsKey('direction')) {
            print('direction yes');
            print(attributes['direction']);
            if (attributes['direction'] == 'rtl') {
              print('direction yes');
              textDirection = pw.TextDirection.rtl;
            } else {
              textDirection = pw.TextDirection.ltr;
            }
          }

          if (attributes.containsKey('link')) {
            continue;
          }
        }
        int currentIndex = delta.toList().indexOf(op);
        Operation? newOP;
        for (int j = currentIndex + 1; j < delta.toList().length; j++) {
          var nextOp = delta.toList()[j];
          if (nextOp.value is String &&
              (nextOp.value as String).startsWith('\n')) {
            newOP = nextOp;
            break;
          }
        }

        if (newOP != null &&
            (newOP.attributes?.containsKey('align') ?? false)) {
          switch (newOP.attributes?['align']) {
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
        } else if (newOP == null) {
          textAlign = pw.TextAlign.left;
        }
        // Check if text starts with '\n'
        bool startsWithNewLine = text.startsWith('\n');
        //
        if (delta.toList().indexOf(op) == 0) {
          startsWithNewLine = true;
        }
        if (startsWithNewLine) {
          print(
              '$startsWithNewLine texalign: $textAlign. ${delta.toList().indexOf(op)}:${text.toString()}');
          textWidgets.add(pw.Container(
              width: double.infinity,
              alignment: textAlign == pw.TextAlign.left
                  ? pw.Alignment.topLeft
                  : textAlign == pw.TextAlign.right
                      ? pw.Alignment.topRight
                      : pw.Alignment.center,
              child: pw.RichText(
                text: pw.TextSpan(children: [
                  pw.TextSpan(
                    text: text.substring(0,
                        text[text.length - 1] == '\n' ? text.length - 1 : null),
                    style: textStyle,
                  )
                ]),
                textAlign: textAlign,
                textDirection: textDirection,
              )));
        } else {
          print(
              'texalign: $textAlign. ${delta.toList().indexOf(op)}:${text.toString()}');
          (((textWidgets[textWidgets.length - 1] as pw.Container).child
                      as pw.RichText)
                  .text as pw.TextSpan)
              .children
              ?.add(pw.TextSpan(
                  text: text.substring(0,
                      text[text.length - 1] == '\n' ? text.length - 1 : null),
                  style: textStyle));
        }
      }
    }

    print('________END convertDELTA LD_________');
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start, // Adjust as necessary
      children: textWidgets,
    );
  }

// genWidget
  Widget _generateWid(sWidth, sHeight) {
    var width = (sWidth * (1 - vDividerPosition)) - 16;
    var doc = documentPropertiesList;
    var sheetList = spreadSheetList;
    return SingleChildScrollView(
      controller: pdfScrollController,
      child: Column(
        children: [
          for (int i = 0; i < pageCount; i++)
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 30.0, horizontal: 10),
              child: RepaintBoundary(
                key: globalKeys[i],
                child: Container(
                  width: doc[i].pageFormatController == PdfPageFormat.a4
                      ? 1 * 793.7007874
                      : doc[i].pageFormatController == PdfPageFormat.a3
                          ? 0.72 * 1122.519685
                          : doc[i].pageFormatController == PdfPageFormat.a5
                              ? 1 * 559.37007874
                              : doc[i].pageFormatController == PdfPageFormat.a6
                                  ? 1 * 396.8503937
                                  : doc[i].pageFormatController ==
                                          PdfPageFormat.letter
                                      ? 1 * 816
                                      : doc[i].pageFormatController ==
                                              PdfPageFormat.legal
                                          ? 1 * 816
                                          : 2480 / 2,
                  height: doc[i].pageFormatController == PdfPageFormat.a4
                      ? 1 * 1122.519685
                      : doc[i].pageFormatController == PdfPageFormat.a3
                          ? 0.72 * 1587.4015748
                          : doc[i].pageFormatController == PdfPageFormat.a5
                              ? 1 * 793.7007874
                              : doc[i].pageFormatController == PdfPageFormat.a6
                                  ? 1 * 559.37007874
                                  : doc[i].pageFormatController ==
                                          PdfPageFormat.letter
                                      ? 1 * 1056
                                      : doc[i].pageFormatController ==
                                              PdfPageFormat.legal
                                          ? 1 * 1344
                                          : 3508 / 2,
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    // BoxShadow(
                    //   blurRadius: 5,
                  ]),
                  padding: EdgeInsets.only(
                    top: double.parse(doc[i].marginTopController.text),
                    bottom: double.parse(doc[i].marginBottomController.text),
                    left: double.parse(doc[i].marginLeftController.text),
                    right: double.parse(doc[i].marginRightController.text),
                  ),
                  child: _buildSheetListWidget(
                      sheetList[i], sWidth * (1 - vDividerPosition)),
                ),
              ),
            )
        ],
      ),
    );
    //   itemCount: pageCount,
    //   itemBuilder: (context, i) {
    //   },
    // );
  }

  Widget _buildSheetListWidget(SheetList sheetList, double width) {
    return IntrinsicHeight(
      child: Flex(
        direction: sheetList.direction,
        children: List.generate(sheetList.sheetList.length, (index) {
          final item = sheetList.sheetList[index];
          if (item is TextEditorItem) {
            print('in buildSheetListWidget item is: $item');
            return IgnorePointer(
              key: ValueKey(item),
              child: Container(
                width: sheetList.direction == Axis.horizontal ? width : null,
                child: QuillEditor(
                  key: ValueKey(item.id),
                  configurations: QuillEditorConfigurations(
                    scrollable: false,
                    showCursor: false,
                    enableInteractiveSelection: false,
                    enableSelectionToolbar: false,
                    requestKeyboardFocusOnCheckListChanged: false,
                    customStyleBuilder: (attribute) {
                      // Handle letter spacing
                      if (attribute.key == 'letterSpacing') {
                        String? letterSpacing = attribute.value as String?;
                        return TextStyle(
                          letterSpacing: double.parse(letterSpacing ?? '0'),
                        );
                      }
                      // Handle word spacing (custom attribute example)
                      if (attribute.key == 'wordSpacing') {
                        String? wordSpacing = attribute.value as String?;
                        return TextStyle(
                          wordSpacing: double.parse(wordSpacing ?? '0'),
                        );
                      }
                      // Handle line height (custom attribute example)
                      if (attribute.key == 'lineHeight') {
                        String? lineHeight = attribute.value as String?;
                        return TextStyle(
                          height: double.parse(lineHeight ?? '0'),
                        );
                      }
                      // Return default TextStyle if attribute not handled
                      return TextStyle();
                    },
                    disableClipboard: true,
                    controller: QuillController(
                      document: item.textEditorController.document,
                      selection: item.textEditorController.selection,
                      readOnly: true,
                      onSelectionChanged: (textSelection) {
                        setState(() {});
                      },
                      onReplaceText: (index, len, data) {
                        setState(() {});
                        return false;
                      },
                      onSelectionCompleted: () {
                        setState(() {});
                      },
                      onDelete: (cursorPosition, forward) {
                        setState(() {});
                      },
                    ),
                  ),
                  focusNode: FocusNode(),
                  scrollController: ScrollController(),
                ),
              ),
            );
          } else if (item is SheetList) {
            print('in buildSheetListWidget item is: $item');
            return _buildSheetListWidget(item, width);
          }
          return SizedBox();
        }),
      ),
    );
  }

  void _addPdfPage() {
    var lm = Boxes.getLayouts().values.toList().cast<LayoutModel>();
    var id = Uuid().v4();

    print('pageCount in addpage: $pageCount');
    DocumentProperties newdoc = DocumentProperties(
      pageNumberController:
          TextEditingController(text: (++pageCount).toString()),
      marginAllController: TextEditingController(text: '10'),
      marginLeftController: TextEditingController(text: '10'),
      marginRightController: TextEditingController(text: '10'),
      marginBottomController: TextEditingController(text: '10'),
      marginTopController: TextEditingController(text: '10'),
      orientationController: pw.PageOrientation.portrait,
      pageFormatController: PdfPageFormat.a4,
    );
    setState(() {
      documentPropertiesList.add(newdoc);
    });
    print('in addpage newdoc: $newdoc');
    lm[keyIndex].docPropsList = docPropToBox(documentPropertiesList);
    lm[keyIndex].save();
    print('inaddpage after addinbox docprop: ${lm[keyIndex].docPropsList}');
    SheetList newsheetlist =
        SheetList(id: id, parentId: parentId, sheetList: []);

    setState(() {
      spreadSheetList.add(newsheetlist);
    });
    lm[keyIndex].spreadSheetList = spreadSheetToBox(spreadSheetList);
    lm[keyIndex]
        .save(); // Boxes.getLayouts().update(LayoutModel(docPropsList: newdoc, spreadSheetList: newsheetlist.toSheetListBox(), id: id));
    setState(() {
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

  Future<void> _capturePng(i) async {
    try {
      // var _globalKey = globalKeys[i];
      print(globalKeys[i].toString());
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        RenderRepaintBoundary? boundary = globalKeys[i]
            .currentContext
            ?.findRenderObject() as RenderRepaintBoundary?;
        if (boundary == null) {
          print("Boundary is null");
          return;
        }
        ui.Image image = await boundary.toImage(pixelRatio: 7.0);
        ByteData? byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData == null) {
          print("ByteData is null");
          return;
        }
        Uint8List pngBytes = byteData.buffer.asUint8List();
        _images.clear();
        setState(() {
          _images.add(pngBytes);
        });
        print('image added');
        _genPdf();
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _genPdf() async {
    final pdf = pw.Document();

    for (var img in _images) {
      final image = pw.MemoryImage(img);
      pdf.addPage(
        pw.Page(
          margin: pw.EdgeInsets.all(0),
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(image),
            );
          },
        ),
      );
    }

    final output = await getApplicationDocumentsDirectory();
    final file = File("${output.path}/example.pdf");
    await file.writeAsBytes(await pdf.save());

    // Display the PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
    // await Printing.sharePdf(bytes: await pdf.save());
    print("PDF saved to: ${file.path}");
  }

  void updateBox() {
    var lm = Boxes.getLayouts().values.toList().cast<LayoutModel>();
    lm[keyIndex].docPropsList = docPropToBox(documentPropertiesList);
    lm[keyIndex].spreadSheetList = spreadSheetToBox(spreadSheetList);
    lm[keyIndex].save();
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
                      //APPBAR
                      Expanded(
                        flex: (appbarHeight * 10000).round(),
                        child: Container(
                          height: sHeight * 0.1,
                        ),
                      ),
                      //TOP HALF
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
                                              height:
                                                  sHeight * hDividerPosition,
                                              color: Colors.transparent,
                                            ),

                                            ///LEFT TITLE PAGE PROPS
                                            Positioned(
                                              // duration: Durations.medium4,
                                              top: 0,
                                              left: panelIndex.panelIndex != -1
                                                  ? -sWidth * vDividerPosition
                                                  : 0,
                                              height: (sHeight) *
                                                  (hDividerPosition),
                                              width: sWidth * vDividerPosition,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                child:

                                                    ///LEFT TITLE PAGE PROPS
                                                    Material(
                                                  color: defaultPalette
                                                      .transparent,
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
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      left: 10,
                                                                      top: 8,
                                                                      bottom:
                                                                          5),
                                                              width: sWidth *
                                                                  vDividerPosition *
                                                                  0.4,
                                                              child: Text(
                                                                  vDividerPosition <
                                                                          0.45
                                                                      ? 'PG \nPRP'
                                                                      : 'Page Properties',
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
                                                              right: 30,
                                                              top: 12,
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                    color: defaultPalette
                                                                        .tertiary,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8)),
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        top: 5),
                                                                height: 30,
                                                                width: 50,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceAround,
                                                                  children: [
                                                                    GestureDetector(
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .keyboard_arrow_left_sharp,
                                                                        color: defaultPalette
                                                                            .black,
                                                                      ),
                                                                      onTap:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          print(
                                                                              '________PREV PAGE STARTED LD_________');
                                                                          if (currentPageIndex ==
                                                                              0) {
                                                                            pdfScrollController.animateTo(currentPageIndex * ((1.41428571429 * ((sWidth * (1 - vDividerPosition)))) + 16),
                                                                                duration: Duration(milliseconds: 100),
                                                                                curve: Curves.easeIn);
                                                                            return;
                                                                          }
                                                                          currentPageIndex--;

                                                                          pdfScrollController.animateTo(
                                                                              currentPageIndex * ((1.41428571429 * ((sWidth * (1 - vDividerPosition)))) + 16),
                                                                              duration: Duration(milliseconds: 100),
                                                                              curve: Curves.easeIn);
                                                                        });
                                                                        print(
                                                                            '________END PREV PAGE LD_________');
                                                                      },
                                                                    ),
                                                                    GestureDetector(
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .keyboard_arrow_right_sharp,
                                                                        color: defaultPalette
                                                                            .black,
                                                                      ),
                                                                      onTap:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          print(
                                                                              '________NEXT PAGE STARTED LD_________');
                                                                          if (pageCount ==
                                                                              (currentPageIndex + 1)) {
                                                                            _addPdfPage();

                                                                            currentPageIndex++;
                                                                            pdfScrollController.animateTo(currentPageIndex * ((1.41428571429 * ((sWidth * (1 - vDividerPosition)) - 6)) + 6),
                                                                                duration: Duration(milliseconds: 100),
                                                                                curve: Curves.easeIn);

                                                                            print('________END NEXT PAGE LD_________');
                                                                            return;
                                                                          }

                                                                          currentPageIndex++;

                                                                          pdfScrollController.animateTo(
                                                                              currentPageIndex * ((1.41428571429 * ((sWidth * (1 - vDividerPosition)) - 6)) + 6),
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
                                                          height:
                                                              textFieldHeight,
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
                                                                    onTap:
                                                                        () {},
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
                                                                    color: defaultPalette
                                                                        .black,
                                                                    fontSize:
                                                                        15,
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
                                                                        BorderRadius.circular(
                                                                            10.0), // Replace with your desired radius
                                                                  ),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        width:
                                                                            2,
                                                                        color: defaultPalette
                                                                            .black),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            12.0), // Same as border
                                                                  ),
                                                                  disabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        width:
                                                                            2,
                                                                        color: defaultPalette
                                                                            .black),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            12.0), // Same as border
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        width:
                                                                            3,
                                                                        color: defaultPalette
                                                                            .tertiary),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0), // Same as border
                                                                  ),
                                                                ),
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                style: TextStyle(
                                                                    color: defaultPalette
                                                                        .black,
                                                                    fontSize:
                                                                        15),
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
                                                                    color: defaultPalette
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
                                                                  child:
                                                                      SizedBox(
                                                                    height:
                                                                        textFieldHeight,
                                                                    child: // TO STACK THE INCREMENT BUTTONS
                                                                        Stack(
                                                                      children: [
                                                                        //MARGIN ALL TEXT
                                                                        TextFormField(
                                                                          onTapOutside:
                                                                              (event) {
                                                                            marginAllFocus.unfocus();
                                                                          },
                                                                          obscureText:
                                                                              documentPropertiesList[currentPageIndex].useIndividualMargins,
                                                                          focusNode:
                                                                              marginAllFocus,
                                                                          controller:
                                                                              documentPropertiesList[currentPageIndex].marginAllController,
                                                                          inputFormatters: [
                                                                            NumericInputFormatter(maxValue: documentPropertiesList[currentPageIndex].pageFormatController.width / 2.001)
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
                                                                              borderRadius: BorderRadius.circular(10.0), // Replace with your desired radius
                                                                            ),
                                                                            enabledBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: BorderSide(width: 2, color: defaultPalette.black),
                                                                              borderRadius: BorderRadius.circular(12.0), // Same as border
                                                                            ),
                                                                            focusedBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: BorderSide(width: 3, color: defaultPalette.tertiary),
                                                                              borderRadius: BorderRadius.circular(10.0), // Same as border
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

                                                                            documentPropertiesList[currentPageIndex].marginTopController.text =
                                                                                value;
                                                                            documentPropertiesList[currentPageIndex].marginBottomController.text =
                                                                                value;
                                                                            documentPropertiesList[currentPageIndex].marginLeftController.text =
                                                                                value;
                                                                            documentPropertiesList[currentPageIndex].marginRightController.text =
                                                                                value;
                                                                            // _updatePdfPreview(
                                                                            //     '');
                                                                            // });
                                                                          },
                                                                          enabled:
                                                                              !documentPropertiesList[currentPageIndex].useIndividualMargins,
                                                                        ),

                                                                        Positioned(
                                                                          top: (textFieldHeight / 2) -
                                                                              15 / 2,
                                                                          left: (textFieldHeight / 2) -
                                                                              15 / 2,
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
                                                                              // _updatePdfPreview('');
                                                                            },
                                                                            child:
                                                                                Icon(
                                                                              IconsaxPlusLinear.arrow_left_1,
                                                                              size: 15,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Positioned(
                                                                          top: (textFieldHeight / 2) -
                                                                              15 / 2,
                                                                          right:
                                                                              (textFieldHeight / 2) - 15 / 2,
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

                                                                              // _updatePdfPreview('');
                                                                            },
                                                                            child:
                                                                                Icon(
                                                                              IconsaxPlusLinear.arrow_right_3,
                                                                              size: 15,
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
                                                                        documentPropertiesList[currentPageIndex]
                                                                            .useIndividualMargins = !documentPropertiesList[
                                                                                currentPageIndex]
                                                                            .useIndividualMargins;
                                                                        if (documentPropertiesList[currentPageIndex].useIndividualMargins ==
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
                                                                    icon: documentPropertiesList[currentPageIndex]
                                                                            .useIndividualMargins
                                                                        ? Icon(
                                                                            IconsaxPlusBold.maximize_1,
                                                                            size:
                                                                                30,
                                                                          )
                                                                        : Icon(
                                                                            IconsaxPlusLinear.maximize_2,
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
                                                                                // onChanged: (value) => _updatePdfPreview(''),
                                                                              ),
                                                                              Positioned(
                                                                                top: (textFieldHeight / 2) - 15 / 2,
                                                                                left: 15 / 2,
                                                                                child: GestureDetector(
                                                                                  onTap: () {
                                                                                    setState(() {
                                                                                      documentPropertiesList[currentPageIndex].marginTopController.text = (double.parse(documentPropertiesList[currentPageIndex].marginTopController.text) - 1).abs().toString();
                                                                                    });
                                                                                    // _updatePdfPreview('');
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

                                                                                    // _updatePdfPreview('');
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
                                                                        width:
                                                                            10,
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
                                                                                // onChanged: (value) => _updatePdfPreview(''),
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
                                                                                    // _updatePdfPreview('');
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

                                                                                    // _updatePdfPreview('');
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
                                                                                  // _updatePdfPreview('')
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
                                                                                    // _updatePdfPreview('');
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

                                                                                    // _updatePdfPreview('');
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
                                                                        width:
                                                                            10,
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
                                                                                // onChanged: (value) => _updatePdfPreview,
                                                                              ),
                                                                              Positioned(
                                                                                top: (textFieldHeight / 2) - 15 / 2,
                                                                                left: 15 / 2,
                                                                                child: GestureDetector(
                                                                                  onTap: () {
                                                                                    setState(() {
                                                                                      documentPropertiesList[currentPageIndex].marginRightController.text = (double.parse(documentPropertiesList[currentPageIndex].marginRightController.text) - 1).abs().toString();
                                                                                    });
                                                                                    // _updatePdfPreview('');
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

                                                                                    // _updatePdfPreview('');
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
                                                            //Orientation
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
                                                                        .all(
                                                                            10),
                                                                initialItem: documentPropertiesList[currentPageIndex]
                                                                            .orientationController ==
                                                                        pw.PageOrientation
                                                                            .portrait
                                                                    ? 'Portrait'
                                                                    : 'Landscape',
                                                                onChanged:
                                                                    (value) {
                                                                  setState(() {
                                                                    documentPropertiesList[
                                                                            currentPageIndex]
                                                                        .orientationController = value ==
                                                                            'Portrait'
                                                                        ? pw.PageOrientation
                                                                            .portrait
                                                                        : pw.PageOrientation
                                                                            .landscape;
                                                                  });
                                                                  // _updatePdfPreview(
                                                                  //     '');
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
                                                                            ? Icons.crop_portrait
                                                                            : Icons.crop_3_2_sharp,
                                                                        size:
                                                                            20,
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            10,
                                                                      ),
                                                                      Text(item)
                                                                    ],
                                                                  );
                                                                },
                                                                decoration:
                                                                    CustomDropdownDecoration(
                                                                  prefixIcon:
                                                                      Icon(
                                                                    documentPropertiesList[currentPageIndex].orientationController ==
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
                                                                          color: defaultPalette
                                                                              .black,
                                                                          width:
                                                                              2),
                                                                  expandedBorder:
                                                                      Border.all(
                                                                          color:
                                                                              defaultPalette
                                                                                  .tertiary,
                                                                          width:
                                                                              3),
                                                                  closedFillColor:
                                                                      defaultPalette
                                                                          .primary,
                                                                  hintStyle:
                                                                      TextStyle(
                                                                    color: defaultPalette
                                                                        .black,
                                                                  ),
                                                                  headerStyle:
                                                                      TextStyle(
                                                                    color: defaultPalette
                                                                        .black,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(height: 5),
                                                            //Page Format
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
                                                                ],
                                                                initialItem: getPageFormatString(
                                                                    documentPropertiesList[
                                                                            currentPageIndex]
                                                                        .pageFormatController),
                                                                onChanged:
                                                                    (value) {
                                                                  setState(() {
                                                                    documentPropertiesList[currentPageIndex]
                                                                            .pageFormatController =
                                                                        getPageFormatFromString(value ??
                                                                            '');
                                                                  });
                                                                  // _updatePdfPreview(
                                                                  //     '');
                                                                },
                                                                closedHeaderPadding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10),
                                                                decoration:
                                                                    CustomDropdownDecoration(
                                                                  closedBorderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              12),
                                                                  closedBorder:
                                                                      Border.all(
                                                                          color: defaultPalette
                                                                              .black,
                                                                          width:
                                                                              2),
                                                                  expandedBorder:
                                                                      Border.all(
                                                                          color:
                                                                              defaultPalette
                                                                                  .tertiary,
                                                                          width:
                                                                              3),
                                                                  closedFillColor:
                                                                      defaultPalette
                                                                          .primary,
                                                                  hintStyle: TextStyle(
                                                                      color: defaultPalette
                                                                          .black),
                                                                  headerStyle:
                                                                      TextStyle(
                                                                          color:
                                                                              defaultPalette.black),
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
                                            Positioned(
                                              // duration: Durations.medium3,
                                              left: panelIndex.panelIndex == -1
                                                  ? sWidth * vDividerPosition
                                                  : 44,
                                              child: Container(
                                                height: sHeight *
                                                    (hDividerPosition),
                                                width: (sWidth *
                                                        vDividerPosition) -
                                                    44,
                                                child: Column(
                                                  // direction: Axis.vertical,
                                                  children: [
                                                    Container(
                                                      height: 50,
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      padding: EdgeInsets.only(
                                                          left: 5, top: 5),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          //heading
                                                          Text(
                                                            'TEXT STYLE',
                                                            style: GoogleFonts
                                                                .bungee(
                                                                    fontSize:
                                                                        18,
                                                                    letterSpacing:
                                                                        0,
                                                                    height: 1),
                                                          ),
                                                          //id
                                                          Text(
                                                            panelIndex.id,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: GoogleFonts
                                                                .lexend(
                                                                    fontSize: 8,
                                                                    letterSpacing:
                                                                        0,
                                                                    height:
                                                                        0.9),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    panelIndex.panelIndex == -1
                                                        ? Container(
                                                            color: Colors.amber,
                                                            height: 10,
                                                            width: 5,
                                                          )
                                                        : Expanded(
                                                            child: Container(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(5),
                                                              child: Builder(
                                                                builder:
                                                                    (context) {
                                                                  var item = _sheetItemIterator(
                                                                      panelIndex
                                                                          .id,
                                                                      spreadSheetList[
                                                                          currentPageIndex]) as TextEditorItem;

                                                                  bool _getIsToggled(
                                                                      Map<String,
                                                                              Attribute>
                                                                          attrs,
                                                                      Attribute
                                                                          attribute) {
                                                                    if (attribute.key == Attribute.list.key ||
                                                                        attribute.key ==
                                                                            Attribute
                                                                                .header.key ||
                                                                        attribute.key ==
                                                                            Attribute
                                                                                .script.key ||
                                                                        attribute.key ==
                                                                            Attribute.align.key) {
                                                                      final currentAttribute =
                                                                          attrs[
                                                                              attribute.key];
                                                                      if (currentAttribute ==
                                                                          null) {
                                                                        print(
                                                                            'returning false');
                                                                        return false;
                                                                      }
                                                                      print(
                                                                          'returning ${currentAttribute.value == attribute.value}');
                                                                      return currentAttribute
                                                                              .value ==
                                                                          attribute
                                                                              .value;
                                                                    }
                                                                    print(
                                                                        'returning ${attrs.containsKey(attribute.key)}');
                                                                    return attrs
                                                                        .containsKey(
                                                                            attribute.key);
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
                                                                        print(
                                                                            down);
                                                                      });
                                                                    }

                                                                    void _handleTapUp(
                                                                        TapUpDetails
                                                                            details) {
                                                                      if (!toggleOnTap &&
                                                                          down) {
                                                                        setState(
                                                                            () {
                                                                          down =
                                                                              !down;
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
                                                                          alignment:
                                                                              Alignment.bottomRight,
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
                                                                      (sWidth *
                                                                              vDividerPosition) -
                                                                          44;

                                                                  TextEditingController
                                                                      hexController =
                                                                      TextEditingController()
                                                                        ..text =
                                                                            '${item.textEditorController.getSelectionStyle().attributes['color']?.value ?? '#00000000'}';
                                                                  TextEditingController
                                                                      bghexController =
                                                                      TextEditingController()
                                                                        ..text =
                                                                            '${(item.textEditorController.getSelectionStyle().attributes['background']?.value ?? '#00000000')}';
                                                                  TextEditingController
                                                                      fontSizeController =
                                                                      TextEditingController()
                                                                        ..text =
                                                                            '${double.parse(item.textEditorController.getSelectionStyle().attributes['size']?.value ?? '0')}';
                                                                  if (fontSizeController
                                                                      .text
                                                                      .endsWith(
                                                                          '.0')) {
                                                                    fontSizeController
                                                                            .text =
                                                                        '${double.parse(item.textEditorController.getSelectionStyle().attributes['size']?.value ?? '0').ceil()}';
                                                                  }
                                                                  TextEditingController
                                                                      letterSpaceController =
                                                                      TextEditingController()
                                                                        ..text =
                                                                            '${double.parse(item.textEditorController.getSelectionStyle().attributes[LetterSpacingAttribute._key]?.value ?? '0')}';
                                                                  if (letterSpaceController
                                                                      .text
                                                                      .endsWith(
                                                                          '.0')) {
                                                                    letterSpaceController.text = letterSpaceController
                                                                        .text
                                                                        .replaceAll(
                                                                            '.0',
                                                                            '');
                                                                  }
                                                                  TextEditingController
                                                                      wordSpaceController =
                                                                      TextEditingController()
                                                                        ..text =
                                                                            '${double.parse(item.textEditorController.getSelectionStyle().attributes[WordSpacingAttribute._key]?.value ?? '0')}';
                                                                  if (wordSpaceController
                                                                      .text
                                                                      .endsWith(
                                                                          '.0')) {
                                                                    wordSpaceController.text = wordSpaceController
                                                                        .text
                                                                        .replaceAll(
                                                                            '.0',
                                                                            '');
                                                                  }
                                                                  TextEditingController
                                                                      lineSpaceController =
                                                                      TextEditingController()
                                                                        ..text =
                                                                            '${double.parse(item.textEditorController.getSelectionStyle().attributes[LineHeightAttribute._key]?.value ?? '0')}';
                                                                  if (lineSpaceController
                                                                      .text
                                                                      .endsWith(
                                                                          '.0')) {
                                                                    lineSpaceController.text = lineSpaceController
                                                                        .text
                                                                        .replaceAll(
                                                                            '.0',
                                                                            '');
                                                                  }
                                                                  int crossAxisCount =
                                                                      width < (width / vDividerPosition) / 1.75
                                                                          ? 2
                                                                          : 4;
                                                                  var iconWidth =
                                                                      width /
                                                                          crossAxisCount /
                                                                          1.05;
                                                                  var iconHeight =
                                                                      // 50.0;
                                                                      width < (width / vDividerPosition) / 2.2
                                                                          ? iconWidth
                                                                          : width < (width / vDividerPosition) / 1.75
                                                                              ? iconWidth / 1.3
                                                                              : iconWidth;
                                                                  var fCrossAxisCount = width <
                                                                          (sWidth) /
                                                                              3
                                                                      ? 1
                                                                      : width <
                                                                              (sWidth) / 1.7
                                                                          ? 2
                                                                          : 3;
                                                                  var fButtonWidth =
                                                                      width /
                                                                          fCrossAxisCount /
                                                                          1.05;
                                                                  var fButtonHeight =
                                                                      fButtonWidth *
                                                                          0.5;
                                                                  return PageView(
                                                                    controller:
                                                                        textStyleTabControler,
                                                                    scrollDirection:
                                                                        Axis.vertical,
                                                                    onPageChanged:
                                                                        (value) {
                                                                      print(
                                                                          value);
                                                                    },
                                                                    children: [
                                                                      //FONTS
                                                                      Stack(
                                                                        children: [
                                                                          Positioned(
                                                                            top:
                                                                                0,
                                                                            height:
                                                                                sHeight * (hDividerPosition - appbarHeight),
                                                                            width:
                                                                                width - 10,
                                                                            child:
                                                                                GridView.builder(
                                                                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: fCrossAxisCount, childAspectRatio: 2),
                                                                              itemCount: fonts.length,
                                                                              itemBuilder: (context, index) {
                                                                                return buildElevatedLayerButton(
                                                                                  buttonHeight: fButtonHeight,
                                                                                  buttonWidth: fButtonWidth,
                                                                                  toggleOnTap: true,
                                                                                  isTapped: item.textEditorController.getSelectionStyle().attributes[Attribute.font.key]?.value == fonts[index],
                                                                                  animationDuration: const Duration(milliseconds: 100),
                                                                                  animationCurve: Curves.ease,
                                                                                  onClick: () {
                                                                                    item.textEditorController.formatSelection(Attribute.fromKeyValue(
                                                                                      Attribute.font.key,
                                                                                      fonts[index] == 'Clear' ? null : fonts[index],
                                                                                    ));
                                                                                    setState(() {});
                                                                                  },
                                                                                  baseDecoration: BoxDecoration(
                                                                                    color: Colors.green,
                                                                                    border: Border.all(),
                                                                                  ),
                                                                                  topDecoration: BoxDecoration(
                                                                                    color: Colors.white,
                                                                                    border: Border.all(),
                                                                                  ),
                                                                                  topLayerChild: Text(
                                                                                    fonts[index],
                                                                                    style: TextStyle(fontFamily: fonts[index], fontSize: fButtonWidth / 7),
                                                                                    maxLines: 1,
                                                                                  ),
                                                                                  borderRadius: BorderRadius.circular(8),
                                                                                );
                                                                              },
                                                                            ),
                                                                          ),
                                                                          // const Text(
                                                                          //   'Font Family',
                                                                          //   style: TextStyle(
                                                                          //     fontSize: 15,
                                                                          //   ),
                                                                          //   textAlign: TextAlign.left,
                                                                          //   textDirection: TextDirection.ltr,
                                                                          // ),
                                                                        ],
                                                                      ),
                                                                      //FORMATTING ALL THAT PAGE
                                                                      SingleChildScrollView(
                                                                        child:
                                                                            SizedBox(
                                                                          width:
                                                                              width,
                                                                          height: width < (width / vDividerPosition) / 2.2
                                                                              ? iconWidth * 7
                                                                              : width < (width / vDividerPosition) / 1.75
                                                                                  ? (iconWidth / 1.3) * 7
                                                                                  : iconWidth * 5,
                                                                          child:
                                                                              Stack(
                                                                            children: [
                                                                              // BOLD ITALIC UNDERLINE STRIKETHRU
                                                                              Positioned(
                                                                                left: 0,
                                                                                top: 0,
                                                                                width: width - 10,
                                                                                height: iconHeight * 3,
                                                                                child: GridView.builder(
                                                                                  physics: NeverScrollableScrollPhysics(),
                                                                                  itemCount: 4,
                                                                                  padding: EdgeInsets.all(0),
                                                                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                                                      crossAxisCount: crossAxisCount,
                                                                                      crossAxisSpacing: 0,
                                                                                      mainAxisSpacing: 0,
                                                                                      // mainAxisExtent: width/3
                                                                                      childAspectRatio: width < (width / vDividerPosition) / 2.2
                                                                                          ? 1
                                                                                          : width < (width / vDividerPosition) / 1.75
                                                                                              ? 1.3
                                                                                              : 1),
                                                                                  itemBuilder: (BuildContext context, int index) {
                                                                                    switch (index) {
                                                                                      case 0:
                                                                                        // BOLD
                                                                                        return buildElevatedLayerButton(
                                                                                          buttonHeight: iconHeight,
                                                                                          buttonWidth: iconWidth,
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
                                                                                            color: Colors.white,
                                                                                            border: Border.all(),
                                                                                          ),
                                                                                          topLayerChild: Icon(
                                                                                            TablerIcons.bold,
                                                                                            color: Colors.black,
                                                                                            size: 20,
                                                                                          ),
                                                                                          borderRadius: BorderRadius.circular(10),
                                                                                        );
                                                                                      case 1:
                                                                                        //ITALIC
                                                                                        return buildElevatedLayerButton(
                                                                                          buttonHeight: iconHeight,
                                                                                          buttonWidth: iconWidth,
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
                                                                                            color: Colors.white,
                                                                                            border: Border.all(),
                                                                                          ),
                                                                                          topLayerChild: Icon(
                                                                                            TablerIcons.italic,
                                                                                            color: Colors.black,
                                                                                            size: 20,
                                                                                          ),
                                                                                          borderRadius: BorderRadius.circular(10),
                                                                                        );
                                                                                      case 2:
                                                                                        //UNDERLINE
                                                                                        return buildElevatedLayerButton(
                                                                                          buttonHeight: iconHeight,
                                                                                          buttonWidth: iconWidth,
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
                                                                                            color: Colors.white,
                                                                                            border: Border.all(),
                                                                                          ),
                                                                                          topLayerChild: Icon(
                                                                                            TablerIcons.underline,
                                                                                            color: Colors.black,
                                                                                            size: 20,
                                                                                          ),
                                                                                          borderRadius: BorderRadius.circular(10),
                                                                                        );
                                                                                      case 3:
                                                                                        //STRIKETHRU
                                                                                        return buildElevatedLayerButton(
                                                                                          buttonHeight: iconHeight,
                                                                                          buttonWidth: iconWidth,
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
                                                                                            color: Colors.white,
                                                                                            border: Border.all(),
                                                                                          ),
                                                                                          topLayerChild: Icon(
                                                                                            TablerIcons.strikethrough,
                                                                                            color: Colors.black,
                                                                                            size: 20,
                                                                                          ),
                                                                                          borderRadius: BorderRadius.circular(10),
                                                                                        );
                                                                                      default:
                                                                                        return Container();
                                                                                    }
                                                                                  },
                                                                                ),
                                                                              ),
                                                                              // SUPER, SUBS, LTR, RTL
                                                                              Positioned(
                                                                                top: width < (width / vDividerPosition) / 2.2
                                                                                    ? iconWidth * 2.2
                                                                                    : width < (width / vDividerPosition) / 1.75
                                                                                        ? (iconWidth / 1.3) * 2.2
                                                                                        : iconWidth * 1.2,
                                                                                left: 0,
                                                                                width: width - 10,
                                                                                height: iconHeight * 2,
                                                                                child: GridView.builder(
                                                                                  physics: NeverScrollableScrollPhysics(),
                                                                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                                                    crossAxisCount: crossAxisCount,
                                                                                    crossAxisSpacing: 0,
                                                                                    mainAxisSpacing: 0,
                                                                                    childAspectRatio: width < (width / vDividerPosition) / 2.2
                                                                                        ? 1
                                                                                        : width < (width / vDividerPosition) / 1.75
                                                                                            ? 1.3
                                                                                            : 1,
                                                                                  ),
                                                                                  itemCount: 4,
                                                                                  itemBuilder: (BuildContext context, int index) {
                                                                                    switch (index) {
                                                                                      case 0:
                                                                                        //SUBSCRIPT
                                                                                        return buildElevatedLayerButton(
                                                                                          buttonHeight: iconHeight,
                                                                                          buttonWidth: iconWidth,
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
                                                                                            color: Colors.white,
                                                                                            border: Border.all(),
                                                                                          ),
                                                                                          topLayerChild: Icon(
                                                                                            TablerIcons.subscript,
                                                                                            color: Colors.black,
                                                                                            size: 20,
                                                                                          ),
                                                                                          borderRadius: BorderRadius.circular(10),
                                                                                        );
                                                                                      case 1:
                                                                                        //SUPERSCIPT
                                                                                        return buildElevatedLayerButton(
                                                                                          buttonHeight: iconHeight,
                                                                                          buttonWidth: iconWidth,
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
                                                                                            color: Colors.white,
                                                                                            border: Border.all(),
                                                                                          ),
                                                                                          topLayerChild: Icon(
                                                                                            TablerIcons.superscript,
                                                                                            color: Colors.black,
                                                                                            size: 20,
                                                                                          ),
                                                                                          borderRadius: BorderRadius.circular(10),
                                                                                        );
                                                                                      case 2:
                                                                                        //DIRECTION LTR
                                                                                        return buildElevatedLayerButton(
                                                                                          buttonHeight: iconHeight,
                                                                                          buttonWidth: iconWidth,
                                                                                          toggleOnTap: true,
                                                                                          isTapped: !_getIsToggled(item.textEditorController.getSelectionStyle().attributes, Attribute.rtl),
                                                                                          animationDuration: const Duration(milliseconds: 100),
                                                                                          animationCurve: Curves.ease,
                                                                                          onClick: () {
                                                                                            var currentValue = _getIsToggled(item.textEditorController.getSelectionStyle().attributes, Attribute.rtl);
                                                                                            item.textEditorController.formatSelection(
                                                                                              currentValue ? Attribute.clone(Attribute.rtl, null) : Attribute.rtl,
                                                                                            );
                                                                                          },
                                                                                          baseDecoration: BoxDecoration(
                                                                                            color: Colors.green,
                                                                                            border: Border.all(),
                                                                                          ),
                                                                                          topDecoration: BoxDecoration(
                                                                                            color: Colors.white,
                                                                                            border: Border.all(),
                                                                                          ),
                                                                                          topLayerChild: Icon(
                                                                                            TablerIcons.text_direction_ltr,
                                                                                            color: Colors.black,
                                                                                            size: 20,
                                                                                          ),
                                                                                          borderRadius: BorderRadius.circular(10),
                                                                                        );
                                                                                      case 3:
                                                                                        //DIRECTION RTL
                                                                                        return buildElevatedLayerButton(
                                                                                          buttonHeight: iconHeight,
                                                                                          buttonWidth: iconWidth,
                                                                                          toggleOnTap: true,
                                                                                          isTapped: _getIsToggled(item.textEditorController.getSelectionStyle().attributes, Attribute.rtl),
                                                                                          animationDuration: const Duration(milliseconds: 100),
                                                                                          animationCurve: Curves.ease,
                                                                                          onClick: () {
                                                                                            var currentValue = _getIsToggled(item.textEditorController.getSelectionStyle().attributes, Attribute.rtl);
                                                                                            item.textEditorController.formatSelection(
                                                                                              currentValue ? Attribute.clone(Attribute.rtl, null) : Attribute.rtl,
                                                                                            );
                                                                                          },
                                                                                          baseDecoration: BoxDecoration(
                                                                                            color: Colors.green,
                                                                                            border: Border.all(),
                                                                                          ),
                                                                                          topDecoration: BoxDecoration(
                                                                                            color: Colors.white,
                                                                                            border: Border.all(),
                                                                                          ),
                                                                                          topLayerChild: Icon(
                                                                                            TablerIcons.text_direction_rtl,
                                                                                            color: Colors.black,
                                                                                            size: 20,
                                                                                          ),
                                                                                          borderRadius: BorderRadius.circular(10),
                                                                                        );

                                                                                      default:
                                                                                        return Container();
                                                                                    }
                                                                                  },
                                                                                ),
                                                                              ),
                                                                              // LEFT RIGHT CENTER JUSTIFY
                                                                              Positioned(
                                                                                top: width < (width / vDividerPosition) / 2.2
                                                                                    ? iconWidth * 2.2
                                                                                        //height of the previous wdiget
                                                                                        +
                                                                                        iconHeight * 2.2
                                                                                    : width < (width / vDividerPosition) / 1.75
                                                                                        ? (iconWidth / 1.3) * 2.2
                                                                                            //height of the previous wdiget
                                                                                            +
                                                                                            iconHeight * 2.2
                                                                                        : iconWidth * 1.2
                                                                                            //height of the previous wdiget
                                                                                            +
                                                                                            iconHeight * 1.2,
                                                                                left: 0,
                                                                                width: width - 10,
                                                                                height: iconHeight * 2,
                                                                                child: GridView.builder(
                                                                                  physics: NeverScrollableScrollPhysics(),
                                                                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                                                    crossAxisCount: crossAxisCount,
                                                                                    crossAxisSpacing: 0,
                                                                                    mainAxisSpacing: 0,
                                                                                    childAspectRatio: width < (width / vDividerPosition) / 2.2
                                                                                        ? 1
                                                                                        : width < (width / vDividerPosition) / 1.75
                                                                                            ? 1.3
                                                                                            : 1,
                                                                                  ),
                                                                                  itemCount: 4,
                                                                                  itemBuilder: (BuildContext context, int index) {
                                                                                    switch (index) {
                                                                                      case 0:
                                                                                        //LEFT ALIGN
                                                                                        return buildElevatedLayerButton(
                                                                                          buttonHeight: iconHeight,
                                                                                          buttonWidth: iconWidth,
                                                                                          toggleOnTap: true,
                                                                                          isTapped: _getIsToggled(item.textEditorController.getSelectionStyle().attributes, Attribute.leftAlignment),
                                                                                          animationDuration: const Duration(milliseconds: 100),
                                                                                          animationCurve: Curves.ease,
                                                                                          onClick: () {
                                                                                            var currentValue = _getIsToggled(item.textEditorController.getSelectionStyle().attributes, Attribute.leftAlignment);
                                                                                            item.textEditorController.formatSelection(
                                                                                              currentValue ? Attribute.clone(Attribute.leftAlignment, null) : Attribute.leftAlignment,
                                                                                            );
                                                                                            final uncurrentValue = item.textEditorController.getSelectionStyle().attributes.containsKey(Attribute.rightAlignment.key);
                                                                                            if (uncurrentValue && currentValue) {
                                                                                              item.textEditorController.formatSelection(
                                                                                                Attribute.clone(Attribute.leftAlignment, null),
                                                                                              );
                                                                                              currentValue = _getIsToggled(item.textEditorController.getSelectionStyle().attributes, Attribute.leftAlignment);
                                                                                            }
                                                                                            print('$uncurrentValue && $currentValue');
                                                                                            if (uncurrentValue && !currentValue) {
                                                                                              print('un');
                                                                                              print(uncurrentValue);
                                                                                              item.textEditorController.formatSelection(Attribute.clone(Attribute.rightAlignment, null));
                                                                                              item.textEditorController.formatSelection(
                                                                                                Attribute.leftAlignment,
                                                                                              );
                                                                                              setState(() {
                                                                                                currentValue = _getIsToggled(item.textEditorController.getSelectionStyle().attributes, Attribute.leftAlignment);
                                                                                              });
                                                                                              print('cu');
                                                                                              print(currentValue);
                                                                                              return;
                                                                                            }
                                                                                            item.textEditorController.formatSelection(
                                                                                              currentValue ? Attribute.clone(Attribute.leftAlignment, null) : Attribute.leftAlignment,
                                                                                            );
                                                                                          },
                                                                                          baseDecoration: BoxDecoration(
                                                                                            color: Colors.green,
                                                                                            border: Border.all(),
                                                                                          ),
                                                                                          topDecoration: BoxDecoration(
                                                                                            color: Colors.white,
                                                                                            border: Border.all(),
                                                                                          ),
                                                                                          topLayerChild: Icon(
                                                                                            TablerIcons.align_left,
                                                                                            color: Colors.black,
                                                                                            size: 20,
                                                                                          ),
                                                                                          borderRadius: BorderRadius.circular(10),
                                                                                        );
                                                                                      case 1:
                                                                                        //RIGHT ALIGN
                                                                                        return buildElevatedLayerButton(
                                                                                          buttonHeight: iconHeight,
                                                                                          buttonWidth: iconWidth,
                                                                                          toggleOnTap: true,
                                                                                          isTapped: _getIsToggled(item.textEditorController.getSelectionStyle().attributes, Attribute.rightAlignment),
                                                                                          animationDuration: const Duration(milliseconds: 100),
                                                                                          animationCurve: Curves.ease,
                                                                                          onClick: () {
                                                                                            var currentValue = _getIsToggled(item.textEditorController.getSelectionStyle().attributes, Attribute.rightAlignment);
                                                                                            item.textEditorController.formatSelection(
                                                                                              currentValue ? Attribute.clone(Attribute.rightAlignment, null) : Attribute.rightAlignment,
                                                                                            );
                                                                                            final uncurrentValue = item.textEditorController.getSelectionStyle().attributes.containsKey(Attribute.leftAlignment.key);
                                                                                            if (uncurrentValue && currentValue) {
                                                                                              item.textEditorController.formatSelection(
                                                                                                Attribute.clone(Attribute.rightAlignment, null),
                                                                                              );
                                                                                              currentValue = _getIsToggled(item.textEditorController.getSelectionStyle().attributes, Attribute.rightAlignment);
                                                                                            }
                                                                                            print('$uncurrentValue && $currentValue');
                                                                                            if (uncurrentValue && !currentValue) {
                                                                                              print('un');
                                                                                              print(uncurrentValue);
                                                                                              item.textEditorController.formatSelection(Attribute.clone(Attribute.leftAlignment, null));
                                                                                              item.textEditorController.formatSelection(
                                                                                                Attribute.rightAlignment,
                                                                                              );
                                                                                              setState(() {
                                                                                                currentValue = _getIsToggled(item.textEditorController.getSelectionStyle().attributes, Attribute.rightAlignment);
                                                                                              });
                                                                                              print('cu');
                                                                                              print(currentValue);
                                                                                              return;
                                                                                            }
                                                                                            item.textEditorController.formatSelection(
                                                                                              currentValue ? Attribute.clone(Attribute.rightAlignment, null) : Attribute.rightAlignment,
                                                                                            );
                                                                                          },
                                                                                          baseDecoration: BoxDecoration(
                                                                                            color: Colors.green,
                                                                                            border: Border.all(),
                                                                                          ),
                                                                                          topDecoration: BoxDecoration(
                                                                                            color: Colors.white,
                                                                                            border: Border.all(),
                                                                                          ),
                                                                                          topLayerChild: Icon(
                                                                                            TablerIcons.align_right,
                                                                                            color: Colors.black,
                                                                                            size: 20,
                                                                                          ),
                                                                                          borderRadius: BorderRadius.circular(10),
                                                                                        );
                                                                                      case 2:
                                                                                        //CENTER ALIGN
                                                                                        return buildElevatedLayerButton(
                                                                                          buttonHeight: iconHeight,
                                                                                          buttonWidth: iconWidth,
                                                                                          toggleOnTap: true,
                                                                                          isTapped: _getIsToggled(item.textEditorController.getSelectionStyle().attributes, Attribute.centerAlignment),
                                                                                          animationDuration: const Duration(milliseconds: 100),
                                                                                          animationCurve: Curves.ease,
                                                                                          onClick: () {
                                                                                            var currentValue = _getIsToggled(item.textEditorController.getSelectionStyle().attributes, Attribute.centerAlignment);
                                                                                            item.textEditorController.formatSelection(
                                                                                              currentValue ? Attribute.clone(Attribute.centerAlignment, null) : Attribute.centerAlignment,
                                                                                            );
                                                                                          },
                                                                                          baseDecoration: BoxDecoration(
                                                                                            color: Colors.green,
                                                                                            border: Border.all(),
                                                                                          ),
                                                                                          topDecoration: BoxDecoration(
                                                                                            color: Colors.white,
                                                                                            border: Border.all(),
                                                                                          ),
                                                                                          topLayerChild: Icon(
                                                                                            TablerIcons.align_center,
                                                                                            color: Colors.black,
                                                                                            size: 20,
                                                                                          ),
                                                                                          borderRadius: BorderRadius.circular(10),
                                                                                        );
                                                                                      case 3:
                                                                                        //JUSTIFY ALIGN
                                                                                        return buildElevatedLayerButton(
                                                                                          buttonHeight: iconHeight,
                                                                                          buttonWidth: iconWidth,
                                                                                          toggleOnTap: true,
                                                                                          isTapped: _getIsToggled(item.textEditorController.getSelectionStyle().attributes, Attribute.justifyAlignment),
                                                                                          animationDuration: const Duration(milliseconds: 100),
                                                                                          animationCurve: Curves.ease,
                                                                                          onClick: () {
                                                                                            var currentValue = _getIsToggled(item.textEditorController.getSelectionStyle().attributes, Attribute.justifyAlignment);
                                                                                            item.textEditorController.formatSelection(
                                                                                              currentValue ? Attribute.clone(Attribute.justifyAlignment, null) : Attribute.justifyAlignment,
                                                                                            );
                                                                                          },
                                                                                          baseDecoration: BoxDecoration(
                                                                                            color: Colors.green,
                                                                                            border: Border.all(),
                                                                                          ),
                                                                                          topDecoration: BoxDecoration(
                                                                                            color: Colors.white,
                                                                                            border: Border.all(),
                                                                                          ),
                                                                                          topLayerChild: Icon(
                                                                                            TablerIcons.align_justified,
                                                                                            color: Colors.black,
                                                                                            size: 20,
                                                                                          ),
                                                                                          borderRadius: BorderRadius.circular(10),
                                                                                        );

                                                                                      default:
                                                                                        return Container();
                                                                                    }
                                                                                  },
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      //Font Size, Word Spacing, Letter Spacing, Line Spacing
                                                                      SingleChildScrollView(
                                                                        child:
                                                                            //SIZE SPACE PARENT
                                                                            Container(
                                                                          padding:
                                                                              EdgeInsets.only(left: 5),
                                                                          width:
                                                                              width,
                                                                          height:
                                                                              70 * 5,
                                                                          child:
                                                                              Column(
                                                                            children: [
                                                                              //Font Size TEXT FIELD PARENT
                                                                              ClipRRect(
                                                                                borderRadius: BorderRadius.circular(10),
                                                                                child: Container(
                                                                                  decoration: BoxDecoration(color: defaultPalette.primary, border: Border.all(width: 2, strokeAlign: BorderSide.strokeAlignInside), borderRadius: BorderRadius.circular(8)),
                                                                                  height: 70,
                                                                                  width: width,
                                                                                  child: Row(
                                                                                    children: [
                                                                                      //Icon title slider field
                                                                                      Expanded(
                                                                                        flex: (1600 * vDividerPosition).ceil(),
                                                                                        child: Stack(
                                                                                          children: [
                                                                                            //Row font and title
                                                                                            GestureDetector(
                                                                                              onTap: () {
                                                                                                // fontSizeFocus.unfocus();
                                                                                                fontSizeFocus.requestFocus();
                                                                                              },
                                                                                              child: Padding(
                                                                                                padding: EdgeInsets.only(top: 5, left: 5),
                                                                                                child: Row(
                                                                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                                  children: [
                                                                                                    Expanded(
                                                                                                        flex: 100,
                                                                                                        child: Icon(
                                                                                                          TablerIcons.text_size,
                                                                                                          size: 18,
                                                                                                        )),
                                                                                                    vDividerPosition > 0.45
                                                                                                        ? Expanded(
                                                                                                            flex: 700,
                                                                                                            child: Container(
                                                                                                              height: 18,
                                                                                                              alignment: Alignment.bottomLeft,
                                                                                                              child: Text(
                                                                                                                '  Font Size',
                                                                                                                style: TextStyle(fontSize: 12, textBaseline: TextBaseline.ideographic),
                                                                                                              ),
                                                                                                            ))
                                                                                                        : Container(),
                                                                                                  ],
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            //TextField
                                                                                            TextField(
                                                                                              onTapOutside: (event) {
                                                                                                // fontSizeFocus.unfocus();
                                                                                              },
                                                                                              onSubmitted: (value) {
                                                                                                item.textEditorController.formatSelection(
                                                                                                  Attribute.clone(Attribute.size, value.toString()),
                                                                                                );
                                                                                              },
                                                                                              focusNode: fontSizeFocus,
                                                                                              controller: fontSizeController,
                                                                                              inputFormatters: [
                                                                                                NumericInputFormatter(maxValue: 100),
                                                                                              ],
                                                                                              style: GoogleFonts.lexend(color: defaultPalette.black.withOpacity(fontSizeFocus.hasFocus ? 0.5 : 0.1), fontWeight: FontWeight.bold, fontSize: (80 * vDividerPosition).clamp(70, 100)),
                                                                                              cursorColor: defaultPalette.black,
                                                                                              // selectionControls: MaterialTextSelectionControls(),
                                                                                              textAlign: TextAlign.right,
                                                                                              scrollPadding: EdgeInsets.all(0),
                                                                                              textAlignVertical: TextAlignVertical.top,
                                                                                              decoration: InputDecoration(
                                                                                                contentPadding: EdgeInsets.all(0),

                                                                                                // filled: true,
                                                                                                // fillColor: defaultPalette.primary,
                                                                                                enabledBorder: OutlineInputBorder(
                                                                                                  borderSide: BorderSide(width: 2, color: defaultPalette.transparent),
                                                                                                  borderRadius: BorderRadius.circular(2.0), // Same as border
                                                                                                ),
                                                                                                focusedBorder: OutlineInputBorder(
                                                                                                  borderSide: BorderSide(width: 2, color: defaultPalette.transparent),
                                                                                                  borderRadius: BorderRadius.circular(2.0), // Same as border
                                                                                                ),
                                                                                              ),
                                                                                              keyboardType: TextInputType.number,
                                                                                            ),

                                                                                            //Balloon Slider
                                                                                            Positioned(
                                                                                              bottom: 0,
                                                                                              width: width * 0.6,
                                                                                              child: BalloonSlider(
                                                                                                  trackHeight: 15,
                                                                                                  thumbRadius: 7.5,
                                                                                                  showRope: true,
                                                                                                  color: defaultPalette.tertiary,
                                                                                                  ropeLength: 300 / 8,
                                                                                                  value: double.parse((item.textEditorController.getSelectionStyle().attributes[Attribute.size.key]?.value) ?? 20.toString()) / 100,
                                                                                                  onChanged: (val) {
                                                                                                    setState(() {
                                                                                                      item.textEditorController.formatSelection(
                                                                                                        Attribute.clone(Attribute.size, (val * 100).toStringAsFixed(0)),
                                                                                                      );
                                                                                                    });
                                                                                                  }),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                      //+ -
                                                                                      Expanded(
                                                                                        flex: vDividerPosition > 0.45 ? (450 * vDividerPosition).ceil() : 1,
                                                                                        child: Stack(
                                                                                          // mainAxisAlignment: MainAxisAlignment.start,
                                                                                          children: [
                                                                                            Positioned(
                                                                                              top: -4,
                                                                                              right: 4,
                                                                                              height: 35,
                                                                                              child: ElevatedLayerButton(
                                                                                                // isTapped: false,
                                                                                                // toggleOnTap: true,
                                                                                                onClick: () {
                                                                                                  setState(() {
                                                                                                    var val = int.parse(fontSizeController.text) + 1;
                                                                                                    item.textEditorController.formatSelection(
                                                                                                      Attribute.clone(Attribute.size, val.toString()),
                                                                                                    );
                                                                                                  });
                                                                                                },
                                                                                                buttonHeight: 32,
                                                                                                buttonWidth: 65 * vDividerPosition,
                                                                                                borderRadius: BorderRadius.circular(100),
                                                                                                animationDuration: const Duration(milliseconds: 100),
                                                                                                animationCurve: Curves.ease,
                                                                                                topDecoration: BoxDecoration(
                                                                                                  color: Colors.white,
                                                                                                  border: Border.all(),
                                                                                                ),
                                                                                                topLayerChild: Icon(
                                                                                                  IconsaxPlusLinear.add,
                                                                                                  size: 20,
                                                                                                ),
                                                                                                baseDecoration: BoxDecoration(
                                                                                                  color: Colors.green,
                                                                                                  border: Border.all(),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            Positioned(
                                                                                              bottom: 5,
                                                                                              right: 4,
                                                                                              child: ElevatedLayerButton(
                                                                                                // isTapped: false,
                                                                                                // toggleOnTap: true,
                                                                                                onClick: () {
                                                                                                  setState(() {
                                                                                                    var val = (int.parse(fontSizeController.text) - 1).clamp(0, 100);
                                                                                                    item.textEditorController.formatSelection(
                                                                                                      Attribute.clone(Attribute.size, val.toString()),
                                                                                                    );
                                                                                                  });
                                                                                                },
                                                                                                buttonHeight: 32,
                                                                                                buttonWidth: 65 * vDividerPosition,
                                                                                                borderRadius: BorderRadius.circular(100),
                                                                                                animationDuration: const Duration(milliseconds: 100),
                                                                                                animationCurve: Curves.ease,
                                                                                                topDecoration: BoxDecoration(
                                                                                                  color: Colors.white,
                                                                                                  border: Border.all(),
                                                                                                ),
                                                                                                topLayerChild: Icon(
                                                                                                  IconsaxPlusLinear.minus,
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
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              //
                                                                              //
                                                                              SizedBox(
                                                                                height: 20,
                                                                              ),
                                                                              //LetterSpacing Parentt
                                                                              ClipRRect(
                                                                                borderRadius: BorderRadius.circular(10),
                                                                                child: Container(
                                                                                  decoration: BoxDecoration(color: defaultPalette.primary, border: Border.all(width: 2, strokeAlign: BorderSide.strokeAlignInside), borderRadius: BorderRadius.circular(8)),
                                                                                  height: 70,
                                                                                  width: width,
                                                                                  child: Row(
                                                                                    children: [
                                                                                      //LetterSpacing
                                                                                      //Icon title slider field
                                                                                      Expanded(
                                                                                        flex: (1600 * vDividerPosition).ceil(),
                                                                                        child: Stack(
                                                                                          children: [
                                                                                            //LetterSpacing
                                                                                            //Row font and title
                                                                                            GestureDetector(
                                                                                              onTap: () {
                                                                                                letterSpaceFocus.requestFocus();
                                                                                              },
                                                                                              //LetterSpacing
                                                                                              //Row font and title
                                                                                              child: Padding(
                                                                                                padding: EdgeInsets.only(top: 5, left: 5),
                                                                                                //LetterSpacing
                                                                                                //Row font and title
                                                                                                child: Row(
                                                                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                                  children: [
                                                                                                    //LetterSpacing
                                                                                                    //icon
                                                                                                    Expanded(
                                                                                                        flex: 100,
                                                                                                        child: Icon(
                                                                                                          TablerIcons.letter_spacing,
                                                                                                          size: 18,
                                                                                                        )),
                                                                                                    //LetterSpacing
                                                                                                    //title
                                                                                                    vDividerPosition > 0.45
                                                                                                        ? Expanded(
                                                                                                            flex: 700,
                                                                                                            child: Container(
                                                                                                              height: 18,
                                                                                                              alignment: Alignment.bottomLeft,
                                                                                                              child: Text(
                                                                                                                '  Letter Space',
                                                                                                                style: TextStyle(fontSize: 12, textBaseline: TextBaseline.ideographic),
                                                                                                              ),
                                                                                                            ))
                                                                                                        : Container(),
                                                                                                  ],
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            //LetterSpacing
                                                                                            //TextField
                                                                                            TextField(
                                                                                              onTapOutside: (event) {
                                                                                                // fontSizeFocus.unfocus();
                                                                                              },
                                                                                              onSubmitted: (value) {
                                                                                                item.textEditorController.formatSelection(
                                                                                                  LetterSpacingAttribute((value).toString()),
                                                                                                );
                                                                                              },
                                                                                              focusNode: letterSpaceFocus,
                                                                                              controller: letterSpaceController,
                                                                                              inputFormatters: [
                                                                                                NumericInputFormatter(maxValue: 100),
                                                                                              ],
                                                                                              style: GoogleFonts.lexend(color: defaultPalette.black.withOpacity(fontSizeFocus.hasFocus ? 0.5 : 0.1), fontWeight: FontWeight.bold, fontSize: (80 * vDividerPosition).clamp(70, 100)),
                                                                                              cursorColor: defaultPalette.black,
                                                                                              // selectionControls: MaterialTextSelectionControls(),
                                                                                              textAlign: TextAlign.right,
                                                                                              scrollPadding: EdgeInsets.all(0),
                                                                                              textAlignVertical: TextAlignVertical.top,
                                                                                              decoration: InputDecoration(
                                                                                                contentPadding: EdgeInsets.all(0),

                                                                                                // filled: true,
                                                                                                // fillColor: defaultPalette.primary,
                                                                                                enabledBorder: OutlineInputBorder(
                                                                                                  borderSide: BorderSide(width: 2, color: defaultPalette.transparent),
                                                                                                  borderRadius: BorderRadius.circular(2.0), // Same as border
                                                                                                ),
                                                                                                focusedBorder: OutlineInputBorder(
                                                                                                  borderSide: BorderSide(width: 2, color: defaultPalette.transparent),
                                                                                                  borderRadius: BorderRadius.circular(2.0), // Same as border
                                                                                                ),
                                                                                              ),
                                                                                              keyboardType: TextInputType.number,
                                                                                            ),
                                                                                            //LetterSpacing
                                                                                            //Balloon Slider
                                                                                            Positioned(
                                                                                              bottom: 0,
                                                                                              width: width * 0.6,
                                                                                              child: BalloonSlider(
                                                                                                  trackHeight: 15,
                                                                                                  thumbRadius: 7.5,
                                                                                                  showRope: true,
                                                                                                  color: defaultPalette.tertiary,
                                                                                                  ropeLength: 300 / 8,
                                                                                                  value: double.parse((item.textEditorController.getSelectionStyle().attributes[LetterSpacingAttribute._key]?.value) ?? 0.toString()) / 100,
                                                                                                  onChanged: (val) {
                                                                                                    setState(() {
                                                                                                      item.textEditorController.formatSelection(
                                                                                                        LetterSpacingAttribute((val * 100).ceil().toString()),
                                                                                                      );
                                                                                                    });
                                                                                                  }),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                      //LetterSpacing
                                                                                      //+ -
                                                                                      Expanded(
                                                                                        flex: vDividerPosition > 0.45 ? (450 * vDividerPosition).ceil() : 1,
                                                                                        child: Stack(
                                                                                          children: [
                                                                                            Positioned(
                                                                                              top: -4,
                                                                                              right: 4,
                                                                                              height: 35,
                                                                                              child: ElevatedLayerButton(
                                                                                                onClick: () {
                                                                                                  setState(() {
                                                                                                    var val = int.parse(letterSpaceController.text) + 1;

                                                                                                    item.textEditorController.formatSelection(
                                                                                                      LetterSpacingAttribute((val).toString()),
                                                                                                    );
                                                                                                  });
                                                                                                },
                                                                                                buttonHeight: 32,
                                                                                                buttonWidth: 65 * vDividerPosition,
                                                                                                borderRadius: BorderRadius.circular(100),
                                                                                                animationDuration: const Duration(milliseconds: 100),
                                                                                                animationCurve: Curves.ease,
                                                                                                topDecoration: BoxDecoration(
                                                                                                  color: Colors.white,
                                                                                                  border: Border.all(),
                                                                                                ),
                                                                                                topLayerChild: Icon(
                                                                                                  IconsaxPlusLinear.add,
                                                                                                  size: 20,
                                                                                                ),
                                                                                                baseDecoration: BoxDecoration(
                                                                                                  color: Colors.green,
                                                                                                  border: Border.all(),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            Positioned(
                                                                                              bottom: 5,
                                                                                              right: 4,
                                                                                              child: ElevatedLayerButton(
                                                                                                // isTapped: false,
                                                                                                // toggleOnTap: true,
                                                                                                onClick: () {
                                                                                                  setState(() {
                                                                                                    var val = (int.parse(letterSpaceController.text) - 1).clamp(0, 100);
                                                                                                    item.textEditorController.formatSelection(
                                                                                                      LetterSpacingAttribute((val).toString()),
                                                                                                    );
                                                                                                  });
                                                                                                },
                                                                                                buttonHeight: 32,
                                                                                                buttonWidth: 65 * vDividerPosition,
                                                                                                borderRadius: BorderRadius.circular(100),
                                                                                                animationDuration: const Duration(milliseconds: 100),
                                                                                                animationCurve: Curves.ease,
                                                                                                topDecoration: BoxDecoration(
                                                                                                  color: Colors.white,
                                                                                                  border: Border.all(),
                                                                                                ),
                                                                                                topLayerChild: Icon(
                                                                                                  IconsaxPlusLinear.minus,
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
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),

                                                                              SizedBox(
                                                                                height: 20,
                                                                              ),
                                                                              //WordSpacing
                                                                              ClipRRect(
                                                                                borderRadius: BorderRadius.circular(10),
                                                                                child: Container(
                                                                                  decoration: BoxDecoration(color: defaultPalette.primary, border: Border.all(width: 2, strokeAlign: BorderSide.strokeAlignInside), borderRadius: BorderRadius.circular(8)),
                                                                                  height: 70,
                                                                                  width: width,
                                                                                  child: Row(
                                                                                    children: [
                                                                                      //WordSpacing
                                                                                      //Icon title slider field
                                                                                      Expanded(
                                                                                        flex: (1600 * vDividerPosition).ceil(),
                                                                                        child: Stack(
                                                                                          children: [
                                                                                            //WordSpacing
                                                                                            //Row font and title
                                                                                            GestureDetector(
                                                                                              onTap: () {
                                                                                                wordSpaceFocus.requestFocus();
                                                                                              },
                                                                                              //WordSpacing
                                                                                              //Row font and title
                                                                                              child: Padding(
                                                                                                padding: EdgeInsets.only(top: 5, left: 5),
                                                                                                //WordSpacing
                                                                                                //Row font and title
                                                                                                child: Row(
                                                                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                                  children: [
                                                                                                    //WordSpacing
                                                                                                    //icon
                                                                                                    Expanded(
                                                                                                        flex: 100,
                                                                                                        child: Icon(
                                                                                                          TablerIcons.spacing_horizontal,
                                                                                                          size: 18,
                                                                                                        )),
                                                                                                    //WordSpacing
                                                                                                    //title
                                                                                                    vDividerPosition > 0.45
                                                                                                        ? Expanded(
                                                                                                            flex: 700,
                                                                                                            child: Container(
                                                                                                              height: 18,
                                                                                                              alignment: Alignment.bottomLeft,
                                                                                                              child: Text(
                                                                                                                '  Word Space',
                                                                                                                style: TextStyle(fontSize: 12, textBaseline: TextBaseline.ideographic),
                                                                                                              ),
                                                                                                            ))
                                                                                                        : Container(),
                                                                                                  ],
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            //WordSpacing
                                                                                            //TextField
                                                                                            TextField(
                                                                                              onTapOutside: (event) {
                                                                                                // fontSizeFocus.unfocus();
                                                                                              },
                                                                                              onSubmitted: (value) {
                                                                                                item.textEditorController.formatSelection(
                                                                                                  WordSpacingAttribute((value).toString()),
                                                                                                );
                                                                                              },
                                                                                              focusNode: wordSpaceFocus,
                                                                                              controller: wordSpaceController,
                                                                                              inputFormatters: [
                                                                                                NumericInputFormatter(maxValue: 100),
                                                                                              ],
                                                                                              style: GoogleFonts.lexend(color: defaultPalette.black.withOpacity(fontSizeFocus.hasFocus ? 0.5 : 0.1), fontWeight: FontWeight.bold, fontSize: (80 * vDividerPosition).clamp(70, 100)),
                                                                                              cursorColor: defaultPalette.black,
                                                                                              // selectionControls: MaterialTextSelectionControls(),
                                                                                              textAlign: TextAlign.right,
                                                                                              scrollPadding: EdgeInsets.all(0),
                                                                                              textAlignVertical: TextAlignVertical.top,
                                                                                              decoration: InputDecoration(
                                                                                                contentPadding: EdgeInsets.all(0),

                                                                                                // filled: true,
                                                                                                // fillColor: defaultPalette.primary,
                                                                                                enabledBorder: OutlineInputBorder(
                                                                                                  borderSide: BorderSide(width: 2, color: defaultPalette.transparent),
                                                                                                  borderRadius: BorderRadius.circular(2.0), // Same as border
                                                                                                ),
                                                                                                focusedBorder: OutlineInputBorder(
                                                                                                  borderSide: BorderSide(width: 2, color: defaultPalette.transparent),
                                                                                                  borderRadius: BorderRadius.circular(2.0), // Same as border
                                                                                                ),
                                                                                              ),
                                                                                              keyboardType: TextInputType.number,
                                                                                            ),
                                                                                            //WordSpacing
                                                                                            //Balloon Slider
                                                                                            Positioned(
                                                                                              bottom: 0,
                                                                                              width: width * 0.6,
                                                                                              child: BalloonSlider(
                                                                                                  trackHeight: 15,
                                                                                                  thumbRadius: 7.5,
                                                                                                  showRope: true,
                                                                                                  color: defaultPalette.tertiary,
                                                                                                  ropeLength: 300 / 8,
                                                                                                  value: double.parse((item.textEditorController.getSelectionStyle().attributes[WordSpacingAttribute._key]?.value) ?? 0.toString()) / 100,
                                                                                                  onChanged: (val) {
                                                                                                    setState(() {
                                                                                                      item.textEditorController.formatSelection(
                                                                                                        WordSpacingAttribute((val * 100).ceil().toString()),
                                                                                                      );
                                                                                                    });
                                                                                                  }),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                      //WordSpacing
                                                                                      //+ -
                                                                                      Expanded(
                                                                                        flex: vDividerPosition > 0.45 ? (450 * vDividerPosition).ceil() : 1,
                                                                                        child: Stack(
                                                                                          children: [
                                                                                            Positioned(
                                                                                              top: -4,
                                                                                              right: 4,
                                                                                              height: 35,
                                                                                              child: ElevatedLayerButton(
                                                                                                onClick: () {
                                                                                                  setState(() {
                                                                                                    var val = int.parse(wordSpaceController.text) + 1;

                                                                                                    item.textEditorController.formatSelection(
                                                                                                      WordSpacingAttribute((val).toString()),
                                                                                                    );
                                                                                                  });
                                                                                                },
                                                                                                buttonHeight: 32,
                                                                                                buttonWidth: 65 * vDividerPosition,
                                                                                                borderRadius: BorderRadius.circular(100),
                                                                                                animationDuration: const Duration(milliseconds: 100),
                                                                                                animationCurve: Curves.ease,
                                                                                                topDecoration: BoxDecoration(
                                                                                                  color: Colors.white,
                                                                                                  border: Border.all(),
                                                                                                ),
                                                                                                topLayerChild: Icon(
                                                                                                  IconsaxPlusLinear.add,
                                                                                                  size: 20,
                                                                                                ),
                                                                                                baseDecoration: BoxDecoration(
                                                                                                  color: Colors.green,
                                                                                                  border: Border.all(),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            Positioned(
                                                                                              bottom: 5,
                                                                                              right: 4,
                                                                                              child: ElevatedLayerButton(
                                                                                                // isTapped: false,
                                                                                                // toggleOnTap: true,
                                                                                                onClick: () {
                                                                                                  setState(() {
                                                                                                    var val = (int.parse(wordSpaceController.text) - 1).clamp(0, 100);
                                                                                                    item.textEditorController.formatSelection(
                                                                                                      WordSpacingAttribute((val).toString()),
                                                                                                    );
                                                                                                  });
                                                                                                },
                                                                                                buttonHeight: 32,
                                                                                                buttonWidth: 65 * vDividerPosition,
                                                                                                borderRadius: BorderRadius.circular(100),
                                                                                                animationDuration: const Duration(milliseconds: 100),
                                                                                                animationCurve: Curves.ease,
                                                                                                topDecoration: BoxDecoration(
                                                                                                  color: Colors.white,
                                                                                                  border: Border.all(),
                                                                                                ),
                                                                                                topLayerChild: Icon(
                                                                                                  IconsaxPlusLinear.minus,
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
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              //
                                                                              SizedBox(
                                                                                height: 20,
                                                                              ),
                                                                              //LineHeight
                                                                              ClipRRect(
                                                                                borderRadius: BorderRadius.circular(10),
                                                                                child: Container(
                                                                                  decoration: BoxDecoration(color: defaultPalette.primary, border: Border.all(width: 2, strokeAlign: BorderSide.strokeAlignInside), borderRadius: BorderRadius.circular(8)),
                                                                                  height: 70,
                                                                                  width: width,
                                                                                  child: Row(
                                                                                    children: [
                                                                                      //LineHeight
                                                                                      //Icon title slider field
                                                                                      Expanded(
                                                                                        flex: (1600 * vDividerPosition).ceil(),
                                                                                        child: Stack(
                                                                                          children: [
                                                                                            //LineHeight
                                                                                            //Row font and title
                                                                                            GestureDetector(
                                                                                              onTap: () {
                                                                                                lineSpaceFocus.requestFocus();
                                                                                              },
                                                                                              //LineHeight
                                                                                              //Row font and title
                                                                                              child: Padding(
                                                                                                padding: EdgeInsets.only(top: 5, left: 5),
                                                                                                //LineHeight
                                                                                                //Row font and title
                                                                                                child: Row(
                                                                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                                  children: [
                                                                                                    //LineHeight
                                                                                                    //icon
                                                                                                    Expanded(
                                                                                                        flex: 100,
                                                                                                        child: Icon(
                                                                                                          TablerIcons.spacing_vertical,
                                                                                                          size: 18,
                                                                                                        )),
                                                                                                    //LineHeight
                                                                                                    //title
                                                                                                    vDividerPosition > 0.45
                                                                                                        ? Expanded(
                                                                                                            flex: 700,
                                                                                                            child: Container(
                                                                                                              height: 18,
                                                                                                              alignment: Alignment.bottomLeft,
                                                                                                              child: Text(
                                                                                                                '  Line Space',
                                                                                                                style: TextStyle(fontSize: 12, textBaseline: TextBaseline.ideographic),
                                                                                                              ),
                                                                                                            ))
                                                                                                        : Container(),
                                                                                                  ],
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            //LineHeight
                                                                                            //TextField
                                                                                            TextField(
                                                                                              onTapOutside: (event) {
                                                                                                // fontSizeFocus.unfocus();
                                                                                              },
                                                                                              onSubmitted: (value) {
                                                                                                item.textEditorController.formatSelection(
                                                                                                  LineHeightAttribute((value).toString()),
                                                                                                );
                                                                                              },
                                                                                              focusNode: lineSpaceFocus,
                                                                                              controller: lineSpaceController,
                                                                                              inputFormatters: [
                                                                                                NumericInputFormatter(maxValue: 100),
                                                                                              ],
                                                                                              style: GoogleFonts.lexend(color: defaultPalette.black.withOpacity(fontSizeFocus.hasFocus ? 0.5 : 0.1), fontWeight: FontWeight.bold, fontSize: (80 * vDividerPosition).clamp(70, 100)),
                                                                                              cursorColor: defaultPalette.black,
                                                                                              // selectionControls: MaterialTextSelectionControls(),
                                                                                              textAlign: TextAlign.right,
                                                                                              scrollPadding: EdgeInsets.all(0),
                                                                                              textAlignVertical: TextAlignVertical.top,
                                                                                              decoration: InputDecoration(
                                                                                                contentPadding: EdgeInsets.all(0),

                                                                                                // filled: true,
                                                                                                // fillColor: defaultPalette.primary,
                                                                                                enabledBorder: OutlineInputBorder(
                                                                                                  borderSide: BorderSide(width: 2, color: defaultPalette.transparent),
                                                                                                  borderRadius: BorderRadius.circular(2.0), // Same as border
                                                                                                ),
                                                                                                focusedBorder: OutlineInputBorder(
                                                                                                  borderSide: BorderSide(width: 2, color: defaultPalette.transparent),
                                                                                                  borderRadius: BorderRadius.circular(2.0), // Same as border
                                                                                                ),
                                                                                              ),
                                                                                              keyboardType: TextInputType.number,
                                                                                            ),
                                                                                            //LineHeight
                                                                                            //Balloon Slider
                                                                                            Positioned(
                                                                                              bottom: 0,
                                                                                              width: width * 0.6,
                                                                                              child: BalloonSlider(
                                                                                                  trackHeight: 15,
                                                                                                  thumbRadius: 7.5,
                                                                                                  showRope: true,
                                                                                                  color: defaultPalette.tertiary,
                                                                                                  ropeLength: 300 / 8,
                                                                                                  value: double.parse((item.textEditorController.getSelectionStyle().attributes[LineHeightAttribute._key]?.value) ?? 0.toString()) / 100,
                                                                                                  onChanged: (val) {
                                                                                                    setState(() {
                                                                                                      item.textEditorController.formatSelection(
                                                                                                        LineHeightAttribute((val * 100).ceil().toString()),
                                                                                                      );
                                                                                                    });
                                                                                                  }),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                      //LineHeight
                                                                                      //+ -
                                                                                      Expanded(
                                                                                        flex: vDividerPosition > 0.45 ? (450 * vDividerPosition).ceil() : 1,
                                                                                        child: Stack(
                                                                                          children: [
                                                                                            Positioned(
                                                                                              top: -4,
                                                                                              right: 4,
                                                                                              height: 35,
                                                                                              child: ElevatedLayerButton(
                                                                                                onClick: () {
                                                                                                  setState(() {
                                                                                                    var val = int.parse(lineSpaceController.text) + 1;

                                                                                                    item.textEditorController.formatSelection(
                                                                                                      LineHeightAttribute((val).toString()),
                                                                                                    );
                                                                                                  });
                                                                                                },
                                                                                                buttonHeight: 32,
                                                                                                buttonWidth: 65 * vDividerPosition,
                                                                                                borderRadius: BorderRadius.circular(100),
                                                                                                animationDuration: const Duration(milliseconds: 100),
                                                                                                animationCurve: Curves.ease,
                                                                                                topDecoration: BoxDecoration(
                                                                                                  color: Colors.white,
                                                                                                  border: Border.all(),
                                                                                                ),
                                                                                                topLayerChild: Icon(
                                                                                                  IconsaxPlusLinear.add,
                                                                                                  size: 20,
                                                                                                ),
                                                                                                baseDecoration: BoxDecoration(
                                                                                                  color: Colors.green,
                                                                                                  border: Border.all(),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            Positioned(
                                                                                              bottom: 5,
                                                                                              right: 4,
                                                                                              child: ElevatedLayerButton(
                                                                                                // isTapped: false,
                                                                                                // toggleOnTap: true,
                                                                                                onClick: () {
                                                                                                  setState(() {
                                                                                                    var val = (int.parse(lineSpaceController.text) - 1).clamp(0, 100);
                                                                                                    item.textEditorController.formatSelection(
                                                                                                      LineHeightAttribute((val).toString()),
                                                                                                    );
                                                                                                  });
                                                                                                },
                                                                                                buttonHeight: 32,
                                                                                                buttonWidth: 65 * vDividerPosition,
                                                                                                borderRadius: BorderRadius.circular(100),
                                                                                                animationDuration: const Duration(milliseconds: 100),
                                                                                                animationCurve: Curves.ease,
                                                                                                topDecoration: BoxDecoration(
                                                                                                  color: Colors.white,
                                                                                                  border: Border.all(),
                                                                                                ),
                                                                                                topLayerChild: Icon(
                                                                                                  IconsaxPlusLinear.minus,
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
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              //
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      //Colors
                                                                      SingleChildScrollView(
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              width,
                                                                          height:
                                                                              sHeight * (hDividerPosition - appbarHeight * 1.2),
                                                                          // decoration: BoxDecoration(border: Border.all(width: 2), borderRadius: BorderRadius.circular(12)),
                                                                          // padding: EdgeInsets.only(bottom: 10),
                                                                          // color:
                                                                          // Colors.amberAccent,
                                                                          child: TabContainer(
                                                                              controller: tabcunt,
                                                                              tabEdge: TabEdge.top,
                                                                              tabsStart: 0,
                                                                              tabExtent: 30,
                                                                              childPadding: EdgeInsets.symmetric(vertical: 0),
                                                                              colors: [
                                                                                Colors.grey.withOpacity(.4),
                                                                                Colors.grey.withOpacity(.4)
                                                                                // hexToColor(item.textEditorController.getSelectionStyle().attributes['color']?.value),
                                                                                // hexToColor(item.textEditorController.getSelectionStyle().attributes['background']?.value),
                                                                              ],
                                                                              selectedTextStyle: TextStyle(
                                                                                color: defaultPalette.black,
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
                                                                                  child: ClipRRect(
                                                                                    borderRadius: BorderRadius.circular(8),
                                                                                    child: Column(
                                                                                      children: [
                                                                                        //FONT COLOR
                                                                                        //HEX TEXT FIEKLD
                                                                                        Container(
                                                                                          height: hDividerPosition < 0.25 ? textFieldHeight * 1.5 : textFieldHeight * 1.3,
                                                                                          margin: EdgeInsets.only(top: hDividerPosition < 0.25 ? 10 : 0),
                                                                                          padding: EdgeInsets.all(5),
                                                                                          child: Stack(
                                                                                            children: [
                                                                                              TextFormField(
                                                                                                onTapOutside: (event) {},
                                                                                                controller: hexController,
                                                                                                inputFormatters: [
                                                                                                  HexColorInputFormatter()
                                                                                                ],
                                                                                                onFieldSubmitted: (value) {
                                                                                                  item.textEditorController.formatSelection(
                                                                                                    ColorAttribute('#${value}'),
                                                                                                  );
                                                                                                },
                                                                                                style: TextStyle(color: defaultPalette.black),
                                                                                                cursorColor: defaultPalette.secondary,
                                                                                                textAlign: TextAlign.center,
                                                                                                textAlignVertical: TextAlignVertical.center,
                                                                                                decoration: InputDecoration(
                                                                                                  contentPadding: EdgeInsets.all(0),
                                                                                                  prefixIconConstraints: BoxConstraints(minWidth: presuConstraintsMinW),
                                                                                                  suffixIconConstraints: BoxConstraints(minWidth: presuConstraintsMinW),
                                                                                                  filled: true,
                                                                                                  fillColor: defaultPalette.primary,
                                                                                                  border: OutlineInputBorder(
                                                                                                    borderRadius: BorderRadius.circular(10.0),
                                                                                                  ),
                                                                                                  enabledBorder: OutlineInputBorder(
                                                                                                    borderSide: BorderSide(width: 2, color: defaultPalette.transparent),
                                                                                                    borderRadius: BorderRadius.circular(12.0),
                                                                                                  ),
                                                                                                  focusedBorder: OutlineInputBorder(
                                                                                                    borderSide: BorderSide(width: 3, color: defaultPalette.transparent),
                                                                                                    borderRadius: BorderRadius.circular(10.0),
                                                                                                  ),
                                                                                                ),
                                                                                                keyboardType: TextInputType.number,
                                                                                              ),
                                                                                              if (vDividerPosition > 0.45) ...[
                                                                                                if (vDividerPosition > 0.48)
                                                                                                  Positioned(
                                                                                                    top: (textFieldHeight / 2) - 10,
                                                                                                    left: 10,
                                                                                                    child: GestureDetector(
                                                                                                      child: Icon(
                                                                                                        IconsaxPlusLinear.text,
                                                                                                        size: 20,
                                                                                                        color: hexToColor(hexController.text),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                              ]
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                        //
                                                                                        if (hDividerPosition > 0.2) ...[
                                                                                          //FONT COLOR
                                                                                          //PICKER ND EVERYHTING
                                                                                          Expanded(
                                                                                            child: TabBarView(
                                                                                              physics: NeverScrollableScrollPhysics(),
                                                                                              children: [
                                                                                                SingleChildScrollView(
                                                                                                  child: Padding(
                                                                                                    padding: const EdgeInsets.all(10),
                                                                                                    child: ColorPicker(
                                                                                                      displayThumbColor: true,
                                                                                                      portraitOnly: true,
                                                                                                      pickerAreaBorderRadius: BorderRadius.circular(5),
                                                                                                      colorPickerWidth: 500 * hDividerPosition,
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
                                                                                                Padding(
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
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                          if (hDividerPosition > 0.25)
                                                                                            TabBar(
                                                                                              dividerHeight: 0,
                                                                                              indicatorSize: TabBarIndicatorSize.label,
                                                                                              indicatorColor: defaultPalette.tertiary,
                                                                                              labelColor: defaultPalette.tertiary,
                                                                                              labelPadding: EdgeInsets.all(0),
                                                                                              tabs: [
                                                                                                //FONT COLOR
                                                                                                Tab(
                                                                                                  height: 30,
                                                                                                  child: Container(
                                                                                                    padding: EdgeInsets.all(2),
                                                                                                    // margin: EdgeInsets.only(left: 5, right: 5),
                                                                                                    height: 30,
                                                                                                    width: width,
                                                                                                    alignment: Alignment.center,
                                                                                                    decoration: BoxDecoration(color: defaultPalette.primary.withOpacity(0.7), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8))),
                                                                                                    child: Text(
                                                                                                      'Picker',
                                                                                                      style: GoogleFonts.lexend(fontSize: 12),
                                                                                                    ),
                                                                                                  ),
                                                                                                ), //FONT COLOR
                                                                                                Tab(
                                                                                                  height: 30,
                                                                                                  child: Container(
                                                                                                    padding: EdgeInsets.all(2),
                                                                                                    // margin: EdgeInsets.only(right: 5, left: 5),
                                                                                                    alignment: Alignment.center,
                                                                                                    height: 30,
                                                                                                    width: width,
                                                                                                    decoration: BoxDecoration(color: defaultPalette.primary.withOpacity(0.7), borderRadius: BorderRadius.only(bottomRight: Radius.circular(8))),
                                                                                                    child: Text(
                                                                                                      'Palette',
                                                                                                      style: GoogleFonts.lexend(fontSize: 12),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                        ] //
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                //BG COLORRR
                                                                                DefaultTabController(
                                                                                  length: 2,
                                                                                  child: ClipRRect(
                                                                                    borderRadius: BorderRadius.circular(8),
                                                                                    child: Column(
                                                                                      children: [
                                                                                        //Background color
                                                                                        //HEX TEXT FIEKLD
                                                                                        Container(
                                                                                          height: hDividerPosition < 0.25 ? textFieldHeight * 1.5 : textFieldHeight * 1.3,
                                                                                          margin: EdgeInsets.only(top: hDividerPosition < 0.25 ? 10 : 0),
                                                                                          padding: EdgeInsets.all(5),
                                                                                          child: Stack(
                                                                                            children: [
                                                                                              TextFormField(
                                                                                                onTapOutside: (event) {
                                                                                                  // Focus.unfocus();
                                                                                                },
                                                                                                // focusNode: marginTopFocus,
                                                                                                controller: bghexController,
                                                                                                inputFormatters: [
                                                                                                  HexColorInputFormatter()
                                                                                                  // FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                                                                                                  // NumericInputFormatter(maxValue: (documentPropertiesList[currentPageIndex].pageFormatController.height / 1.11 - double.parse(documentPropertiesList[currentPageIndex].marginBottomController.text))),
                                                                                                ],
                                                                                                onFieldSubmitted: (value) {
                                                                                                  item.textEditorController.formatSelection(
                                                                                                    BackgroundAttribute('${value}'),
                                                                                                  );
                                                                                                  FocusScope.of(context).previousFocus();
                                                                                                },
                                                                                                style: TextStyle(color: defaultPalette.black),
                                                                                                cursorColor: defaultPalette.secondary,
                                                                                                textAlign: TextAlign.center,
                                                                                                textAlignVertical: TextAlignVertical.center,
                                                                                                decoration: InputDecoration(
                                                                                                  contentPadding: EdgeInsets.all(0),
                                                                                                  prefixIconConstraints: BoxConstraints(minWidth: presuConstraintsMinW),
                                                                                                  suffixIconConstraints: BoxConstraints(minWidth: presuConstraintsMinW),
                                                                                                  filled: true,
                                                                                                  fillColor: defaultPalette.primary,
                                                                                                  border: OutlineInputBorder(
                                                                                                    // borderSide: BorderSide(width: 5, color: defaultPalette.black),
                                                                                                    borderRadius: BorderRadius.circular(10.0), // Replace with your desired radius
                                                                                                  ),
                                                                                                  enabledBorder: OutlineInputBorder(
                                                                                                    borderSide: BorderSide(width: 2, color: defaultPalette.transparent),
                                                                                                    borderRadius: BorderRadius.circular(12.0), // Same as border
                                                                                                  ),
                                                                                                  focusedBorder: OutlineInputBorder(
                                                                                                    borderSide: BorderSide(width: 3, color: defaultPalette.transparent),
                                                                                                    borderRadius: BorderRadius.circular(10.0), // Same as border
                                                                                                  ),
                                                                                                ),
                                                                                                keyboardType: TextInputType.number,
                                                                                                // onChanged: (value) => _updatePdfPreview(''),
                                                                                              ),
                                                                                              if (vDividerPosition > 0.45) ...[
                                                                                                if (vDividerPosition > 0.48)
                                                                                                  Positioned(
                                                                                                    top: (textFieldHeight / 2) - 14,
                                                                                                    left: 6,
                                                                                                    child: GestureDetector(
                                                                                                      child: Icon(
                                                                                                        IconsaxPlusBold.text,
                                                                                                        size: 28,
                                                                                                        color: hexToColor(bghexController.text),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                              ]
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                        //
                                                                                        if (hDividerPosition > 0.2) ...[
                                                                                          //Background color
                                                                                          //PICKER ND EVERYHTING
                                                                                          Expanded(
                                                                                            child: TabBarView(
                                                                                              physics: NeverScrollableScrollPhysics(),
                                                                                              children: [
                                                                                                SingleChildScrollView(
                                                                                                  child: Padding(
                                                                                                    padding: const EdgeInsets.all(10),
                                                                                                    child: ColorPicker(
                                                                                                      displayThumbColor: true,
                                                                                                      portraitOnly: true,
                                                                                                      pickerAreaBorderRadius: BorderRadius.circular(5),
                                                                                                      colorPickerWidth: 500 * hDividerPosition,
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
                                                                                                ), //FONT COLOR
                                                                                                Padding(
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
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                          if (hDividerPosition > 0.25)
                                                                                            TabBar(
                                                                                              dividerHeight: 0,
                                                                                              indicatorSize: TabBarIndicatorSize.label,
                                                                                              indicatorColor: defaultPalette.tertiary,
                                                                                              labelColor: defaultPalette.tertiary,
                                                                                              labelPadding: EdgeInsets.all(0),
                                                                                              tabs: [
                                                                                                //FONT COLOR
                                                                                                Tab(
                                                                                                  height: 30,
                                                                                                  child: Container(
                                                                                                    padding: EdgeInsets.all(2),
                                                                                                    // margin: EdgeInsets.only(left: 5, right: 5),
                                                                                                    height: 30,
                                                                                                    width: width,
                                                                                                    alignment: Alignment.center,
                                                                                                    decoration: BoxDecoration(
                                                                                                      color: defaultPalette.primary.withOpacity(0.7),
                                                                                                    ),
                                                                                                    child: Text(
                                                                                                      'Picker',
                                                                                                      style: GoogleFonts.lexend(fontSize: 12),
                                                                                                    ),
                                                                                                  ),
                                                                                                ), //FONT COLOR
                                                                                                Tab(
                                                                                                  height: 30,
                                                                                                  child: Container(
                                                                                                    padding: EdgeInsets.all(2),
                                                                                                    alignment: Alignment.center,
                                                                                                    height: 30,
                                                                                                    width: width,
                                                                                                    decoration: BoxDecoration(
                                                                                                      color: defaultPalette.primary.withOpacity(0.7),
                                                                                                    ),
                                                                                                    child: Text(
                                                                                                      'Palette',
                                                                                                      style: GoogleFonts.lexend(fontSize: 12),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                        ] //
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ]),
                                                                          //
                                                                        ),
                                                                      )
                                                                    ],
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            //Text SIDEBAR
                                            AnimatedPositioned(
                                                left:
                                                    panelIndex.panelIndex == -1
                                                        ? -100
                                                        : 0,
                                                top: 0,
                                                duration: Durations.long4,
                                                child: PlayableToolbarWidget(
                                                    itemsGutter: 0,
                                                    toolbarBackgroundRadius: 0,
                                                    toolbarWidth: 44,
                                                    toolbarShadow:
                                                        defaultPalette.black
                                                            .withOpacity(0.05),
                                                    toolbarHorizontalPadding: 0,
                                                    toolbarHeight: sHeight *
                                                        hDividerPosition,
                                                    itemsOffset: 0,
                                                    toolbarItems: [
                                                      ListItemModel(
                                                        isTapped: isTapped[0],
                                                        onTap: () {
                                                          var item = _sheetItemIterator(
                                                                  panelIndex.id,
                                                                  spreadSheetList[
                                                                      currentPageIndex])
                                                              as TextEditorItem;
                                                          item.focusNode
                                                              .unfocus();
                                                          setState(() {
                                                            panelIndex =
                                                                PanelIndex(
                                                                    id: '',
                                                                    panelIndex:
                                                                        -1);
                                                          });
                                                          for (var i = 0;
                                                              i <
                                                                  isTapped
                                                                      .length;
                                                              i++) {
                                                            setState(() {
                                                              isTapped[i] =
                                                                  false;
                                                            });
                                                          }
                                                          setState(() {
                                                            isTapped[1] = true;
                                                          });
                                                        },
                                                        title: 'Duh',
                                                        color: defaultPalette
                                                            .tertiary,
                                                        icon: TablerIcons.x,
                                                      ),
                                                      ListItemModel(
                                                        isTapped: isTapped[1],
                                                        onTap: () {
                                                          for (var i = 0;
                                                              i <
                                                                  isTapped
                                                                      .length;
                                                              i++) {
                                                            setState(() {
                                                              isTapped[i] =
                                                                  false;
                                                            });
                                                          }
                                                          setState(() {
                                                            isTapped[1] = true;
                                                            textStyleTabControler
                                                                .animateToPage(0,
                                                                    duration:
                                                                        Durations
                                                                            .medium1,
                                                                    curve: Curves
                                                                        .easeIn);
                                                          });
                                                        },
                                                        title: 'Font',
                                                        color: defaultPalette
                                                            .primary,
                                                        icon: TablerIcons
                                                            .typography,
                                                      ),
                                                      ListItemModel(
                                                        isTapped: isTapped[2],
                                                        onTap: () {
                                                          for (var i = 0;
                                                              i <
                                                                  isTapped
                                                                      .length;
                                                              i++) {
                                                            setState(() {
                                                              isTapped[i] =
                                                                  false;
                                                            });
                                                          }
                                                          setState(() {
                                                            isTapped[2] = true;
                                                            textStyleTabControler
                                                                .animateToPage(1,
                                                                    duration:
                                                                        Durations
                                                                            .medium1,
                                                                    curve: Curves
                                                                        .easeIn);
                                                          });
                                                        },
                                                        title: 'Format',
                                                        color: defaultPalette
                                                            .primary,
                                                        icon: TablerIcons.bold,
                                                      ),
                                                      //sizespace
                                                      ListItemModel(
                                                        isTapped: isTapped[3],
                                                        onTap: () {
                                                          for (var i = 0;
                                                              i <
                                                                  isTapped
                                                                      .length;
                                                              i++) {
                                                            setState(() {
                                                              isTapped[i] =
                                                                  false;
                                                            });
                                                          }
                                                          setState(() {
                                                            isTapped[3] = true;
                                                            textStyleTabControler
                                                                .animateToPage(2,
                                                                    duration:
                                                                        Durations
                                                                            .medium1,
                                                                    curve: Curves
                                                                        .easeIn);
                                                          });
                                                        },
                                                        title: 'Size',
                                                        color: defaultPalette
                                                            .primary,
                                                        icon: TablerIcons
                                                            .text_size,
                                                      ),
                                                      //paint
                                                      ListItemModel(
                                                        isTapped: isTapped[4],
                                                        onTap: () {
                                                          for (var i = 0;
                                                              i <
                                                                  isTapped
                                                                      .length;
                                                              i++) {
                                                            setState(() {
                                                              isTapped[i] =
                                                                  false;
                                                            });
                                                          }
                                                          setState(() {
                                                            isTapped[4] = true;
                                                            textStyleTabControler
                                                                .animateToPage(3,
                                                                    duration:
                                                                        Durations
                                                                            .medium1,
                                                                    curve: Curves
                                                                        .easeIn);
                                                          });
                                                        },
                                                        title: 'Color',
                                                        color: defaultPalette
                                                            .primary,
                                                        icon: TablerIcons.paint,
                                                      ),
                                                    ]))
                                          ],
                                        ),
                                      )),

                                  ////////////////////RIGHT SCREEN PDF PREVIEW

                                  Expanded(
                                    flex: ((1 - vDividerPosition) * 10000)
                                        .toInt(),
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 300),
                                      // color: Colors.green,
                                      child: Center(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            //emulating the pdf preview
                            Positioned(
                              top: sHeight * appbarHeight / 6,
                              left: (sWidth * vDividerPosition),
                              // right: 0,
                              // width: 2480 ,
                              // height: sHeight * hDividerPosition+126,
                              child: Zoomable(
                                maxScale: 10,
                                child: Transform.scale(
                                  scale: (1 - vDividerPosition) * 0.48,
                                  // scale: 1,
                                  alignment: Alignment.topLeft,
                                  child: Container(
                                    // width: 2480,
                                    // height: (sWidth-64)*sqrt2 ,
                                    height: (sHeight) *
                                        hDividerPosition /
                                        ((1 - vDividerPosition) * 0.48),
                                    padding: EdgeInsets.only(
                                        bottom: 25, top: 25, right: 40),
                                    decoration: BoxDecoration(boxShadow: [
                                      BoxShadow(
                                          blurRadius: 500,
                                          offset: Offset(5, 5),
                                          color: defaultPalette.black
                                              .withOpacity(0.06))
                                    ]),
                                    alignment: Alignment.center,
                                    child: _generateWid(sWidth, sHeight),
                                  ),
                                ),
                              ),
                            ),
                            ///////////VERTICAL GRIP
                            Positioned(
                              left: vDividerPosition * sWidth - 37,
                              top: 17,
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 50),
                                width: 32,
                                height: 30,
                                decoration: BoxDecoration(
                                    color: defaultPalette.tertiary,
                                    borderRadius: BorderRadius.circular(8)),
                                child: GestureDetector(
                                  onPanUpdate: (details) {
                                    double newPosition = (vDividerPosition +
                                            details.delta.dx /
                                                context.size!.width)
                                        .clamp(0.4, 0.85);
                                    _updatevDividerPosition(newPosition);
                                  },
                                  child: Icon(
                                    TablerIcons.grip_vertical,
                                    color: defaultPalette.black,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
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
                                      child: Container(
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: defaultPalette.black
                                                .withOpacity(0.9)),
                                        child: Icon(
                                          TablerIcons.grip_horizontal,
                                          color: defaultPalette.white,
                                          size: 20,
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
                                      onPressed: () async {
                                        // pw.Page pdf = await exportDelegate
                                        //     .exportToPdfPage('2');
                                        // setState(() {
                                        //   genpdf.addPage(pdf);
                                        // });
                                        _capturePng(0);
                                      },
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
                                ],
                              ),
                            ),
                            ////// SPREADSHEET
                            Expanded(
                              flex: (8 * 10000),
                              child: Container(
                                // height: sHeight / 20,
                                width: sWidth,
                                color: defaultPalette.black.withOpacity(.9),
                                child: Stack(
                                  children: [
                                    // botomGraph
                                    IgnorePointer(
                                      ignoring: true,
                                      child: AnimatedContainer(
                                        duration: Durations.extralong1,
                                        height: sHeight,
                                        width: sWidth,
                                        alignment: Alignment.centerRight,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.0),
                                        ),
                                        padding: EdgeInsets.only(
                                          top: 0,
                                        ),
                                        //layGraph
                                        child: Opacity(
                                          opacity: 0.35,
                                          child: LineChart(LineChartData(
                                              lineBarsData: [
                                                LineChartBarData()
                                              ],
                                              titlesData:
                                                  FlTitlesData(show: false),
                                              gridData: FlGridData(
                                                  show: true,
                                                  horizontalInterval: 10,
                                                  verticalInterval: 30),
                                              borderData:
                                                  FlBorderData(show: false),
                                              minY: 0,
                                              maxY: 50,
                                              maxX: dateTimeNow
                                                          .millisecondsSinceEpoch
                                                          .ceilToDouble() /
                                                      500 +
                                                  250,
                                              minX: dateTimeNow
                                                      .millisecondsSinceEpoch
                                                      .ceilToDouble() /
                                                  500)),
                                        ),
                                      ),
                                    ),
                                    //Main SpreadSheet
                                    ReorderableListView.builder(
                                      footer: null,
                                      header: null,
                                      // scrollDirection: Axis.horizontal,
                                      itemExtentBuilder: null,
                                      proxyDecorator:
                                          (child, index, animation) {
                                        return child;
                                      },
                                      padding: EdgeInsets.all(0),
                                      onReorder: (int oldIndex, int newIndex) {
                                        setState(() {
                                          if (newIndex > oldIndex) {
                                            newIndex -= 1;
                                          }
                                          final item =
                                              spreadSheetList[currentPageIndex]
                                                  .removeAt(oldIndex);
                                          spreadSheetList[currentPageIndex]
                                              .insert(newIndex, item);
                                        });
                                      },
                                      itemCount:
                                          spreadSheetList[currentPageIndex]
                                              .length,
                                      itemBuilder: (context, index) {
                                        print(
                                            'hello hello sprdsheetBuilding: ${spreadSheetList[currentPageIndex][index]}');
                                        if (spreadSheetList[currentPageIndex]
                                            [index] is TextEditorItem) {
                                          var textEditorItem =
                                              spreadSheetList[currentPageIndex]
                                                  [index] as TextEditorItem;
                                          return Stack(
                                            key: ValueKey(textEditorItem
                                                .id), // Ensure each item has a unique key
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                  var isTrue = false;
                                                  SheetItem? itemE;
                                                  if (panelIndex.id ==
                                                      textEditorItem.id) {
                                                    isTrue = true;
                                                  }
                                                  setState(() {
                                                    itemE = _sheetItemIterator(
                                                        textEditorItem.id,
                                                        spreadSheetList[
                                                            currentPageIndex]);

                                                    if (itemE != null) {
                                                      index = _sheetListIterator(
                                                              itemE!.parentId,
                                                              spreadSheetList[
                                                                  currentPageIndex])
                                                          .indexOf(itemE!);
                                                      panelIndex = PanelIndex(
                                                          id: itemE!.id,
                                                          panelIndex: index,
                                                          parentId:
                                                              itemE?.parentId);
                                                    } else {
                                                      panelIndex = PanelIndex(
                                                          id: textEditorItem.id,
                                                          panelIndex: index,
                                                          parentId:
                                                              textEditorItem
                                                                  .parentId);
                                                    }

                                                    // index = temp ?? index;

                                                    if (hDividerPosition >
                                                        0.48) {
                                                      hDividerPosition = 0.4;
                                                    }
                                                  });
                                                  // Future.delayed(Duration.zero)
                                                  //     .then((_) {
                                                  //   textStylePageController
                                                  //       .jumpToPage(panelIndex
                                                  //           .panelIndex);
                                                  // });
                                                  Future.delayed(
                                                          Durations.short1)
                                                      .then((h) {
                                                    if (!isTrue) {
                                                      textStyleTabControler
                                                          .animateToPage(0,
                                                              curve: Curves
                                                                  .bounceIn,
                                                              duration:
                                                                  Durations
                                                                      .short1);
                                                      for (var i = 0;
                                                          i < isTapped.length;
                                                          i++) {
                                                        setState(() {
                                                          isTapped[i] = false;
                                                        });
                                                      }
                                                      setState(() {
                                                        isTapped[1] = true;
                                                      });
                                                    }
                                                  });

                                                  print('clicked');

                                                  print(panelIndex);
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 4,
                                                          bottom: 8,
                                                          left: 20,
                                                          right: 20),
                                                  margin: EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        defaultPalette.primary,
                                                    border: Border.all(
                                                      width: panelIndex.id ==
                                                              textEditorItem.id
                                                          ? 4
                                                          : 2,
                                                      color: panelIndex.id ==
                                                              textEditorItem.id
                                                          ? defaultPalette
                                                              .tertiary
                                                          : defaultPalette
                                                              .black,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        padding:
                                                            EdgeInsets.only(
                                                                bottom: 4),
                                                        child: Text(
                                                            'id : ${textEditorItem.id}',
                                                            style: TextStyle(
                                                                fontSize: 10)),
                                                      ),
                                                      QuillEditor(
                                                        configurations:
                                                            textEditorItem
                                                                .textEditorConfigurations,
                                                        focusNode:
                                                            textEditorItem
                                                                .focusNode,
                                                        scrollController:
                                                            textEditorItem
                                                                .scrollController,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              //contextMenu in main spreadsheet
                                              AnimatedPositioned(
                                                duration: Durations.medium3,
                                                bottom: 0,
                                                left: panelIndex.id ==
                                                        textEditorItem.id
                                                    ? 0
                                                    : -50,
                                                right: 0,
                                                child: SingleChildScrollView(
                                                  child: Transform.flip(
                                                    flipX: true,
                                                    child: Transform.flip(
                                                      flipX: true,
                                                      child:
                                                          panelIndex.id ==
                                                                  textEditorItem
                                                                      .id
                                                              ? ExpandableMenu(
                                                                  backgroundColor:
                                                                      defaultPalette
                                                                          .white
                                                                          .withOpacity(
                                                                              1),
                                                                  iconColor:
                                                                      defaultPalette
                                                                          .tertiary,
                                                                  itemContainerColor:
                                                                      defaultPalette
                                                                          .secondary,
                                                                  width: 40.0,
                                                                  height: 40.0,
                                                                  items: List
                                                                      .generate(
                                                                          12,
                                                                          (intt) {
                                                                    switch (
                                                                        intt) {
                                                                      case 0:
                                                                        return PopupMenuButton<
                                                                            String>(
                                                                          iconSize:
                                                                              20,
                                                                          padding:
                                                                              EdgeInsets.all(0),
                                                                          icon:
                                                                              Icon(
                                                                            TablerIcons.message_plus,
                                                                            color:
                                                                                defaultPalette.black.withOpacity(0.8),
                                                                          ),
                                                                          onSelected:
                                                                              (String value) {
                                                                            // Handle the selected option here in main spreadsheet
                                                                            switch (value) {
                                                                              case 'Above':
                                                                                setState(() {
                                                                                  var newItem = _addTextField(shouldReturn: true);
                                                                                  spreadSheetList[currentPageIndex].insert(index, newItem);
                                                                                  index++;
                                                                                });
                                                                                break;
                                                                              case 'Below':
                                                                                setState(() {
                                                                                  var newItem = _addTextField(shouldReturn: true);
                                                                                  spreadSheetList[currentPageIndex].insert(index + 1, newItem);
                                                                                });
                                                                                // Your logic for "Below" in main spreadsheet
                                                                                break;
                                                                              case 'Left':
                                                                                setState(() {
                                                                                  var newId = Uuid().v4();
                                                                                  var item = spreadSheetList[currentPageIndex].removeAt(index);
                                                                                  spreadSheetList[currentPageIndex].insert(
                                                                                      index,
                                                                                      SheetList(direction: Axis.horizontal, id: newId, parentId: spreadSheetList[currentPageIndex].id, sheetList: [
                                                                                        _addTextField(shouldReturn: true),
                                                                                        item
                                                                                      ]));
                                                                                });
                                                                                break;
                                                                              //in main spreadsheet
                                                                              case 'Right':
                                                                                setState(() {
                                                                                  var newId = Uuid().v4();
                                                                                  var item = spreadSheetList[currentPageIndex].removeAt(index);
                                                                                  spreadSheetList[currentPageIndex].insert(
                                                                                      index,
                                                                                      SheetList(direction: Axis.horizontal, id: newId, parentId: spreadSheetList[currentPageIndex].id, sheetList: [
                                                                                        item,
                                                                                        _addTextField(shouldReturn: true),
                                                                                      ]));
                                                                                });
                                                                                break;
                                                                            }
                                                                          },
                                                                          itemBuilder:
                                                                              (BuildContext context) {
                                                                            return [
                                                                              const PopupMenuItem<String>(
                                                                                value: 'Above',
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                  children: [
                                                                                    Icon(TablerIcons.arrow_bar_to_up),
                                                                                    Text('Above')
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              const PopupMenuItem<String>(
                                                                                value: 'Below',
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                  children: [
                                                                                    Icon(TablerIcons.arrow_bar_to_down),
                                                                                    Text('Below')
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              const PopupMenuItem<String>(
                                                                                value: 'Left',
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                  children: [
                                                                                    Icon(TablerIcons.arrow_bar_to_left),
                                                                                    Text('Left')
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              const PopupMenuItem<String>(
                                                                                value: 'Right',
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                  children: [
                                                                                    Icon(TablerIcons.arrow_bar_to_right),
                                                                                    Text('Right')
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ];
                                                                          },
                                                                        );

                                                                      case 1:
                                                                        //MOVE TEXT UP in main spreadsheet
                                                                        return GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            setState(() {
                                                                              if (index != 0) {
                                                                                var item = spreadSheetList[currentPageIndex].removeAt(index);
                                                                                spreadSheetList[currentPageIndex].insert(index - 1, item);

                                                                                // Update the index to reflect the new position of the item
                                                                                index--; // Decrement index to reflect the item's new position

                                                                                panelIndex = PanelIndex(id: panelIndex.id, panelIndex: panelIndex.panelIndex + 1, parentId: panelIndex.parentId);
                                                                                print('Updated index of text editor: $index');
                                                                              }
                                                                              print('Current index of text editor: $index');
                                                                            });
                                                                          },
                                                                          child:
                                                                              Icon(
                                                                            TablerIcons.arrow_up,
                                                                            color:
                                                                                defaultPalette.black.withOpacity(0.8),
                                                                          ),
                                                                        );
                                                                      case 2:
                                                                        //MOVE TEXT DOWN in main spreadsheet
                                                                        return GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            setState(() {
                                                                              if (index != spreadSheetList[currentPageIndex].length - 1) {
                                                                                var item = spreadSheetList[currentPageIndex].removeAt(index);
                                                                                spreadSheetList[currentPageIndex].insert(index + 1, item);
                                                                                index++;
                                                                                print('index of texteditor DT: $index');
                                                                              }
                                                                            });
                                                                          },
                                                                          child:
                                                                              Icon(
                                                                            TablerIcons.arrow_down,
                                                                            color:
                                                                                defaultPalette.black.withOpacity(0.8),
                                                                          ),
                                                                        );
                                                                      case 3:
                                                                        //EXPORT TEXT in main spreadsheet
                                                                        return GestureDetector(
                                                                          onTap:
                                                                              () async {
                                                                            // Get the current text editor item
                                                                            var textEditorItem =
                                                                                spreadSheetList[currentPageIndex][index] as TextEditorItem;

                                                                            // Create a GlobalKey for the RepaintBoundary
                                                                            GlobalKey
                                                                                repaintBoundaryKey =
                                                                                GlobalKey();

                                                                            // Navigate to a new page with the PDF preview
                                                                            await Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                builder: (context) => Scaffold(
                                                                                  appBar: AppBar(
                                                                                    title: Text('PDF Preview'),
                                                                                    actions: [
                                                                                      IconButton(
                                                                                        icon: Icon(Icons.image),
                                                                                        onPressed: () async {
                                                                                          RenderRepaintBoundary boundary = repaintBoundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
                                                                                          ui.Image image = await boundary.toImage(pixelRatio: 6.0);
                                                                                          ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
                                                                                          Uint8List pngBytes = byteData!.buffer.asUint8List();

                                                                                          // Get the directory to save the image
                                                                                          final directory = await getApplicationDocumentsDirectory();
                                                                                          final imagePath = '${directory.path}/captured_image.png';
                                                                                          File(imagePath).writeAsBytesSync(pngBytes);

                                                                                          print('Image saved at: $imagePath');
                                                                                        },
                                                                                      ),
                                                                                      IconButton(
                                                                                        icon: Icon(Icons.print),
                                                                                        onPressed: () async {
                                                                                          RenderRepaintBoundary boundary = repaintBoundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
                                                                                          ui.Image image = await boundary.toImage(pixelRatio: 6.0);
                                                                                          ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
                                                                                          Uint8List pngBytes = byteData!.buffer.asUint8List();

                                                                                          // Get the directory to save the image
                                                                                          final directory = await getApplicationDocumentsDirectory();
                                                                                          final imagePath = '${directory.path}/captured_image.png';
                                                                                          File(imagePath).writeAsBytesSync(pngBytes);

                                                                                          // Prepare the PDF document
                                                                                          final pdf = pw.Document();
                                                                                          final imageProvider = pw.MemoryImage(pngBytes);

                                                                                          pdf.addPage(
                                                                                            pw.Page(
                                                                                              pageFormat: documentPropertiesList[currentPageIndex].pageFormatController,
                                                                                              margin: pw.EdgeInsets.only(
                                                                                                top: double.parse(documentPropertiesList[currentPageIndex].marginTopController.text),
                                                                                                bottom: double.parse(documentPropertiesList[currentPageIndex].marginBottomController.text),
                                                                                                left: double.parse(documentPropertiesList[currentPageIndex].marginLeftController.text),
                                                                                                right: double.parse(documentPropertiesList[currentPageIndex].marginRightController.text),
                                                                                              ),
                                                                                              build: (pw.Context context) {
                                                                                                return pw.Center(
                                                                                                  child: pw.Image(imageProvider),
                                                                                                ); // Center the image on the page
                                                                                              },
                                                                                            ),
                                                                                          );

                                                                                          // Save the PDF to a file
                                                                                          final pdfPath = '${directory.path}/document.pdf';
                                                                                          final file = File(pdfPath);
                                                                                          await file.writeAsBytes(await pdf.save());

                                                                                          print('PDF saved at: $pdfPath');
                                                                                        },
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                  body: RepaintBoundary(
                                                                                    key: repaintBoundaryKey,
                                                                                    child: Container(
                                                                                      width: documentPropertiesList[currentPageIndex].pageFormatController == PdfPageFormat.a4
                                                                                          ? 793.7
                                                                                          : documentPropertiesList[currentPageIndex].pageFormatController == PdfPageFormat.a3
                                                                                              ? 812.8
                                                                                              : documentPropertiesList[currentPageIndex].pageFormatController == PdfPageFormat.a5
                                                                                                  ? 559.4
                                                                                                  : documentPropertiesList[currentPageIndex].pageFormatController == PdfPageFormat.a6
                                                                                                      ? 396.9
                                                                                                      : documentPropertiesList[currentPageIndex].pageFormatController == PdfPageFormat.letter
                                                                                                          ? 816
                                                                                                          : documentPropertiesList[currentPageIndex].pageFormatController == PdfPageFormat.legal
                                                                                                              ? 816
                                                                                                              : 1240, // Default width
                                                                                      height: documentPropertiesList[currentPageIndex].pageFormatController == PdfPageFormat.a4
                                                                                          ? 1122.5
                                                                                          : documentPropertiesList[currentPageIndex].pageFormatController == PdfPageFormat.a3
                                                                                              ? 1122.5
                                                                                              : documentPropertiesList[currentPageIndex].pageFormatController == PdfPageFormat.a5
                                                                                                  ? 793.7
                                                                                                  : documentPropertiesList[currentPageIndex].pageFormatController == PdfPageFormat.a6
                                                                                                      ? 559.4
                                                                                                      : documentPropertiesList[currentPageIndex].pageFormatController == PdfPageFormat.letter
                                                                                                          ? 1056
                                                                                                          : documentPropertiesList[currentPageIndex].pageFormatController == PdfPageFormat.legal
                                                                                                              ? 1344
                                                                                                              : 3508, // Default height
                                                                                      padding: EdgeInsets.only(
                                                                                        top: double.parse(documentPropertiesList[currentPageIndex].marginTopController.text),
                                                                                        bottom: double.parse(documentPropertiesList[currentPageIndex].marginBottomController.text),
                                                                                        left: double.parse(documentPropertiesList[currentPageIndex].marginLeftController.text),
                                                                                        right: double.parse(documentPropertiesList[currentPageIndex].marginRightController.text),
                                                                                      ),
                                                                                      margin: EdgeInsets.all(20),
                                                                                      decoration: BoxDecoration(color: Colors.white, boxShadow: [
                                                                                        BoxShadow(blurRadius: 10, color: Colors.black)
                                                                                      ]),
                                                                                      child: QuillEditor(
                                                                                        // Replace with your QuillEditor configurations
                                                                                        configurations: QuillEditorConfigurations(controller: textEditorItem.textEditorConfigurations.controller), focusNode: FocusNode(), scrollController: ScrollController(),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            );
                                                                          },
                                                                          child:
                                                                              Icon(
                                                                            TablerIcons.file_export,
                                                                            color:
                                                                                defaultPalette.black.withOpacity(0.8),
                                                                          ),
                                                                        );
                                                                      case 4:
                                                                        //clear text in text field in main spreadsheet
                                                                        return GestureDetector(
                                                                          onTap:
                                                                              () async {
                                                                            await showAdaptiveDialog(
                                                                              context: context,
                                                                              builder: (context) {
                                                                                return AlertDialog(
                                                                                  title: Text('Confirm Clear'),
                                                                                  content: Text('This will clear the text from current Text Field. Are you sure?'),
                                                                                  actions: [
                                                                                    TextButton(
                                                                                        onPressed: () {
                                                                                          setState(() {
                                                                                            textEditorItem.textEditorController.document = Document();
                                                                                          });
                                                                                          Navigator.pop(context);
                                                                                        },
                                                                                        child: Text('Yes')),
                                                                                    TextButton(
                                                                                        onPressed: () {
                                                                                          Navigator.pop(context);
                                                                                        },
                                                                                        child: Text('No')),
                                                                                  ],
                                                                                );
                                                                              },
                                                                            );
                                                                          },
                                                                          child:
                                                                              Icon(
                                                                            TablerIcons.x,
                                                                            color:
                                                                                defaultPalette.black.withOpacity(0.8),
                                                                          ),
                                                                        );
                                                                      case 5:
                                                                        //Delete Text Field in main spreadsheet
                                                                        return GestureDetector(
                                                                          onTap:
                                                                              () async {
                                                                            await showAdaptiveDialog(
                                                                              context: context,
                                                                              builder: (context) {
                                                                                return AlertDialog(
                                                                                  title: Text('Confirm Delete'),
                                                                                  content: Text('This will DELETE the current Text Field with its contents. Are you sure?'),
                                                                                  actions: [
                                                                                    TextButton(
                                                                                        onPressed: () {
                                                                                          setState(() {
                                                                                            spreadSheetList[currentPageIndex].removeAt(index);
                                                                                            panelIndex.id = '';
                                                                                            panelIndex.panelIndex = -1;
                                                                                          });
                                                                                          Navigator.pop(context);
                                                                                        },
                                                                                        child: Text('Yes')),
                                                                                    TextButton(
                                                                                        onPressed: () {
                                                                                          Navigator.pop(context);
                                                                                        },
                                                                                        child: Text('No')),
                                                                                  ],
                                                                                );
                                                                              },
                                                                            );
                                                                          },
                                                                          child:
                                                                              Icon(
                                                                            TablerIcons.trash,
                                                                            color:
                                                                                defaultPalette.black.withOpacity(0.8),
                                                                          ),
                                                                        );
                                                                      default:
                                                                        return Container();
                                                                    }
                                                                  }), // simplified item generation in main spreadsheet
                                                                )
                                                              : null,
                                                    ),
                                                  ),
                                                ),
                                              ), // Expandable menus and other widgets can stay the same
                                            ],
                                          );
                                        } else if (spreadSheetList[
                                                currentPageIndex][index]
                                            is SheetList) {
                                          return Stack(
                                            key: ValueKey((spreadSheetList[
                                                        currentPageIndex][index]
                                                    as SheetList)
                                                .id),
                                            children: [
                                              _buildListWidget(spreadSheetList[
                                                      currentPageIndex][index]
                                                  as SheetList),
                                              AnimatedPositioned(
                                                duration: Durations.medium3,
                                                bottom: 0,
                                                left: panelIndex.parentId ==
                                                        spreadSheetList[
                                                                    currentPageIndex]
                                                                [index]
                                                            .id
                                                    ? 0
                                                    : -50,
                                                right: 0,
                                                child: SingleChildScrollView(
                                                  child: Transform.flip(
                                                    flipX: true,
                                                    child: Transform.flip(
                                                      flipX: true,
                                                      child: panelIndex
                                                                  .parentId ==
                                                              spreadSheetList[
                                                                          currentPageIndex]
                                                                      [index]
                                                                  .id
                                                          ? ExpandableMenu(
                                                              backgroundColor:
                                                                  defaultPalette
                                                                      .white
                                                                      .withOpacity(
                                                                          1),
                                                              iconColor:
                                                                  defaultPalette
                                                                      .tertiary,
                                                              itemContainerColor:
                                                                  defaultPalette
                                                                      .secondary,
                                                              width: 40.0,
                                                              height: 40.0,
                                                              items:
                                                                  List.generate(
                                                                      12,
                                                                      (intt) {
                                                                switch (intt) {
                                                                  case 0:
                                                                    return PopupMenuButton<
                                                                        String>(
                                                                      iconSize:
                                                                          20,
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              0),
                                                                      icon:
                                                                          Icon(
                                                                        TablerIcons
                                                                            .message_plus,
                                                                        color: defaultPalette
                                                                            .black
                                                                            .withOpacity(0.8),
                                                                      ),
                                                                      onSelected:
                                                                          (String
                                                                              value) {
                                                                        // Handle the selected option here
                                                                        switch (
                                                                            value) {
                                                                          case 'Above':
                                                                            setState(() {
                                                                              var newItem = _addTextField(shouldReturn: true);
                                                                              (spreadSheetList[currentPageIndex][index] as SheetList).insert(0, newItem);
                                                                              index++;
                                                                            });
                                                                            break;
                                                                          case 'Below':
                                                                            setState(() {
                                                                              var newItem = _addTextField(shouldReturn: true);
                                                                              (spreadSheetList[currentPageIndex][index] as SheetList).sheetList.add(newItem);
                                                                            });
                                                                            // Your logic for "Below"
                                                                            break;
                                                                          case 'Left':
                                                                            setState(() {
                                                                              var newId = Uuid().v4();
                                                                              var item = spreadSheetList[currentPageIndex].removeAt(index);
                                                                              spreadSheetList[currentPageIndex].insert(
                                                                                  index,
                                                                                  SheetList(direction: Axis.horizontal, id: newId, parentId: spreadSheetList[currentPageIndex].id, sheetList: [
                                                                                    _addTextField(shouldReturn: true),
                                                                                    item
                                                                                  ]));
                                                                            });
                                                                            break;
                                                                          case 'Right':
                                                                            // Your logic for "Right"
                                                                            setState(() {
                                                                              var newId = Uuid().v4();
                                                                              var item = spreadSheetList[currentPageIndex].removeAt(index);
                                                                              spreadSheetList[currentPageIndex].insert(
                                                                                  index,
                                                                                  SheetList(direction: Axis.horizontal, id: newId, parentId: spreadSheetList[currentPageIndex].id, sheetList: [
                                                                                    item,
                                                                                    _addTextField(shouldReturn: true),
                                                                                  ]));
                                                                            });
                                                                            break;
                                                                        }
                                                                      },
                                                                      itemBuilder:
                                                                          (BuildContext
                                                                              context) {
                                                                        return [
                                                                          const PopupMenuItem<
                                                                              String>(
                                                                            value:
                                                                                'Above',
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                              children: [
                                                                                Icon(TablerIcons.arrow_bar_to_up),
                                                                                Text('Above')
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          const PopupMenuItem<
                                                                              String>(
                                                                            value:
                                                                                'Below',
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                              children: [
                                                                                Icon(TablerIcons.arrow_bar_to_down),
                                                                                Text('Below')
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          const PopupMenuItem<
                                                                              String>(
                                                                            value:
                                                                                'Left',
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                              children: [
                                                                                Icon(TablerIcons.arrow_bar_to_left),
                                                                                Text('Left')
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          const PopupMenuItem<
                                                                              String>(
                                                                            value:
                                                                                'Right',
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                              children: [
                                                                                Icon(TablerIcons.arrow_bar_to_right),
                                                                                Text('Right')
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ];
                                                                      },
                                                                    );

                                                                  case 1:
                                                                    //MOVE TEXT UP
                                                                    return GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          if (index !=
                                                                              0) {
                                                                            var item =
                                                                                spreadSheetList[currentPageIndex].removeAt(index);
                                                                            spreadSheetList[currentPageIndex].insert(index - 1,
                                                                                item);

                                                                            // Update the index to reflect the new position of the item
                                                                            index--; // Decrement index to reflect the item's new position

                                                                            panelIndex = PanelIndex(
                                                                                id: panelIndex.id,
                                                                                panelIndex: panelIndex.panelIndex + 1,
                                                                                parentId: panelIndex.parentId);
                                                                            print('Updated index of text editor: $index');
                                                                          }
                                                                          print(
                                                                              'Current index of text editor: $index');
                                                                        });
                                                                      },
                                                                      child:
                                                                          Icon(
                                                                        TablerIcons
                                                                            .arrow_up,
                                                                        color: defaultPalette
                                                                            .black
                                                                            .withOpacity(0.8),
                                                                      ),
                                                                    );
                                                                  case 2:
                                                                    //MOVE TEXT DOWN
                                                                    return GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          if (index !=
                                                                              spreadSheetList[currentPageIndex].length - 1) {
                                                                            var item =
                                                                                spreadSheetList[currentPageIndex].removeAt(index);
                                                                            spreadSheetList[currentPageIndex].insert(index + 1,
                                                                                item);
                                                                            index++;
                                                                            print('index of texteditor DT: $index');
                                                                          }
                                                                        });
                                                                      },
                                                                      child:
                                                                          Icon(
                                                                        TablerIcons
                                                                            .arrow_down,
                                                                        color: defaultPalette
                                                                            .black
                                                                            .withOpacity(0.8),
                                                                      ),
                                                                    );
                                                                  case 3:
                                                                    //EXPORT TEXT
                                                                    return GestureDetector(
                                                                      onTap:
                                                                          () async {
                                                                        // Get the current text editor item
                                                                        var textEditorItem =
                                                                            spreadSheetList[currentPageIndex][index]
                                                                                as TextEditorItem;

                                                                        // Create a GlobalKey for the RepaintBoundary
                                                                        GlobalKey
                                                                            repaintBoundaryKey =
                                                                            GlobalKey();

                                                                        // Navigate to a new page with the PDF preview
                                                                        await Navigator
                                                                            .push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                Scaffold(
                                                                              appBar: AppBar(
                                                                                title: Text('PDF Preview'),
                                                                                actions: [
                                                                                  IconButton(
                                                                                    icon: Icon(Icons.image),
                                                                                    onPressed: () async {
                                                                                      RenderRepaintBoundary boundary = repaintBoundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
                                                                                      ui.Image image = await boundary.toImage(pixelRatio: 6.0);
                                                                                      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
                                                                                      Uint8List pngBytes = byteData!.buffer.asUint8List();

                                                                                      // Get the directory to save the image
                                                                                      final directory = await getApplicationDocumentsDirectory();
                                                                                      final imagePath = '${directory.path}/captured_image.png';
                                                                                      File(imagePath).writeAsBytesSync(pngBytes);

                                                                                      print('Image saved at: $imagePath');
                                                                                    },
                                                                                  ),
                                                                                  IconButton(
                                                                                    icon: Icon(Icons.print),
                                                                                    onPressed: () async {
                                                                                      RenderRepaintBoundary boundary = repaintBoundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
                                                                                      ui.Image image = await boundary.toImage(pixelRatio: 6.0);
                                                                                      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
                                                                                      Uint8List pngBytes = byteData!.buffer.asUint8List();

                                                                                      // Get the directory to save the image
                                                                                      final directory = await getApplicationDocumentsDirectory();
                                                                                      final imagePath = '${directory.path}/captured_image.png';
                                                                                      File(imagePath).writeAsBytesSync(pngBytes);

                                                                                      // Prepare the PDF document
                                                                                      final pdf = pw.Document();
                                                                                      final imageProvider = pw.MemoryImage(pngBytes);

                                                                                      pdf.addPage(
                                                                                        pw.Page(
                                                                                          pageFormat: documentPropertiesList[currentPageIndex].pageFormatController,
                                                                                          margin: pw.EdgeInsets.only(
                                                                                            top: double.parse(documentPropertiesList[currentPageIndex].marginTopController.text),
                                                                                            bottom: double.parse(documentPropertiesList[currentPageIndex].marginBottomController.text),
                                                                                            left: double.parse(documentPropertiesList[currentPageIndex].marginLeftController.text),
                                                                                            right: double.parse(documentPropertiesList[currentPageIndex].marginRightController.text),
                                                                                          ),
                                                                                          build: (pw.Context context) {
                                                                                            return pw.Center(
                                                                                              child: pw.Image(imageProvider),
                                                                                            ); // Center the image on the page
                                                                                          },
                                                                                        ),
                                                                                      );

                                                                                      // Save the PDF to a file
                                                                                      final pdfPath = '${directory.path}/document.pdf';
                                                                                      final file = File(pdfPath);
                                                                                      await file.writeAsBytes(await pdf.save());

                                                                                      print('PDF saved at: $pdfPath');
                                                                                    },
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              body: RepaintBoundary(
                                                                                key: repaintBoundaryKey,
                                                                                child: Container(
                                                                                  width: documentPropertiesList[currentPageIndex].pageFormatController == PdfPageFormat.a4
                                                                                      ? 793.7
                                                                                      : documentPropertiesList[currentPageIndex].pageFormatController == PdfPageFormat.a3
                                                                                          ? 812.8
                                                                                          : documentPropertiesList[currentPageIndex].pageFormatController == PdfPageFormat.a5
                                                                                              ? 559.4
                                                                                              : documentPropertiesList[currentPageIndex].pageFormatController == PdfPageFormat.a6
                                                                                                  ? 396.9
                                                                                                  : documentPropertiesList[currentPageIndex].pageFormatController == PdfPageFormat.letter
                                                                                                      ? 816
                                                                                                      : documentPropertiesList[currentPageIndex].pageFormatController == PdfPageFormat.legal
                                                                                                          ? 816
                                                                                                          : 1240, // Default width
                                                                                  height: documentPropertiesList[currentPageIndex].pageFormatController == PdfPageFormat.a4
                                                                                      ? 1122.5
                                                                                      : documentPropertiesList[currentPageIndex].pageFormatController == PdfPageFormat.a3
                                                                                          ? 1122.5
                                                                                          : documentPropertiesList[currentPageIndex].pageFormatController == PdfPageFormat.a5
                                                                                              ? 793.7
                                                                                              : documentPropertiesList[currentPageIndex].pageFormatController == PdfPageFormat.a6
                                                                                                  ? 559.4
                                                                                                  : documentPropertiesList[currentPageIndex].pageFormatController == PdfPageFormat.letter
                                                                                                      ? 1056
                                                                                                      : documentPropertiesList[currentPageIndex].pageFormatController == PdfPageFormat.legal
                                                                                                          ? 1344
                                                                                                          : 3508, // Default height
                                                                                  padding: EdgeInsets.only(
                                                                                    top: double.parse(documentPropertiesList[currentPageIndex].marginTopController.text),
                                                                                    bottom: double.parse(documentPropertiesList[currentPageIndex].marginBottomController.text),
                                                                                    left: double.parse(documentPropertiesList[currentPageIndex].marginLeftController.text),
                                                                                    right: double.parse(documentPropertiesList[currentPageIndex].marginRightController.text),
                                                                                  ),
                                                                                  margin: EdgeInsets.all(20),
                                                                                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                                                                                    BoxShadow(blurRadius: 10, color: Colors.black)
                                                                                  ]),
                                                                                  child: QuillEditor(
                                                                                    // Replace with your QuillEditor configurations
                                                                                    configurations: QuillEditorConfigurations(controller: textEditorItem.textEditorConfigurations.controller),
                                                                                    focusNode: FocusNode(),
                                                                                    scrollController: ScrollController(),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        );
                                                                      },
                                                                      child:
                                                                          Icon(
                                                                        TablerIcons
                                                                            .file_export,
                                                                        color: defaultPalette
                                                                            .black
                                                                            .withOpacity(0.8),
                                                                      ),
                                                                    );
                                                                  case 4:
                                                                    //clear text in text field
                                                                    return GestureDetector(
                                                                      onTap:
                                                                          () async {
                                                                        await showAdaptiveDialog(
                                                                          context:
                                                                              context,
                                                                          builder:
                                                                              (context) {
                                                                            return AlertDialog(
                                                                              title: Text('Confirm Clear'),
                                                                              content: Text('This will clear the text from current Text Field. Are you sure?'),
                                                                              actions: [
                                                                                TextButton(
                                                                                    onPressed: () {
                                                                                      setState(() {
                                                                                        (spreadSheetList[currentPageIndex][index] as SheetList).sheetList = [];
                                                                                      });
                                                                                      Navigator.pop(context);
                                                                                    },
                                                                                    child: Text('Yes')),
                                                                                TextButton(
                                                                                    onPressed: () {
                                                                                      Navigator.pop(context);
                                                                                    },
                                                                                    child: Text('No')),
                                                                              ],
                                                                            );
                                                                          },
                                                                        );
                                                                      },
                                                                      child:
                                                                          Icon(
                                                                        TablerIcons
                                                                            .x,
                                                                        color: defaultPalette
                                                                            .black
                                                                            .withOpacity(0.8),
                                                                      ),
                                                                    );
                                                                  case 5:
                                                                    //Delete Text Field
                                                                    return GestureDetector(
                                                                      onTap:
                                                                          () async {
                                                                        await showAdaptiveDialog(
                                                                          context:
                                                                              context,
                                                                          builder:
                                                                              (context) {
                                                                            return AlertDialog(
                                                                              title: Text('Confirm Delete'),
                                                                              content: Text('This will DELETE the current Text Field with its contents. Are you sure?'),
                                                                              actions: [
                                                                                TextButton(
                                                                                    onPressed: () {
                                                                                      setState(() {
                                                                                        spreadSheetList[currentPageIndex].removeAt(index);
                                                                                        panelIndex.id = '';
                                                                                        panelIndex.panelIndex = -1;
                                                                                      });
                                                                                      Navigator.pop(context);
                                                                                    },
                                                                                    child: Text('Yes')),
                                                                                TextButton(
                                                                                    onPressed: () {
                                                                                      Navigator.pop(context);
                                                                                    },
                                                                                    child: Text('No')),
                                                                              ],
                                                                            );
                                                                          },
                                                                        );
                                                                      },
                                                                      child:
                                                                          Icon(
                                                                        TablerIcons
                                                                            .trash,
                                                                        color: defaultPalette
                                                                            .black
                                                                            .withOpacity(0.8),
                                                                      ),
                                                                    );
                                                                  default:
                                                                    return Container();
                                                                }
                                                              }), // simplified item generation
                                                            )
                                                          : null,
                                                    ),
                                                  ),
                                                ),
                                              ), // Expandable menus and other widgets can stay the same
                                            ],
                                          );
                                        }
                                        return Container(
                                          key: ValueKey(Uuid().v4()),
                                          color: Colors.amberAccent,
                                          height: 12,
                                        );
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
                  left: -20,
                  child: ElevatedLayerButton(
                    // isTapped: false,
                    // toggleOnTap: true,
                    onClick: () {
                      var lm = Boxes.getLayouts()
                          .values
                          .toList()
                          .cast<LayoutModel>();
                      lm[keyIndex].docPropsList =
                          docPropToBox(documentPropertiesList);
                      lm[keyIndex].spreadSheetList =
                          spreadSheetToBox(spreadSheetList);
                      lm[keyIndex].save();
                      Navigator.pop(context);
                    },
                    buttonHeight: 60,
                    buttonWidth: 60,
                    borderRadius: BorderRadius.circular(100),
                    animationDuration: const Duration(milliseconds: 100),
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
                //
              ],
            ),
          ),
        ));
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

  Widget _buildListWidget(SheetList sheetList) {
    // sheetList = sheetList as SheetList;
    return GestureDetector(
      // key: ValueKey(sheetList.id),
      onTap: () {
        setState(() {
          panelIndex.parentId = sheetList.id;
        });
      },
      // buildlistw
      child: Container(
        width: sheetList.direction == Axis.vertical ? sWidth : sWidth,
        height: sheetList.direction == Axis.vertical
            ? (100 * sheetList.length).ceilToDouble()
            : 150,
        padding: EdgeInsets.all(0),
        margin: EdgeInsets.all(10),
        // buildlistw
        decoration: BoxDecoration(
            color: defaultPalette.primary,
            borderRadius: BorderRadius.circular(10)),
        // key: ValueKey(sheetList.id),
        child: ReorderableListView.builder(
          // header: Text('  ${sheetList.id}'),
          scrollDirection: sheetList.direction,
          // buildlistw
          proxyDecorator: (child, index, animation) {
            return Container(child: child);
          },
          itemBuilder: (context, index) {
            print('hello hello sprdListBuilding: ${sheetList[index]}');
            if (sheetList[index] is TextEditorItem) {
              var textEditorItem = sheetList[index] as TextEditorItem;
              return Stack(
                key: ValueKey(
                    textEditorItem.id), // Ensure each item has a unique key
                children: [
                  GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      var isTrue = false;
                      SheetItem? itemE;
                      if (panelIndex.id == textEditorItem.id) {
                        isTrue = true;
                      }
                      setState(() {
                        itemE =
                            _sheetItemIterator(textEditorItem.id, sheetList);

                        if (itemE != null) {
                          index = _sheetListIterator(itemE!.parentId, sheetList)
                              .indexOf(itemE!);
                          panelIndex = PanelIndex(
                              id: itemE!.id,
                              panelIndex: index,
                              parentId: sheetList.id);
                        } else {
                          panelIndex = PanelIndex(
                              id: textEditorItem.id,
                              panelIndex: index,
                              parentId: sheetList.id);
                        }

                        // index = temp ?? index;

                        if (hDividerPosition > 0.48) {
                          hDividerPosition = 0.4;
                        }
                      });
                      // Future.delayed(Duration.zero).then((_) {
                      //   textStylePageController.jumpToPage(panelIndex.panelIndex);
                      // });
                      Future.delayed(Durations.short1).then((h) {
                        if (!isTrue) {
                          textStyleTabControler.animateToPage(0,
                              curve: Curves.bounceIn,
                              duration: Durations.short1);
                          for (var i = 0; i < isTapped.length; i++) {
                            setState(() {
                              isTapped[i] = false;
                            });
                          }
                          setState(() {
                            isTapped[1] = true;
                          });
                        }
                      });

                      print('clicked');

                      print(panelIndex);
                    },
                    child: SingleChildScrollView(
                      child: Container(
                        width:
                            sheetList.direction == Axis.vertical ? null : 200,
                        padding: const EdgeInsets.only(
                            top: 4, bottom: 8, left: 20, right: 20),
                        margin: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: defaultPalette.primary,
                          border: Border.all(
                            width: panelIndex.id == textEditorItem.id ? 4 : 2,
                            color: panelIndex.id == textEditorItem.id
                                ? defaultPalette.tertiary
                                : defaultPalette.black,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'id : ${textEditorItem.id}',
                                style: TextStyle(fontSize: 10),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            QuillEditor(
                              configurations:
                                  textEditorItem.textEditorConfigurations,
                              focusNode: textEditorItem.focusNode,
                              scrollController: textEditorItem.scrollController,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  //contextMenu inside build function
                  AnimatedPositioned(
                    duration: Durations.medium3,
                    bottom: 0,
                    left: panelIndex.id == textEditorItem.id ? 0 : -50,
                    right: 0,
                    child: SingleChildScrollView(
                      child: Transform.flip(
                        flipX: true,
                        child: Transform.flip(
                          flipX: true,
                          child: panelIndex.id == textEditorItem.id
                              ? ExpandableMenu(
                                  backgroundColor:
                                      defaultPalette.white.withOpacity(1),
                                  iconColor: defaultPalette.tertiary,
                                  itemContainerColor: defaultPalette.secondary,
                                  width: 40.0,
                                  height: 40.0,
                                  items: List.generate(12, (intt) {
                                    switch (intt) {
                                      case 0:
                                        return PopupMenuButton<String>(
                                          iconSize: 20,
                                          padding: EdgeInsets.all(0),
                                          icon: Icon(
                                            TablerIcons.message_plus,
                                            color: defaultPalette.black
                                                .withOpacity(0.8),
                                          ),
                                          onSelected: (String value) {
                                            // Handle the selected option here
                                            switch (value) {
                                              case 'Above':
                                                setState(() {
                                                  if (sheetList.direction ==
                                                      Axis.vertical) {
                                                    var newItem = _addTextField(
                                                        shouldReturn: true);
                                                    sheetList.insert(
                                                        index, newItem);
                                                  } else {
                                                    setState(() {
                                                      var newId = Uuid().v4();
                                                      var item = spreadSheetList[
                                                              currentPageIndex]
                                                          .removeAt(index);
                                                      spreadSheetList[currentPageIndex].insert(
                                                          index,
                                                          SheetList(
                                                              direction: Axis
                                                                  .horizontal,
                                                              id: newId,
                                                              parentId:
                                                                  spreadSheetList[
                                                                          currentPageIndex]
                                                                      .id,
                                                              sheetList: [
                                                                _addTextField(
                                                                    shouldReturn:
                                                                        true),
                                                                item
                                                              ]));
                                                    });
                                                  }
                                                });
                                                break;
                                              case 'Below':
                                                setState(() {
                                                  var newItem = _addTextField(
                                                      shouldReturn: true);
                                                  sheetList.insert(
                                                      index + 1, newItem);
                                                });
                                                // Your logic for "Below"
                                                break;
                                              case 'Left':
                                                setState(() {
                                                  var newId = Uuid().v4();
                                                  var item = spreadSheetList[
                                                          currentPageIndex]
                                                      .removeAt(index);
                                                  spreadSheetList[
                                                          currentPageIndex]
                                                      .insert(
                                                          index,
                                                          SheetList(
                                                              direction: Axis
                                                                  .horizontal,
                                                              id: newId,
                                                              parentId:
                                                                  spreadSheetList[
                                                                          currentPageIndex]
                                                                      .id,
                                                              sheetList: [
                                                                _addTextField(
                                                                    shouldReturn:
                                                                        true),
                                                                item
                                                              ]));
                                                });
                                                break;
                                              case 'Right':
                                                // Your logic for "Right" inside listwidgetbuild
                                                setState(() {
                                                  if (sheetList.direction ==
                                                      Axis.vertical) {
                                                    var newId = Uuid().v4();
                                                    var item = spreadSheetList[
                                                            currentPageIndex]
                                                        .removeAt(index);
                                                    spreadSheetList[
                                                            currentPageIndex]
                                                        .insert(
                                                            index,
                                                            SheetList(
                                                                direction: Axis
                                                                    .horizontal,
                                                                id: newId,
                                                                parentId:
                                                                    spreadSheetList[
                                                                            currentPageIndex]
                                                                        .id,
                                                                sheetList: [
                                                                  _addTextField(
                                                                      shouldReturn:
                                                                          true),
                                                                  item
                                                                ]));
                                                  }
                                                });
                                                break;
                                            }
                                          },
                                          itemBuilder: (BuildContext context) {
                                            return [
                                              const PopupMenuItem<String>(
                                                value: 'Above',
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    Icon(TablerIcons
                                                        .arrow_bar_to_up),
                                                    Text('Above')
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem<String>(
                                                value: 'Below',
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    Icon(TablerIcons
                                                        .arrow_bar_to_down),
                                                    Text('Below')
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem<String>(
                                                value: 'Left',
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    Icon(TablerIcons
                                                        .arrow_bar_to_left),
                                                    Text('Left')
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem<String>(
                                                value: 'Right',
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    Icon(TablerIcons
                                                        .arrow_bar_to_right),
                                                    Text('Right')
                                                  ],
                                                ),
                                              ),
                                            ];
                                          },
                                        );

                                      case 1:
                                        //MOVE TEXT UP
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              if (index != 0) {
                                                var item = spreadSheetList[
                                                        currentPageIndex]
                                                    .removeAt(index);
                                                spreadSheetList[
                                                        currentPageIndex]
                                                    .insert(index - 1, item);

                                                // Update the index to reflect the new position of the item
                                                index--; // Decrement index to reflect the item's new position

                                                panelIndex = PanelIndex(
                                                    parentId:
                                                        panelIndex.parentId,
                                                    id: panelIndex.id,
                                                    panelIndex:
                                                        panelIndex.panelIndex +
                                                            1);
                                                print(
                                                    'Updated index of text editor: $index');
                                              }
                                              print(
                                                  'Current index of text editor: $index');
                                            });
                                          },
                                          child: Icon(
                                            TablerIcons.arrow_up,
                                            color: defaultPalette.black
                                                .withOpacity(0.8),
                                          ),
                                        );
                                      case 2:
                                        //MOVE TEXT DOWN
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              if (index !=
                                                  spreadSheetList[
                                                              currentPageIndex]
                                                          .length -
                                                      1) {
                                                var item = spreadSheetList[
                                                        currentPageIndex]
                                                    .removeAt(index);
                                                spreadSheetList[
                                                        currentPageIndex]
                                                    .insert(index + 1, item);
                                                index++;
                                                print(
                                                    'index of texteditor DT: $index');
                                              }
                                            });
                                          },
                                          child: Icon(
                                            TablerIcons.arrow_down,
                                            color: defaultPalette.black
                                                .withOpacity(0.8),
                                          ),
                                        );
                                      case 3:
                                        //EXPORT TEXT
                                        return GestureDetector(
                                          onTap: () async {
                                            // Get the current text editor item
                                            var textEditorItem =
                                                spreadSheetList[
                                                        currentPageIndex][index]
                                                    as TextEditorItem;

                                            // Create a GlobalKey for the RepaintBoundary
                                            GlobalKey repaintBoundaryKey =
                                                GlobalKey();

                                            // Navigate to a new page with the PDF preview
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Scaffold(
                                                  appBar: AppBar(
                                                    title: Text('PDF Preview'),
                                                    actions: [
                                                      IconButton(
                                                        icon: Icon(Icons.image),
                                                        onPressed: () async {
                                                          RenderRepaintBoundary
                                                              boundary =
                                                              repaintBoundaryKey
                                                                      .currentContext!
                                                                      .findRenderObject()
                                                                  as RenderRepaintBoundary;
                                                          ui.Image image =
                                                              await boundary
                                                                  .toImage(
                                                                      pixelRatio:
                                                                          6.0);
                                                          ByteData? byteData =
                                                              await image
                                                                  .toByteData(
                                                                      format: ui
                                                                          .ImageByteFormat
                                                                          .png);
                                                          Uint8List pngBytes =
                                                              byteData!.buffer
                                                                  .asUint8List();

                                                          // Get the directory to save the image
                                                          final directory =
                                                              await getApplicationDocumentsDirectory();
                                                          final imagePath =
                                                              '${directory.path}/captured_image.png';
                                                          File(imagePath)
                                                              .writeAsBytesSync(
                                                                  pngBytes);

                                                          print(
                                                              'Image saved at: $imagePath');
                                                        },
                                                      ),
                                                      IconButton(
                                                        icon: Icon(Icons.print),
                                                        onPressed: () async {
                                                          RenderRepaintBoundary
                                                              boundary =
                                                              repaintBoundaryKey
                                                                      .currentContext!
                                                                      .findRenderObject()
                                                                  as RenderRepaintBoundary;
                                                          ui.Image image =
                                                              await boundary
                                                                  .toImage(
                                                                      pixelRatio:
                                                                          6.0);
                                                          ByteData? byteData =
                                                              await image
                                                                  .toByteData(
                                                                      format: ui
                                                                          .ImageByteFormat
                                                                          .png);
                                                          Uint8List pngBytes =
                                                              byteData!.buffer
                                                                  .asUint8List();

                                                          // Get the directory to save the image
                                                          final directory =
                                                              await getApplicationDocumentsDirectory();
                                                          final imagePath =
                                                              '${directory.path}/captured_image.png';
                                                          File(imagePath)
                                                              .writeAsBytesSync(
                                                                  pngBytes);

                                                          // Prepare the PDF document
                                                          final pdf =
                                                              pw.Document();
                                                          final imageProvider =
                                                              pw.MemoryImage(
                                                                  pngBytes);

                                                          pdf.addPage(
                                                            pw.Page(
                                                              pageFormat: documentPropertiesList[
                                                                      currentPageIndex]
                                                                  .pageFormatController,
                                                              margin:
                                                                  pw.EdgeInsets
                                                                      .only(
                                                                top: double.parse(
                                                                    documentPropertiesList[
                                                                            currentPageIndex]
                                                                        .marginTopController
                                                                        .text),
                                                                bottom: double.parse(
                                                                    documentPropertiesList[
                                                                            currentPageIndex]
                                                                        .marginBottomController
                                                                        .text),
                                                                left: double.parse(
                                                                    documentPropertiesList[
                                                                            currentPageIndex]
                                                                        .marginLeftController
                                                                        .text),
                                                                right: double.parse(
                                                                    documentPropertiesList[
                                                                            currentPageIndex]
                                                                        .marginRightController
                                                                        .text),
                                                              ),
                                                              build: (pw.Context
                                                                  context) {
                                                                return pw
                                                                    .Center(
                                                                  child: pw.Image(
                                                                      imageProvider),
                                                                ); // Center the image on the page
                                                              },
                                                            ),
                                                          );

                                                          // Save the PDF to a file
                                                          final pdfPath =
                                                              '${directory.path}/document.pdf';
                                                          final file =
                                                              File(pdfPath);
                                                          await file
                                                              .writeAsBytes(
                                                                  await pdf
                                                                      .save());

                                                          print(
                                                              'PDF saved at: $pdfPath');
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  body: RepaintBoundary(
                                                    key: repaintBoundaryKey,
                                                    child: Container(
                                                      width: documentPropertiesList[
                                                                      currentPageIndex]
                                                                  .pageFormatController ==
                                                              PdfPageFormat.a4
                                                          ? 793.7
                                                          : documentPropertiesList[
                                                                          currentPageIndex]
                                                                      .pageFormatController ==
                                                                  PdfPageFormat
                                                                      .a3
                                                              ? 812.8
                                                              : documentPropertiesList[
                                                                              currentPageIndex]
                                                                          .pageFormatController ==
                                                                      PdfPageFormat
                                                                          .a5
                                                                  ? 559.4
                                                                  : documentPropertiesList[currentPageIndex]
                                                                              .pageFormatController ==
                                                                          PdfPageFormat
                                                                              .a6
                                                                      ? 396.9
                                                                      : documentPropertiesList[currentPageIndex].pageFormatController ==
                                                                              PdfPageFormat.letter
                                                                          ? 816
                                                                          : documentPropertiesList[currentPageIndex].pageFormatController == PdfPageFormat.legal
                                                                              ? 816
                                                                              : 1240, // Default width
                                                      height: documentPropertiesList[
                                                                      currentPageIndex]
                                                                  .pageFormatController ==
                                                              PdfPageFormat.a4
                                                          ? 1122.5
                                                          : documentPropertiesList[
                                                                          currentPageIndex]
                                                                      .pageFormatController ==
                                                                  PdfPageFormat
                                                                      .a3
                                                              ? 1122.5
                                                              : documentPropertiesList[
                                                                              currentPageIndex]
                                                                          .pageFormatController ==
                                                                      PdfPageFormat
                                                                          .a5
                                                                  ? 793.7
                                                                  : documentPropertiesList[currentPageIndex]
                                                                              .pageFormatController ==
                                                                          PdfPageFormat
                                                                              .a6
                                                                      ? 559.4
                                                                      : documentPropertiesList[currentPageIndex].pageFormatController ==
                                                                              PdfPageFormat.letter
                                                                          ? 1056
                                                                          : documentPropertiesList[currentPageIndex].pageFormatController == PdfPageFormat.legal
                                                                              ? 1344
                                                                              : 3508, // Default height
                                                      padding: EdgeInsets.only(
                                                        top: double.parse(
                                                            documentPropertiesList[
                                                                    currentPageIndex]
                                                                .marginTopController
                                                                .text),
                                                        bottom: double.parse(
                                                            documentPropertiesList[
                                                                    currentPageIndex]
                                                                .marginBottomController
                                                                .text),
                                                        left: double.parse(
                                                            documentPropertiesList[
                                                                    currentPageIndex]
                                                                .marginLeftController
                                                                .text),
                                                        right: double.parse(
                                                            documentPropertiesList[
                                                                    currentPageIndex]
                                                                .marginRightController
                                                                .text),
                                                      ),
                                                      margin:
                                                          EdgeInsets.all(20),
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          boxShadow: [
                                                            BoxShadow(
                                                                blurRadius: 10,
                                                                color: Colors
                                                                    .black)
                                                          ]),
                                                      child: QuillEditor(
                                                        // Replace with your QuillEditor configurations
                                                        configurations:
                                                            QuillEditorConfigurations(
                                                                controller: textEditorItem
                                                                    .textEditorConfigurations
                                                                    .controller),
                                                        focusNode: FocusNode(),
                                                        scrollController:
                                                            ScrollController(),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          child: Icon(
                                            TablerIcons.file_export,
                                            color: defaultPalette.black
                                                .withOpacity(0.8),
                                          ),
                                        );
                                      case 4:
                                        //clear text in text field
                                        return GestureDetector(
                                          onTap: () async {
                                            await showAdaptiveDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Text('Confirm Clear'),
                                                  content: Text(
                                                      'This will clear the text from current Text Field. Are you sure?'),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            textEditorItem
                                                                    .textEditorController
                                                                    .document =
                                                                Document();
                                                          });
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text('Yes')),
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text('No')),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          child: Icon(
                                            TablerIcons.x,
                                            color: defaultPalette.black
                                                .withOpacity(0.8),
                                          ),
                                        );
                                      case 5:
                                        //Delete Text Field
                                        return GestureDetector(
                                          onTap: () async {
                                            await showAdaptiveDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Text('Confirm Delete'),
                                                  content: Text(
                                                      'This will DELETE the current Text Field with its contents. Are you sure?'),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            spreadSheetList[
                                                                    currentPageIndex]
                                                                .removeAt(
                                                                    index);
                                                            panelIndex.id = '';
                                                            panelIndex
                                                                .panelIndex = -1;
                                                          });
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text('Yes')),
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text('No')),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          child: Icon(
                                            TablerIcons.trash,
                                            color: defaultPalette.black
                                                .withOpacity(0.8),
                                          ),
                                        );
                                      default:
                                        return Container();
                                    }
                                  }), // simplified item generation
                                )
                              : null,
                        ),
                      ),
                    ),
                  ), // Expandable menus and other widgets can stay the same
                ],
              );
              // buildlistw
            } else if (sheetList[index] is SheetList) {
              return Stack(key: ValueKey(sheetList[index].id), children: [
                Positioned(
                    // width: (sheetList[index] as SheetList).direction ==
                    //         Axis.vertical
                    //     ? sWidth
                    //     : null,
                    // height: (sheetList[index] as SheetList).direction ==
                    //         Axis.vertical
                    //     ? (100 * (sheetList[index] as SheetList).length)
                    //         .ceilToDouble()
                    //     : 100,
                    child: _buildListWidget(sheetList[index] as SheetList))
              ]);
            }
            return Container(
              key: ValueKey(Uuid().v4()),
              color: Colors.amberAccent,
              height: 12,
              // buildlistw
            );
          },
          itemCount: sheetList.length,
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              final item = sheetList.removeAt(oldIndex);
              // buildlistw
              sheetList.insert(newIndex, item);
            });
          },
        ),
      ),
    );
  }

  //
}

class WordSpacingAttribute extends Attribute<String?> {
  static const _key = 'wordSpacing';
  const WordSpacingAttribute(String? value)
      : super('wordSpacing', AttributeScope.inline, value);
}

class LineHeightAttribute extends Attribute<String?> {
  static const _key = 'lineHeight';
  const LineHeightAttribute(String? value)
      : super('lineHeight', AttributeScope.inline, value);
}

class LetterSpacingAttribute extends Attribute<String?> {
  static const _key = 'letterSpacing';
  const LetterSpacingAttribute(String? value)
      : super('letterSpacing', AttributeScope.inline, value);
}
