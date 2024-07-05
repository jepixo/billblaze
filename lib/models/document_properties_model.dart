// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:billblaze/models/TextFieldControllerModel.dart';

class DocumentProperties {
  TextEditingController pageNumberController;
  TextEditingController marginAllController;
  TextEditingController marginLeftController;
  TextEditingController marginRightController;
  TextEditingController marginBottomController;
  TextEditingController marginTopController;
  TextEditingController orientationController;
  TextEditingController pageFormatController;
  List<TextFieldController> textFieldControllers;

  DocumentProperties({
    required this.pageNumberController,
    required this.marginAllController,
    required this.marginLeftController,
    required this.marginRightController,
    required this.marginBottomController,
    required this.marginTopController,
    required this.orientationController,
    required this.pageFormatController,
    required this.textFieldControllers,
  });
}

class DocumentProperties2 {
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

  DocumentProperties2({
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

  DocumentProperties2 copyWith({
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
    return DocumentProperties2(
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
    return 'DocumentProperties2(pageNumberController: $pageNumberController, marginAllController: $marginAllController, marginLeftController: $marginLeftController, marginRightController: $marginRightController, marginBottomController: $marginBottomController, marginTopController: $marginTopController, orientationController: $orientationController, pageFormatController: $pageFormatController, useIndividualMargins: $useIndividualMargins)';
  }

  @override
  bool operator ==(covariant DocumentProperties2 other) {
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
}
