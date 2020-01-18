import 'package:flutter/material.dart';
import 'package:flutter_learning/models/project.dart';
import 'package:flutter_learning/screens/actions_interface.dart';
import 'package:flutter_learning/screens/project_list.dart';
import 'package:flutter_learning/utils/list_generator_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'task_details.dart';
import 'dart:async';
import 'package:flutter_learning/utils/database_helper.dart';
import 'package:flutter_learning/models/task.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> with ActionsInterface<Project> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Task> taskList;
  List<Project> projectList;
  List<TextEditingController> taskControllers;
  int taskCount = 0;
  int projectCount = 0;

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
        title: Text("Tasks"),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.settings),
          tooltip: "Projects",
          onPressed: () {
            navigateToProjects();
          },)
        ],
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

  void _delete(BuildContext context, Task task) async {
    int result = await databaseHelper.deleteTask(task.id);
    if (result != 0) {
      _showSnackBar(context, "Task Deleted Successfully");
      updateTaskListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigateToProjects() async {
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ProjectList();
    }));

    if (result != null) {
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
      Future<List<Task>> taskListFuture = databaseHelper.getTaskList();
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
