import 'package:flutter/material.dart';

/// The [Davi] scroll theme.
/// Defines the configuration of the overall visual [TableScrollbarThemeData] for a widget subtree within the app.
class TableScrollbarThemeData {
  /// Builds a theme data.
  const TableScrollbarThemeData(
      {this.radius,
      this.margin = TableScrollbarThemeDataDefaults.margin,
      this.borderThickness = TableScrollbarThemeDataDefaults.borderThickness,
      this.thickness = TableScrollbarThemeDataDefaults.thickness,
      this.verticalBorderColor =
          TableScrollbarThemeDataDefaults.verticalBorderColor,
      this.verticalColor = TableScrollbarThemeDataDefaults.verticalColor,
      this.pinnedHorizontalBorderColor =
          TableScrollbarThemeDataDefaults.pinnedHorizontalBorderColor,
      this.pinnedHorizontalColor =
          TableScrollbarThemeDataDefaults.pinnedHorizontalColor,
      this.unpinnedHorizontalBorderColor =
          TableScrollbarThemeDataDefaults.unpinnedHorizontalBorderColor,
      this.unpinnedHorizontalColor =
          TableScrollbarThemeDataDefaults.unpinnedHorizontalColor,
      this.thumbColor = TableScrollbarThemeDataDefaults.thumbColor,
      this.horizontalOnlyWhenNeeded =
          TableScrollbarThemeDataDefaults.horizontalOnlyWhenNeeded,
      this.verticalOnlyWhenNeeded =
          TableScrollbarThemeDataDefaults.verticalOnlyWhenNeeded,
      this.columnDividerColor =
          TableScrollbarThemeDataDefaults.columnDividerColor});

  final Radius? radius;
  final double margin;
  final double thickness;
  final double borderThickness;
  final Color verticalBorderColor;
  final Color verticalColor;
  final Color pinnedHorizontalBorderColor;
  final Color pinnedHorizontalColor;
  final Color unpinnedHorizontalBorderColor;
  final Color unpinnedHorizontalColor;
  final Color thumbColor;

  /// Display the horizontal scrollbar only when needed.
  final bool horizontalOnlyWhenNeeded;

  /// Display the vertical scrollbar only when needed.
  final bool verticalOnlyWhenNeeded;

  /// The pinned column divider color.
  final Color? columnDividerColor;

  /// Creates a copy of this theme but with the given fields replaced with
  /// the new values.
  TableScrollbarThemeData copyWith({
    Radius? radius,
    double? margin,
    double? thickness,
    double? borderThickness,
    Color? verticalBorderColor,
    Color? verticalColor,
    Color? pinnedHorizontalBorderColor,
    Color? pinnedHorizontalColor,
    Color? unpinnedHorizontalBorderColor,
    Color? unpinnedHorizontalColor,
    Color? thumbColor,
    bool? horizontalOnlyWhenNeeded,
    bool? verticalOnlyWhenNeeded,
    Color? columnDividerColor,
  }) {
    return TableScrollbarThemeData(
        radius: radius ?? this.radius,
        margin: margin ?? this.margin,
        thickness: thickness ?? this.thickness,
        borderThickness: borderThickness ?? this.borderThickness,
        verticalBorderColor: verticalBorderColor ?? this.verticalBorderColor,
        verticalColor: verticalColor ?? this.verticalColor,
        pinnedHorizontalBorderColor:
            pinnedHorizontalBorderColor ?? this.pinnedHorizontalBorderColor,
        pinnedHorizontalColor:
            pinnedHorizontalColor ?? this.pinnedHorizontalColor,
        unpinnedHorizontalBorderColor:
            unpinnedHorizontalBorderColor ?? this.unpinnedHorizontalBorderColor,
        unpinnedHorizontalColor:
            unpinnedHorizontalColor ?? this.unpinnedHorizontalColor,
        thumbColor: thumbColor ?? this.thumbColor,
        horizontalOnlyWhenNeeded:
            horizontalOnlyWhenNeeded ?? this.horizontalOnlyWhenNeeded,
        verticalOnlyWhenNeeded:
            verticalOnlyWhenNeeded ?? this.verticalOnlyWhenNeeded,
        columnDividerColor: columnDividerColor ?? this.columnDividerColor);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TableScrollbarThemeData &&
          runtimeType == other.runtimeType &&
          radius == other.radius &&
          margin == other.margin &&
          thickness == other.thickness &&
          borderThickness == other.borderThickness &&
          verticalBorderColor == other.verticalBorderColor &&
          verticalColor == other.verticalColor &&
          pinnedHorizontalBorderColor == other.pinnedHorizontalBorderColor &&
          pinnedHorizontalColor == other.pinnedHorizontalColor &&
          unpinnedHorizontalBorderColor ==
              other.unpinnedHorizontalBorderColor &&
          unpinnedHorizontalColor == other.unpinnedHorizontalColor &&
          thumbColor == other.thumbColor &&
          horizontalOnlyWhenNeeded == other.horizontalOnlyWhenNeeded &&
          verticalOnlyWhenNeeded == other.verticalOnlyWhenNeeded &&
          columnDividerColor == other.columnDividerColor;

  @override
  int get hashCode =>
      radius.hashCode ^
      margin.hashCode ^
      thickness.hashCode ^
      borderThickness.hashCode ^
      verticalBorderColor.hashCode ^
      verticalColor.hashCode ^
      pinnedHorizontalBorderColor.hashCode ^
      pinnedHorizontalColor.hashCode ^
      unpinnedHorizontalBorderColor.hashCode ^
      unpinnedHorizontalColor.hashCode ^
      thumbColor.hashCode ^
      horizontalOnlyWhenNeeded.hashCode ^
      verticalOnlyWhenNeeded.hashCode ^
      columnDividerColor.hashCode;
}

class TableScrollbarThemeDataDefaults {
  static const horizontalOnlyWhenNeeded = true;
  static const verticalOnlyWhenNeeded = true;
  static const double margin = 0;
  static const double thickness = 10;
  static const double borderThickness = 1;
  static const Color verticalBorderColor = Colors.grey;
  static const Color verticalColor = Color(0xFFE0E0E0);
  static const Color unpinnedHorizontalBorderColor = Colors.grey;
  static const Color unpinnedHorizontalColor = Color(0xFFE0E0E0);
  static const Color pinnedHorizontalBorderColor = Colors.grey;
  static const Color pinnedHorizontalColor = Color(0xFFE0E0E0);
  static const Color thumbColor = Color(0xFF616161);
  static const Color columnDividerColor = Colors.grey;
}
