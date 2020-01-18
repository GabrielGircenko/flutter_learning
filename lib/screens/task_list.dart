import 'package:flutter/material.dart';
import 'package:flutter_learning/enums/task_list_type.dart';
import 'package:flutter_learning/models/project.dart';
import 'package:flutter_learning/models/task.dart';
import 'package:flutter_learning/screens/task_details.dart';
import 'package:flutter_learning/screens/task_list_abs.dart';
import 'package:flutter_learning/utils/list_generator_helper.dart';
import 'package:sqflite/sqflite.dart';

class TaskList extends TaskListAbs {
  @override
  State<StatefulWidget> createState() {
    return TaskListState();
  }
}

class TaskListState extends TaskListAbsState {
  
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
        title: Text("Tasks"), // TODO Add Project name here
      ),
      body: getKeepLikeListView(this, taskList, taskCount, taskControllers),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint("FAB clicked");
          navigateToTaskDetails(Task("", "", -1, -1), "Add Task");
        },
        tooltip: "Add Task",
        child: Icon(Icons.add),
      ),
    );
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
      Future<List<Task>> taskListFuture = databaseHelper.getTaskList(TaskListType.InAProject, -1);  // TODO Update projectId
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