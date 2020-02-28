import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:priority_keeper/enums/movement_type.dart';
import 'package:priority_keeper/enums/task_list_type.dart';
import 'package:priority_keeper/models/project.dart';
import 'package:priority_keeper/models/project_id.dart';
import 'package:priority_keeper/models/task.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;
  static Database _database;

  final String _db =
      "projects.db"; // TODO updateDb renaming database file from notes.db in version 3->4
  final int _databaseVersion = 7;

  final String _taskTable = "task_table";
  final String _projectTable = "project_table";
  static final String colTaskId = "id";
  static final String colTaskPosition = "position";
  static final String colTaskCompleted = "task_completed";
  static final String colTaskDescription = "description";
  static final String colProjectId = "projectId";
  static final String colProjectPosition = "position";
  static final String colProjectCompleted = "project_completed";
  static final String colTitle = "title";
  static final String colDateModified = "date_modified";
  //static final String colDateCreated = "date_created";
  //static final String colDateDue = "date_due";

  final String _taskTableOld = "_task_table_old";
  final String _projectTableOld = "_project_table_old";

  final String _taskTableV1 = "note_table";
  final String _projectTableV3 = "priority_table";
  final String _colProjectIdV1 = "priority";
  static final String _colDateV6 = "date";
  static final String _colProjectIdV3 = "priorityId";

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null)
      _databaseHelper = DatabaseHelper._createInstance();

    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) _database = await initializeDatabase();
    return _database;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + _db;

    var projectsDatabase = await openDatabase(path,
        version: _databaseVersion, onCreate: _createDb, onUpgrade: _upgradeDb);
    return projectsDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await _createProjectTable(db);
    await _createTaskTable(db);
  }

  Future _createProjectTable(Database db) async {
    await db.execute(_getCreateProjectTableQuery());
    await db.execute(_getCreateProjectTriggerQuery());
  }

  Future _createTaskTable(Database db) async {
    await db.execute(_getCreateTaskTableQuery());
    await db.execute(_getCreateTaskTriggerQuery());
  }

  String _getCreateProjectTableQuery() {
    return "CREATE TABLE $_projectTable("
        "$colProjectId INTEGER PRIMARY KEY AUTOINCREMENT, "
        "$colProjectPosition INTEGER, "
        "$colTitle TEXT, "
        "$colDateModified INTEGER DEFAULT CURRENT_TIMESTAMP, "
        "$colProjectCompleted TinyInt(1) NOT NULL DEFAULT 0);";
  }

  String _getCreateProjectTriggerQuery() {
    return "CREATE TRIGGER update_project_modified_date "
        "AFTER UPDATE ON $_projectTable "
        "FOR EACH ROW "
        "BEGIN "
        "UPDATE $_projectTable SET $colDateModified = CURRENT_TIMESTAMP WHERE $colProjectId = old.$colProjectId;"
        "END";
  }

  String _getCreateTaskTableQuery() {
    return "CREATE TABLE $_taskTable("
        "$colTaskId INTEGER PRIMARY KEY AUTOINCREMENT, "
        "$colTitle TEXT, "
        "$colTaskDescription TEXT, "
        "$colProjectId INTEGER, "
        "$colDateModified INTEGER DEFAULT CURRENT_TIMESTAMP, "
        "$colTaskPosition INTEGER, "
        "$colTaskCompleted TinyInt(1) NOT NULL DEFAULT 0);";
  }

  String _getCreateTaskTriggerQuery() {
    return "CREATE TRIGGER update_task_modified_date "
        "AFTER UPDATE ON $_taskTable "
        "FOR EACH ROW "
        "BEGIN "
        "UPDATE $_taskTable SET $colDateModified = CURRENT_TIMESTAMP WHERE $colTaskId = old.$colTaskId; "
        "END";
  }

  // TODO Test upgrades
  void _upgradeDb(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      if (oldVersion == 1) {
        // rename a projectId column inside a task table
        await db.execute("ALTER TABLE $_taskTableV1 RENAME TO $_taskTableOld;");

        _createTaskTable(db);

        await db.execute(
            "INSERT INTO $_taskTable ($colTaskId, $colTitle, $colTaskDescription, $colProjectId, $_colDateV6) "
            "SELECT $colTaskId, $colTitle, $colTaskDescription, $_colProjectIdV1, $colDateModified "
            "FROM $_taskTableOld;");

        _createProjectTable(db);

        await db.execute("INSERT INTO $_projectTable ($colProjectPosition) "
            "SELECT $_colProjectIdV1 "
            "FROM $_taskTableOld;");
      } else if (oldVersion == 2) {
        // update the name of project table
        await db.execute(
            "ALTER TABLE $_projectTableV3 RENAME TO $_projectTableOld;");

        _createProjectTable(db);

        await db.execute(
            "INSERT INTO $_projectTable ($colProjectPosition, $colTitle) "
            "SELECT $colProjectId, $colTitle "
            "FROM $_projectTableOld;");
      } else if (oldVersion == 3) {
        // update name of the task and project tables
        await db.execute("ALTER TABLE $_taskTableV1 RENAME TO $_taskTableOld;");

        _createTaskTable(db);

        await db.execute(
            "INSERT INTO $_taskTable ($colTaskId, $colTitle, $colTaskDescription, $colProjectId, $_colDateV6) "
            "SELECT $colTaskId, $colTitle, $colTaskDescription, $_colProjectIdV1, $colDateModified "
            "FROM $_taskTableOld;");

        await db.execute(
            "ALTER TABLE $_projectTableV3 RENAME TO $_projectTableOld;");

        _createProjectTable(db);

        await db.execute(
            "INSERT INTO $_projectTable ($colProjectPosition, $colTitle) "
            "SELECT $_colProjectIdV3, $colTitle "
            "FROM $_projectTableOld;");
      } else if (oldVersion == 4) {
        // update colTaskPosition
        await db.execute("UPDATE $_taskTable "
            "SET $colTaskPosition = $colTaskId;");
      } else if (oldVersion == 5) {
        // add completed columns
        await db.execute(
            "ALTER TABLE $_taskTable ADD COLUMN $colTaskCompleted TinyInt(1) NOT NULL DEFAULT 0;");
        await db.execute(
            "ALTER TABLE $_projectTable ADD COLUMN $colProjectCompleted TinyInt(1) NOT NULL DEFAULT 0;");
      } else if (oldVersion == 6) {
        // add date modified column to project list, rename date column in task list
        await db.execute("ALTER TABLE $_taskTable RENAME TO $_taskTableOld;");

        _createTaskTable(db);

        await db.execute(
            "INSERT INTO $_taskTable ($colTaskId, $colTitle, $colTaskDescription, $colProjectId, $colTaskPosition, $colTaskCompleted) "
            "SELECT $colTaskId, $colTitle, $colTaskDescription, $colProjectId, $colTaskPosition, $colTaskCompleted "
            "FROM $_taskTableOld;");

        await db
            .execute("ALTER TABLE $_projectTable RENAME TO $_projectTableOld;");

        _createProjectTable(db);

        await db.execute(
            "INSERT INTO $_projectTable ($colProjectId, $colProjectPosition, $colTitle, $colProjectCompleted) "
            "SELECT $colProjectId, $colProjectPosition, $colTitle, $colProjectCompleted "
            "FROM $_projectTableOld;");
      }

      await db.execute("DROP TABLE IF EXISTS $_taskTableOld;");
      await db.execute("DROP TABLE IF EXISTS $_projectTableOld;");
    }
  }

  // Fetch Operation: Get all task objects from database
  Future<List<Map<String, dynamic>>> getHomeTaskMapList() async {
    Database db = await this.database;

    // TODO Use INNER JOIN after setting taskPositions in a separate screen
    return await db.rawQuery(
        "SELECT foo.*, $_projectTable.$colProjectPosition as projectPosition "
        "FROM ("
        "SELECT $_taskTable.$colTaskId, $_taskTable.$colTitle, $_taskTable.$colTaskDescription, $_taskTable.$colProjectId, $_taskTable.$colDateModified, $_taskTable.$colTaskCompleted, MIN($_taskTable.$colTaskPosition) as $colTaskPosition "
        "FROM $_taskTable "
        "WHERE $_taskTable.$colTaskCompleted = 0 "
        "GROUP BY $_taskTable.$colProjectId"
        ") foo "
        "JOIN $_projectTable ON foo.$colProjectId = $_projectTable.$colProjectId "
        "WHERE $_projectTable.$colProjectCompleted = 0 "
        "order by $_projectTable.$colProjectPosition;");
  }

  // Fetch Operation: Get all task objects from database
  Future<List<Map<String, dynamic>>> getTaskMapListInsideAProject(
      int projectId, bool checkedItems) async {
    Database db = await this.database;

    int checkedItemsTinyInt = checkedItems ? 1 : 0;

    return await db.rawQuery("SELECT * "
        "FROM $_taskTable "
        "WHERE $colProjectId = $projectId AND $colTaskCompleted = $checkedItemsTinyInt "
        "order by $colTaskPosition;");
  }

  // Insert Operation: Insert a Task object to database
  Future<int> insertTask(Task task) async {
    Database db = await this.database;
    var result = await db.insert(_taskTable, task.toMap());
    return result;
  }

  // Update Operation: Update a Task object and save it to database
  Future<int> updateTask(Task task) async {
    var db = await this.database;
    return await db.update(_taskTable, task.toMap(),
        where: "$colTaskId = ?", whereArgs: [task.taskId]);
  }

  // TODO Don't reorder if the task has the highest value of #colTaskId in the table
  // Delete Operation: Delete a Task object from database
  Future<int> deleteTask(bool checked, int taskId, int projectId) async {
    var db = await this.database;
    var result = await db
        .rawDelete("DELETE FROM $_taskTable WHERE $colTaskId = $taskId");

    if (result != 0) {
      return await _updateTaskPositionsAfterDelete(checked, projectId);
    } else {
      return 0;
    }
  }

  // TODO Make optimization algorithm which will decide if it's neccessary to reorder positions
  Future<int> _updateTaskPositionsAfterDelete(
      bool checked, int projectId) async {
    var taskList =
        await getTaskList(TaskListType.InAProject, checked, projectId);
    return _updateTaskPositions(taskList);
  }

  Future<int> updateTaskPositionsAfterOnCheckedChanged(
      int projectId, bool checked) async {
    var result = 1;

    var taskList = await getTaskList(TaskListType.InAProject, false, projectId);
    if (!checked) {
      taskList = _prepareListForUpdatingPositions(taskList);
    }

    result *= await _updateTaskPositions(taskList);

    var checkedTaskList =
        await getTaskList(TaskListType.InAProject, true, projectId);
    if (checked) {
      checkedTaskList = _prepareListForUpdatingPositions(checkedTaskList);
    }

    result *= await _updateTaskPositions(checkedTaskList);

    return result;
  }

  Future<int> _updateTaskPositions(List<Task> taskList) async {
    var result = 1;

    if (taskList.length > 1) {
      var db = await this.database;
      for (int i = 0; i < taskList.length; i++) {
        var id = taskList[i].taskId;
        result *= await db.rawUpdate("UPDATE $_taskTable "
            "SET $colTaskPosition = $i "
            "WHERE $colTaskId = $id;");
      }
    }

    return result;
  }

  // Use only for onCheckedChanged
  List<T> _prepareListForUpdatingPositions<T extends AbsWithProjectId>(
      List<T> list) {
    if (list.length > 1) {
      int maxTime = 0;
      int maxTimePosition = 0;
      for (int i = 0; i < list.length; i++) {
        if (maxTime < list[i].dateModified) {
          maxTime = list[i].dateModified;
          maxTimePosition = i;
        }
      }

      if (list[0].completed) {
        // add item to the beginning
        list.insert(0, list.removeAt(maxTimePosition));
      } else {
        // add item to the end
        list.add(list.removeAt(maxTimePosition));
      }
    }

    return list;
  }

  // Get number of Task objects in database
  Future<int> getTaskCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery("SELECT COUNT (*) from $_taskTable");
    return Sqflite.firstIntValue(x);
  }

  // TODO Order by colProjectPosition
  // Get the 'Map List' [ List<Map> ] and convert it to 'Task List' [ List<Task> ]
  // projectId is ignored in case of Home task list
  Future<List<Task>> getTaskList(
      TaskListType type, bool checked, int projectId) async {
    var taskMapList; // Get 'Map List' from database
    if (type == TaskListType.Home) {
      taskMapList = await getHomeTaskMapList();
    } else if (type == TaskListType.InAProject) {
      taskMapList = await getTaskMapListInsideAProject(projectId, checked);
    }

    int count =
        taskMapList.length; // Count the number of map entries in db table

    List<Task> taskList = List<Task>();
    // For loop to create a 'Task List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      taskList.add(Task.fromMapObject(taskMapList[i]));
    }

    return taskList;
  }

  // TODO Finish reorderTask method
  // Reorder Operation: Reorder a Task object in database
  Future<int> reorderTask(bool checked, int projectId, int taskPosition,
      MovementType movementType) async {
    var taskList =
        await getTaskList(TaskListType.InAProject, checked, projectId);
    var result = 1;

    if (movementType == MovementType.moveUp) {
      if (taskPosition - 1 >= 0) {
        var db = await this.database;
        var id1 = taskList[taskPosition].taskId;
        result *= await db.rawUpdate("UPDATE $_taskTable "
            "SET $colTaskPosition = $taskPosition-1 WHERE $colTaskId = $id1");

        var id2 = taskList[taskPosition - 1].taskId;
        result *= await db.rawUpdate("UPDATE $_taskTable "
            "SET $colTaskPosition = $taskPosition WHERE $colTaskId = $id2");
      } else {
        result = 0;
      }
    } else {
      if (taskPosition < taskList.length - 1) {
        var db = await this.database;
        var id1 = taskList[taskPosition].taskId;
        result *= await db.rawUpdate("UPDATE $_taskTable "
            "SET $colTaskPosition = $taskPosition+1 WHERE $colTaskId = $id1");

        var id2 = taskList[taskPosition + 1].taskId;
        result *= await db.rawUpdate("UPDATE $_taskTable "
            "SET $colTaskPosition = $taskPosition WHERE $colTaskId = $id2");
      } else {
        result = 0;
      }
    }

    return result;
  }

  // Insert Operation: Insert a Project object to database
  Future<int> insertProject(Project project) async {
    Database db = await this.database;
    var result = await db.insert(_projectTable, project.toMap());
    return result;
  }

  // Update Operation: Update a Project object and save it to database
  Future<int> updateProject(Project project) async {
    var db = await this.database;
    return await db.update(_projectTable, project.toMap(),
        where: "$colProjectId = ?", whereArgs: [project.projectId]);
  }

  // TODO Don't reorder if the project has the highest value of #colProjectId in the table
  // Delete Operation: Delete a Project object from database
  Future<int> deleteProject(bool checked, int projectId) async {
    var db = await this.database;
    var result = await db.rawDelete(
        "DELETE FROM $_projectTable WHERE $colProjectId = $projectId");

    if (result != 0) {
      return await _updateProjectPositionsAfterDelete(checked);
    } else {
      return 0;
    }
  }

  // TODO Make optimization algorithm which will decide if it's neccessary to reorder positions
  Future<int> _updateProjectPositionsAfterDelete(bool checked) async {
    var projectList = await getProjectList(checked);
    return _updateProjectPositions(projectList);
  }

  Future<int> updateProjectPositionsAfterOnCheckedChanged(bool checked) async {
    var result = 1;
    var projectList = await getProjectList(false);
    if (!checked) {
      projectList = _prepareListForUpdatingPositions(projectList);
    }

    result *= await _updateProjectPositions(projectList);

    var checkedProjectList = await getProjectList(true);
    if (checked) {
      checkedProjectList = _prepareListForUpdatingPositions(checkedProjectList);
    }

    result *= await _updateProjectPositions(checkedProjectList);

    return result;
  }

  Future<int> _updateProjectPositions(List<Project> projectList) async {
    var result = 1;

    if (projectList.length > 1) {
      var db = await this.database;
      for (int i = 0; i < projectList.length; i++) {
        var id = projectList[i].projectId;
        result *= await db.rawUpdate("UPDATE $_projectTable "
            "SET $colProjectPosition = $i WHERE $colProjectId = $id");
      }
    }

    return result;
  }

  // TODO Finish reorderProject method
  // Reorder Operation: Reorder a Project object in database
  Future<int> reorderProject(
      int projectPosition, bool isChecked, MovementType movementType) async {
    var projectList = await getProjectList(isChecked);
    var result = 1;

    if (movementType == MovementType.moveUp) {
      if (projectPosition - 1 >= 0) {
        var db = await this.database;
        var id1 = projectList[projectPosition].projectId;
        result *= await db.rawUpdate("UPDATE $_projectTable "
            "SET $colProjectPosition = $projectPosition-1 WHERE $colProjectId = $id1");

        var id2 = projectList[projectPosition - 1].projectId;
        result *= await db.rawUpdate("UPDATE $_projectTable "
            "SET $colProjectPosition = $projectPosition WHERE $colProjectId = $id2");
      } else {
        result = 0;
      }
    } else {
      if (projectPosition < projectList.length - 1) {
        var db = await this.database;
        var id1 = projectList[projectPosition].projectId;
        result *= await db.rawUpdate("UPDATE $_projectTable "
            "SET $colProjectPosition = $projectPosition+1 WHERE $colProjectId = $id1");

        var id2 = projectList[projectPosition + 1].projectId;
        result *= await db.rawUpdate("UPDATE $_projectTable "
            "SET $colProjectPosition = $projectPosition WHERE $colProjectId = $id2");
      } else {
        result = 0;
      }
    }

    return result;
  }

  // Get number of Project objects in database
  Future<int> getProjectCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery("SELECT COUNT (*) from $_projectTable");
    return Sqflite.firstIntValue(x);
  }

  // Fetch Operation: Get all priority objects from database
  Future<List<Map<String, dynamic>>> getProjectMapList(
      bool checkedItems) async {
    Database db = await this.database;
    int checkedItemsTinyInt = checkedItems ? 1 : 0;
    var result = await db.query(_projectTable,
        where: "$colProjectCompleted = $checkedItemsTinyInt",
        orderBy: "$colProjectPosition");
    return result;
  }

  // Get the 'Map List' [ List<Map> ] and convert it to 'Project List' [ List<Project> ]
  Future<List<Project>> getProjectList(bool checkedItems) async {
    var projectMapList =
        await getProjectMapList(checkedItems); // Get 'Map List' from database
    int count =
        projectMapList.length; // Count the number of map entries in db table

    List<Project> projectList = List<Project>();
    // For loop to create a 'Project List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      projectList.add(Project.fromMapObject(projectMapList[i]));
    }

    return projectList;
  }
}
