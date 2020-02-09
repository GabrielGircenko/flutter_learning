import 'package:flutter/material.dart';
import 'package:flutter_learning/enums/action_type.dart';
import 'package:flutter_learning/enums/checked_item_state.dart';
import 'package:flutter_learning/enums/movement_type.dart';
import 'package:flutter_learning/enums/screen_type.dart';
import 'package:flutter_learning/enums/task_list_type.dart';
import 'package:flutter_learning/models/project.dart';
import 'package:flutter_learning/models/task.dart';
import 'package:flutter_learning/screens/task_details.dart';
import 'package:flutter_learning/screens/task_list_abs.dart';
import 'package:flutter_learning/utils/list_generator_helper.dart';
import 'package:sqflite/sqlite_api.dart';

class TaskList extends TaskListAbs {
  
  final String appBarTitle;
  final Project project;
  
  TaskList(this.project, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return TaskListState(this.project, this.appBarTitle);
  }
}

class TaskListState extends TaskListAbsState {
  
  String _appBarTitle;
  @override
  Project project;

  @override
  TaskListType type = TaskListType.InAProject;

  TaskListState(this.project, this._appBarTitle);
  
  @override
  Widget build(BuildContext context) {
    if (projectList == null) {
      projectList = List<Project>();
    }

    if (taskList == null) {
      taskList = List<Task>();
      updateTaskListView();
    }

    if (checkedTaskList == null) {
      checkedTaskList = List<Task>();
      updateCheckedListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle + " Tasks"),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: new Container(
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new Flexible(
                  child: 
                  getKeepLikeListView(context, this, taskList, CheckedItemState.unchecked, taskCount, taskControllers, ScreenType.tasks),          
                ),
                Divider(),
                Text("Checked items"), 
                getKeepLikeListView(context, this, checkedTaskList, CheckedItemState.checked, checkedTaskCount, checkedTaskControllers, ScreenType.tasks),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Builder(
        builder: (BuildContext context) {
          return FloatingActionButton(
            onPressed: () {
              debugPrint("FAB clicked");
              _addBlankTask(context);
              //navigateToTaskDetails(Task("", taskList.length, "", project.projectId, project.projectPosition), "Add Task");
            },
            tooltip: "Add Task",
            child: Icon(Icons.add),
            );
          },
        )
      );
  }

  void _addBlankTask(BuildContext context) {
    taskList.add(Task("", taskList.length, "", project.projectId, project.projectPosition));
    save(context, CheckedItemState.unchecked, ActionType.add, taskList.length - 1);
  }

  @override
  void reorder(BuildContext context, Task task, CheckedItemState state, MovementType movementType) async {
    int result = await databaseHelper.reorderTask(state.isChecked, task.projectId, task.taskPosition, movementType);
    if (result != 0) {
      showSnackBar(context, "Task moved successfully");
      state.isChecked ? updateCheckedListView() : updateTaskListView();
    }
  }

  void navigateToTaskDetails(Task note, String title) async {
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return TaskDetails(note, title);
    }));

    if (result) {
      updateTaskListView();
    }
  }

  @override
  void updateCheckedListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
    Future<List<Task>> taskListFuture = databaseHelper.getTaskList(TaskListType.InAProject, CheckedItemState.checked.isChecked, project.projectId);
      taskListFuture.then((taskList) {
        setState(() {
          this.checkedTaskList = taskList;
          this.checkedTaskControllers = List<TextEditingController>();

          this.checkedTaskCount = checkedTaskList.length;
          for (int i = 0; i < this.checkedTaskList.length; i++) {
            this.checkedTaskControllers.add(TextEditingController(
                text: checkedTaskList[i].title != null
                    ? checkedTaskList[i].title
                    : "",
            ));
          }
        });
      });
    });
  }
}