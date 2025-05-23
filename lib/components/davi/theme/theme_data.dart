import 'cell_theme_data.dart';
import 'edge_theme_data.dart';
import 'header_cell_theme_data.dart';
import 'header_theme_data.dart';
import 'row_theme_data.dart';
import 'scrollbar_theme_data.dart';
import 'summary_theme_data.dart';
import 'package:flutter/material.dart';

//TODO handle negative values
/// The [Davi] theme.
/// Defines the configuration of the overall visual [DaviThemeData] for a widget subtree within the app.
class DaviThemeData {
  /// Builds a theme data.
  const DaviThemeData(
      {this.columnDividerFillHeight =
          DaviThemeDataDefaults.columnDividerFillHeight,
      this.columnDividerThickness =
          DaviThemeDataDefaults.columnDividerThickness,
      this.columnDividerColor = DaviThemeDataDefaults.columnDividerColor,
      this.decoration = DaviThemeDataDefaults.tableDecoration,
      this.row = const RowThemeData(),
      this.edge = const EdgeThemeData(),
      this.cell = const CellThemeData(),
      this.header = const HeaderThemeData(),
      this.summary = const SummaryThemeData(),
      this.headerCell = const HeaderCellThemeData(),
      this.scrollbar = const TableScrollbarThemeData()});

  final bool columnDividerFillHeight;
  final double columnDividerThickness;
  final Color? columnDividerColor;
  final BoxDecoration? decoration;
  final CellThemeData cell;
  final HeaderThemeData header;
  final SummaryThemeData summary;
  final HeaderCellThemeData headerCell;
  final EdgeThemeData edge;
  final RowThemeData row;
  final TableScrollbarThemeData scrollbar;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DaviThemeData &&
          runtimeType == other.runtimeType &&
          columnDividerFillHeight == other.columnDividerFillHeight &&
          columnDividerThickness == other.columnDividerThickness &&
          columnDividerColor == other.columnDividerColor &&
          decoration == other.decoration &&
          cell == other.cell &&
          edge == other.edge &&
          header == other.header &&
          summary == other.summary &&
          headerCell == other.headerCell &&
          row == other.row &&
          scrollbar == other.scrollbar;

  @override
  int get hashCode =>
      columnDividerThickness.hashCode ^
      columnDividerFillHeight.hashCode ^
      columnDividerColor.hashCode ^
      decoration.hashCode ^
      edge.hashCode ^
      cell.hashCode ^
      header.hashCode ^
      summary.hashCode ^
      headerCell.hashCode ^
      row.hashCode ^
      scrollbar.hashCode;
}

class DaviThemeDataDefaults {
  static const bool columnDividerFillHeight = true;
  static const double columnDividerThickness = 1;
  static const BoxDecoration tableDecoration = BoxDecoration(
      border: Border(
          bottom: BorderSide(color: Colors.grey),
          top: BorderSide(color: Colors.grey),
          left: BorderSide(color: Colors.grey),
          right: BorderSide(color: Colors.grey)));
  static const BoxDecoration topRightCornerDecoration = BoxDecoration(
      color: Color(0xFFE0E0E0),
      border: Border(
          left: BorderSide(color: Colors.grey),
          bottom: BorderSide(color: Colors.grey)));

  static const Color columnDividerColor = Colors.grey;
}
