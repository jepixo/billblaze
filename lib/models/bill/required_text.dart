import 'package:billblaze/models/index_path.dart';
import 'package:hive/hive.dart';

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
  
}
