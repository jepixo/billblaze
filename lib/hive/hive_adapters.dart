import 'dart:typed_data';

import 'package:hive_ce/hive.dart';
import 'package:billblaze/models/bill/required_text.dart';
import 'package:billblaze/models/document_properties_model.dart';
import 'package:billblaze/models/index_path.dart';
import 'package:billblaze/models/input_block.dart';
import 'package:billblaze/models/layout_model.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_decoration.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_functions.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_item.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_list.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_table_lib/sheet_table.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_table_lib/sheet_table_cell.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_table_lib/sheet_table_column.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_table_lib/sheet_table_row.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_text.dart';
import 'package:billblaze/models/spread_sheet_lib/sized_item.dart';

@GenerateAdapters([
  AdapterSpec<DocumentPropertiesBox>(),
  AdapterSpec<SheetItem>(),
  AdapterSpec<SheetListBox>(),
  AdapterSpec<SheetTextBox>(),
  AdapterSpec<LayoutModel>(),
  AdapterSpec<SheetDecoration>(),
  AdapterSpec<SuperDecorationBox>(),
  AdapterSpec<ItemDecorationBox>(),
  AdapterSpec<SheetTableBox>(),
  AdapterSpec<SheetTableCellBox>(),
  AdapterSpec<SheetTableRowBox>(),
  AdapterSpec<SheetTableColumnBox>(),
  AdapterSpec<IndexPath>(),
  AdapterSpec<InputBlock>(),
  AdapterSpec<SheetFunction>(),
  AdapterSpec<UniStatFunction>(),
  AdapterSpec<RequiredText>(),
  AdapterSpec<ColumnFunction>(),
  AdapterSpec<InputBlockFunction>(),
  AdapterSpec<BiStatFunction>(),
  AdapterSpec<UidGeneratorFunction>(),
  AdapterSpec<SheetSizedItem>(),
])
part 'hive_adapters.g.dart';
