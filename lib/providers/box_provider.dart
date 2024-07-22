import 'package:billblaze/models/layout_model.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_list.dart';
import 'package:hive/hive.dart';

class Boxes {
  static Box<SheetList> getSheetList() => Hive.box('sheetlist');
  static Box<LayoutModel> getLayouts() => Hive.box<LayoutModel>('layouts');
}
