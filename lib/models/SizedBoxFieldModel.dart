import 'package:billblaze/models/NodeFieldProperties.dart';
import 'package:uuid/uuid.dart';

class SizedBoxFieldController extends NodeFieldProperties {
  double width;
  double height;
  SizedBoxFieldController({
    required Uuid id,
    this.width = 10,
    this.height = 10,
  }) : super(id.toString());
}
