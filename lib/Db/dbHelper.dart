
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:mytodo/Models/model.dart';

const todosStatusActive = 0;
const todosStatusDone = 1;
const importantDefault = 0;

const databaseName = 'todoAppDb3.db';
const databaseVersion = 1;
const sqlCreateStatement = '''
CREATE TABLE "todos" (
	 "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	 "title" TEXT NOT NULL,
	 "created" text NOT NULL,
	 "updated" TEXT NOT NULL,
	 "status" integer DEFAULT $todosStatusActive,
	 "category" TEXT NOT NULL,
	 "isImportant" integer DEFAULT $importantDefault
);
''';

const dbTableName = 'todos';

class DB {
  DB._();
  static final DB sharedInstance = DB._();

  Database _database;
  Future<Database> get database async {
    return _database ?? await initDB();
  }

  Future<Database> initDB() async {
    Directory docsDirectory = await getApplicationDocumentsDirectory();
    String path = join(docsDirectory.path, databaseName);

    return await openDatabase(path, version: databaseVersion,
        onCreate: (Database db, int version) async {
          await db.execute(sqlCreateStatement);
        });
  }

  void createTodo(Todo todo) async {
    final db = await database;
    await db.insert(dbTableName, todo.toMapAutoID());
  }

  void updateTodo(Todo todo) async {
    final db = await database;
    await db
        .update(dbTableName, todo.toMap(), where: 'id=?', whereArgs: [todo.id]);
  }

  void importantTodo(int important,int id) async {
    final db = await database;
    await db
        .rawQuery("UPDATE $dbTableName SET isImportant = ${important} WHERE id = ${id}");
  }

  Future<int> importantStatus(int id) async {
    final db = await database;
    List<Map<String, dynamic>> importantStatus = await db.rawQuery("Select isImportant from $dbTableName where id = ${id}");
    int result = Sqflite.firstIntValue(importantStatus);
    return result;
  }

  void deleteTodo(Todo todo) async {
    final db = await database;
    await db.delete(dbTableName, where: 'id=?', whereArgs: [todo.id]);
  }

  void deleteAllTodos({int status = todosStatusDone}) async {
    final db = await database;
    await db.delete(dbTableName, where: 'status=?', whereArgs: [status]);
  }

  Future<List<Todo>> getImportants() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery("Select * from $dbTableName where isImportant=1 order by updated ASC");

    return List.generate(maps.length, (i) {
      return Todo(
          id: maps[i]['id'],
          title: maps[i]['title'],
          created: DateTime.parse(maps[i]['created']),
          updated: DateTime.parse(maps[i]['updated']),
          status: maps[i]['status'],
          category: maps[i]['category'],
          isImportant: maps[i]['isImportant']
      );
    });
  }

  Future<List<Todo>> retrieveTodos(
      {TodoStatus status = TodoStatus.active, String category}) async {
    final db = await database;
//    final List<Map<String, dynamic>> maps = await db.query(kTableTodos,
//        where: 'status=?', whereArgs: [status.index], orderBy: 'updated ASC');
    final List<Map<String, dynamic>> maps = await db.rawQuery("Select * from $dbTableName where status=${status.index} and category='$category' order by updated ASC");

    // Convert List<Map<String, dynamic>> to List<Todo_object>
    return List.generate(maps.length, (i) {
      return Todo(
          id: maps[i]['id'],
          title: maps[i]['title'],
          created: DateTime.parse(maps[i]['created']),
          updated: DateTime.parse(maps[i]['updated']),
          status: maps[i]['status'],
          category: maps[i]['category'],
          isImportant: maps[i]['isImportant']
      );
    });
  }
}
