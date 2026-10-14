import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import '../../../../core/database/app_database.dart';
import '../models/quran_word_model.dart';

/// Loads the immutable 500-word master list from
/// `assets/data/quran_500_words.json` and makes sure it's mirrored into the
/// `words` SQLite table exactly once (first launch), so the rest of the app
/// can query content and progress together with plain SQL.
///
/// The JSON file is treated as the single source of truth: ranks, spelling
/// and frequency are never altered here.
class VocabularyLocalDataSource {
  static const String _assetPath = 'assets/data/quran_500_words.json';

  Future<List<QuranWordModel>> loadWordsFromAsset() async {
    final raw = await rootBundle.loadString(_assetPath);
    final List<dynamic> decoded = json.decode(raw) as List<dynamic>;
    final words = decoded
        .map((e) => QuranWordModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // Defensive integrity check (see spec §42): ranks must be 1..500, no
    // duplicates, nothing reordered. If this ever fails it means the asset
    // was tampered with — fail loudly instead of silently learning wrong data.
    final ranks = words.map((w) => w.rank).toList()..sort();
    final expected = List.generate(words.length, (i) => i + 1);
    assert(ranks.length == 500 && _listEquals(ranks, expected),
        'quran_500_words.json must contain exactly ranks 1..500 with no gaps or duplicates');

    words.sort((a, b) => a.rank.compareTo(b.rank));
    return words;
  }

  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Future<void> seedDatabaseIfEmpty() async {
    final db = await AppDatabase.instance.database;
    final countResult = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM words'));
    if ((countResult ?? 0) > 0) return; // already seeded

    final words = await loadWordsFromAsset();
    final batch = db.batch();
    for (final w in words) {
      batch.insert('words', w.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      batch.insert(
        'word_progress',
        {'word_rank': w.rank},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<QuranWordModel>> getAllWordsFromDb() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('words', orderBy: 'rank ASC');
    return rows.map((r) => QuranWordModel.fromMap(r)).toList();
  }
}
