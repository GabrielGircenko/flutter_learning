
import 'package:meta/meta.dart';

class AbsWithProjectId {
  @protected
  int projectIdProtected = -1;

  int get projectId => projectIdProtected;
}