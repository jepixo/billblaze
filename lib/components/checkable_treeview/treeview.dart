import 'package:billblaze/colors.dart';
import 'package:flutter/gestures.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';
import 'dart:ui' as ui;
part 'tree_node.dart';

part 'treeview_state.dart';

/// A customizable tree view widget for Flutter applications.
///
/// [TreeView] displays hierarchical data in a tree structure, allowing for
/// selection, expansion, and collapse of nodes. It supports various features
/// such as multi-selection, filtering, sorting, and customization of appearance.
///
/// The widget is generic over type [T], which represents the type of value
/// associated with each node in the tree.
///
/// Key features:
/// - Hierarchical data display
/// - Node selection (single or multi)
/// - Expandable/collapsible nodes
/// - Optional "Select All" functionality
/// - Customizable node appearance
/// - Filtering and sorting capabilities
/// - Expand/collapse all functionality
///
/// Example usage:
/// ```dart
/// TreeView<String>(
///   nodes: [
///     TreeNode(
///       label: const Text('Root'),
///       children: [
///         TreeNode(label: const Text('Child 1'), value: 'child1'),
///         TreeNode(label: const Text('Child 2'), value: 'child2'),
///       ],
///     ),
///   ],
///   onSelectionChanged: (selectedValues) {
///     print('Selected values: $selectedValues');
///   },
/// )
/// ```
/// 
final ValueNotifier<bool> treeViewRebuildNotifier = ValueNotifier(false);

class TreeView<T> extends StatefulWidget {
  /// The root nodes of the tree.
  final List<TreeNode<T>> nodes;

  /// Callback function called when the selection state changes.
  final Function(List<bool>)? onSelectionChanged;

  final Function(List<bool>)? onExpansionChanged;

  /// Optional theme data for the tree view.
  final ThemeData? theme;

  /// Whether to show a "Select All" checkbox.
  final bool showSelectAll;

  /// The number of levels to initially expand. If null, no nodes are expanded.
  final int? initialExpandedLevels;

  /// Custom widget to replace the default "Select All" checkbox.
  final Widget? selectAllWidget;

  /// The trailing widget displayed for select all node.
  final Widget Function(BuildContext context)? selectAllTrailing;

  /// Whether to show the expand/collapse all button.
  final bool showExpandCollapseButton;

  /// Custom function to draw nodes
  final Function(TreeNode<T> node, bool isSelected)? customDrawNode;

  final double? width; 

  /// Creates a [TreeView] widget.
  ///
  /// The [nodes] and [onSelectionChanged] parameters are required.
  ///
  /// The [theme] parameter can be used to customize the appearance of the tree view.
  ///
  /// Set [showSelectAll] to true to display a "Select All" checkbox.
  ///
  /// The [selectAllWidget] can be used to provide a custom widget for the "Select All" functionality.
  ///
  /// Use [initialExpandedLevels] to control how many levels of the tree are initially expanded.
  /// If null, no nodes are expanded. If set to 0, all nodes are expanded.
  /// If set to 1, only the root nodes are expanded, if set to 2, the root nodes and their direct children are expanded, and so on.
  ///
  /// Set [showExpandCollapseButton] to true to display a button that expands or collapses all nodes.
  const TreeView({
    super.key,
    required this.nodes,
    this.onSelectionChanged,
    this.theme,
    this.showSelectAll = false,
    this.selectAllWidget,
    this.selectAllTrailing,
    this.initialExpandedLevels,
    this.showExpandCollapseButton = false,
    this.customDrawNode,
    this.width,
    this.onExpansionChanged,
  });

  @override
  TreeViewState<T> createState() => TreeViewState<T>();
}
