import 'package:flutter/material.dart';
import 'package:flutter_learning/enums/action_type.dart';
import 'package:flutter_learning/models/project.dart';
import 'package:flutter_learning/utils/screen_with_snackbar.dart';
import 'package:flutter_learning/screens/actions_interface.dart';
import 'package:flutter_learning/utils/database_helper.dart';
import 'package:flutter_learning/models/task.dart';
import 'package:flutter_learning/utils/task_action_helper.dart';

abstract class TaskListAbs extends StatefulWidget {}

abstract class TaskListAbsState extends State<TaskListAbs> with ActionsInterface<Task>, ScreenWithSnackbar {
  @protected
  DatabaseHelper databaseHelper = DatabaseHelper();
  @protected
  List<Task> taskList;
  @protected
  List<Project> projectList;
  @protected
  List<TextEditingController> taskControllers;
  @protected
  int taskCount = 0;
  @protected
  int projectCount = 0;
  @protected
  var formKey = GlobalKey<FormState>();

  @override
  void delete(BuildContext context, Task task) async {
    int result = await databaseHelper.deleteTask(task.taskId, task.projectId);
    if (result != 0) {
      showSnackBar(context, "Task Deleted Successfully");
      updateTaskListView();
    }
  }

  @override
  void save(BuildContext context, ActionType action, int position) async {
    await TaskActionHelper.saveTaskToDatabase(context, formKey, taskList[position], databaseHelper);
  }

  @protected
  void updateTaskListView() {}
}
