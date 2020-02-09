import 'package:flutter/material.dart';
import 'package:flutter_learning/enums/action_type.dart';
import 'package:flutter_learning/enums/checked_item_state.dart';
import 'package:flutter_learning/enums/movement_type.dart';
import 'package:flutter_learning/enums/screen_type.dart';
import 'package:flutter_learning/models/project_id.dart';
import 'package:flutter_learning/models/task.dart';
import 'package:flutter_learning/screens/actions_interface.dart';
import 'package:flutter_learning/utils/visual_helper.dart';

ListView getKeepLikeListView<T extends AbsWithProjectId>(BuildContext context, ActionsInterface callback, List<T> list, CheckedItemState state, int itemCount, List<TextEditingController> itemControllers, ScreenType screenType) {
    return ListView.builder(
                  itemCount: itemCount,
                  itemBuilder: (context, int position) {
                    return Card(
                        color: Colors.white,
                        elevation: 2,
                        child: ListTile(
                            leading:  Row(
                              mainAxisSize: MainAxisSize.min,         
                              children: <Widget>[
                                Checkbox(
                                  value: list[position].completed,
                                  onChanged: (completed) => callback.onCheckboxChanged(context, state, position, completed)),
                                CircleAvatar(
                                  backgroundColor:
                                      VisualHelper.getProjectColor(
                                        list[position].projectId),
                                  child: VisualHelper.getProjectIcon(
                                      list[position].projectId)
                                      )
                                ]
                            ),
                            title: TextFormField(
                                controller: itemControllers[position],
                                validator: (String value) {
                                  if (value.isEmpty) {
                                    return "Please enter the title.";

                                  } else {
                                    debugPrint(
                                        "Something changed in Title Text Field");
                                    callback.updateTitle(state, position);
                                  }
                                },
                                onFieldSubmitted: (_) => callback.save(context, state, ActionType.updateTitle, position)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,         
                              children: makeChildren(context, callback, list, state, position, screenType == ScreenType.home)
                              ),
                                onTap: () {
                                  debugPrint("List Item Tapped");
                                  callback.itemClicked(state, position);
                                }));
                  });
  }

List<Widget> makeChildren<T extends AbsWithProjectId>(BuildContext context, ActionsInterface callback, 
                                          List<T> list, CheckedItemState state, int position, bool isHomeScreen) {
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
          callback.reorder(context, list[position], state, MovementType.moveDown);
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

ListView getTaskListViewOld(BuildContext context, int taskCount, List<Task> taskList) {
    TextStyle titleStyle = Theme.of(context).textTheme.subhead;

    return ListView.builder(
        itemCount: taskCount,
        itemBuilder: (BuildContext context, int position) {
          return Card(
            color: Colors.white,
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                  backgroundColor:
                      VisualHelper.getProjectColor(taskList[position].projectId),
                  child: VisualHelper.getProjectIcon(taskList[position].projectId)),
              title: Text(
                taskList[position].title,
                style: titleStyle,
              ),
              subtitle: Text(taskList[position].date),
              trailing: GestureDetector(
                  child: Icon(
                Icons.delete,
                color: Colors.grey,
              ),
              onTap: () {
                    // TODO _delete(context, taskList[position]);
              },
              ),
              onTap: () {
                debugPrint("ListTile Tapped");
                // TODO navigateToTaskDetails(taskList[position], "Edit Task");
              },
            ),
          );
        });
  }
