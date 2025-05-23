import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

// Import your model classes
import 'models/farmer_model.dart';
import 'models/product.dart';
import 'models/message.dart';

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
    // Farmers Table
    await db.execute('''
      CREATE TABLE farmers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        contact TEXT,
        harvest TEXT,
        price REAL,
        imagePath TEXT,
        username TEXT UNIQUE,
        password TEXT
      )
    ''');

    // Admins Table
    await db.execute('''
      CREATE TABLE admins (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    // Users Table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT UNIQUE,
        password TEXT
      )
    ''');

    // Products Table
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        price REAL,
        quantity INTEGER,
        description TEXT,
        imagePath TEXT,
        farmerId INTEGER
      )
    ''');

    // Orders Table
    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId INTEGER,
        userId INTEGER,
        amount INTEGER,
        totalCost REAL,
        orderDate TEXT
      )
    ''');

    // Cart Table
    await db.execute('''
      CREATE TABLE cart (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        productId INTEGER,
        productName TEXT,
        quantity INTEGER,
        cost REAL
      )
    ''');

    // Messages Table
    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        senderId TEXT,
        senderRole TEXT,
        receiverId TEXT,
        receiverRole TEXT,
        message TEXT,
        timestamp TEXT,
        seen INTEGER DEFAULT 0
      )
    ''');

    // Recommendations Table
    await db.execute('''
      CREATE TABLE recommendations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        farmer TEXT,
        crop TEXT,
        date TEXT
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS farmers');
    await db.execute('DROP TABLE IF EXISTS admins');
    await db.execute('DROP TABLE IF EXISTS users');
    await db.execute('DROP TABLE IF EXISTS products');
    await db.execute('DROP TABLE IF EXISTS orders');
    await db.execute('DROP TABLE IF EXISTS cart');
    await db.execute('DROP TABLE IF EXISTS messages');
    await db.execute('DROP TABLE IF EXISTS recommendations');
    await _onCreate(db, newVersion);
  }

  // ========== Admin Methods ==========

  Future<void> insertDefaultAdmin() async {
    final db = await database;
    final result = await db.query('admins', where: 'username = ?', whereArgs: ['admin']);
    if (result.isEmpty) {
      await db.insert('admins', {
        'username': 'admin',
        'password': 'admin123',
      });
    }
  }

  Future<Map<String, dynamic>?> validateAdmin(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'admins',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getAdminProfile(int adminId) async {
    final db = await database;
    final result = await db.query('admins', where: 'id = ?', whereArgs: [adminId]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateAdmin(int id, String username, String password) async {
    final db = await database;
    return await db.update(
      'admins',
      {'username': username, 'password': password},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  // ========== Farmer Methods ==========
  Future<List<Map<String, dynamic>>> getFarmers() async {
  final db = await database;
  return await db.query('farmers');
}

Future<int> addFarmer(Map<String, dynamic> farmer) async {
  final db = await database;
  return await db.insert('farmers', farmer);
}

Future<int> updateFarmer(int id, Map<String, dynamic> farmer) async {
  final db = await database;
  return await db.update('farmers', farmer, where: 'id = ?', whereArgs: [id]);
}
  // ========== Messages Methods ==========

  Future<void> addMessage(Map<String, dynamic> message) async {
    final db = await database;
    await db.insert('messages', message);
  }
 Future<int> insertMessage(Map<String, dynamic> message) async {
    final db = await database;
    return await db.insert('messages', message);
  }
  Future<void> updateMessageSeen(int id, int seen) async {
    final db = await database;
    await db.update('messages', {'seen': seen}, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getMessages(String senderId, String receiverId) async {
    final db = await database;
    return await db.query(
      'messages',
      where: '(senderId = ? AND receiverId = ?) OR (senderId = ? AND receiverId = ?)',
      whereArgs: [senderId, receiverId, receiverId, senderId],
      orderBy: 'timestamp ASC',
    );
  }

  Future<void> clearAllMessages() async {
    final db = await database;
    await db.delete('messages');
  }

  // ========== Recommendation History ==========

  Future<void> insertRecommendation(Map<String, dynamic> recommendation) async {
    final db = await database;
    await db.insert('recommendations', recommendation);
  }

  Future<List<Map<String, dynamic>>> getRecommendations(String farmerName) async {
    final db = await database;
    return await db.query(
      'recommendations',
      where: 'farmer = ?',
      whereArgs: [farmerName],
      orderBy: 'date DESC',
    );
  }

  // ========== Products Methods ==========

  Future<void> insertProduct(Map<String, dynamic> product) async {
    final db = await database;
    await db.insert('products', product);
  }

  Future<void> deleteProductById(int id) async {
    final db = await database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }
  // Future<void> getProducts(int id) async{
  //   final db =await database;
  //   await db.getProducts('products', where: 'id =?', whereArgs: [product.id]);
  // }
Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }
  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<List<Product>> getProducts({required int farmerId}) async {
  final db = await database;
  final maps = await db.query(
    'products',
    where: 'farmer_id = ?',
    whereArgs: [farmerId],
  );

  return List.generate(maps.length, (i) {
    return Product.fromMap(maps[i]);
  });
}

  // ========== Account Methods ==========
 

 Future<Map<String, dynamic>?> getAccountByRole(String username, String password, String role) async {
  final db = await database;
  final result = await db.query(
    'users',
    where: 'username = ? AND password = ? AND role = ?',
    whereArgs: [username, password, role],
  );
  if (result.isNotEmpty) {
    return result.first;
  } else {
    return null;
  }
}


  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> validateUser(String email, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // ========== Farmers Methods ==========

  Future<void> insertFarmer(Map<String, dynamic> farmer) async {
    final db = await database;
    await db.insert('farmers', farmer);
  }

  Future<Map<String, dynamic>?> getFarmerByNameAndContact(String name, String contact) async {
    final db = await database;
    final result = await db.query(
      'farmers',
      where: 'name = ? AND contact = ?',
      whereArgs: [name, contact],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> deleteFarmer(int id) async {
    final db = await database;
    await db.delete('farmers', where: 'id = ?', whereArgs: [id]);
  }

Future<Map<String, dynamic>?> validateFarmer(String name, String contact) async {
  final db = await database;
  List<Map<String, dynamic>> result = await db.query(
    'farmers',
    where: 'name = ? AND contact = ?',
    whereArgs: [name, contact],
  );
  if (result.isNotEmpty) {
    return result.first;
  }
  return null;
}

Future<List<Farmer>> getAllFarmers() async {
  final db = await database;
  final maps = await db.query('farmers');
  return maps.map((map) => Farmer.fromMap(map)).toList();
}

  // ========== Orders Methods ==========

  Future<void> insertOrder(Map<String, dynamic> order) async {
    final db = await database;
    await db.insert('orders', order);
  }

  // ========== Cart Methods ==========

  Future<void> insertCart(Map<String, dynamic> cart) async {
    final db = await database;
    await db.insert('cart', cart);
  }

  Future<List<Map<String, dynamic>>> getCartItemsByUserId(int userId) async {
    final db = await database;
    return await db.query('cart', where: 'userId = ?', whereArgs: [userId]);
  }

  Future<void> clearCart() async {
    final db = await database;
    await db.delete('cart');
  }
}
