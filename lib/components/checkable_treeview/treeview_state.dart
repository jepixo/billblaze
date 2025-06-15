part of 'treeview.dart';

/// The state management class for the [TreeView] widget.
///
/// This class handles the internal logic and state of the tree view, including:
/// - Node selection and deselection
/// - Expansion and collapse of nodes
/// - Filtering and sorting of nodes
/// - Handling of "Select All" functionality
/// - Managing the overall tree structure
///
/// It also provides methods for external manipulation of the tree, such as:
/// - [filter] for applying filters to the tree nodes
/// - [sort] for sorting the tree nodes
/// - [setSelectAll] for selecting or deselecting all nodes
/// - [expandAll] and [collapseAll] for expanding or collapsing all nodes
/// - [getSelectedNodes] and [getSelectedValues] for retrieving selected items
///
/// This class is not intended to be used directly by users of the [TreeView] widget,
/// but rather serves as the internal state management mechanism.
class TreeViewState<T> extends State<TreeView<T>> {
  late List<TreeNode<T>> _roots;
  bool _isAllSelected = false;
  late bool _isAllExpanded;

  @override
  void initState() {
    super.initState();
    _roots = widget.nodes;
    _initializeNodes(_roots, null);
    _setInitialExpansion(_roots, 0);
    _updateAllNodesSelectionState();
    _updateSelectAllState();
    _isAllExpanded = widget.initialExpandedLevels == 0;
  }

  @override
  void didUpdateWidget(covariant TreeView<T> oldWidget) {
    
    super.didUpdateWidget(oldWidget);
    _roots = widget.nodes;
    _initializeNodes(_roots, null);
    _setInitialExpansion(_roots, 1);
    _updateAllNodesSelectionState();
    _updateSelectAllState();
    _isAllExpanded = widget.initialExpandedLevels == 0;
  }

  @override
  void didChangeDependencies() {
   
    super.didChangeDependencies();
    _roots = widget.nodes;
    _initializeNodes(_roots, null);
    _setInitialExpansion(_roots, 0);
    _updateAllNodesSelectionState();
    _updateSelectAllState();
    _isAllExpanded = widget.initialExpandedLevels == 0;
  }
  
  

  /// Filters the tree nodes based on the provided filter function.
  ///
  /// The [filterFunction] should return true for nodes that should be visible.
  void filter(bool Function(TreeNode<T>) filterFunction) {
    setState(() {
      _applyFilter(_roots, filterFunction);
      _updateAllNodesSelectionState();
      _updateSelectAllState();
    });
  }

  /// Sorts the tree nodes based on the provided compare function.
  ///
  /// If [compareFunction] is null, the original order is restored.
  void sort(int Function(TreeNode<T>, TreeNode<T>)? compareFunction) {
    setState(() {
      if (compareFunction == null) {
        _applySort(
            _roots, (a, b) => a._originalIndex.compareTo(b._originalIndex));
      } else {
        _applySort(_roots, compareFunction);
      }
    });
  }

  /// Sets the selection state of all nodes.
  void setSelectAll(bool isSelected) {
    setState(() {
      _setAllNodesSelection(isSelected);
      _updateSelectAllState();
    });
    _notifySelectionChanged();
  }

  /// Expands all nodes in the tree.
  void expandAll() {
    setState(() {
      _setExpansionState(_roots, true);
    });
    // _notifyExpansionChanged();
  }

  /// Collapses all nodes in the tree.
  void collapseAll() {
    setState(() {
      _setExpansionState(_roots, false);
    });
    _notifyExpansionChanged();
  }

  /// Sets the selected values in the tree.
  void setSelectedValues(List<T> selectedValues) {
    for (var root in _roots) {
      _setNodeAndDescendantsSelectionByValue(root, selectedValues);
    }
    _updateSelectAllState();
    _notifySelectionChanged();
  }

  void _setNodeAndDescendantsSelectionByValue(
      TreeNode<T> node, List<T> selectedValues) {
    if (node._hidden) return;
    node._isSelected = selectedValues.contains(node.value);
    node._isPartiallySelected = false;
    for (var child in node.children) {
      _setNodeAndDescendantsSelectionByValue(child, selectedValues);
    }
  }

  /// Returns a list of all selected nodes in the tree.
  List<TreeNode<T>> getSelectedNodes() {
    return _getSelectedNodesRecursive(_roots);
  }

  /// Returns a list of all selected child nodes of the given node.
  List<TreeNode<T>> getChildSelectedNodes(TreeNode<T> node) {
    return _getSelectedNodesRecursive(node.children);
  }

