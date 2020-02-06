import 'package:flutter/material.dart';
import 'package:flutter_learning/enums/action_type.dart';
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
  @protected
  Project project;
  @protected
  TaskListType type;

  @override
  void delete(BuildContext context, Task task) async {
    int result = await databaseHelper.deleteTask(task.taskId, task.projectId);
    if (result != 0) {
      showSnackBar(context, "Task deleted successfully");
      updateTaskListView();
    }
  }

  @override
  void onCheckboxChanged(BuildContext context, int position, bool completed) {
    taskList[position].setCompleted(completed);
    save(context, completed ? ActionType.check : ActionType.uncheck, position);
  }

  @override
  void save(BuildContext context, ActionType action, int position) async {
    int result = await TaskActionHelper.saveTaskToDatabase(context, formKey, taskList[position], databaseHelper);
    String message = "";
    if (result != 0) {
      if (action == ActionType.updateTitle) {
        message = "Title updated successfully";

      } else if (action == ActionType.check) {
        message = "Task done";
      
      } else if (action == ActionType.uncheck) {
        message = "Task moved to active tasks";

      } else if (action == ActionType.add) {
        message = "Task saved successfully";
      }

      updateTaskListView();

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

  @protected
  void updateTaskListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Task>> taskListFuture = databaseHelper.getTaskList(type, type == TaskListType.InAProject ? project.projectId : -1);  // TODO Update projectId
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
