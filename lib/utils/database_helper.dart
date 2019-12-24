import 'package:flutter_learning/models/project.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_learning/models/task.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;
  static Database _database;

  final String _db = "projects.db";   // TODO updateDb renaming database file from notes.db in version 3->4
  final int _databaseVersion = 4;

  final String _taskTable = "task_table";
  final String _projectTable = "project_table";
  static final String colId = "id";
  static final String colDate = "date";
  static final String colDescription = "description";
  static final String colProjectId = "projectId";
  static final String colProjectPosition = "position";
  static final String colProjectTitle = "title";
  static final String colTaskPosition = "position";
  static final String colTitle = "title";

  final String _taskTableOld = "_task_table_old";
  final String _projectTableOld = "_project_table_old";

  final String _taskTableV1 = "note_table";
  final String _projectTableV3 = "priority_table";
  final String _colProjectIdV1 = "priority";
  static final String colProjectIdV3 = "priorityId";

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
  }

  String _getCreateProjectTableQuery() {
    return "CREATE TABLE $_projectTable("
        "$colProjectId INTEGER PRIMARY KEY AUTOINCREMENT, "
        "$colProjectPosition INTEGER, "
        "$colProjectTitle TEXT)";
  }

  Future _createTaskTable(Database db) async {
    await db.execute(_getCreateTaskTableQuery());
  }

  String _getCreateTaskTableQuery() {
    return "CREATE TABLE $_taskTable("
        "$colId INTEGER PRIMARY KEY AUTOINCREMENT, "
        "$colTitle TEXT,"
        "$colDescription TEXT,"
        "$colProjectId INTEGER,"
        "$colDate TEXT,"
        "$colTaskPosition INTEGER)";
  }

  // TODO Test upgrades
  void _upgradeDb(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      if (oldVersion == 1) {
        await db.execute(
            "ALTER TABLE $_taskTableV1 RENAME TO $_taskTableOld;");

        await db.execute(_getCreateTaskTableQuery());

        await db.execute("INSERT INTO $_taskTable ($colId, $colTitle, $colDescription, $colProjectId, $colDate) "
            "SELECT $colId, $colTitle, $colDescription, $_colProjectIdV1, $colDate "
            "FROM $_taskTableOld;");

        await db.execute(_getCreateProjectTableQuery());

        await db.execute("INSERT INTO $_projectTable ($colProjectPosition) "
            "SELECT $_colProjectIdV1 "
            "FROM $_taskTableOld;");

      } else if (oldVersion == 2) {
        await db.execute(
            "ALTER TABLE $_projectTableV3 RENAME TO $_projectTableOld;");

        await db.execute(_getCreateProjectTableQuery());

        await db.execute("INSERT INTO $_projectTable ($colProjectPosition, $colProjectTitle) "
            "SELECT $colProjectId, $colProjectTitle "
            "FROM $_projectTableOld;");

      } else if (oldVersion == 3) {
        await db.execute(
            "ALTER TABLE $_taskTableV1 RENAME TO $_taskTableOld;");

        await db.execute(_getCreateTaskTableQuery());

        await db.execute("INSERT INTO $_taskTable ($colId, $colTitle, $colDescription, $colProjectId, $colDate) "
            "SELECT $colId, $colTitle, $colDescription, $_colProjectIdV1, $colDate "
            "FROM $_taskTableOld;");

        await db.execute(
            "ALTER TABLE $_projectTableV3 RENAME TO $_projectTableOld;");

        await db.execute(_getCreateProjectTableQuery());

        await db.execute("INSERT INTO $_projectTable ($colProjectPosition, $colProjectTitle) "
            "SELECT $colProjectIdV3, $colProjectTitle "
            "FROM $_projectTableOld;");
      }

      await db.execute("DROP TABLE IF EXISTS $_taskTableOld");
      await db.execute("DROP TABLE IF EXISTS $_projectTableOld");
    }
  }

  // Fetch Operation: Get all task objects from database
  Future<List<Map<String, dynamic>>> getTaskMapList() async {
    Database db = await this.database;

//    var result = await db.rawQuery("SELECT * FROM $taskTable order by $colProject ASC");
    var result = await db.query(_taskTable, orderBy: "$colProjectId ASC");

    return result;
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
        where: "$colId = ?", whereArgs: [task.id]);
  }

  // Delete Operation: Delete a Task object from database
  Future<int> deleteTask(int id) async {
    var db = await this.database;
    return await db.rawDelete("DELETE FROM $_taskTable WHERE $colId = $id");
  }

  // Get number of Task objects in database
  Future<int> getTaskCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery("SELECT COUNT (*) from $_taskTable");
    return Sqflite.firstIntValue(x);
  }

  // Get the 'Map List' [ List<Map> ] and convert it to 'Task List' [ List<Task> ]
  Future<List<Task>> getTaskList() async {
    var taskMapList = await getTaskMapList(); // Get 'Map List' from database
    int count =
        taskMapList.length; // Count the number of map entries in db table

    List<Task> taskList = List<Task>();
    // For loop to create a 'Task List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      taskList.add(Task.fromMapObject(taskMapList[i]));
    }

    return taskList;
  }

  // Fetch Operation: Get all priority objects from database
  Future<List<Map<String, dynamic>>> getProjectMapList() async {
    Database db = await this.database;

//    var result = await db.rawQuery("SELECT * FROM $taskTable order by $colProject ASC");
    var result = await db.query(_projectTable, orderBy: "$colProjectId ASC");

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

  // Delete Operation: Delete a Project object from database
  Future<int> deleteProject(int projectId) async {
    var db = await this.database;
    return await db.rawDelete(
        "DELETE FROM $_projectTable WHERE $colProjectId = $projectId");
  }

  // TODO Finish reorderProject method
  // Reorder Operation: Reorder a Project object in database
  Future<int> reorderProject(int projectId, int movementType) async {
    var db = await this.database;
    return await db.rawDelete(
        "DELETE FROM $_projectTable WHERE $colProjectId = $projectId");
  }

  // Get number of Project objects in database
  Future<int> getProjectCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery("SELECT COUNT (*) from $_projectTable");
    return Sqflite.firstIntValue(x);
  }

  // Get the 'Map List' [ List<Map> ] and convert it to 'Project List' [ List<Project> ]
  Future<List<Project>> getProjectList() async {
    var projectMapList =
        await getProjectMapList(); // Get 'Map List' from database
    int count = projectMapList.length; // Count the number of map entries in db table

    List<Project> projectList = List<Project>();
    // For loop to create a 'Project List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      projectList.add(Project.fromMapObject(projectMapList[i]));
    }

    return projectList;
  }
}
