import 'package:flutter_learning/utils/database_helper.dart';

class Priority {
  int _priorityId;
  String _title;

  Priority(this._title);

  Priority.withId(this._priorityId, this._title);

  int get priorityId => _priorityId;

  String get title => _title;

  set title(String newTitle) {
    if (newTitle.length <= 255) {
      this._title = newTitle;
    }
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    if (priorityId != null) map[DatabaseHelper.colPriorityId] = _priorityId;

    map[DatabaseHelper.colPriorityTitle] = _title;

    return map;
  }

  Priority.fromMapObject(Map<String, dynamic> map) {
    this._priorityId = map[DatabaseHelper.colPriorityId];
    this._title = map[DatabaseHelper.colPriorityTitle];
  }
}