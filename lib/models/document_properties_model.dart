// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw; 

// part  'document_properties_model.g.dart';

// @HiveType(typeId: 0)
class DocumentPropertiesBox extends HiveObject {
  // @HiveField(0)
  String pageNumberController;
  // @HiveField(1)
  String marginAllController;
  // @HiveField(2)
  String marginLeftController;
  // @HiveField(3)
  String marginRightController;
  // @HiveField(4)
  String marginBottomController;
  // @HiveField(5)
  String marginTopController;
  // @HiveField(6)
  bool orientationController;
  // @HiveField(7)
  Map<String, double> pageFormatController;
  // @HiveField(8)
  bool useIndividualMargins;
  // @HiveField(9)
  String pageColor;

  DocumentPropertiesBox({
    required this.pageNumberController,
    required this.marginAllController,
    required this.marginLeftController,
    required this.marginRightController,
    required this.marginBottomController,
    required this.marginTopController,
    required this.orientationController,
    required this.pageFormatController,
    this.useIndividualMargins = false,
    this.pageColor = "FFFFFF",
  });

  DocumentProperties toDocumentProperties() {
    return DocumentProperties(
      pageNumberController: TextEditingController()..text = pageNumberController,
      marginAllController: TextEditingController()..text = marginAllController,
      marginLeftController: TextEditingController()..text = marginLeftController,
      marginRightController: TextEditingController()..text = marginRightController,
      marginBottomController: TextEditingController()..text = marginBottomController,
      marginTopController: TextEditingController()..text = marginTopController,
      useIndividualMargins: useIndividualMargins,
      orientationController: orientationController == true
          ? pw.PageOrientation.portrait
          : pw.PageOrientation.landscape,
      pageFormatController: _getPageFormatFromMap(pageFormatController),
      pageColor: _getColorFromHex(pageColor),
    );
  }

  PdfPageFormat _getPageFormatFromMap(Map<String, dynamic> format) {
    return PdfPageFormat(
      double.parse(format['width'].toString()),
      double.parse(format['height'].toString()),
    );
  }

