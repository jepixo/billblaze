// ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'package:billblaze/components/spread_sheet_lib/drag_drop_state.dart';
import 'package:billblaze/components/spread_sheet_lib/drag_drop_state.dart';
import 'package:billblaze/components/spread_sheet_lib/sheet_list.dart';
import 'package:billblaze/components/spread_sheet_lib/text_editor_item.dart';
import 'package:billblaze/models/DocumentPropertiesModel.dart';
import 'package:billblaze/screens/layout_designer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

// import 'package:billblaze/components/spread_sheet_lib/text_editor_widget.dart';
var parentId = Uuid().v4();

abstract class SheetItem {
  final String id;
  String parentId;

  SheetItem({required this.id, required this.parentId});
}

// class SpreadSheet extends ConsumerStatefulWidget {
//   const SpreadSheet({super.key});

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() => _SpreadSheetState();
// }

// class _SpreadSheetState extends ConsumerState<SpreadSheet> {
//   @override
//   Widget build(BuildContext context) {
//     print("____BUILD SPREADSHEET____");
//     print(
//         'currentpageINdex in spreadsheet: ${ref.read(currentPageIndexProvider)}');
//     int currentPageIndex = ref.watch(currentPageIndexProvider);
//     SheetList spreadSheet = ref.watch(sheetListProviderFamily(
//         ref.watch(spreadSheetProvider.select((p) => p[currentPageIndex].id))));
//     print('spreadsheet in spreadsheet: ${spreadSheet}');
//     return Stack(
//       children: [
//         Flex(
//           direction: Axis.vertical,
//           children: _buildSpreadSheet(spreadSheet),
//         )
//       ],
//     );
//   }

//   _buildSpreadSheet(SheetList sheetList) {
//     List<Widget> widgetList = [];
//     print('___builDSPREADsheet started___');
//     print('sheelist id: ${sheetList.id}');
//     for (int index = 0; index < sheetList.length; index++) {
//       if (sheetList[index] is TextEditorItem) {
//         print('editorID in buildWidget: ${sheetList[index].id} ');
//         widgetList.add(TextEditorWidget(
//             isPhantom: false,
//             id: sheetList[index].id,
//             textEditorItem: sheetList[index] as TextEditorItem));
//       }
//     }
//     print('_______END BUILD SPREADSHEET__________');
//     return widgetList;
//   }
// }
