import 'package:flutter_learning/models/priority.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_learning/models/note.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;
  static Database _database;

  final String _db = "notes.db";

  final String noteTable = "note_table";
  final String priorityTable = "priority_table";
  static final String colId = "id";
  static final String colTitle = "title";
  static final String colDescription = "description";
  static final String colPriorityId = "priorityId";
  static final String colDate = "date";
  static final String colPriorityTitle = "title";

  final String noteTableOld = "_note_table_old";
  final String priorityTableOld = "_priority_table_old";
  final String colPriorityIdOld = "priority";

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

    var notesDatabase = await openDatabase(path,
        version: 2, onCreate: _createDb, onUpgrade: _upgradeDb);
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await _createPriorityTable(db);
    await _createNoteTable(db);
  }

  Future _createPriorityTable(Database db) async {
    await db.execute(_getCreatePriorityTableQuery());
  }

  String _getCreatePriorityTableQuery() {
    return "CREATE TABLE $priorityTable("
        "$colPriorityId INTEGER PRIMARY KEY AUTOINCREMENT, "
        "$colPriorityTitle TEXT)";
  }

  Future _createNoteTable(Database db) async {
    await db.execute(_getCreateNoteTableQuery());
  }

  String _getCreateNoteTableQuery() {
    return "CREATE TABLE $noteTable("
        "$colId INTEGER PRIMARY KEY AUTOINCREMENT, "
        "$colTitle TEXT,"
        "$colDescription TEXT,"
        "$colPriorityId INTEGER,"
        "$colDate TEXT)";
  }

  void _upgradeDb(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      if (oldVersion == 1) {
        await db.execute(
//            "PRAGMA foreign_keys=off;"
//            ""
//            "BEGIN TRANSACTION;"
//            ""
            "ALTER TABLE $noteTable RENAME TO $noteTableOld;");
//            ""
            await db.execute(_getCreateNoteTableQuery());
//            ""
        await db.execute("INSERT INTO $noteTable ($colId, $colTitle, $colDescription, $colPriorityId, $colDate) "
            "SELECT $colId, $colTitle, $colDescription, $colPriorityIdOld, $colDate "
            "FROM $noteTableOld;");
//            ""
        await db.execute(_getCreatePriorityTableQuery());
//            ""
        await db.execute("INSERT INTO $priorityTable ($colPriorityId) "
            "SELECT $colPriorityIdOld "
            "FROM $noteTableOld;");
//            "COMMIT;"
//            ""
//            "PRAGMA foreign_keys=on;"
//            );
      }
    }
  }

  // Fetch Operation: Get all note objects from database
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;

//    var result = await db.rawQuery("SELECT * FROM $noteTable order by $colPriority ASC");
    var result = await db.query(noteTable, orderBy: "$colPriorityId ASC");

    return result;
  }

  // Insert Operation: Insert a Note object to database
  Future<int> insertNote(Note note) async {
    Database db = await this.database;
    var result = await db.insert(noteTable, note.toMap());
    return result;
  }

  // Update Operation: Update a Note object and save it to database
  Future<int> updateNote(Note note) async {
    var db = await this.database;
    return await db.update(noteTable, note.toMap(),
        where: "$colId = ?", whereArgs: [note.id]);
  }

  // Delete Operation: Delete a Note object from database
  Future<int> deleteNote(int id) async {
    var db = await this.database;
    return await db.rawDelete("DELETE FROM $noteTable WHERE $colId = $id");
  }

  // Get number of Note objects in database
  Future<int> getNoteCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery("SELECT COUNT (*) from $noteTable");
    return Sqflite.firstIntValue(x);
  }

  // Get the 'Map List' [ List<Map> ] and convert it to 'Note List' [ List<Note> ]
  Future<List<Note>> getNoteList() async {
    var noteMapList = await getNoteMapList(); // Get 'Map List' from database
    int count =
        noteMapList.length; // Count the number of map entries in db table

    List<Note> noteList = List<Note>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }

    return noteList;
  }

  // Fetch Operation: Get all priority objects from database
  Future<List<Map<String, dynamic>>> getPriorityMapList() async {
    Database db = await this.database;

//    var result = await db.rawQuery("SELECT * FROM $noteTable order by $colPriority ASC");
    var result = await db.query(priorityTable, orderBy: "$colPriorityId ASC");

    return result;
  }

  // Insert Operation: Insert a Priority object to database
  Future<int> insertPriority(Priority priority) async {
    Database db = await this.database;
    var result = await db.insert(priorityTable, priority.toMap());
    return result;
  }

  // Update Operation: Update a Priority object and save it to database
  Future<int> updatePriority(Priority priority) async {
    var db = await this.database;
    return await db.update(priorityTable, priority.toMap(),
        where: "$colPriorityId = ?", whereArgs: [priority.priorityId]);
  }

  // Delete Operation: Delete a Priority object from database
  Future<int> deletePriority(int priorityId) async {
    var db = await this.database;
    return await db.rawDelete(
        "DELETE FROM $priorityTable WHERE $colPriorityId = $priorityId");
  }

  // Get number of Priority objects in database
  Future<int> getPriorityCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery("SELECT COUNT (*) from $priorityTable");
    return Sqflite.firstIntValue(x);
  }

  // Get the 'Map List' [ List<Map> ] and convert it to 'Priority List' [ List<Priority> ]
  Future<List<Priority>> getPriorityList() async {
    var priorityMapList =
        await getPriorityMapList(); // Get 'Map List' from database
    int count =
        priorityMapList.length; // Count the number of map entries in db table

    List<Priority> noteList = List<Priority>();
    // For loop to create a 'Priority List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      noteList.add(Priority.fromMapObject(priorityMapList[i]));
    }

    return noteList;
  }
}
