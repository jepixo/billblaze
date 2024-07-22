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
  // List<TextFieldController> textFieldControllers;

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
  });

  DocumentProperties toDocumentProperties() {
    return DocumentProperties(
        pageNumberController: TextEditingController()
          ..text = pageNumberController,
        marginAllController: TextEditingController()
          ..text = marginAllController,
        marginLeftController: TextEditingController()
          ..text = marginLeftController,
        marginRightController: TextEditingController()
          ..text = marginRightController,
        marginBottomController: TextEditingController()
          ..text = marginBottomController,
        marginTopController: TextEditingController()
          ..text = marginTopController,
        useIndividualMargins: useIndividualMargins,
        orientationController: orientationController == true
            ? pw.PageOrientation.portrait
            : pw.PageOrientation.landscape,
        pageFormatController: _getPageFormatFromString(pageFormatController));
  }

  PdfPageFormat _getPageFormatFromString(String format) {
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
  }) {
    return DocumentPropertiesBox(
      pageNumberController: pageNumberController ?? this.pageNumberController,
      marginAllController: marginAllController ?? this.marginAllController,
      marginLeftController: marginLeftController ?? this.marginLeftController,
      marginRightController:
          marginRightController ?? this.marginRightController,
      marginBottomController:
          marginBottomController ?? this.marginBottomController,
      marginTopController: marginTopController ?? this.marginTopController,
      orientationController:
          orientationController ?? this.orientationController,
      pageFormatController: pageFormatController ?? this.pageFormatController,
      useIndividualMargins: useIndividualMargins ?? this.useIndividualMargins,
    );
  }

  @override
  String toString() {
    return 'DocumentPropertiesBox(pageNumberController: $pageNumberController, marginAllController: $marginAllController, marginLeftController: $marginLeftController, marginRightController: $marginRightController, marginBottomController: $marginBottomController, marginTopController: $marginTopController, orientationController: $orientationController, pageFormatController: $pageFormatController, useIndividualMargins: $useIndividualMargins)';
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
        other.useIndividualMargins == useIndividualMargins;
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
        useIndividualMargins.hashCode;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pageNumberController': pageNumberController,
      'marginAllController': marginAllController,
      'marginLeftController': marginLeftController,
      'marginRightController': marginRightController,
      'marginBottomController': marginBottomController,
      'marginTopController': marginTopController,
      'orientationController': orientationController,
      'pageFormatController': pageFormatController,
      'useIndividualMargins': useIndividualMargins,
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
    );
  }

  String toJson() => json.encode(toMap());

  factory DocumentPropertiesBox.fromJson(String source) =>
      DocumentPropertiesBox.fromMap(
          json.decode(source) as Map<String, dynamic>);
}

class DocumentProperties extends HiveObject {
  TextEditingController pageNumberController;

  TextEditingController marginAllController;

  TextEditingController marginLeftController;

  TextEditingController marginRightController;

  TextEditingController marginBottomController;

  TextEditingController marginTopController;

  pw.PageOrientation orientationController;

  PdfPageFormat pageFormatController;

  bool useIndividualMargins;
  // List<TextFieldController> textFieldControllers;

  DocumentProperties({
    required this.pageNumberController,
    required this.marginAllController,
    required this.marginLeftController,
    required this.marginRightController,
    required this.marginBottomController,
    required this.marginTopController,
    required this.orientationController,
    required this.pageFormatController,
    this.useIndividualMargins = false,
  });

  DocumentProperties copyWith({
    TextEditingController? pageNumberController,
    TextEditingController? marginAllController,
    TextEditingController? marginLeftController,
    TextEditingController? marginRightController,
    TextEditingController? marginBottomController,
    TextEditingController? marginTopController,
    pw.PageOrientation? orientationController,
    PdfPageFormat? pageFormatController,
    bool? useIndividualMargins,
  }) {
    return DocumentProperties(
      pageNumberController: pageNumberController ?? this.pageNumberController,
      marginAllController: marginAllController ?? this.marginAllController,
      marginLeftController: marginLeftController ?? this.marginLeftController,
      marginRightController:
          marginRightController ?? this.marginRightController,
      marginBottomController:
          marginBottomController ?? this.marginBottomController,
      marginTopController: marginTopController ?? this.marginTopController,
      orientationController:
          orientationController ?? this.orientationController,
      pageFormatController: pageFormatController ?? this.pageFormatController,
      useIndividualMargins: useIndividualMargins ?? this.useIndividualMargins,
    );
  }

  @override
  String toString() {
    return 'DocumentProperties(pageNumberController: $pageNumberController, marginAllController: $marginAllController, marginLeftController: $marginLeftController, marginRightController: $marginRightController, marginBottomController: $marginBottomController, marginTopController: $marginTopController, orientationController: $orientationController, pageFormatController: $pageFormatController, useIndividualMargins: $useIndividualMargins)';
  }

  @override
  bool operator ==(covariant DocumentProperties other) {
    if (identical(this, other)) return true;

    return other.pageNumberController == pageNumberController &&
        other.marginAllController == marginAllController &&
        other.marginLeftController == marginLeftController &&
        other.marginRightController == marginRightController &&
        other.marginBottomController == marginBottomController &&
        other.marginTopController == marginTopController &&
        other.orientationController == orientationController &&
        other.pageFormatController == pageFormatController &&
        other.useIndividualMargins == useIndividualMargins;
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
        useIndividualMargins.hashCode;
  }

  DocumentPropertiesBox toDocPropBox() {
    return DocumentPropertiesBox(
        pageNumberController: pageNumberController.text,
        marginAllController: marginAllController.text,
        marginLeftController: marginLeftController.text,
        marginRightController: marginRightController.text,
        marginBottomController: marginBottomController.text,
        marginTopController: marginTopController.text,
        orientationController:
            orientationController == pw.PageOrientation.landscape
                ? false
                : true,
        pageFormatController: getPageFormatString(pageFormatController));
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
}
