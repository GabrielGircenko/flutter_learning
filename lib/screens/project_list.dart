import 'package:flutter/material.dart';
import 'package:flutter_learning/enums/action_type.dart';
import 'package:flutter_learning/enums/movement_type.dart';
import 'package:flutter_learning/models/project.dart';
import 'package:flutter_learning/utils/screen_with_snackbar.dart';
import 'package:flutter_learning/screens/task_list.dart';
import 'package:flutter_learning/utils/list_generator_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:flutter_learning/utils/database_helper.dart';
import 'actions_interface.dart';

class ProjectList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ProjectListState();
  }
}

class ProjectListState extends State<ProjectList>
    with ActionsInterface<Project>, ScreenWithSnackbar {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Project> projectList;
  List<TextEditingController> projectControllers;
  var _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    if (projectList == null) {
      updateProjectListView();
    }

    return Scaffold(
        appBar: AppBar(
          title: Text("Projects"),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            debugPrint("FAB clicked");
            _addBlankProject(context);
          },
          tooltip: "Add Project",
          child: Icon(Icons.add),
        ),
        body: Form(
            key: _formKey,
            child: getKeepLikeListView(context, this, projectList,
                _getProjectListCount(), projectControllers, false)));
  }

  @override
  void itemClicked(int position) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return TaskList(projectList[position], projectList[position].title);
    }));

    if (result != null) {
      updateProjectListView();
    }
  }

  @override
  void delete(BuildContext context, Project project) async {
    int result = await databaseHelper.deleteProject(project.projectId);
    if (result != 0) {
      showSnackBar(context, "Project deleted successfully");
      updateProjectListView();
    }
  }

  @override
  void reorder(
      BuildContext context, Project project, MovementType movementType) async {
    int result = await databaseHelper.reorderProject(
        project.projectPosition, movementType);
    if (result != 0) {
      showSnackBar(context, "Project moved successfully");
      updateProjectListView();
    }
  }

  @override
  void onCheckboxChanged(BuildContext context, int position, bool completed) {
    projectList[position].setCompleted(completed);
    save(context, completed ? ActionType.check : ActionType.uncheck, position);
  }

  void updateProjectListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Project>> projectListFuture = databaseHelper.getProjectList();
      projectListFuture.then((projectList) {
        setState(() {
          this.projectList = projectList;
          this.projectControllers = List<TextEditingController>();

          for (int i = 0; i < this.projectList.length; i++) {
            this.projectControllers.add(TextEditingController(
                  text:
                      projectList[i].title != null ? projectList[i].title : "",
                ));
          }
        });
      });
    });
  }

  @override
  void updateTitle(int position) {
    projectList[position].title = projectControllers[position].text;
  }

  // Save data to database
  @override
  void save(BuildContext context, ActionType action, int position) async {
    if (_formKey.currentState.validate()) {
      int result;
      if (projectList[position] != null &&
          projectList[position].projectId != null) {
        // Case 1: Update operation
        result = await databaseHelper.updateProject(projectList[position]);

      } else {
        // Case 2: Insert Operation
        result = await databaseHelper.insertProject(projectList[position]);
      }

      if (result != 0) {
        // Success
        String message = "Project saved successfully";
        if (action == ActionType.updateTitle) {
          message = "Title updated successfully";

        } else if (action == ActionType.check) {
          message = "Project done";
        
        } else if (action == ActionType.uncheck) {
          message = "Project moved to active projects";
        }

        showSnackBar(context, message);
        updateProjectListView();

      } else {
        // Failure
        String message = "Problem saving the project";
        if (action == ActionType.updateTitle) {
          message = "Problem updating the title";

        } else if (action == ActionType.check) {
          message = "Problem checking the project";
        
        } else if (action == ActionType.uncheck) {
          message = "Problem unchecking the project";
        } 

        showSnackBar(context, message);
      }
    }
  }

  void _addBlankProject(BuildContext context) {
    projectList.add(new Project.withTitleAndPosition("", projectList.length));
    save(context, ActionType.add, projectList.length - 1);
  }

  int _getProjectListCount() {
    if (this.projectList != null) {
      return this.projectList.length;

    } else {
      return 0;
    }
  }
}
