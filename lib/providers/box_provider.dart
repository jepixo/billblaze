import 'dart:math';

import 'package:billblaze/models/layout_model.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_list.dart';
import 'package:hive/hive.dart';

class Boxes {
  static Box<LayoutModel> getLayouts() => Hive.box<LayoutModel>('layouts');

  static String getLayoutName() {
    int highestNumber =
        -1; // Initialize to -1 to handle cases where no numbers are found.
    final regex = RegExp(r'^Untitled-(\d+)$');
    final layouts = Boxes.getLayouts();

    for (var layout in layouts.values.toList()) {
      final name = layout.name ?? '';
      final match = regex.firstMatch(name);

      if (match != null) {
        final number = int.parse(match.group(1)!);
        highestNumber = max(highestNumber, number);
      }
    }

    // Ensure that the next name is incremented correctly.
    return 'Untitled-${highestNumber + 1}';
  }
}
