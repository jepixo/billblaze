import 'package:billblaze/components/davi.dart';
import 'package:billblaze/components/davi/internal/cells_layout_child.dart';
import 'package:billblaze/components/davi/internal/cells_layout_element.dart';
import 'package:billblaze/components/davi/internal/cells_layout_render_box.dart';
import 'package:billblaze/components/davi/internal/davi_context.dart';
import 'package:billblaze/components/davi/internal/divider_paint_manager.dart';
import 'package:billblaze/components/davi/internal/viewport_state.dart';
import 'package:billblaze/components/davi/internal/table_layout_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

@internal
class CellsLayout<DATA> extends MultiChildRenderObjectWidget {
  const CellsLayout(
      {super.key,
      required this.layoutSettings,
      required this.daviContext,
      required this.verticalOffset,
      required this.leftPinnedAreaBounds,
      required this.unpinnedAreaBounds,
      required this.rowsLength,
      required this.rowRegionCache,
      required this.dividerPaintManager,
      required List<CellsLayoutChild> super.children});

  final TableLayoutSettings layoutSettings;
  final DaviContext<DATA> daviContext;
  final double verticalOffset;
  final Rect leftPinnedAreaBounds;
  final Rect unpinnedAreaBounds;
  final RowRegionCache rowRegionCache;
  final int rowsLength;
  final DividerPaintManager dividerPaintManager;

  @override
  RenderObject createRenderObject(BuildContext context) {
    DaviThemeData theme = DaviTheme.of(context);
    return CellsLayoutRenderBox<DATA>(
        model: daviContext.model,
        hoverBackground: theme.row.hoverBackground,
        hoverForeground: theme.row.hoverForeground,
        cellHeight: layoutSettings.themeMetrics.cell.height,
        rowHeight: layoutSettings.themeMetrics.row.height,
        columnsMetrics: layoutSettings.columnsMetrics,
        verticalOffset: verticalOffset,
        scrollControllers: daviContext.scrollControllers,
        leftPinnedAreaBounds: leftPinnedAreaBounds,
        unpinnedAreaBounds: unpinnedAreaBounds,
        hoverNotifier: daviContext.hoverNotifier,
        themeRowColor: theme.row.color,
        rowColor: daviContext.rowColor,
        dividerColor: theme.row.dividerColor,
        rowsLength: rowsLength,
        rowRegionCache: rowRegionCache,
        columnDividerColor: theme.columnDividerColor,
        columnDividerThickness: theme.columnDividerThickness,
        fillHeight: theme.row.fillHeight,
        columnDividerFillHeight: theme.columnDividerFillHeight,
        dividerThickness: theme.row.dividerThickness,
        dividerPaintManager: dividerPaintManager);
  }

  @override
  MultiChildRenderObjectElement createElement() {
    return CellsLayoutElement(this);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant CellsLayoutRenderBox<DATA> renderObject) {
    super.updateRenderObject(context, renderObject);
    DaviThemeData theme = DaviTheme.of(context);
    renderObject
      ..hoverBackground = theme.row.hoverBackground
      ..hoverForeground = theme.row.hoverForeground
      ..cellHeight = layoutSettings.themeMetrics.cell.height
      ..rowHeight = layoutSettings.themeMetrics.row.height
      ..columnsMetrics = layoutSettings.columnsMetrics
      ..verticalOffset = verticalOffset
      ..scrollControllers = daviContext.scrollControllers
      ..leftPinnedAreaBounds = leftPinnedAreaBounds
      ..unpinnedAreaBounds = unpinnedAreaBounds
      ..hoverNotifier = daviContext.hoverNotifier
      ..fillHeight = theme.row.fillHeight
      ..columnDividerFillHeight = theme.columnDividerFillHeight
      ..rowsLength = rowsLength
      ..rowRegionCache = rowRegionCache
      ..dividerColor = theme.row.dividerColor
      ..dividerThickness = theme.row.dividerThickness
      ..columnDividerColor = theme.columnDividerColor
      ..columnDividerThickness = theme.columnDividerThickness
      ..themeRowColor = theme.row.color
      ..rowColor = daviContext.rowColor
      ..dividerPaintManager = dividerPaintManager
      ..model = daviContext.model;
  }
}
