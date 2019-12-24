import 'package:flutter/material.dart';
import 'package:flutter_learning/models/project.dart';
import 'package:flutter_learning/utils/visual_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:flutter_learning/utils/database_helper.dart';

class ProjectList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ProjectListState();
  }
}

class ProjectListState extends State<ProjectList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Project> projectList = List<Project>();
  List<TextEditingController> priorityControllers;
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
            child: Padding(
                padding: EdgeInsets.all(16),
                child: ListView.builder(
                    itemCount: projectList.length,
                    itemBuilder: (BuildContext context, int position) {
                      return Card(
                          color: Colors.white,
                          elevation: 2,
                          child: ListTile(
                              leading: CircleAvatar(
                                  backgroundColor:
                                      VisualHelper.getPriorityColor(this
                                          .projectList[position]
                                          .priorityId),
                                  child: VisualHelper.getPriorityIcon(
                                      this.projectList[position].priorityId)),
                              title: TextFormField(
                                  controller: priorityControllers[position],
                                  validator: (String value) {
                                    if (value.isEmpty) {
                                      return "Please enter the priority title.";

                                    } else {
                                      debugPrint(
                                          "Something changed in Title Text Field");
                                      updateTitle(position);
                                    }
                                  },
                                  onFieldSubmitted: (_) => _save(position)),
                              trailing: GestureDetector(
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.grey,
                                ),
                                onTap: () {
                                  _delete(context, this.projectList[position]);
                                },
                              ),
                              onTap: () {
                                debugPrint("Priority Tapped");
                              }));
                    }))));
  }

  void _delete(BuildContext context, Project priority) async {
    int result = await databaseHelper.deleteProject(priority.priorityId);
    if (result != 0) {
      _showSnackBar(context, "Priority Deleted Successfully");
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
          this.priorityControllers = List<TextEditingController>();

          for (int i = 0; i < this.projectList.length; i++) {
            this.priorityControllers.add(TextEditingController(
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
    projectList[position].title = priorityControllers[position].text;
  }

  // Save data to database
  void _save(int position) async {
    if (_formKey.currentState.validate()) {
      int result;
      if (projectList[position] != null && projectList[position].priorityId != null) {
        // Case 1: Update operation
        result = await databaseHelper.updateProject(projectList[position]);

      } else {
        // Case 2: Insert Operation
        result = await databaseHelper.insertProject(projectList[position]);
      }

      if (result != 0) {
        // Success
        VisualHelper.showAlertDialog(
            context, "Status", "Priority Saved Successfully");

      } else {
        // Failure
        VisualHelper.showAlertDialog(
            context, "Status", "Problem Saving Priority");
      }
    }
  }

  void _delete2(int position) async {
    // Case 1: If user is trying to delete the NEW NOTE i.e. he has come to
    // the detail page by pressing the FAB of NoteList page.
    if (projectList[position].priorityId == null) {
      VisualHelper.showAlertDialog(
          context, "Status", "No Priority was deleted");
      return;
    }

    // Case 2: User is trying to delete the old note that already has a valid ID.
    int result =
        await databaseHelper.deleteProject(projectList[position].priorityId);
    if (result != 0) {
      VisualHelper.showAlertDialog(
          context, "Status", "Priority Deleted Successfully");
    } else {
      VisualHelper.showAlertDialog(
          context, "Status", "Error Occured while Deleting Priority");
    }
  }

  void _addBlankProject() {
    projectList.add(new Project(""));
    _save(projectList.length - 1);
    updateProjectListView();
  }
}
