import 'package:flutter/material.dart';
import 'package:flutter_learning/utils/database_helper.dart';
import 'package:flutter_learning/models/task.dart';
import 'package:flutter_learning/utils/visual_helper.dart';
import 'package:intl/intl.dart';

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
  Task task;

  var titleController = TextEditingController();
  var descriptionController = TextEditingController();

  TaskDetailsState(this.task, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    var textStyle = Theme
        .of(context)
        .textTheme
        .title;

    titleController.text = task.title;
    descriptionController.text = task.description;

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

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  // TODO Change IntArray with Array<Int>
  // Convert the String priority in the form of integer before saving it to Database
  void updatePriorityAnswer(String value) {
    switch (value) {
      case "High":
        task.priorityId = 1;
        break;

      case "Low":
        task.priorityId = 2;
        break;
    }
  }

  // Update the title of Note object
  void updateTitle() {
    task.title = titleController.text;
  }

  // Update the description of Note object
  void updateDescription() {
    task.description = descriptionController.text;
  }

  // Save data to database
  void _save() async {
    if (_formKey.currentState.validate()) {
      moveToLastScreen();

      task.date = DateFormat.yMMMd().format(DateTime.now());
      int result;
      if (task.id != null) {
        // Case 1: Update operation
        result = await databaseHelper.updateTask(task);
      } else {
        // Case 2: Insert Operation
        result = await databaseHelper.insertTask(task);
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
    if (task.id == null) {
      VisualHelper.showAlertDialog(context, "Status", "No Note was deleted");
      return;
    }

    // Case 2: User is trying to delete the old note that already has a valid ID.
    int result = await databaseHelper.deleteTask(task.id);
    if (result != 0) {
      VisualHelper.showAlertDialog(context, "Status", "Note Deleted Successfully");
    } else {
      VisualHelper.showAlertDialog(context, "Status", "Error Occured while Deleting Note");
    }
  }
}
