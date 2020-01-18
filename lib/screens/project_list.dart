import 'package:flutter/material.dart';
import 'package:flutter_learning/enums/movementType.dart';
import 'package:flutter_learning/models/project.dart';
import 'package:flutter_learning/utils/list_generator_helper.dart';
import 'package:flutter_learning/utils/visual_helper.dart';
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

class ProjectListState extends State<ProjectList> with ActionsInterface<Project> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Project> projectList;
  List<TextEditingController> projectControllers;
  var _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var textStyle = Theme.of(context).textTheme.title;
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
            _addBlankProject();
          },
          tooltip: "Add Project",
          child: Icon(Icons.add),
        ),
        body: Form(
            key: _formKey,
            child: getKeepLikeListView(this, 
              projectList, _getProjectListCount(), projectControllers)
          )
        );
  }

  void delete(BuildContext context, Project project) async {
    int result = await databaseHelper.deleteProject(project.projectId);
    if (result != 0) {
      _showSnackBar(context, "Project Deleted Successfully");
      updateProjectListView();
    }
  }

  void reorder(BuildContext context, Project project, MovementType movementType) async {
    int result = await databaseHelper.reorderProject(project.projectPosition, movementType);
    if (result != 0) {
      _showSnackBar(context, "Project Moved Successfully");
      updateProjectListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void updateProjectListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Project>> projectListFuture =
          databaseHelper.getProjectList();
      projectListFuture.then((projectList) {
        setState(() {
          this.projectList = projectList;
          this.projectControllers = List<TextEditingController>();

          for (int i = 0; i < this.projectList.length; i++) {
            this.projectControllers.add(TextEditingController(
                text: projectList[i].title != null
                    ? projectList[i].title
                    : "",
            ));
          }
        });
      });
    });
  }

  void updateTitle(int position) {
    projectList[position].title = projectControllers[position].text;
  }

  // Save data to database
  void save(int position) async {
    if (_formKey.currentState.validate()) {
      int result;
      if (projectList[position] != null && projectList[position].projectId != null) {
        // Case 1: Update operation
        result = await databaseHelper.updateProject(projectList[position]);

      } else {
        // Case 2: Insert Operation
        result = await databaseHelper.insertProject(projectList[position]);
      }

      if (result != 0) {
        // Success
        VisualHelper.showAlertDialog(
            context, "Status", "Project Saved Successfully");

      } else {
        // Failure
        VisualHelper.showAlertDialog(
            context, "Status", "Problem Saving Project");
      }
    }
  }

  void _delete2(int position) async {
    // Case 1: If user is trying to delete the NEW TASK i.e. he has come to
    // the detail page by pressing the FAB of TaskList page.
    if (projectList[position].projectId == null) {
      VisualHelper.showAlertDialog(
          context, "Status", "No Priority was deleted");
      return;
    }

    // Case 2: User is trying to delete the old note that already has a valid ID.
    int result =
        await databaseHelper.deleteProject(projectList[position].projectId);
    if (result != 0) {
      VisualHelper.showAlertDialog(
          context, "Status", "Priority Deleted Successfully");
    } else {
      VisualHelper.showAlertDialog(
          context, "Status", "Error Occured while Deleting Priority");
    }
  }

  void _addBlankProject() {
    projectList.add(new Project.withTitleAndPosition("", projectList.length));
    save(projectList.length - 1);
    updateProjectListView();
  }

  int _getProjectListCount() {
    if (this.projectList != null) {
      return this.projectList.length;

    } else {
      return 0;
    }
  }
}
