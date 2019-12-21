import 'package:flutter/material.dart';
import 'package:flutter_learning/models/priority.dart';
import 'package:flutter_learning/screens/large_priorities.dart';
import 'package:sqflite/sqflite.dart';
import 'sub_priority_details.dart';
import 'dart:async';
import 'package:flutter_learning/utils/database_helper.dart';
import 'package:flutter_learning/models/note.dart';
import 'package:flutter_learning/utils/visual_helper.dart';

class SubPriorities extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SubPrioritiesState();
  }
}

class SubPrioritiesState extends State<SubPriorities> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;
  List<Priority> priorityList;
  int noteCount = 0;
  int priorityCount = 0;

  @override
  Widget build(BuildContext context) {
    if (priorityList == null) {
      priorityList = List<Priority>();
    }

    if (noteList == null) {
      noteList = List<Note>();
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Notes"),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.settings),
          tooltip: "Settings",
          onPressed: () {
            navigateToSettings();
          },)
        ],
      ),
      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint("FAB clicked");
          navigateToDetails(Note("", "", 2), "Add Note");
        },
        tooltip: "Add Note",
        child: Icon(Icons.add),
      ),
    );
  }

  ListView getNoteListView() {
    TextStyle titleStyle = Theme.of(context).textTheme.subhead;

    return ListView.builder(
        itemCount: noteCount,
        itemBuilder: (BuildContext context, int position) {
          return Card(
            color: Colors.white,
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                  backgroundColor:
                      VisualHelper.getPriorityColor(this.noteList[position].priorityId),
                  child: VisualHelper.getPriorityIcon(this.noteList[position].priorityId)),
              title: Text(
                this.noteList[position].title,
                style: titleStyle,
              ),
              subtitle: Text(this.noteList[position].date),
              trailing: GestureDetector(
                  child: Icon(
                Icons.delete,
                color: Colors.grey,
              ),
              onTap: () {
                    _delete(context, this.noteList[position]);
              },
              ),
              onTap: () {
                debugPrint("ListTile Tapped");
                navigateToDetails(this.noteList[position], "Edit Note");
              },
            ),
          );
        });
  }

  void _delete(BuildContext context, Note note) async {
    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _showSnackBar(context, "Note Deleted Successfully");
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigateToSettings() async {
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return LargePriorities();
    }));

    if (result) {
      updateListView();
    }
  }

  void navigateToDetails(Note note, String title) async {
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return SubPriorityDetails(note, title);
    }));

    if (result) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.noteCount = noteList.length;
        });
      });
    });
  }
}
