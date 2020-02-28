import 'package:flutter/material.dart';
import 'package:priority_keeper/enums/checked_item_state.dart';
import 'package:priority_keeper/enums/screen_type.dart';
import 'package:priority_keeper/enums/task_list_type.dart';
import 'package:priority_keeper/models/project.dart';
import 'package:priority_keeper/models/task.dart';
import 'package:priority_keeper/screens/project_list.dart';
import 'package:priority_keeper/screens/task_list_abs.dart';
import 'package:priority_keeper/utils/list_generator_helper.dart';

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
      updateUncheckedListView();
    }

    return Scaffold(
        appBar: AppBar(
          title: Text("Tasks"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.settings),
              tooltip: "Projects",
              onPressed: () {
                navigateToProjects();
              },
            )
          ],
        ),
        body: Form(
            key: formKey,
            child: getKeepLikeListView(
                context,
                this,
                taskList,
                CheckedItemState.unchecked,
                taskCount,
                taskControllers,
                ScreenType.home)));
  }

  void navigateToProjects() async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ProjectList();
    }));

    updateUncheckedListView();
  }
}
