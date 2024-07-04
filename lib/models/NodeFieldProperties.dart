// import 'package:billblaze/components/appflowy_board.dart';
// import 'package:uuid/uuid.dart';

// abstract class NodeFieldProperties extends AppFlowyGroupData {
//   NodeFieldProperties(String id, String name) : super(id: id, name: name);
// }

abstract class NodeFieldProperties {
  final String id;
  NodeFieldProperties(this.id);
}
