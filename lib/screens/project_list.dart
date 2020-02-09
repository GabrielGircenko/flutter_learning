import 'package:flutter/material.dart';
import 'package:flutter_learning/enums/action_type.dart';
import 'package:flutter_learning/enums/checked_item_state.dart';
import 'package:flutter_learning/enums/movement_type.dart';
import 'package:flutter_learning/enums/screen_type.dart';
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
  List<Project> checkedProjectList;
  List<TextEditingController> checkedProjectControllers;

  var _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    if (projectList == null) {
      updateUncheckedListView();
    }

    if (checkedProjectList == null) {
      updateCheckedListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Projects"),
      ),
      floatingActionButton: Builder(
        builder: (BuildContext context) {
          return FloatingActionButton(
            onPressed: () {
              debugPrint("FAB clicked");
              _addBlankProject(context);
            },
            tooltip: "Add Project",
            child: Icon(Icons.add),
            );
          }
        ),
      body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: new Container(
              child: new Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new Flexible(
                    child: getKeepLikeListView(context, this, projectList, CheckedItemState.unchecked,
                                              _getProjectListCount(), projectControllers, ScreenType.projects),
                  ),
                  Divider(),
                  Text("Checked items"), 
                  getKeepLikeListView(context, this, checkedProjectList, CheckedItemState.checked,
                                              _getCheckedProjectListCount(), checkedProjectControllers, ScreenType.projects),
                ],
              ),
            ),
          ),
      ),
    );
  }

  @override
  void itemClicked(CheckedItemState state, int position) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return TaskList(state.isChecked ? checkedProjectList[position] : projectList[position], 
                      state.isChecked ? checkedProjectList[position].title : projectList[position].title);
    }));

    if (result != null) {
      state.isChecked ? updateCheckedListView() : updateUncheckedListView();
    }
  }

  @override
  void delete(BuildContext context, Project project, CheckedItemState state) async {
    int result = await databaseHelper.deleteProject(state.isChecked, project.projectId);
    if (result != 0) {
      showSnackBar(context, "Project deleted successfully");
      state.isChecked ? updateCheckedListView() : updateUncheckedListView();
    }
  }

  @override
  void reorder(BuildContext context, Project project, CheckedItemState state, 
                MovementType movementType) async {

    int result = await databaseHelper.reorderProject(
        project.projectPosition, state.isChecked, movementType);
    if (result != 0) {
      showSnackBar(context, "Project moved successfully");
      state.isChecked ? updateCheckedListView() : updateUncheckedListView();
    }
  }

  @override
  void onCheckboxChanged(BuildContext context, CheckedItemState state, int position, bool completed) {
    if (state.isChecked) {
      checkedProjectList[position].setCompleted(completed);

    } else {
      projectList[position].setCompleted(completed);
    }

    save(context, state, completed ? ActionType.check : ActionType.uncheck, position);
  }

  @override
  void updateUncheckedListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Project>> projectListFuture = databaseHelper.getProjectList(false);
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
  void updateCheckedListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Project>> projectListFuture = databaseHelper.getProjectList(true);
      projectListFuture.then((projectList) {
        setState(() {
          this.checkedProjectList = projectList;
          this.checkedProjectControllers = List<TextEditingController>();

          for (int i = 0; i < this.checkedProjectList.length; i++) {
            this.checkedProjectControllers.add(TextEditingController(
                  text: checkedProjectList[i].title != null ? checkedProjectList[i].title : "",
                ));
          }
        });
      });
    });
  }

  @override
  void updateTitle(CheckedItemState state, int position) {
    if (state.isChecked) {
      checkedProjectList[position].title = checkedProjectControllers[position].text;
    
    } else {
      projectList[position].title = projectControllers[position].text;
    }
  }

  // Save data to database
  @override
  void save(BuildContext context, CheckedItemState state, ActionType action, int position) async {
    if (_formKey.currentState.validate()) {
      int result;
      if (projectList[position] != null &&
          projectList[position].projectId != null) {
        // Case 1: Update operation
        if (state.isChecked) {
          result = await databaseHelper.updateProject(checkedProjectList[position]);
        
        } else {
          result = await databaseHelper.updateProject(projectList[position]);
        }

        if (action == ActionType.check || action == ActionType.uncheck) {
          result *= await databaseHelper.updateProjectPositionsAfterOnCheckedChanged();
        }

      } else {
        // Case 2: Insert Operation only for unchecked project list
        result = await databaseHelper.insertProject(projectList[position]);
      }

      String message = "";

      if (result != 0) {
        state.isChecked ? updateCheckedListView() : updateUncheckedListView();

        if (action == ActionType.updateTitle) {
          message = "Title updated successfully";

        } else if (action == ActionType.check) {
          message = "Project done";
          updateTheOppositeListView(state);
        
        } else if (action == ActionType.uncheck) {
          message = "Project moved to active projects";
          updateTheOppositeListView(state);

        } else if (action == ActionType.add) {
          message = "Project saved successfully";
        }

      } else {
        if (action == ActionType.updateTitle) {
          message = "Problem updating the title";

        } else if (action == ActionType.check) {
          message = "Problem checking the project";
        
        } else if (action == ActionType.uncheck) {
          message = "Problem unchecking the project";
        
        } else if (action == ActionType.add) {
          message = "Problem saving the project";
        } 
      }

      if (message.isNotEmpty) {
        showSnackBar(context, message);
      }
    }
  }

  void _addBlankProject(BuildContext context) {
    projectList.add(new Project.withTitleAndPosition("", projectList.length));
    save(context, CheckedItemState.unchecked, ActionType.add, projectList.length - 1);
  }

  int _getProjectListCount() {
    if (this.projectList != null) {
      return this.projectList.length;

    } else {
      return 0;
    }
  }

  int _getCheckedProjectListCount() {
    if (this.checkedProjectList != null) {
      return this.checkedProjectList.length;

    } else {
      return 0;
    }
  }
}
