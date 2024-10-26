import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  String dbName = "task.db";
  String tableName = "task";
  String columnId = "id";
  String columnTitle = "title";
  String columnIsDone = "isDone";
  String columnDate = "date";

  Database? _database;

  /// create singleton
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  /// end singleton
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String databasePath = await getDatabasesPath();
    String dbPath = join(databasePath, dbName);
    return await openDatabase(dbPath, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName(
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnTitle TEXT NOT NULL,
        $columnIsDone INTEGER NOT NULL,
        $columnDate TEXT NOT NULL 
      )
    ''');
  }

  static Future<int> insertTask(Map<String, dynamic> row) async {
    final Database db = await DatabaseHelper().database;
    return await db.insert(DatabaseHelper().tableName, row);
  }

  /// getTask
  static Future<List<Map<String, dynamic>>> getTask() async {
    final Database db = await DatabaseHelper().database;
    return await db.query(DatabaseHelper().tableName);
  }

  /// update task
  static Future<int> updateTask(
      {required int id, required Map<String, dynamic> row}) async {
    final Database db = await DatabaseHelper().database;
    return await db.update(DatabaseHelper().tableName, row,
        where: '${DatabaseHelper().columnId} = ?', whereArgs: [id]);
  }

  /// delete Task
  static Future<int> deleteTask({required int id}) async {
    final Database db = await DatabaseHelper().database;
    return await db.delete(DatabaseHelper().tableName,
        where: '${DatabaseHelper().columnId} = ?', whereArgs: [id]);
  }
}
