import 'package:billblaze/models/NodeFieldProperties.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class TextFieldController extends NodeFieldProperties {
  TextEditingController textController;
  TextEditingController hintController;
  FocusNode hintFocusController;
  TextEditingController hintSizeController;
  FocusNode hintSizeFocusController;
  TextEditingController colorController;
  FocusNode colorFocusController;
  FocusNode focusController;
  InputDecoration decoration;
  TextStyle style;
  TextAlign textAlign;

  TextFieldController({
    required this.textController,
    required this.hintController,
    required this.hintFocusController,
    required this.hintSizeController,
    required this.hintSizeFocusController,
    required this.colorController,
    required this.colorFocusController,
    required this.focusController,
    required this.decoration,
    required this.style,
    required this.textAlign,
    required Uuid id,
  }) : super(id.toString());

  // Method to dispose all controllers and focus nodes
  void dispose() {
    textController.dispose();
    hintController.dispose();
    hintFocusController.dispose();
    hintSizeController.dispose();
    hintSizeFocusController.dispose();
    colorController.dispose();
    colorFocusController.dispose();
    focusController.dispose();
  }
}
