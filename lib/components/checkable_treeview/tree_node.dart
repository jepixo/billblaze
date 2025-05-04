part of 'treeview.dart';

/// A node in a tree structure.
///
/// Each [TreeNode] represents an item in a hierarchical data structure.
/// It contains information about its state (expanded, selected, etc.),
/// its children, and its parent.
///
/// The type parameter [T] represents the type of the [value] associated
/// with this node.
class TreeNode<T> {
  /// The label widget displayed for this node.
  final Widget? label;

  /// An optional value associated with this node.
  final T? value;

  /// The icon to display next to this node.
  final Widget? icon;

  /// The trailing widget displayed for this node.
  final Widget Function(BuildContext context, TreeNode<T> node)? trailing;

  /// Extra data associated with this node.
  final dynamic data;

  /// The list of child nodes for this node.
  final List<TreeNode<T>> children;

  bool _selectable = true; 
  TreeNode<T>? _parent;
  bool _hidden = false;
  int _originalIndex = 0;
  bool _isExpanded = false;
  bool? _isSelected = false;
  bool _isPartiallySelected = false;
  double _checkboxSize = 18;
  double _indentSize = 12;
  bool _alternateChildren = true;
  

  TreeNode._internal({
    this.label,
    this.value,
    this.icon,
    this.trailing,
    this.data,
    required this.children, 
    TreeNode<T>? parent,
    bool hidden = false,
    int originalIndex = 0,
    bool isExpanded = false,
    bool? isSelected = false,
    bool isPartiallySelected = false,
    double checkboxSize = 18,
    double indentSize = 12,
    bool selectable = true,
    bool alternateChildren = true,
  })  : _parent = parent,
        _hidden = hidden,
        _originalIndex = originalIndex,
        _isExpanded = isExpanded,
        _isSelected = isSelected,
        _checkboxSize = checkboxSize,
        _indentSize = indentSize,
        _selectable = selectable,
        _alternateChildren = alternateChildren,
        _isPartiallySelected = isPartiallySelected {
    for (var child in this.children) {
      child._parent = this;
    }
  }

  /// Creates a [TreeNode].
  ///
  /// The [label] parameter is required and specifies the widget to display for this node.
  ///
  /// The [value] parameter is an optional value associated with this node.
  ///
  /// The [icon] parameter specifies the icon to display next to the node.
  ///
  /// The [trailing] parameter specifies the widget to display after the node.
  ///
  /// The [data] parameter is an optional map of extra data associated with this node.
  ///
  /// The [isSelected] parameter controls the initial selection state of the node.
  ///
  /// The [children] parameter is an optional list of child nodes.
  factory TreeNode({
    Widget? label,
    T? value,
    Widget? icon,
    Widget Function(BuildContext context, TreeNode<T> node)? trailing,
    dynamic data,
    bool? isSelected = false,
    List<TreeNode<T>>? children,
    double checkboxSize = 18,
    double indentSize = 12,
    bool selectable = true,
    bool alternateChildren = true,
    bool isExpanded = false,
  }) {
    return TreeNode._internal(
      label: label,
      value: value,
      icon: icon,
      trailing: trailing,
      data: data,
      children: children ?? [],
      isSelected: isSelected,
      checkboxSize: checkboxSize,
      indentSize: indentSize,
      selectable: selectable,
      alternateChildren:alternateChildren,
      isExpanded: isExpanded
    );
  }
}
