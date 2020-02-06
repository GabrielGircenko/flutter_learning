import 'package:flutter_learning/enums/action_type.dart';
import 'package:flutter_learning/enums/movement_type.dart';
import 'package:flutter_learning/models/project_id.dart';
import 'package:flutter/material.dart';

mixin ActionsInterface<T extends AbsWithProjectId> {
  void save(BuildContext context, ActionType action, int position) {}
  void updateTitle(int position) {}
  void delete(BuildContext context, T model) {}
  void reorder(BuildContext context, T model, MovementType movementType) {}
  void itemClicked(int position) {}
  void onCheckboxChanged(BuildContext context, int position, bool completed) {}
} 