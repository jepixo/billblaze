// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:hive/hive.dart';

import 'package:billblaze/models/index_path.dart';

part 'required_text.g.dart';

@HiveType(typeId: 18)
class RequiredText {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final int sheetTextType;
  @HiveField(2)
  IndexPath indexPath;
  @HiveField(3)
  final bool isOptional;
  
  RequiredText({
    required this.name,
    required this.sheetTextType,
    required this.indexPath,
    required this.isOptional,
  });
  

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'sheetTextType': sheetTextType,
      'indexPath': indexPath.toJson(),
      'isOptional': isOptional,
    };
  }

  factory RequiredText.fromJson(Map<String, dynamic> map) {
    return RequiredText(
      name: map['name'] as String,
      sheetTextType: map['sheetTextType'] as int,
      indexPath: IndexPath.fromJson(map['indexPath'] as Map<String,dynamic>),
      isOptional: map['isOptional'] as bool,
    );
  }

}
