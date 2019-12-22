import 'package:flutter_learning/utils/database_helper.dart';

class Project {
  int _priorityId;
  String _title;

  Project(this._title);

  Project.withId(this._priorityId, this._title);

  int get priorityId => _priorityId;

  String get title => _title;

  set title(String newTitle) {
    if (newTitle.length <= 255) {
      this._title = newTitle;
    }
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    if (priorityId != null) map[DatabaseHelper.colProjectId] = _priorityId;

    map[DatabaseHelper.colProjectTitle] = _title;

    return map;
  }

  Project.fromMapObject(Map<String, dynamic> map) {
    this._priorityId = map[DatabaseHelper.colProjectId];
    this._title = map[DatabaseHelper.colProjectTitle];
  }
}