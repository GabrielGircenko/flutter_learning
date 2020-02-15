
import 'package:meta/meta.dart';

class AbsWithProjectId {
  
  @protected
  int projectIdProtected; // setting this to -1 was removed due to incorrect adding of a project
  
  bool _completed = false;

  @protected
  int dateModifiedProtected;

  int get projectId => projectIdProtected;

  bool get completed => _completed;

  int get dateModified => dateModifiedProtected;

  void setCompleted(bool value) {
    _completed = value;
  }
}