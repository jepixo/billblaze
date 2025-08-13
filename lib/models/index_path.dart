// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:hive/hive.dart';

part 'index_path.g.dart';

@HiveType(typeId: 14)
class IndexPath {
  @HiveField(0)
  IndexPath? parent;
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

  IndexPath copyWith({
    int? index,
  }) {
    return IndexPath(
      index: index ?? this.index,
    );
  }
  Map<String, dynamic> toJson() => {
    'path': toList(), // e.g., [1, 2, 3]
  };

  // ✅ DESERIALIZATION: Rebuild tree from list
  factory IndexPath.fromJson(Map<String, dynamic> json) {
    print('in InputBlockFromMap: '+json['path'].toString());
    final List<dynamic> path = json['path'];
    IndexPath? result;
    for (final value in path) {
      result = IndexPath(index: value as int, parent: result);
    }
    return result!;
  }
}
