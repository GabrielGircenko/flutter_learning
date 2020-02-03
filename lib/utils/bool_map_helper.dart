
class BoolMapHelper {
  static bool fromMap(int tinyInt) {
    if (tinyInt == 0) {
      return false;
    
    } else {
      return true;
    }
  }

  static int toMap(bool value) {
    if (value) {
      return 1;
    
    } else {
      return 0;
    }
  }
}