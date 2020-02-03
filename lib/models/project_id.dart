
import 'package:meta/meta.dart';

class AbsWithProjectId {
  
  @protected
  int projectIdProtected; // setting this to -1 was removed due to incorrect adding of a project

  int get projectId => projectIdProtected;
}