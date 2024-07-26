import 'dart:math';

import 'package:billblaze/models/layout_model.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_list.dart';
import 'package:hive/hive.dart';

class Boxes {
  static Box<LayoutModel> getLayouts() => Hive.box<LayoutModel>('layouts');

  static String getLayoutName() {
    int highestNumber = 0;
    final regex = RegExp(r'^Untitled-(\d+)$');
    final layouts = Boxes.getLayouts();

    for (var i = 0; i < layouts.length; i++) {
      final name = layouts.get(i)?.name ?? '';
      final match = regex.firstMatch(name);

      if (match != null) {
        final number = int.parse(match.group(1)!);
        highestNumber = max(highestNumber, number);
      }
    }

    return 'Untitled-${highestNumber + 1}';
  }
}
