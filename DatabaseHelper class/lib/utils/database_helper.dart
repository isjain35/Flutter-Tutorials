import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_app1/models/note.dart';


class DatabaseHelper{

  static DatabaseHelper _databaseHelper;
  static Database _database;

  String noteTable = 'note_table';
  String colID = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';

  DatabaseHelper._createInstance();

  factory DatabaseHelper(){

    if(_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;

  }

  Future<Database> get database async{

    if(_database == null)
      {
        _database = await initializeDatabase();
      }
    return _database;

  }

  Future<Database> initializeDatabase() async{
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path +'notes.db';
    var notesDatabase = await openDatabase(path,version: 1,onCreate: _createDB);
    return notesDatabase;
  }

  void _createDB(Database db,int newVersion) async {
    await db.execute(
        'CREATE TABLE $noteTable($colID INTEGER PRIMARY KEY AUTOINCREMENT'
            ',$colTitle TEXT,$colDescription TEXT,$colPriority INTEGER,$colDate TEXT)');
  }

  //Fetch
  Future<List<Map<String, dynamic>>> getNoteMapList() async{
    Database db = await this.database;
    var result = await db.query(noteTable,orderBy: '$colPriority ASC');
    return result;
  }
  //Insert
  Future<int> insertNote(Note note) async{
    Database db = await this.database;
    var result = await db.insert(noteTable, note.toMap());
    return result;
  }
  //Update
  Future<int> updateNote(Note note) async{
    Database db = await this.database;
    var result = await db.update(noteTable, note.toMap(), where:' $colID = ?', whereArgs: [note.id]);
    return result;
  }
  //Delete
  Future<int> deleteNote(int id) async{
    Database db = await this.database;
    var result = await db.rawDelete('DELETE FROM $noteTable WHERE $colID = $id');
    return result;
  }
  //Get number of records in DB
  Future<int> getCount() async{
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) FROM $noteTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }
}