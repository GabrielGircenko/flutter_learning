import 'package:flutter/material.dart';

class VisualHelper {

  // Returns the priority color
  static Color getProjectColor(int projectId) {
    switch (projectId) {
      case 1:
        return Colors.red;

      case 2:
        return Colors.orange;

      case 3:
        return Colors.yellow;

      default:
        return Colors.blue;
    }
  }

  // TODO Maybe unnceccesary if everything is done in the getProjectColor
  // Returns the priority icon
  static Icon getProjectIcon(int projectId) {
    return Icon(Icons.keyboard_arrow_right);
    /*switch (projectId) {
      case 1:
      case 2:
      case 3:
        return Icon(Icons.play_arrow);

      default:
        return Icon(Icons.keyboard_arrow_right);
    }*/
  }

  static void showAlertDialog(BuildContext context, String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}