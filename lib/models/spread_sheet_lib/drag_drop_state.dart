import 'package:billblaze/models/spread_sheet_lib/sheet_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DragDropState {
  final SheetList? draggingList;
  final SheetList? potentialDropList;
  final int draggingIndex;
  final int potentialDropIndex;
  final Duration dur;

  DragDropState(
      {required this.draggingList,
      required this.potentialDropList,
      required this.draggingIndex,
      required this.potentialDropIndex,
      required this.dur});

  DragDropState copyWith({
    SheetList? draggingList,
    SheetList? potentialDropList,
    int? draggingIndex,
    int? potentialDropIndex,
    Duration? dur,
  }) {
    return DragDropState(
      draggingList: draggingList ?? this.draggingList,
      potentialDropList: potentialDropList ?? this.potentialDropList,
      draggingIndex: draggingIndex ?? this.draggingIndex,
      potentialDropIndex: potentialDropIndex ?? this.potentialDropIndex,
      dur: dur ?? this.dur,
    );
  }
}

class DragDropNotifier extends StateNotifier<DragDropState> {
  SheetList? draggingList;
  SheetList? potentialList;
  DragDropNotifier({this.draggingList, this.potentialList})
      : super(DragDropState(
            draggingList: draggingList,
            potentialDropList: potentialList,
            draggingIndex: -1,
            potentialDropIndex: -1,
            dur: Durations.short3));

  void updateDraggingList(SheetList? draggingList) {
    state = state.copyWith(draggingList: draggingList);
  }

  void updatePotentialDropList(SheetList? potentialDropList) {
    state = state.copyWith(potentialDropList: potentialDropList);
  }

  void updateDraggingIndex(int? draggingIndex) {
    state = state.copyWith(draggingIndex: draggingIndex);
  }

  void updatePotentialDropIndex(int? potentialDropIndex) {
    state = state.copyWith(potentialDropIndex: potentialDropIndex);
  }

  void updateDur(Duration dur) {
    state = state.copyWith(dur: dur);
  }
}

final dragDropProvider =
    StateNotifierProvider<DragDropNotifier, DragDropState>((ref) {
  return DragDropNotifier();
});
