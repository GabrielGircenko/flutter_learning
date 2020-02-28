import 'package:flutter/material.dart';
import 'package:priority_keeper/enums/action_type.dart';
import 'package:priority_keeper/enums/checked_item_state.dart';
import 'package:priority_keeper/enums/movement_type.dart';
import 'package:priority_keeper/enums/screen_type.dart';
import 'package:priority_keeper/models/project_id.dart';
import 'package:priority_keeper/screens/actions_interface.dart';
import 'package:priority_keeper/utils/visual_helper.dart';

ListView getKeepLikeListView<T extends AbsWithProjectId>(
    BuildContext context,
    ActionsInterface callback,
    List<T> list,
    CheckedItemState state,
    int itemCount,
    List<TextEditingController> itemControllers,
    ScreenType screenType) {
  return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (context, int position) {
        return Card(
            color: Colors.white,
            elevation: 2,
            child: ListTile(
                leading: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  Checkbox(
                      value: list[position].completed,
                      onChanged: (completed) => callback.onCheckboxChanged(
                          context, state, position, completed)),
                  CircleAvatar(
                      backgroundColor: VisualHelper.getProjectColor(
                          list[position].projectId),
                      child:
                          VisualHelper.getProjectIcon(list[position].projectId))
                ]),
                title: TextFormField(
                    controller: itemControllers[position],
                    validator: (String value) {
                      if (value.isEmpty) {
                        return "Please enter the title.";
                      } else {
                        debugPrint("Something changed in Title Text Field");
                        callback.updateTitle(state, position);
                      }
                    },
                    onFieldSubmitted: (_) => callback.save(
                        context, state, ActionType.updateTitle, position)),
                trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: makeChildren(context, callback, list, state,
                        position, screenType == ScreenType.home)),
                onTap: () {
                  debugPrint("List Item Tapped");
                  callback.itemClicked(state, position);
                }));
      });
}

List<Widget> makeChildren<T extends AbsWithProjectId>(
    BuildContext context,
    ActionsInterface callback,
    List<T> list,
    CheckedItemState state,
    int position,
    bool isHomeScreen) {
  List<Widget> widgets = List<Widget>();

  if (!isHomeScreen) {
    if (position > 0) {
      widgets.add(GestureDetector(
        child: Icon(
          Icons.arrow_upward,
          color: Colors.grey,
        ),
        onTap: () {
          callback.reorder(context, list[position], state, MovementType.moveUp);
        },
      ));
    }

    if (position < list.length - 1) {
      widgets.add(GestureDetector(
        child: Icon(
          Icons.arrow_downward,
          color: Colors.grey,
        ),
        onTap: () {
          callback.reorder(
              context, list[position], state, MovementType.moveDown);
        },
      ));
    }
  }

  widgets.add(GestureDetector(
    child: Icon(
      Icons.delete,
      color: Colors.grey,
    ),
    onTap: () {
      callback.delete(context, list[position], state);
    },
  ));

  return widgets;
}
