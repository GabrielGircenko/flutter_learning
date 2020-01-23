import 'package:flutter/material.dart';
import 'package:flutter_learning/models/project.dart';
import 'package:flutter_learning/utils/database_helper.dart';
import 'package:flutter_learning/models/task.dart';
import 'package:flutter_learning/utils/visual_helper.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqlite_api.dart';

class TaskDetails extends StatefulWidget {
  final String appBarTitle;
  final Task task;

  TaskDetails(this.task, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return TaskDetailsState(this.task, this.appBarTitle);
  }
}

class TaskDetailsState extends State<TaskDetails> {

  var _formKey = GlobalKey<FormState>();

  DatabaseHelper databaseHelper = DatabaseHelper();

  String appBarTitle;
  Task _task;
  List<Project> _projectList;
  List<DropdownMenuItem<Project>> _dropdownMenuItems;
  Project _selectedProject;

  var titleController = TextEditingController();
  var descriptionController = TextEditingController();

  TaskDetailsState(this._task, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    var textStyle = Theme
        .of(context)
        .textTheme
        .title;
        
    if (_projectList == null) {
      _projectList = List<Project>();
      _updateProjectDropdownView();
    }

    titleController.text = _task.title;
    descriptionController.text = _task.description;

    return WillPopScope(
        onWillPop: () {
          moveToLastScreen();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  moveToLastScreen();
                }),
          ),
          body: Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: ListView(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: TextFormField(
                        controller: titleController,
                        style: textStyle,
                        validator: (String value) {
                          if (value.isEmpty) {
                            return "Please enter the task title.";

                          } else {
                            debugPrint("Something changed in task title field");
                            updateTitle();
                          }
                        },
                        decoration: InputDecoration(
                            labelText: "Title",
                            labelStyle: textStyle,
                            errorStyle: TextStyle(
                              fontSize: 15
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5))),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: TextField(
                        controller: descriptionController,
                        style: textStyle,
                        onChanged: (value) {
                          debugPrint(
                              "Something changed in task description field");
                          updateDescription();
                        },
                        decoration: InputDecoration(
                            labelText: "Description",
                            labelStyle: textStyle,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5))),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: DropdownButton(
                        value: _selectedProject,
                        items: _dropdownMenuItems,
                        onChanged: _onChangedProject,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: RaisedButton(
                                color: Theme
                                    .of(context)
                                    .primaryColorDark,
                                textColor: Theme
                                    .of(context)
                                    .primaryColorLight,
                                child: Text(
                                  "Save",
                                  textScaleFactor: 1.5,
                                ),
                                onPressed: () {
                                  debugPrint("Save button clicked");
                                  _save();
                                }),
                          ),
                          Container(
                            width: 8,
                          ),
                          Expanded(
                            child: RaisedButton(
                                color: Theme
                                    .of(context)
                                    .primaryColorDark,
                                textColor: Theme
                                    .of(context)
                                    .primaryColorLight,
                                child: Text(
                                  "Delete",
                                  textScaleFactor: 1.5,
                                ),
                                onPressed: () {
                                  debugPrint("Delete button clicked");
                                  _delete();
                                }),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )),
        ));
  }
  
  void _onChangedProject(Project selectedProject) {
    setState(() {
      _selectedProject = selectedProject; 
      _updateTasksProjectId();
    });
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  void _updateProjectDropdownView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Project>> projectListFuture =
          databaseHelper.getProjectList();
      projectListFuture.then((projectList) {
        setState(() {
          this._projectList = projectList;
          this._dropdownMenuItems = _buildDropdownMenuItems(projectList);
          this._selectedProject = this._projectList[0];
          if (this._task.projectId >= 0) {
            for (Project project in _projectList) {
              if (project.projectId == this._task.projectId) {
                this._selectedProject = project;
                break;
              }
            }
          }
        });
      });
    });
  }

  List<DropdownMenuItem<Project>> _buildDropdownMenuItems(List<Project> list) {
    List<DropdownMenuItem<Project>> items = List();
    for (Project project in list) {
      items.add(
        DropdownMenuItem(
          value: project,
          child: Text(project.title)
        )
      );
    }

    return items;
  }

  // Update the title of Note object
  void updateTitle() {
    _task.title = titleController.text;
  }

  // Update the description of Note object
  void updateDescription() {
    _task.description = descriptionController.text;
  }

  void _updateTasksProjectId() {
    _task.projectId = _selectedProject.projectId;
  }

  // Save data to database
  void _save() async {
    if (_formKey.currentState.validate()) {
      moveToLastScreen();

      _task.date = DateFormat.yMMMd().format(DateTime.now());
      int result;
      if (_task.taskId != null) {
        // Case 1: Update operation
        result = await databaseHelper.updateTask(_task);

      } else {
        // Case 2: Insert Operation
        result = await databaseHelper.insertTask(_task);
      }

      if (result != 0) {
        // Success
        VisualHelper.showAlertDialog(context, "Status", "Note Saved Successfully");

      } else {
        // Failure
        VisualHelper.showAlertDialog(context, "Status", "Problem Saving Note");
      }
    }
  }

  void _delete() async {
    moveToLastScreen();

    // Case 1: If user is trying to delete the NEW NOTE i.e. he has come to
    // the detail page by pressing the FAB of NoteList page.
    if (_task.taskId == null) {
      VisualHelper.showAlertDialog(context, "Status", "No Note was deleted");
      return;
    }

    // Case 2: User is trying to delete the old note that already has a valid ID.
    int result = await databaseHelper.deleteTask(_task.taskId);
    if (result != 0) {
      VisualHelper.showAlertDialog(context, "Status", "Note Deleted Successfully");
    } else {
      VisualHelper.showAlertDialog(context, "Status", "Error Occured while Deleting Note");
    }
  }
}
