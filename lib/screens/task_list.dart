import 'package:flutter/material.dart';
import 'package:flutter_learning/enums/movement_type.dart';
import 'package:flutter_learning/enums/task_list_type.dart';
import 'package:flutter_learning/models/project.dart';
import 'package:flutter_learning/models/task.dart';
import 'package:flutter_learning/screens/task_details.dart';
import 'package:flutter_learning/screens/task_list_abs.dart';
import 'package:flutter_learning/utils/list_generator_helper.dart';
import 'package:sqflite/sqflite.dart';

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
  
  String appBarTitle;
  Project project;

  TaskListState(this.project, this.appBarTitle);
  
  @override
  Widget build(BuildContext context) {
    if (projectList == null) {
      projectList = List<Project>();
    }

    if (taskList == null) {
      taskList = List<Task>();
      updateTaskListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle + " Tasks"),
      ),
      body: Form(
        key: formKey,
        child: getKeepLikeListView(this, taskList, taskCount, taskControllers, false)
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint("FAB clicked");
          navigateToTaskDetails(Task("", taskList.length, "", project.projectId, project.projectPosition), "Add Task");
        },
        tooltip: "Add Task",
        child: Icon(Icons.add),
      ),
    );
  }

  @override
  void updateTitle(int position) {
    taskList[position].title = taskControllers[position].text;
  }

  @override
  void reorder(BuildContext context, Task task, MovementType movementType) async {
    int result = await databaseHelper.reorderTask(task.projectId, task.taskPosition, movementType);
    if (result != 0) {
      showSnackBar(context, "Task Moved Successfully");
      updateTaskListView();
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

  void updateTaskListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Task>> taskListFuture = databaseHelper.getTaskList(TaskListType.InAProject, project.projectId);  // TODO Update projectId
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