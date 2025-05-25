import 'dart:math';

import 'package:billblaze/models/layout_model.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_decoration.dart'; 
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class Boxes {
  static Box<LayoutModel> getLayouts() => Hive.box<LayoutModel>('layouts');
  static Box<SheetDecoration> getDecorations() => Hive.box<SheetDecoration>('decorations');

  static String getLayoutName() {
    int highestNumber =
        -1; // Initialize to -1 to handle cases where no numbers are found.
    final regex = RegExp(r'^Untitled-(\d+)$');
    final layouts = Boxes.getLayouts();

    for (var layout in layouts.values.toList()) {
      final name = layout.name;
      final match = regex.firstMatch(name);

      if (match != null) {
        final number = int.parse(match.group(1)!);
        highestNumber = max(highestNumber, number);
      }
    }

    // Ensure that the next name is incremented correctly.
    return 'Untitled-${highestNumber + 1}';
  }

  static Future<void> saveSuperDecoration(SuperDecorationBox newDecoration) async {
  Box<SheetDecoration> box = Boxes.getDecorations();

  // If id exists, overwrite; otherwise, insert as new (same method)
  await box.put(newDecoration.id, newDecoration);
}

static SuperDecorationBox getSuperDecoration(String id){
  Box<SheetDecoration> decorations = Boxes.getDecorations();

  return decorations.values.firstWhere(
    (decoration) {
      // print('getSuperDecoration: '+decoration.id+' '+decoration.runtimeType.toString());
      return decoration.id == id && decoration is SuperDecorationBox;
      },
    orElse: () {
      String newDecoId = 'dSPR-${ const Uuid().v4()}';
      // print('newonehas to be added in the decoBox unfort: '+ newDecoId);
      SuperDecoration newSuperDecoration = SuperDecoration(id: newDecoId);
      print('doesnt exist '+ id);
      throw Error();},
  ) as SuperDecorationBox;
}


}
