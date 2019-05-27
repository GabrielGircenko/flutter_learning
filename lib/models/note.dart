import 'package:flutter_learning/utils/database_helper.dart';

class Note {
  int _id;
  String _title;
  String _description;
  String _date;
  int _priorityId;

  Note(this._title, this._date, this._priorityId, [this._description]);

  Note.withId(this._id, this._title, this._date, this._priorityId,
      [this._description]);

  int get id => _id;

  String get title => _title;

  String get description => _description;

  int get priorityId => _priorityId;

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

  set priorityId(int newPriority) {
    if (newPriority >= 1 && newPriority <= 2) {
      this._priorityId = newPriority;
    }
  }

  set date(String newDate) {
    this._date = newDate;
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    if (id != null) map[DatabaseHelper.colId] = _id;

    map[DatabaseHelper.colTitle] = _title;
    map[DatabaseHelper.colDescription] = _description;
    map[DatabaseHelper.colPriorityId] = _priorityId;
    map[DatabaseHelper.colDate] = _date;

    return map;
  }

  Note.fromMapObject(Map<String, dynamic> map) {
    this._id = map[DatabaseHelper.colId];
    this._title = map[DatabaseHelper.colTitle];
    this._description = map[DatabaseHelper.colDescription];
    this._priorityId = map[DatabaseHelper.colPriorityId];
    this._date = map[DatabaseHelper.colDate];
  }
}
