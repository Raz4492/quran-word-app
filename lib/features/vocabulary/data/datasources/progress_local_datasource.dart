import 'package:sqflite/sqflite.dart';
import '../../../../core/database/app_database.dart';
import '../models/word_progress_model.dart';

class ProgressLocalDataSource {
  Future<Database> get _db async => AppDatabase.instance.database;

  Future<WordProgressModel> getProgress(int rank) async {
    final db = await _db;
    final rows =
        await db.query('word_progress', where: 'word_rank = ?', whereArgs: [rank]);
    if (rows.isEmpty) return WordProgressModel.initial(rank);
    return WordProgressModel.fromMap(rows.first);
  }

  Future<List<WordProgressModel>> getAllProgress() async {
    final db = await _db;
    final rows = await db.query('word_progress');
    return rows.map((r) => WordProgressModel.fromMap(r)).toList();
  }

  Future<void> saveProgress(WordProgressModel progress) async {
    final db = await _db;
    await db.insert(
      'word_progress',
      progress.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<WordProgressModel>> getDueForReview({int? limit}) async {
    final db = await _db;
    final nowIso = DateTime.now().toIso8601String();
    final rows = await db.query(
      'word_progress',
      where: "status != 'new' AND (next_review_at IS NULL OR next_review_at <= ?)",
      whereArgs: [nowIso],
      orderBy: 'next_review_at ASC',
      limit: limit,
    );
    return rows.map((r) => WordProgressModel.fromMap(r)).toList();
  }

  Future<List<WordProgressModel>> getByStatus(String status) async {
    final db = await _db;
    final rows =
        await db.query('word_progress', where: 'status = ?', whereArgs: [status]);
    return rows.map((r) => WordProgressModel.fromMap(r)).toList();
  }

  Future<List<WordProgressModel>> getFavorites() async {
    final db = await _db;
    final rows = await db.query('word_progress', where: 'is_favorite = 1');
    return rows.map((r) => WordProgressModel.fromMap(r)).toList();
  }

  Future<List<WordProgressModel>> getDifficult() async {
    final db = await _db;
    final rows = await db.query('word_progress', where: 'is_difficult = 1');
    return rows.map((r) => WordProgressModel.fromMap(r)).toList();
  }

  /// Words never studied yet, in rank order (so lessons follow the canonical
  /// 1-500 ranking rather than jumping around).
  Future<List<int>> getNewWordRanksInOrder({required int limit}) async {
    final db = await _db;
    final rows = await db.rawQuery('''
      SELECT w.rank FROM words w
      LEFT JOIN word_progress p ON p.word_rank = w.rank
      WHERE p.status = 'new' OR p.status IS NULL
      ORDER BY w.rank ASC
      LIMIT ?
    ''', [limit]);
    return rows.map((r) => r['rank'] as int).toList();
  }

  Future<void> resetAll() async {
    final db = await _db;
    await db.delete('word_progress');
  }

  Future<Map<String, int>> statusCounts() async {
    final db = await _db;
    final rows = await db.rawQuery('''
      SELECT COALESCE(p.status, 'new') as status, COUNT(*) as count
      FROM words w
      LEFT JOIN word_progress p ON p.word_rank = w.rank
      GROUP BY COALESCE(p.status, 'new')
    ''');
    return {for (final r in rows) r['status'] as String: r['count'] as int};
  }
}
