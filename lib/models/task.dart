import 'package:flutter_learning/models/project_id.dart';
import 'package:flutter_learning/utils/bool_map_helper.dart';
import 'package:flutter_learning/utils/database_helper.dart';

class Task extends AbsWithProjectId {
  
  int _taskId;
  String _title;
  String _description;
  int _taskPosition;
  int _projectPosition;

  Task(this._title, this._taskPosition, projectId, this._projectPosition, [this._description]) {
    projectIdProtected = projectId;
  }

  Task.withId(this._taskId, this._taskPosition, this._title, projectIdProtected, this._projectPosition,
      [this._description])  {
    projectIdProtected = projectId;
  }

  int get taskId => _taskId;

  String get title => _title;

  String get description => _description;

  int get taskPosition => _taskPosition;

  int get projectPosition => _projectPosition;

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

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    if (taskId != null) map[DatabaseHelper.colTaskId] = _taskId;

    map[DatabaseHelper.colTitle] = _title;
    map[DatabaseHelper.colTaskDescription] = _description;
    map[DatabaseHelper.colProjectId] = projectIdProtected;
    map[DatabaseHelper.colTaskPosition] = _taskPosition;
    map[DatabaseHelper.colTaskCompleted] = BoolMapHelper.toMap(completed);

    return map;
  }

  Task.fromMapObject(Map<String, dynamic> map) {
    this._taskId = map[DatabaseHelper.colTaskId];
    this._title = map[DatabaseHelper.colTitle];
    this._description = map[DatabaseHelper.colTaskDescription];
    this.projectIdProtected = map[DatabaseHelper.colProjectId];
    this._taskPosition = map[DatabaseHelper.colTaskPosition];
    setCompleted(BoolMapHelper.fromMap(map[DatabaseHelper.colTaskCompleted]));
    this.dateModifiedProtected = DateTime.parse(map[DatabaseHelper.colDateModified]).millisecondsSinceEpoch;
  }
}
