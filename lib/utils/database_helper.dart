import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:app_crud_sqlite/models/person.dart';

class DatabaseHelper {
  static const _databaseName = 'Persona.db';
  static const _databaseVersion = 1;

  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory dataDirectory = await getApplicationDocumentsDirectory();
    String dbPath = join(dataDirectory.path, _databaseName);
    return await openDatabase(dbPath,
        version: _databaseVersion, onCreate: _onCreateDB);
  }

  _onCreateDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${Person.tblPerson} (
        ${Person.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Person.colName} TEXT NOT NULL,
        ${Person.colAddress} TEXT NOT NULL,
        ${Person.colPhone} INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertPerson(Person person) async {
    Database db = await database;
    return await db.insert(Person.tblPerson, person.toMap());
  }

  Future<int> updatePerson(Person person) async {
    Database db = await database;
    return await db.update(Person.tblPerson, person.toMap(),
        where: '${Person.colId} = ?', whereArgs: [person.id]);
  }

  Future<int> deletePerson(int id) async {
    Database db = await database;
    return await db.delete(Person.tblPerson,
        where: '${Person.colId} = ?', whereArgs: [id]);
  }

  Future<List<Person>> fetchPersons() async {
    Database db = await database;
    List<Map> persons = await db.query(Person.tblPerson);
    return persons.length == 0
        ? []
        : persons.map((e) => Person.fromMap(e)).toList();
  }
}
