// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:billblaze/models/DocumentPropertiesModel.dart';
import 'package:billblaze/models/NodeFieldProperties.dart';

class PageWidgetNode extends NodeFieldProperties {
  DocumentProperties documentProperties;
  List<NodeFieldProperties> nodeFieldProperties;
  PageWidgetNode({
    required Uuid id,
    required this.documentProperties,
    required this.nodeFieldProperties,
  }) : super(id.toString());
}

class LayoutWidgetNode {
  List<PageWidgetNode> page = [];
  LayoutWidgetNode({
    this.page = const [],
  });
  // : this.page = [
  //   PageWidgetNode(id: Uuid(),
  //   documentProperties: DocumentProperties(
  //     pageNumberController: TextEditingController(),
  //     marginAllController: TextEditingController(),
  //     marginLeftController: TextEditingController(),
  //     marginRightController: TextEditingController(),
  //     marginBottomController: TextEditingController(),
  //     marginTopController: TextEditingController(),
  //     orientationController: TextEditingController(),
  //     pageFormatController: TextEditingController(), textFieldControllers: []),

  //   // nodeFieldProperties:
  //   )]
}
