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

    if (priorityId != null) map["priorityId"] = _priorityId;

    map["title"] = _title;

    return map;
  }

  Priority.fromMapObject(Map<String, dynamic> map) {
    this._priorityId = map["priorityId"];
    this._title = map["title"];
  }
}