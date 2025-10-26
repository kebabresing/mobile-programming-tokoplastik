import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:toko_plastik_rizky/domain/product.dart';
import 'package:toko_plastik_rizky/domain/supplier.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "toko_plastik.db");

    // open the database
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onConfigure: (Database db) async {
        // enable foreign keys
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE suppliers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        sku TEXT,
        category TEXT,
        price REAL,
        stock INTEGER,
        imagePath TEXT,
        supplierId INTEGER,
        description TEXT,
        buyPrice REAL,
        FOREIGN KEY (supplierId) REFERENCES suppliers(id) ON DELETE CASCADE ON UPDATE NO ACTION
      )
    ''');
  }

  // Supplier CRUD
  Future<int> insertSupplier(Supplier supplier) async {
    final database = await db;
    return await database.insert('suppliers', supplier.toMap());
  }

  Future<int> updateSupplier(Supplier supplier) async {
    final database = await db;
    return await database.update('suppliers', supplier.toMap(), where: 'id = ?', whereArgs: [supplier.id]);
  }

  Future<int> deleteSupplier(int id) async {
    final database = await db;
    return await database.delete('suppliers', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Supplier>> getSuppliers() async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query('suppliers', orderBy: 'name');
    return List.generate(maps.length, (i) => Supplier.fromMap(maps[i]));
  }

  Future<Supplier?> getSupplierById(int id) async {
    final database = await db;
    final maps = await database.query('suppliers', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return Supplier.fromMap(maps.first);
    return null;
  }

  // Product CRUD
  Future<int> insertProduct(Product product) async {
    final database = await db;
    return await database.insert('products', product.toMap());
  }

  Future<int> updateProduct(Product product) async {
    final database = await db;
    return await database.update('products', product.toMap(), where: 'id = ?', whereArgs: [product.id]);
  }

  Future<int> deleteProduct(int id) async {
    final database = await db;
    return await database.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Product>> getProducts({int? supplierId}) async {
    final database = await db;
    List<Map<String, dynamic>> maps;
    if (supplierId != null) {
      maps = await database.query('products', where: 'supplierId = ?', whereArgs: [supplierId], orderBy: 'name');
    } else {
      maps = await database.query('products', orderBy: 'name');
    }
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<List<Product>> getProductsBySupplier(int supplierId) async {
    return getProducts(supplierId: supplierId);
  }
}
