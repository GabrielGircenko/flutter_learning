import 'package:flutter/material.dart';
import 'package:priority_keeper/models/task.dart';
import 'package:priority_keeper/utils/database_helper.dart';

class TaskActionHelper {
  static Future<int> saveTaskToDatabase(
      BuildContext context,
      GlobalKey<FormState> formKey,
      Task task,
      DatabaseHelper databaseHelper) async {
    if (formKey.currentState.validate()) {
      int result;
      if (task.taskId != null) {
        // Case 1: Update operation
        result = await databaseHelper.updateTask(task);
      } else {
        // Case 2: Insert Operation
        result = await databaseHelper.insertTask(task);
      }

      return result;
    }

    return 0;
  }
}
