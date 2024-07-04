import 'package:billblaze/models/NodeFieldProperties.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ListFieldController extends NodeFieldProperties {
  MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start;
  MainAxisSize mainAxisSize = MainAxisSize.max;
  CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center;
  TextDirection? textDirection;
  VerticalDirection verticalDirection = VerticalDirection.down;
  TextBaseline? textBaseline;
  Axis? axis;
  List<NodeFieldProperties> children = const <NodeFieldProperties>[];
  // Column self;
  ListFieldController({
    required Uuid id,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.textBaseline,
    this.children = const [],
    this.axis = Axis.vertical,
    // required this.self,
  }) : super(id.toString());
}