  Color _getColorFromHex(String hexCode) {
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  DocumentPropertiesBox copyWith({
    String? pageNumberController,
    String? marginAllController,
    String? marginLeftController,
    String? marginRightController,
    String? marginBottomController,
    String? marginTopController,
    bool? orientationController,
    Map<String, double>? pageFormatController,
    bool? useIndividualMargins,
    String? pageColor,
  }) {
    return DocumentPropertiesBox(
      pageNumberController: pageNumberController ?? this.pageNumberController,
      marginAllController: marginAllController ?? this.marginAllController,
      marginLeftController: marginLeftController ?? this.marginLeftController,
      marginRightController: marginRightController ?? this.marginRightController,
      marginBottomController: marginBottomController ?? this.marginBottomController,
      marginTopController: marginTopController ?? this.marginTopController,
      orientationController: orientationController ?? this.orientationController,
      pageFormatController: pageFormatController ?? this.pageFormatController,
      useIndividualMargins: useIndividualMargins ?? this.useIndividualMargins,
      pageColor: pageColor ?? this.pageColor,
    );
  }

  @override
  String toString() {
    return 'DocumentPropertiesBox(pageNumberController: $pageNumberController, marginAllController: $marginAllController, marginLeftController: $marginLeftController, marginRightController: $marginRightController, marginBottomController: $marginBottomController, marginTopController: $marginTopController, orientationController: $orientationController, pageFormatController: $pageFormatController, useIndividualMargins: $useIndividualMargins, pageColor: $pageColor)';
  }

  @override
  bool operator ==(covariant DocumentPropertiesBox other) {
    if (identical(this, other)) return true;
    return other.pageNumberController == pageNumberController &&
        other.marginAllController == marginAllController &&
        other.marginLeftController == marginLeftController &&
        other.marginRightController == marginRightController &&
        other.marginBottomController == marginBottomController &&
        other.marginTopController == marginTopController &&
        other.orientationController == orientationController &&
        other.pageFormatController == pageFormatController &&
        other.useIndividualMargins == useIndividualMargins &&
        other.pageColor == pageColor;
  }

  @override
  int get hashCode {
    return pageNumberController.hashCode ^
        marginAllController.hashCode ^
        marginLeftController.hashCode ^
        marginRightController.hashCode ^
        marginBottomController.hashCode ^
        marginTopController.hashCode ^
        orientationController.hashCode ^
        pageFormatController.hashCode ^
        useIndividualMargins.hashCode ^
        pageColor.hashCode;
  }

  Map<String, dynamic> toMap() {
    return {
      'pageNumberController': pageNumberController,
      'marginAllController': marginAllController,
      'marginLeftController': marginLeftController,
      'marginRightController': marginRightController,
      'marginBottomController': marginBottomController,
      'marginTopController': marginTopController,
      'orientationController': orientationController,
      'pageFormatController': pageFormatController,
      'useIndividualMargins': useIndividualMargins,
      'pageColor': pageColor,
    };
  }

  factory DocumentPropertiesBox.fromMap(Map<String, dynamic> map) {
    return DocumentPropertiesBox(
      pageNumberController: map['pageNumberController'] as String,
      marginAllController: map['marginAllController'] as String,
      marginLeftController: map['marginLeftController'] as String,
      marginRightController: map['marginRightController'] as String,
      marginBottomController: map['marginBottomController'] as String,
      marginTopController: map['marginTopController'] as String,
      orientationController: map['orientationController'] as bool,
      pageFormatController: map['pageFormatController'] as Map<String, double>,
      useIndividualMargins: map['useIndividualMargins'] as bool,
      pageColor: map['pageColor'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory DocumentPropertiesBox.fromJson(String source) => DocumentPropertiesBox.fromMap(json.decode(source));
}




class DocumentProperties {
   TextEditingController pageNumberController;
   TextEditingController marginAllController;
   TextEditingController marginLeftController;
   TextEditingController marginRightController;
   TextEditingController marginBottomController;
   TextEditingController marginTopController;
   bool useIndividualMargins;
   pw.PageOrientation orientationController;
   PdfPageFormat pageFormatController;
   Color pageColor;

  DocumentProperties({
    required this.pageNumberController,
    required this.marginAllController,
    required this.marginLeftController,
    required this.marginRightController,
    required this.marginBottomController,
    required this.marginTopController,
    this.useIndividualMargins = false,
    this.orientationController = pw.PageOrientation.portrait,
    required this.pageFormatController,
    this.pageColor = const Color(0xFFFFFFFF),
  });

  DocumentPropertiesBox toDocPropBox() {
    return DocumentPropertiesBox(
      pageNumberController: pageNumberController.text,
      marginAllController: marginAllController.text,
      marginLeftController: marginLeftController.text,
      marginRightController: marginRightController.text,
      marginBottomController: marginBottomController.text,
      marginTopController: marginTopController.text,
      useIndividualMargins: useIndividualMargins,
      orientationController: orientationController == pw.PageOrientation.portrait,
      pageFormatController: _getMapFromPageFormat(pageFormatController),
      pageColor: pageColor.value.toRadixString(16).padLeft(8, '0').substring(2),
    );
  }

  Map<String, double> _getMapFromPageFormat(PdfPageFormat format) {
    return {
      'width': format.width,
      'height': format.height,
    };
  }

  DocumentProperties copyWith({
    TextEditingController? pageNumberController,
    TextEditingController? marginAllController,
    TextEditingController? marginLeftController,
    TextEditingController? marginRightController,
    TextEditingController? marginBottomController,
    TextEditingController? marginTopController,
    bool? useIndividualMargins,
    pw.PageOrientation? orientationController,
    PdfPageFormat? pageFormatController,
    Color? pageColor,
  }) {
    return DocumentProperties(
      pageNumberController: pageNumberController ?? this.pageNumberController,
      marginAllController: marginAllController ?? this.marginAllController,
      marginLeftController: marginLeftController ?? this.marginLeftController,
      marginRightController: marginRightController ?? this.marginRightController,
      marginBottomController: marginBottomController ?? this.marginBottomController,
      marginTopController: marginTopController ?? this.marginTopController,
      useIndividualMargins: useIndividualMargins ?? this.useIndividualMargins,
      orientationController: orientationController ?? this.orientationController,
      pageFormatController: pageFormatController ?? this.pageFormatController,
      pageColor: pageColor ?? this.pageColor,
    );
  }

  @override
  String toString() {
    return 'DocumentProperties(pageNumberController: ${pageNumberController.text}, marginAllController: ${marginAllController.text}, marginLeftController: ${marginLeftController.text}, marginRightController: ${marginRightController.text}, marginBottomController: ${marginBottomController.text}, marginTopController: ${marginTopController.text}, useIndividualMargins: $useIndividualMargins, orientationController: $orientationController, pageFormatController: $pageFormatController, pageColor: $pageColor)';
  }
}
