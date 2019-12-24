import 'package:flutter_learning/utils/database_helper.dart';

class Project {
  int _projectId;
  int _projectPosition;
  String _title;

  //Project(this._title);

  Project.withTitleAndPosition(this._title, this._projectPosition);

  Project.withId(this._projectId, this._title);

  int get projectId => _projectId;

  int get projectPosition => _projectPosition;

  String get title => _title;

  set title(String newTitle) {
    if (newTitle.length <= 255) {
      this._title = newTitle;
    }
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    if (projectId != null) map[DatabaseHelper.colProjectId] = _projectId;
    if (_projectPosition != null) map[DatabaseHelper.colProjectPosition] = _projectPosition;

    map[DatabaseHelper.colProjectTitle] = _title;

    return map;
  }

  Project.fromMapObject(Map<String, dynamic> map) {
    this._projectId = map[DatabaseHelper.colProjectId];
    this._projectPosition = map[DatabaseHelper.colProjectPosition];
    this._title = map[DatabaseHelper.colProjectTitle];
  }
}