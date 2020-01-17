import 'package:flutter_learning/utils/database_helper.dart';

class Task {
  int _id;
  String _title;
  String _description;
  String _date;
  int _projectId = -1;

  Task(this._title, this._date, this._projectId, [this._description]);

  Task.withId(this._id, this._title, this._date, this._projectId,
      [this._description]);

  int get id => _id;

  String get title => _title;

  String get description => _description;

  int get projectId => _projectId;

  String get date => _date;

  set title(String newTitle) {
    if (newTitle.length <= 255) {
      this._title = newTitle;
    }
  }

  set description(String newDescription) {
    if (newDescription.length <= 255) {
      this._description = newDescription;
    }
  }

  set projectId(int newPriority) {
    this._projectId = newPriority;
  }

  set date(String newDate) {
    this._date = newDate;
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    if (id != null) map[DatabaseHelper.colTaskId] = _id;

    map[DatabaseHelper.colTitle] = _title;
    map[DatabaseHelper.colDescription] = _description;
    map[DatabaseHelper.colProjectId] = _projectId;
    map[DatabaseHelper.colDate] = _date;

    return map;
  }

  Task.fromMapObject(Map<String, dynamic> map) {
    this._id = map[DatabaseHelper.colTaskId];
    this._title = map[DatabaseHelper.colTitle];
    this._description = map[DatabaseHelper.colDescription];
    this._projectId = map[DatabaseHelper.colProjectId];
    this._date = map[DatabaseHelper.colDate];
  }
}
