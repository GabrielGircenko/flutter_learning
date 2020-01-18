import 'package:flutter/material.dart';
import 'package:flutter_learning/models/project.dart';
import 'package:flutter_learning/screens/project_list.dart';
import 'package:sqflite/sqflite.dart';
import 'task_details.dart';
import 'dart:async';
import 'package:flutter_learning/utils/database_helper.dart';
import 'package:flutter_learning/models/task.dart';
import 'package:flutter_learning/utils/visual_helper.dart';

class TaskList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TaskListState();
  }
}

class TaskListState extends State<TaskList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Task> taskList;
  List<Project> projectList;
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
      body: getTaskListView(),
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

  ListView getTaskListView() {
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
                      VisualHelper.getProjectColor(this.taskList[position].projectId),
                  child: VisualHelper.getProjectIcon(this.taskList[position].projectId)),
              title: Text(
                this.taskList[position].title,
                style: titleStyle,
              ),
              subtitle: Text(this.taskList[position].date),
              trailing: GestureDetector(
                  child: Icon(
                Icons.delete,
                color: Colors.grey,
              ),
              onTap: () {
                    _delete(context, this.taskList[position]);
              },
              ),
              onTap: () {
                debugPrint("ListTile Tapped");
                navigateToTaskDetails(this.taskList[position], "Edit Note");
              },
            ),
          );
        });
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
          this.taskCount = taskList.length;
        });
      });
    });
  }
}
