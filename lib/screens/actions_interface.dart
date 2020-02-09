import 'package:flutter_learning/enums/action_type.dart';
import 'package:flutter_learning/enums/checked_item_state.dart';
import 'package:flutter_learning/enums/movement_type.dart';
import 'package:flutter_learning/models/project_id.dart';
import 'package:flutter/material.dart';

mixin ActionsInterface<T extends AbsWithProjectId> {
  void save(BuildContext context, CheckedItemState state, ActionType action, int position) {}
  void updateTitle(CheckedItemState state, int position) {}
  void delete(BuildContext context, T model, CheckedItemState state) {}
  void reorder(BuildContext context, T model, CheckedItemState state, MovementType movementType) {}
  void itemClicked(CheckedItemState state, int position) {}
  void onCheckboxChanged(BuildContext context, CheckedItemState state, int position, bool completed) {}
  void updateCheckedListView() {}
} 