import 'package:flutter/material.dart';
import 'package:flutter_learning/models/task.dart';
import 'package:flutter_learning/utils/database_helper.dart';
import 'package:intl/intl.dart';

class TaskActionHelper {

  static Future<int> saveTaskToDatabase(BuildContext context, GlobalKey<FormState> formKey, 
                          Task task, DatabaseHelper databaseHelper) async {
      if (formKey.currentState.validate()) {
        task.date = DateFormat.yMMMd().format(DateTime.now());
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