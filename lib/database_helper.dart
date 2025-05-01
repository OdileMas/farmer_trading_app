import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'farmers.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute(''' 
      CREATE TABLE farmers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        contact TEXT,
        harvest TEXT,
        price REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE admins (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT UNIQUE,
        password TEXT
      )
    ''');

    // Insert default admin
    await db.insert('admins', {
      'username': 'admin',
      'password': 'admin123'
    });
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS farmers');
    await db.execute('DROP TABLE IF EXISTS admins');
    await db.execute('DROP TABLE IF EXISTS users');
    await _onCreate(db, newVersion);
  }

  // ===================== Admin Methods =====================

  Future<int> insertAdmin(Map<String, dynamic> admin) async {
    Database db = await instance.database;
    return await db.insert('admins', admin);
  }

  Future<Map<String, dynamic>?> validateAdmin(String username, String password) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(
      'admins',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // ===================== User Methods =====================

  Future<int> insertUser(Map<String, dynamic> user) async {
    Database db = await instance.database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> validateUser(String email, String password) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // ===================== Farmer CRUD =====================

  Future<int> insertFarmer(Map<String, dynamic> farmer) async {
    Database db = await instance.database;
    return await db.insert('farmers', farmer);
  }

  Future<List<Map<String, dynamic>>> getFarmers() async {
    Database db = await instance.database;
    return await db.query('farmers');
  }

  Future<int> updateFarmer(Map<String, dynamic> farmer) async {
    Database db = await instance.database;
    int id = farmer['id'];
    return await db.update(
      'farmers',
      farmer,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteFarmer(int id) async {
    Database db = await instance.database;
    return await db.delete(
      'farmers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
