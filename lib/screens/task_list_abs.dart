import 'package:flutter/material.dart';
import 'package:flutter_learning/enums/action_type.dart';
import 'package:flutter_learning/enums/checked_item_state.dart';
import 'package:flutter_learning/enums/task_list_type.dart';
import 'package:flutter_learning/models/project.dart';
import 'package:flutter_learning/utils/screen_with_snackbar.dart';
import 'package:flutter_learning/screens/actions_interface.dart';
import 'package:flutter_learning/utils/database_helper.dart';
import 'package:flutter_learning/models/task.dart';
import 'package:flutter_learning/utils/task_action_helper.dart';
import 'package:sqflite/sqlite_api.dart';

abstract class TaskListAbs extends StatefulWidget {}

abstract class TaskListAbsState extends State<TaskListAbs> with ActionsInterface<Task>, ScreenWithSnackbar {
  
  @protected
  DatabaseHelper databaseHelper = DatabaseHelper();
  @protected
  List<Project> projectList;
  @protected
  int projectCount = 0;
  @protected
  Project project;
  @protected
  List<Task> taskList;
  @protected
  int taskCount = 0;
  @protected
  List<TextEditingController> taskControllers;
  @protected
  List<Task> checkedTaskList;
  @protected
  int checkedTaskCount = 0;
  @protected
  List<TextEditingController> checkedTaskControllers;
  @protected
  var formKey = GlobalKey<FormState>();
  @protected
  TaskListType type;

  @override
  void updateTitle(CheckedItemState state, int position) {
    if (state.isChecked) {
      checkedTaskList[position].title = checkedTaskControllers[position].text;

    } else {
      taskList[position].title = taskControllers[position].text;
    }
  }

  @override
  void delete(BuildContext context, Task task, CheckedItemState state) async {
    int result = await databaseHelper.deleteTask(state.isChecked, task.taskId, task.projectId);
    if (result != 0) {
      showSnackBar(context, "Task deleted successfully");
      state.isChecked ? updateCheckedListView() : updateTaskListView();
    }
  }

  @override
  void onCheckboxChanged(BuildContext context, CheckedItemState state, int position, bool completed) {
    if (state.isChecked) {
      checkedTaskList[position].setCompleted(completed);

    } else {
      taskList[position].setCompleted(completed);
    }

    save(context, state, completed ? ActionType.check : ActionType.uncheck, position);
  }

  @override
  void save(BuildContext context, CheckedItemState state, ActionType action, int position) async {
    int result = await TaskActionHelper.saveTaskToDatabase(
      context, 
      formKey, 
      state.isChecked ? checkedTaskList[position] : taskList[position], 
      databaseHelper);

    String message = "";
    if (result != 0) {
      if (action == ActionType.updateTitle) {
        message = "Title updated successfully";

      } else if (action == ActionType.check) {
        message = "Task done";
        _updateTheOppositeListView(state);
      
      } else if (action == ActionType.uncheck) {
        message = "Task moved to active tasks";
        _updateTheOppositeListView(state);

      } else if (action == ActionType.add) {
        message = "Task saved successfully";
      }

      state.isChecked ? updateCheckedListView() : updateTaskListView();

    } else {
      if (action == ActionType.updateTitle) {
        message = "Problem updating the title";

      } else if (action == ActionType.check) {
        message = "Problem checking the task";
      
      } else if (action == ActionType.uncheck) {
        message = "Problem unchecking the task";

      } else if (action == ActionType.add) {
        message = "Problem saving the task";
      }
    }

    if (message.isNotEmpty) {
      showSnackBar(context, message);
    }
  }

  void _updateTheOppositeListView(CheckedItemState state) {
    state.isChecked ? updateTaskListView() : updateCheckedListView();
  }

  @protected
  void updateTaskListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Task>> taskListFuture = databaseHelper.getTaskList(type, CheckedItemState.unchecked.isChecked, type == TaskListType.InAProject ? project.projectId : -1);  // TODO Update projectId
      taskListFuture.then((taskList) {
        setState(() {
          this.taskList = taskList;
          this.taskControllers = List<TextEditingController>();

          this.taskCount = taskList.length;
          for (int i = 0; i < this.taskList.length; i++) {
            this.taskControllers.add(TextEditingController(
                text: taskList[i].title != null
                    ? taskList[i].title
                    : "",
            ));
          }
        });
      });
    });
  }
}
