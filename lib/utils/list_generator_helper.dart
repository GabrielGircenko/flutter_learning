import 'package:flutter/material.dart';
import 'package:flutter_learning/enums/action_type.dart';
import 'package:flutter_learning/enums/movement_type.dart';
import 'package:flutter_learning/models/project_id.dart';
import 'package:flutter_learning/models/task.dart';
import 'package:flutter_learning/screens/actions_interface.dart';
import 'package:flutter_learning/utils/visual_helper.dart';

ListView getKeepLikeListView<T extends AbsWithProjectId>(BuildContext context, ActionsInterface callback, List<T> list, int itemCount, List<TextEditingController> itemControllers, bool isHomeScreen) {
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
                                  onChanged: (completed) => callback.onCheckboxChanged(context, position, completed)),
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
                                    callback.updateTitle(position);
                                  }
                                },
                                onFieldSubmitted: (_) => callback.save(context, ActionType.updateTitle, position)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,         
                              children: makeChildren(context, callback, list, position, isHomeScreen)
                              ),
                                onTap: () {
                                  debugPrint("List Item Tapped");
                                  callback.itemClicked(position);
                                }));
                  });
  }

List<Widget> makeChildren<T extends AbsWithProjectId>(BuildContext context, ActionsInterface callback, 
                                          List<T> list, int position, bool isHomeScreen) {
  List<Widget> widgets = List<Widget>();

  if (!isHomeScreen) {
    widgets.add(GestureDetector(
      child: Icon(
        Icons.arrow_upward,
        color: Colors.grey,
      ),
      onTap: () {
        callback.reorder(context, list[position], MovementType.moveUp);
      },
    ));

    widgets.add(GestureDetector(
      child: Icon(
        Icons.arrow_downward,
        color: Colors.grey,
      ),
      onTap: () {
        callback.reorder(context, list[position], MovementType.moveDown);
      },
    ));
  }

  widgets.add(GestureDetector(
    child: Icon(
      Icons.delete,
      color: Colors.grey,
    ),
    onTap: () {
      callback.delete(context, list[position]);
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
