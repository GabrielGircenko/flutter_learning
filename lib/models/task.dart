import 'package:flutter_learning/models/project_id.dart';
import 'package:flutter_learning/utils/database_helper.dart';

class Task extends AbsWithProjectId {
  int _taskId;
  String _title;
  String _description;
  String _date;
  int _taskPosition;
  int _projectPosition;

  Task(this._title, this._taskPosition, this._date, projectId, this._projectPosition, [this._description]) {
    projectIdProtected = projectId;
  }

  Task.withId(this._taskId, this._taskPosition, this._title, this._date, projectIdProtected, this._projectPosition,
      [this._description])  {
    projectIdProtected = projectId;
  }

  int get taskId => _taskId;

  String get title => _title;

  String get description => _description;

  int get taskPosition => _taskPosition;

  int get projectPosition => _projectPosition;

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

  set taskPosition(int position) {
    this._taskPosition = position;
  }

  set projectId(int newProjectId) {
    this.projectIdProtected = newProjectId;
  }

  set date(String newDate) {
    this._date = newDate;
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    if (taskId != null) map[DatabaseHelper.colTaskId] = _taskId;

    map[DatabaseHelper.colTitle] = _title;
    map[DatabaseHelper.colDescription] = _description;
    map[DatabaseHelper.colProjectId] = projectIdProtected;
    map[DatabaseHelper.colDate] = _date;
    map[DatabaseHelper.colTaskPosition] = _taskPosition;

    return map;
  }

  Task.fromMapObject(Map<String, dynamic> map) {
    this._taskId = map[DatabaseHelper.colTaskId];
    this._title = map[DatabaseHelper.colTitle];
    this._description = map[DatabaseHelper.colDescription];
    this.projectIdProtected = map[DatabaseHelper.colProjectId];
    this._date = map[DatabaseHelper.colDate];
    this._taskPosition = map[DatabaseHelper.colTaskPosition];
  }
}
