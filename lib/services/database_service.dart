import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static const _dbName = 'dailycost.db';
  static const _dbVersion = 1;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        brand TEXT,
        category TEXT,
        price REAL NOT NULL,
        purchase_date TEXT NOT NULL,
        expected_lifespan_months INTEGER NOT NULL,
        image_path TEXT,
        source TEXT NOT NULL DEFAULT 'manual',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  // ==================== CRUD ====================

  Future<List<Map<String, dynamic>>> queryAllItems() async {
    final db = await database;
    return db.query('items', orderBy: 'created_at DESC');
  }

  Future<Map<String, dynamic>> queryItemById(int id) async {
    final db = await database;
    final results = await db.query('items', where: 'id = ?', whereArgs: [id]);
    return results.first;
  }

  Future<int> insertItem(Map<String, dynamic> item) async {
    final db = await database;
    return db.insert('items', item);
  }

  Future<int> updateItem(Map<String, dynamic> item) async {
    final db = await database;
    return db.update(
      'items',
      item,
      where: 'id = ?',
      whereArgs: [item['id']],
    );
  }

  Future<int> deleteItem(int id) async {
    final db = await database;
    return db.delete('items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllItems() async {
    final db = await database;
    await db.delete('items');
  }

  Future<List<Map<String, dynamic>>> queryItemsByCategory(
      String category) async {
    final db = await database;
    return db.query(
      'items',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'created_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> queryAllCategories() async {
    final db = await database;
    return db.rawQuery(
      'SELECT DISTINCT category FROM items WHERE category IS NOT NULL ORDER BY category',
    );
  }
}
