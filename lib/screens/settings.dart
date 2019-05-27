import 'package:flutter/material.dart';
import 'package:flutter_learning/models/priority.dart';
import 'package:flutter_learning/utils/visual_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:flutter_learning/utils/database_helper.dart';

class Settings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SettingsState();
  }
}

class SettingsState extends State<Settings> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Priority> priorityList;
  var _formKey = GlobalKey<FormState>();
  int count = 0;

  var titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var textStyle = Theme
        .of(context)
        .textTheme
        .title;

    return Scaffold(
        appBar: AppBar(
          title: Text("Settings"),
        ),
        body: Form(
            key: _formKey,
            child: ListView.builder(
                itemCount: count + 1,
                itemBuilder: (BuildContext context, int position) {
                  if (position == count) {
                    return TextFormField(
                      controller: titleController,
                      decoration: InputDecoration(
                          hintText: "Priority Title",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5))),
                    );
                  } else {
                    return Card(
                      color: Colors.white,
                      elevation: 2,
                      child: ListTile(
                        leading: CircleAvatar(
                            backgroundColor: VisualHelper.getPriorityColor(
                                this.priorityList[position].priorityId),
                            child: VisualHelper.getPriorityIcon(
                                this.priorityList[position].priorityId)),
                        title: Text(
                          this.priorityList[position].title,
                          style: textStyle,
                        ),
                        trailing: GestureDetector(
                          child: Icon(
                            Icons.delete,
                            color: Colors.grey,
                          ),
                          onTap: () {
                            _delete(context, this.priorityList[position]);
                          },
                        ),
                        onTap: () {
                          debugPrint("Priority Tapped");
                        },
                      ),
                    );
                  }
                })));
  }

  void _delete(BuildContext context, Priority priority) async {
    int result = await databaseHelper.deletePriority(priority.priorityId);
    if (result != 0) {
      _showSnackBar(context, "Priority Deleted Successfully");
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Priority>> priorityListFuture = databaseHelper.getPriorityList();
      priorityListFuture.then((priorityList) {
        setState(() {
          this.priorityList = priorityList;
          this.count = priorityList.length;
        });
      });
    });
  }
}
