// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';

part 'document_properties_model.g.dart';

@HiveType(typeId: 0)
class DocumentPropertiesBox extends HiveObject {
  @HiveField(0)
  String pageNumberController;
  @HiveField(1)
  String marginAllController;
  @HiveField(2)
  String marginLeftController;
  @HiveField(3)
  String marginRightController;
  @HiveField(4)
  String marginBottomController;
  @HiveField(5)
  String marginTopController;
  @HiveField(6)
  bool orientationController;
  @HiveField(7)
  String pageFormatController;
  @HiveField(8)
  bool useIndividualMargins;
  @HiveField(9)
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
      pageFormatController: _getPageFormatFromString(pageFormatController),
      pageColor: _getColorFromHex(pageColor),
    );
  }

  PdfPageFormat _getPageFormatFromString(String format) {
    switch (format) {
      case 'A4': return PdfPageFormat.a4;
      case 'A3': return PdfPageFormat.a3;
      case 'A5': return PdfPageFormat.a5;
      case 'A6': return PdfPageFormat.a6;
      case 'Letter': return PdfPageFormat.letter;
      case 'Legal': return PdfPageFormat.legal;
      case 'Standard': return PdfPageFormat.standard;
      case 'Roll 57': return PdfPageFormat.roll57;
      case 'Roll 80': return PdfPageFormat.roll80;
      default: return PdfPageFormat.a4;
    }
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
    String? pageFormatController,
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
      pageFormatController: map['pageFormatController'] as String,
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
      pageFormatController: _getStringFromPageFormat(pageFormatController),
      pageColor: pageColor.value.toRadixString(16).padLeft(8, '0').substring(2),
    );
  }

  String _getStringFromPageFormat(PdfPageFormat format) {
    if (format == PdfPageFormat.a4) return 'A4';
    if (format == PdfPageFormat.a3) return 'A3';
    if (format == PdfPageFormat.a5) return 'A5';
    if (format == PdfPageFormat.a6) return 'A6';
    if (format == PdfPageFormat.letter) return 'Letter';
    if (format == PdfPageFormat.legal) return 'Legal';
    if (format == PdfPageFormat.standard) return 'Standard';
    if (format == PdfPageFormat.roll57) return 'Roll 57';
    if (format == PdfPageFormat.roll80) return 'Roll 80';
    return 'A4';
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
