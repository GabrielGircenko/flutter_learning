import 'package:flutter/material.dart';
import 'package:flutter_learning/utils/database_helper.dart';
import 'package:flutter_learning/models/note.dart';
import 'package:flutter_learning/utils/visual_helper.dart';
import 'package:intl/intl.dart';

class NoteDetails extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  NoteDetails(this.note, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailsState(this.note, this.appBarTitle);
  }
}

class NoteDetailsState extends State<NoteDetails> {

  var _formKey = GlobalKey<FormState>();
  static var _priorities = ["High", "Low"];

  DatabaseHelper databaseHelper = DatabaseHelper();

  String appBarTitle;
  Note note;

  var titleController = TextEditingController();
  var descriptionController = TextEditingController();

  NoteDetailsState(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    var textStyle = Theme
        .of(context)
        .textTheme
        .title;

    titleController.text = note.title;
    descriptionController.text = note.description;

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
                    /*ListTile(
                      title: DropdownButton(
                          items: _priorities.map((String dropDownStringItem) {
                            return DropdownMenuItem<String>(
                              value: dropDownStringItem,
                              child: Text(dropDownStringItem),
                            );
                          }).toList(),
                          style: textStyle,
                          value: getPriorityAsString(note.priorityId),
                          onChanged: (valueSelectedByUser) {
                            setState(() {
                              debugPrint("User selected $valueSelectedByUser");
                              updatePriorityAnswer(valueSelectedByUser);
                            });
                          }),
                    ),*/

                    // Second element
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: TextFormField(
                        controller: titleController,
                        style: textStyle,
                        validator: (String value) {
                          if (value.isEmpty) {
                            return "Please enter the title.";

                          } else {
                            debugPrint("Something changed in Title Text Field");
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

                    // Third element
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: TextField(
                        controller: descriptionController,
                        style: textStyle,
                        onChanged: (value) {
                          debugPrint(
                              "Something changed in Description Text Field");
                          updateDescription();
                        },
                        decoration: InputDecoration(
                            labelText: "Description",
                            labelStyle: textStyle,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5))),
                      ),
                    ),

                    // Fourth element
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

  // Convert the String priority in the form of integer before saving it to Database
  void updatePriorityAnswer(String value) {
    switch (value) {
      case "High":
        note.priorityId = 1;
        break;

      case "Low":
        note.priorityId = 2;
        break;
    }
  }

  // Convert int priority String priority and display it to the user in DropDown
  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0]; // "High"
        break;

      case 2:
        priority = _priorities[1]; // "Low"
        break;
    }

    return priority;
  }

  // Update the title of Note object
  void updateTitle() {
    note.title = titleController.text;
  }

  // Update the description of Note object
  void updateDescription() {
    note.description = descriptionController.text;
  }

  // Save data to database
  void _save() async {
    if (_formKey.currentState.validate()) {
      moveToLastScreen();

      note.date = DateFormat.yMMMd().format(DateTime.now());
      int result;
      if (note.id != null) {
        // Case 1: Update operation
        result = await databaseHelper.updateNote(note);
      } else {
        // Case 2: Insert Operation
        result = await databaseHelper.insertNote(note);
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
    if (note.id == null) {
      VisualHelper.showAlertDialog(context, "Status", "No Note was deleted");
      return;
    }

    // Case 2: User is trying to delete the old note that already has a valid ID.
    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      VisualHelper.showAlertDialog(context, "Status", "Note Deleted Successfully");
    } else {
      VisualHelper.showAlertDialog(context, "Status", "Error Occured while Deleting Note");
    }
  }
}
