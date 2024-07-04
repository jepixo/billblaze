// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:billblaze/components/spread_sheet.dart';
import 'package:billblaze/components/spread_sheet_lib/drag_drop_state.dart';
import 'package:billblaze/components/spread_sheet_lib/sheet_list.dart';

class DragWrap extends ConsumerStatefulWidget {
  const DragWrap({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DragWrapState();
}

class _DragWrapState extends ConsumerState<DragWrap> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
