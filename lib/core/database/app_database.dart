import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Owns the single SQLite connection for the app and creates the schema
/// described in the product spec (§33). The 500-word list is loaded from
/// the bundled JSON asset once on first launch and copied into the `words`
/// table so the rest of the app can query everything (progress + content)
/// with plain SQL and stay fully offline.
class AppDatabase {
  AppDatabase._internal();
  static final AppDatabase instance = AppDatabase._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'quran_500_words.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE words (
        rank INTEGER PRIMARY KEY,
        arabic TEXT NOT NULL,
        transliteration TEXT NOT NULL,
        bangla TEXT NOT NULL,
        english TEXT NOT NULL,
        frequency INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE word_progress (
        word_rank INTEGER PRIMARY KEY,
        status TEXT NOT NULL DEFAULT 'new',
        times_seen INTEGER NOT NULL DEFAULT 0,
        times_correct INTEGER NOT NULL DEFAULT 0,
        times_wrong INTEGER NOT NULL DEFAULT 0,
        streak INTEGER NOT NULL DEFAULT 0,
        ease_factor REAL NOT NULL DEFAULT 2.5,
        interval_days INTEGER NOT NULL DEFAULT 0,
        last_reviewed_at TEXT,
        next_review_at TEXT,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        is_difficult INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (word_rank) REFERENCES words (rank)
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        words_target INTEGER NOT NULL DEFAULT 10,
        words_completed INTEGER NOT NULL DEFAULT 0,
        quiz_completed INTEGER NOT NULL DEFAULT 0,
        review_completed INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    await db.execute(
        'CREATE INDEX idx_progress_status ON word_progress (status)');
    await db.execute(
        'CREATE INDEX idx_progress_next_review ON word_progress (next_review_at)');
  }

  /// Wipes all learning progress (not the 500-word master list) after the
  /// user confirms a "Reset Progress" dialog. Never called implicitly.
  Future<void> resetProgress() async {
    final db = await database;
    await db.delete('word_progress');
    await db.delete('daily_sessions');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _db = null;
  }
}
