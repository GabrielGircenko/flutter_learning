import 'package:flutter/material.dart';
import 'package:flutter_learning/models/project.dart';
import 'package:flutter_learning/utils/screen_with_snackbar.dart';
import 'package:flutter_learning/screens/actions_interface.dart';
import 'package:flutter_learning/utils/database_helper.dart';
import 'package:flutter_learning/models/task.dart';

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
  void delete(BuildContext context, Task task) async {
    int result = await databaseHelper.deleteTask(task.taskId);
    if (result != 0) {
      showSnackBar(context, "Task Deleted Successfully");
      updateTaskListView();
    }
  }

  @protected
  void updateTaskListView() {}
}
