import 'package:flutter/material.dart';
import 'package:flutter_learning/enums/checked_item_state.dart';
import 'package:flutter_learning/enums/screen_type.dart';
import 'package:flutter_learning/enums/task_list_type.dart';
import 'package:flutter_learning/models/project.dart';
import 'package:flutter_learning/screens/project_list.dart';
import 'package:flutter_learning/screens/task_list_abs.dart';
import 'package:flutter_learning/utils/list_generator_helper.dart';
import 'package:flutter_learning/models/task.dart';

class Home extends TaskListAbs {
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends TaskListAbsState {

  @override
  TaskListType type = TaskListType.Home;

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
        child: getKeepLikeListView(context, this, taskList, CheckedItemState.unchecked, taskCount, taskControllers, ScreenType.home)
      )
    );
  }

  void navigateToProjects() async {
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ProjectList();
    }));

    updateTaskListView();
  }
}
