import 'package:flutter/material.dart';
import 'package:priority_keeper/enums/action_type.dart';
import 'package:priority_keeper/enums/checked_item_state.dart';
import 'package:priority_keeper/enums/movement_type.dart';
import 'package:priority_keeper/models/project_id.dart';

mixin ActionsInterface<T extends AbsWithProjectId> {
  void save(BuildContext context, CheckedItemState state, ActionType action,
      int position) {}
  void updateTitle(CheckedItemState state, int position) {}
  void delete(BuildContext context, T model, CheckedItemState state) {}
  void reorder(BuildContext context, T model, CheckedItemState state,
      MovementType movementType) {}
  void itemClicked(CheckedItemState state, int position) {}
  void onCheckboxChanged(BuildContext context, CheckedItemState state,
      int position, bool completed) {}
  void updateUncheckedListView() {}
  void updateCheckedListView() {}
  void updateTheOppositeListView(CheckedItemState state) {
    state.isChecked ? updateUncheckedListView() : updateCheckedListView();
  }
}
