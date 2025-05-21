import 'package:billblaze/components/davi/theme/scrollbar_theme_data.dart';
import 'package:meta/meta.dart';

/// Stores scrollbar theme values that change the table layout.
@internal
class TableScrollbarThemeMetrics {
  TableScrollbarThemeMetrics({required TableScrollbarThemeData themeData})
      : thickness = themeData.thickness,
        borderThickness = themeData.borderThickness;

  final double thickness;
  final double borderThickness;

  double get width => borderThickness + thickness;

  double get height => borderThickness + thickness;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TableScrollbarThemeMetrics &&
          runtimeType == other.runtimeType &&
          thickness == other.thickness &&
          borderThickness == other.borderThickness;

  @override
  int get hashCode => thickness.hashCode ^ borderThickness.hashCode;
}
