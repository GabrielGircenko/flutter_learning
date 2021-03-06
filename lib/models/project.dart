import 'package:priority_keeper/models/project_id.dart';
import 'package:priority_keeper/utils/bool_map_helper.dart';
import 'package:priority_keeper/utils/database_helper.dart';

class Project extends AbsWithProjectId {
  int _projectPosition;
  String _title;

  Project.withTitleAndPosition(this._title, this._projectPosition);

  Project.withId(projectIdProtected, this._title);

  int get projectPosition => _projectPosition;

  String get title => _title;

  set title(String newTitle) {
    if (newTitle.length <= 255) {
      this._title = newTitle;
    }
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    if (projectId != null)
      map[DatabaseHelper.colProjectId] = projectIdProtected;
    if (_projectPosition != null)
      map[DatabaseHelper.colProjectPosition] = _projectPosition;

    map[DatabaseHelper.colTitle] = _title;
    map[DatabaseHelper.colProjectCompleted] = BoolMapHelper.toMap(completed);

    return map;
  }

  Project.fromMapObject(Map<String, dynamic> map) {
    this.projectIdProtected = map[DatabaseHelper.colProjectId];
    this._projectPosition = map[DatabaseHelper.colProjectPosition];
    this._title = map[DatabaseHelper.colTitle];
    setCompleted(
        BoolMapHelper.fromMap(map[DatabaseHelper.colProjectCompleted]));
    this.dateModifiedProtected =
        DateTime.parse(map[DatabaseHelper.colDateModified])
            .millisecondsSinceEpoch;
  }
}
