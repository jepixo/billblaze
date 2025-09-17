import 'dart:math';

import 'package:billblaze/models/layout_model.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_decoration.dart';
import 'package:billblaze/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';

class Boxes {
  static Box<LayoutModel> getLayouts(WidgetRef ref) => Hive.box<LayoutModel>(ref.read(authPr).currentUser?.email??'layouts');
  static Box<String> getFolderPaths() => Hive.box<String>('folderPaths');
  static void setFolderPath(WidgetRef ref, String path) => getFolderPaths().put(ref.read(authPr).currentUser?.email??'default', path);
  static String getLayoutName(WidgetRef ref) {
    int highestNumber = -1; 
    final regex = RegExp(r'^Untitled-(\d+)\.bbc$'); // match Untitled-N.bbc
    final layouts = Boxes.getLayouts(ref);

    for (var layout in layouts.values.toList()) {
      final name = layout.name;
      final match = regex.firstMatch(name);

      if (match != null) {
        final number = int.parse(match.group(1)!);
        highestNumber = max(highestNumber, number);
      }
    }

    // Always return with .bbc extension
    return 'Untitled-${highestNumber + 1}.bbc';
  }


  static String getBillName(WidgetRef ref) {
    int highestNumber =
        -1; // Initialize to -1 to handle cases where no numbers are found.
    final regex = RegExp(r'^Bill-(\d+)\.bbc$');
    final layouts = Boxes.getLayouts(ref);

    for (var layout in layouts.values.toList()) {
      final name = layout.name;
      final match = regex.firstMatch(name);

      if (match != null) {
        final number = int.parse(match.group(1)!);
        highestNumber = max(highestNumber, number);
      }
    }

    // Ensure that the next name is incremented correctly.
    return 'Bill-${highestNumber + 1}.bbc';
  }

//   static Future<void> saveSuperDecoration(SuperDecorationBox newDecoration) async {
//   Box<SheetDecoration> box = Boxes.getDecorations();

//   // If id exists, overwrite; otherwise, insert as new (same method)
//   await box.put(newDecoration.id, newDecoration);
// }

// static SuperDecorationBox getSuperDecoration(String id){
//   Box<SheetDecoration> decorations = Boxes.getDecorations();

//   return decorations.values.firstWhere(
//     (decoration) {
//       // print('getSuperDecoration: '+decoration.id+' '+decoration.runtimeType.toString());
//       return decoration.id == id && decoration is SuperDecorationBox;
//       },
//     orElse: () {
//       String newDecoId = 'dSPR-${ const Uuid().v4()}';
//       // print('newonehas to be added in the decoBox unfort: '+ newDecoId);
//       SuperDecoration newSuperDecoration = SuperDecoration(id: newDecoId);
//    print('doesnt exist '+ id);
//       throw Error();},
//   ) as SuperDecorationBox;
// }


}