  /// Returns a list of all selected values in the tree.
  List<bool> getSelectedValues() {
    return _getSelectedValues(_roots);
  }

  /// Returns a list of all selected child nodes values of the given node.
  List<bool> getChildSelectedValues(TreeNode<T> node) {
    return _getSelectedValues(node.children);
  }

  void _initializeNodes(List<TreeNode<T>> nodes, TreeNode<T>? parent) {
    for (int i = 0; i < nodes.length; i++) {
      nodes[i]._originalIndex = i;
      nodes[i]._parent = parent;
      _initializeNodes(nodes[i].children, nodes[i]);
    }
  }

  void _setInitialExpansion(List<TreeNode<T>> nodes, int currentLevel) {
    if (widget.initialExpandedLevels == null) {
      return;
    }
    for (var node in nodes) {
      if (widget.initialExpandedLevels == 0) {
        node._isExpanded = true;
      } else {
        node._isExpanded = currentLevel < widget.initialExpandedLevels!;
      }
      if (node._isExpanded) {
        _setInitialExpansion(node.children, currentLevel + 1);
      }
    }
  }

  void _applySort(List<TreeNode<T>> nodes,
      int Function(TreeNode<T>, TreeNode<T>) compareFunction) {
    nodes.sort(compareFunction);
    for (var node in nodes) {
      if (node.children.isNotEmpty) {
        _applySort(node.children, compareFunction);
      }
    }
  }

  void _applyFilter(
      List<TreeNode<T>> nodes, bool Function(TreeNode<T>) filterFunction) {
    for (var node in nodes) {
      bool shouldShow =
          filterFunction(node) || _hasVisibleDescendant(node, filterFunction);
      node._hidden = !shouldShow;
      _applyFilter(node.children, filterFunction);
    }
  }

  void _updateAllNodesSelectionState() {
    for (var root in _roots) {
      _updateNodeSelectionStateBottomUp(root);
    }
  }

  void _updateNodeSelectionStateBottomUp(TreeNode<T> node) {
    for (var child in node.children) {
      _updateNodeSelectionStateBottomUp(child);
    }
    _updateSingleNodeSelectionState(node);
  }

  void _updateNodeSelection(TreeNode<T> node, bool? isSelected) {
    setState(() {
      if (isSelected == null) {
        _handlePartialSelection(node);
      } else {
        _updateNodeAndDescendants(node, isSelected);
      }
      _updateAncestorsRecursively(node);
      _updateSelectAllState();
    });
    _notifySelectionChanged();
  }

  void _handlePartialSelection(TreeNode<T> node) {
    if ((node._isSelected ?? false) || node._isPartiallySelected) {
      _updateNodeAndDescendants(node, false);
    } else {
      _updateNodeAndDescendants(node, true);
    }
  }

  void _updateNodeAndDescendants(TreeNode<T> node, bool isSelected) {
    if (!node._hidden) {
      node._isSelected = isSelected;
      node._isPartiallySelected = false;
      for (var child in node.children) {
        _updateNodeAndDescendants(child, isSelected);
      }
    }
  }

  void _updateAncestorsRecursively(TreeNode<T> node) {
    TreeNode<T>? parent = node._parent;
    if (parent != null) {
      _updateSingleNodeSelectionState(parent);
      _updateAncestorsRecursively(parent);
    }
  }

  void _notifySelectionChanged() {
    List<bool> selectedValues = _getSelectedValues(_roots);
    widget.onSelectionChanged?.call(selectedValues);
  }

  List<bool> _getSelectedValues(List<TreeNode<T>> nodes) {
    List<bool> selectedValues = [];
    for (var node in nodes) {
      if ( !node._hidden) {
        selectedValues.add(node._isSelected??false);
      }
      selectedValues.addAll(_getSelectedValues(node.children));
    }
    return selectedValues;
  }

  void _notifyExpansionChanged() {
    List<bool> selectedValues = _getExpandedValues(_roots);
    widget.onExpansionChanged?.call(selectedValues);
  }

  List<bool> _getExpandedValues(List<TreeNode<T>> nodes) {
    List<bool> selectedValues = [];
    for (var node in nodes) {
      if ( !node._hidden) {
        selectedValues.add(node._isExpanded);
      }
      selectedValues.addAll(_getExpandedValues(node.children));
    }
    return selectedValues;
  }


