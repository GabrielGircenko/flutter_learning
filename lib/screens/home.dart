import 'package:flutter/material.dart';
import 'package:flutter_learning/enums/task_list_type.dart';
import 'package:flutter_learning/models/project.dart';
import 'package:flutter_learning/screens/project_list.dart';
import 'package:flutter_learning/screens/task_list_abs.dart';
import 'package:flutter_learning/utils/list_generator_helper.dart';
import 'package:flutter_learning/models/task.dart';
import 'package:sqflite/sqflite.dart';

class Home extends TaskListAbs {
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends TaskListAbsState {

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
      body: Form(
        key: formKey,
        child: getKeepLikeListView(context, this, taskList, taskCount, taskControllers, true)
      )
    );
  }

  @override
  void updateTitle(int position) {
    taskList[position].title = taskControllers[position].text;
  }

  void navigateToProjects() async {
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ProjectList();
    }));

    updateTaskListView();
  }

  void updateTaskListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Task>> taskListFuture = databaseHelper.getTaskList(TaskListType.Home, -1);
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
