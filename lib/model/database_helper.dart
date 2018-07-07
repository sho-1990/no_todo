import 'dart:async';
import 'dart:io';

import 'package:no_todo/model/nodo_item.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';


class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  final String tableNodo = "nodoTbl";
  final String columnId  = "id";
  final String columnItemName = "itemName";
  final String columnDateCreated = "dateCreated";

  static Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  DatabaseHelper.internal();

  /*
  * id | nodoname | password
  * ------------------------
  * 1  | Paulo    | paulo
  * 2  | James    | bond
  * */
  void _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE $tableNodo($columnId INTEGER PRIMARY KEY, $columnItemName TEXT, $columnDateCreated TEXT)"
    );
  }

  initDb() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, "notodo_db.db"); // home://directory/files/nodo_db.db
    var ourDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return ourDb;
  }

  // CRUD - CREATE, READ, UPDATE, DELETE
  // Insertion
  Future<int> saveItem(NoDoItem nodo) async {
    var dbClient = await db;
    int res = await dbClient.insert(tableNodo, nodo.toMap());
    return res;
  }

  // Get NoDos
  Future<List> getItems() async {
    var dbClient = await db;
    var result = await dbClient.rawQuery("SELECT * FROM $tableNodo ORDER BY $columnItemName ASC");

    return result.toList();
  }

  Future<int> getCount() async {
    var dbClient = await db;
    return Sqflite.firstIntValue(
        await dbClient.rawQuery("SELECT COUNT(*) FROM $tableNodo")
    );
  }

  Future<NoDoItem> getItem(int id) async {
    var dbClient = await db;

    var result = await dbClient.rawQuery("SELECT * FROM $tableNodo WHERE $columnId = $id");
    if (result.length == 0) return null;
    return NoDoItem.fromMap(result.first);
  }

  Future<int> deleteItem(int id) async {
    var dbClient = await db;
    return await dbClient.delete(tableNodo,
        where: "$columnId = ?", whereArgs: [id]);
  }

  Future<int> updateItem(NoDoItem nodo) async {
    var dbClient = await db;
    return await dbClient.update(tableNodo, nodo.toMap(),
        where: "$columnId = ${nodo.id}", whereArgs: [nodo.id]);
  }

  Future close() async {
    var dbClient = await db;
    return dbClient.close();
  }
}