  Widget _buildTreeNode(TreeNode<T> node, {double leftPadding = 0}) {
    if (node._hidden) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: EdgeInsets.only(left: leftPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const SizedBox(height: 2),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: InkWell(
              hoverColor:  defaultPalette.extras[1],
              splashColor: defaultPalette.extras[1],
              highlightColor:  defaultPalette.extras[1],
              onDoubleTap: () { 
                _toggleNodeExpansion(node);
                _notifyExpansionChanged();
              },
              onTap: () { 
                if(node.children.isNotEmpty)_toggleNodeExpansion(node);
                if(node.children.isEmpty) _updateNodeSelection(node, !(node._isSelected??false));
                },
              child: Row(
                children: [ 
                  // const SizedBox(width: 2),
                  if (node.icon != null) node.icon!,
                  // const SizedBox(width: 2),
                  //label text
                  Expanded(
                      child: 
                  // Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: [
                      DynMouseScroll(
                        builder: (context, controller, physics) {
                          
                          return Listener(
                            onPointerSignal: (event) { 
                              if (event is PointerScrollEvent) {
                                // print('scrolling '+ (event.scrollDelta.dy.toString()??'0') + ' controller '+ controller.offset.toString(),);
                                controller.jumpTo( 
                                  (controller.offset + (event.scrollDelta.dy)) 
                                ); 
                              } 
                               
                            },
                            child: SingleChildScrollView(
                              controller: controller,
                              physics: physics,
                              scrollDirection: Axis.horizontal,
                              child: node.label??Container()),
                          );
                        }
                      ),
                      // if (node.trailing != null)
                      //   Padding(
                      //       padding: const EdgeInsetsDirectional.only(end: 12),
                      //       child: node.trailing!(context, node)),
                                          
                      // ],
                      // )
                      ),
                  
                  if(node._selectable)
                  customTriCheckbox(
                          value: (node._isSelected ?? false)
                              ? true
                              : (node._isPartiallySelected ? null : false),
                          onChanged: (newValue) =>
                              _updateNodeSelection(node, newValue ?? false),
                          size: node._checkboxSize, // customize size here
                          activeColor: defaultPalette.extras[0],
                           // customize color
                        ),
                  
                ],
              ),
            ),
          ),
          if(node.children.isNotEmpty)
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            tween: Tween<double>(
              begin: node._isExpanded ? 0 : 1,
              end: node._isExpanded ? 1 : 0,
            ),
            builder: (context, value, child) {
              return ClipRect(
                child: Align(
                  heightFactor: value,
                  child: child,
                ),
              );
            },
            child: node.children.isNotEmpty
                ? Padding(
                    padding: EdgeInsets.only(left: node._indentSize),
                    child:node._alternateChildren && (widget.width??100)>200? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // First column: even-indexed items
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (int i = 0; i < node.children.length; i += 2)
                                      _buildTreeNode(node.children[i]),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(width: 0), // optional spacing between columns

                              // Second column: odd-indexed items
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (int i = 1; i < node.children.length; i += 2)
                                      _buildTreeNode(node.children[i]),
                                  ],
                                ),
                              ),
                              SizedBox(width: 2,)
                            ],
                          )

                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: node.children
                          .map((child) => _buildTreeNode(child))
                          .toList(),
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  void _toggleNodeExpansion(TreeNode<T> node) {
    setState(() {
      node._isExpanded = !node._isExpanded;
    });
    _notifyExpansionChanged();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool _hasVisibleDescendant(
      TreeNode<T> node, bool Function(TreeNode<T>) filterFunction) {
    for (var child in node.children) {
      if (filterFunction(child) ||
          _hasVisibleDescendant(child, filterFunction)) {
        return true;
      }
    }
    return false;
  }

  void _updateSingleNodeSelectionState(TreeNode<T> node) {
    if (node.children.isEmpty ||
        node.children.every((child) => child._hidden)) {
      return;
    }

    List<TreeNode<T>> visibleChildren =
        node.children.where((child) => !child._hidden).toList();
    bool allSelected = visibleChildren.every((child) => (child._isSelected??false));
    bool anySelected = visibleChildren
        .any((child) => (child._isSelected??false) || child._isPartiallySelected);

    if (allSelected) {
      node._isSelected = true;
      node._isPartiallySelected = false;
    } else if (anySelected) {
      node._isSelected = false;
      node._isPartiallySelected = true;
    } else {
      node._isSelected = false;
      node._isPartiallySelected = false;
    }
  }

  void _setExpansionState(List<TreeNode<T>> nodes, bool isExpanded) {
    for (var node in nodes) {
      node._isExpanded = isExpanded;
      _setExpansionState(node.children, isExpanded);
    }
    _notifyExpansionChanged();
  }

  void _updateSelectAllState() {
    if (!widget.showSelectAll) return;
    bool allSelected = _roots
        .where((node) => !node._hidden)
        .every((node) => _isNodeFullySelected(node));
    setState(() {
      _isAllSelected = allSelected;
    });
  }

  bool _isNodeFullySelected(TreeNode<T> node) {
    if (node._hidden) return true;
    if (!(node._isSelected ?? false)) return false;
    return node.children
        .where((child) => !child._hidden)
        .every(_isNodeFullySelected);
  }

  void _handleSelectAll(bool? value) {
    if (value == null) return;
    _setAllNodesSelection(value);
    _updateSelectAllState();
    _notifySelectionChanged();
  }

  void _setAllNodesSelection(bool isSelected) {
    for (var root in _roots) {
      _setNodeAndDescendantsSelection(root, isSelected);
    }
  }

  void _setNodeAndDescendantsSelection(TreeNode<T> node, bool isSelected) {
    if (node._hidden) return;
    node._isSelected = isSelected;
    node._isPartiallySelected = false;
    for (var child in node.children) {
      _setNodeAndDescendantsSelection(child, isSelected);
    }
  }

  void _toggleExpandCollapseAll() {
    setState(() {
      _isAllExpanded = !_isAllExpanded;
      var expansionvalues = _getExpandedValues(_roots);
      if ( 
        expansionvalues[1] &&
    expansionvalues[6] &&
    expansionvalues[11] &&
    expansionvalues[14] &&
    expansionvalues[20] &&
    expansionvalues[29] &&
    expansionvalues[32] &&
    expansionvalues[38]){
      _isAllExpanded = true;
    } else {
      _isAllExpanded = false;
    }
    if (!expansionvalues[0] && !_isAllExpanded){
      _isAllExpanded = true;
    }
    
    _setExpansionState(_roots, !_isAllExpanded);
    _roots[0]._isExpanded = true;
    });
    _notifyExpansionChanged();
  }

  @override
  Widget build(BuildContext context) { 

    return Theme(
        data: widget.theme ?? Theme.of(context),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return   ClipRRect(
                borderRadius: BorderRadius.circular(9),child: Material(
                color: defaultPalette.transparent,
                child: Container( 
                      width: widget.width,         
                      child:   Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.showSelectAll ||
                                  widget.showExpandCollapseButton)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 0),
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: InkWell(
                                      hoverColor:  defaultPalette.primary,
                                      splashColor: defaultPalette.primary,
                                      highlightColor:  defaultPalette.primary,
                                      onTap: () {
                                        _toggleExpandCollapseAll();
                                      },
                                      onDoubleTap: () {
                                        setState(() {
                                          _roots[0]._isExpanded =!_roots[0]._isExpanded; 
                                          _notifyExpansionChanged();
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          Expanded(child: Text('  properties', 
                                          style: GoogleFonts.lexend(
                                            fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                    height: 1.2,
                                    letterSpacing: -1,
                                    color: defaultPalette.extras[0])
                                      )),
                                          
                                          if (widget.showSelectAll)
                                             
                                            customTriCheckbox(
                                              value:  _isAllSelected, 
                                              onChanged: _handleSelectAll,
                                              activeColor: defaultPalette.extras[0],
                                              size: 21
                                              ),
                                         SizedBox(width: 1,)
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ..._roots.map((root) => _buildTreeNode(root)),
                            SizedBox(height: 3,)
                            ],
                          ) 
                        
                    ),
              ),
            );
          },
        ));
  }

  List<TreeNode<T>> _getSelectedNodesRecursive(List<TreeNode<T>> nodes) {
    List<TreeNode<T>> selectedNodes = [];
    for (var node in nodes) {
      if ((node._isSelected ?? false)&& !node._hidden) {
        selectedNodes.add(node);
      }
      if (node.children.isNotEmpty) {
        selectedNodes.addAll(_getSelectedNodesRecursive(node.children));
      }
    }
    return selectedNodes;
  }

  Widget customTriCheckbox({
  required bool? value,
  required ValueChanged<bool?> onChanged,
  double size = 28.0,
  Color activeColor = Colors.blue,
}) {
  IconData icon;
  if (value == null) {
    icon = TablerIcons.pinned; // Tristate (partially selected)
  } else if (value) {
    icon = TablerIcons.pin_filled;
  } else {
    icon = TablerIcons.pin;
  }

  return InkWell(

    hoverColor:  defaultPalette.tertiary,
    splashColor: defaultPalette.tertiary,
    highlightColor:  defaultPalette.tertiary,
    onTap: () {
      if (value == null) {
        onChanged(true); // from partial → full
      } else {
        onChanged(!value); // toggle true <→ false
      }
    },
    borderRadius: BorderRadius.circular(50),
    child: Icon(
      icon,
      size: size,
      color: activeColor,
    ),
  );
}




}
