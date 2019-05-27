import 'package:flutter/material.dart';

class VisualHelper {

  // Returns the priority color
  static Color getPriorityColor(int priority) {
    switch (priority) {
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

  // Returns the priority icon
  static Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
      case 2:
      case 3:
        return Icon(Icons.play_arrow);

      default:
        return Icon(Icons.keyboard_arrow_right);
    }
  }
}