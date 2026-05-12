import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/focus_model.dart';
import '../models/plant_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('touch_some_grass.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE discovered_plants ADD COLUMN image_path TEXT');
          await db.execute('ALTER TABLE discovered_plants ADD COLUMN location TEXT');
        }
        if (oldVersion < 3) {
          // Kolom baru versi 3
          await db.execute('ALTER TABLE discovered_plants ADD COLUMN latin_name TEXT');
          await db.execute('ALTER TABLE discovered_plants ADD COLUMN benefits TEXT');
          await db.execute('ALTER TABLE discovered_plants ADD COLUMN city TEXT');
          await db.execute('ALTER TABLE discovered_plants ADD COLUMN discovered_at TEXT');
        }
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Tabel Kategori (Modul 7 - Relational)
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    // Tabel Riwayat Fokus
    await db.execute('''
      CREATE TABLE focus_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_name TEXT NOT NULL,
        duration_minutes INTEGER NOT NULL,
        date TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');

    // Tabel Tanaman (AI Scanner / Grassbook) — versi 3
    await db.execute('''
      CREATE TABLE discovered_plants (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        latin_name TEXT,
        benefits TEXT,
        confidence REAL NOT NULL,
        city TEXT,
        discovered_at TEXT NOT NULL,
        image_path TEXT
      )
    ''');

    // Inisialisasi kategori bawaan
    await db.insert('categories', {'name': 'Belajar'});
    await db.insert('categories', {'name': 'Bekerja'});
    await db.insert('categories', {'name': 'Olahraga'});
    await db.insert('categories', {'name': 'Santai'});
  }

  // --- CRUD untuk Kategori ---
  Future<List<FocusCategory>> getCategories() async {
    final db = await instance.database;
    final result = await db.query('categories');
    return result.map((json) => FocusCategory.fromMap(json)).toList();
  }

  // --- CRUD untuk Riwayat Fokus (Modul 6) ---

  // 1. Create (Insert)
  Future<int> insertFocusHistory(FocusHistory history) async {
    final db = await instance.database;
    return await db.insert('focus_history', history.toMap());
  }

  // 2. Read (Select dengan JOIN Modul 7)
  Future<List<FocusHistory>> getAllFocusHistory() async {
    final db = await instance.database;
    // Menggunakan JOIN untuk mengambil nama kategori sekaligus
    final result = await db.rawQuery('''
      SELECT focus_history.*, categories.name AS category_name
      FROM focus_history
      INNER JOIN categories ON focus_history.category_id = categories.id
      ORDER BY focus_history.id DESC
    ''');
    
    return result.map((json) => FocusHistory.fromMap(json)).toList();
  }

  // 3. Update
  Future<int> updateFocusHistory(FocusHistory history) async {
    final db = await instance.database;
    return await db.update(
      'focus_history',
      history.toMap(),
      where: 'id = ?',
      whereArgs: [history.id],
    );
  }

  // 4. Delete
  Future<int> deleteFocusHistory(int id) async {
    final db = await instance.database;
    return await db.delete(
      'focus_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- CRUD untuk Grassbook (AI Scanner) ---

  // Simpan tanaman yang baru ditemukan
  Future<int> insertDiscoveredPlant(DiscoveredPlant plant) async {
    final db = await instance.database;
    return await db.insert('discovered_plants', plant.toMap());
  }

  // Ambil semua tanaman yang sudah di-unlock
  Future<List<DiscoveredPlant>> getDiscoveredPlants() async {
    final db = await instance.database;
    final result = await db.query('discovered_plants', orderBy: 'id DESC');
    return result.map((json) => DiscoveredPlant.fromMapLegacy(json)).toList();
  }

  // Hapus tanaman berdasarkan ID
  Future<int> deleteDiscoveredPlant(int id) async {
    final db = await instance.database;
    return await db.delete(
      'discovered_plants',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
