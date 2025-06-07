// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:hive/hive.dart';

part 'index_path.g.dart';

@HiveType(typeId: 14)
class IndexPath {
  @HiveField(0)
  final IndexPath? parent;
  @HiveField(1)
  int index;

  IndexPath({required this.index, this.parent});

  List<int> toList() {
    final result = <int>[];
    IndexPath? current = this;
    while (current != null) {
      result.insert(0, current.index);
      current = current.parent;
    }
    return result;
  }

  @override
  String toString() => toList().join('/');
}
