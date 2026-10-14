import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Validates assets/data/quran_500_words.json directly from disk so this
/// test catches a corrupted or hand-edited dataset even before the app
/// loads it (the same checks also run as an `assert` at runtime in
/// VocabularyLocalDataSource).
void main() {
  late List<dynamic> words;

  setUpAll(() {
    final file = File('assets/data/quran_500_words.json');
    words = json.decode(file.readAsStringSync()) as List<dynamic>;
  });

  test('contains exactly 500 words', () {
    expect(words.length, 500);
  });

  test('ranks are exactly 1..500 with no gaps or duplicates', () {
    final ranks = words.map((w) => w['rank'] as int).toList()..sort();
    expect(ranks, List.generate(500, (i) => i + 1));
  });

  test('no word has an empty required field', () {
    for (final w in words) {
      final map = w as Map<String, dynamic>;
      for (final key in ['arabic', 'transliteration', 'bangla', 'english']) {
        expect(map[key], isNotNull, reason: 'rank ${map['rank']} missing $key');
        expect((map[key] as String).trim(), isNotEmpty,
            reason: 'rank ${map['rank']} has empty $key');
      }
    }
  });

  test('frequency is either a positive int or null (never fabricated as 0)',
      () {
    for (final w in words) {
      final map = w as Map<String, dynamic>;
      final freq = map['frequency'];
      if (freq != null) {
        expect(freq, isA<int>());
        expect(freq, greaterThan(0));
      }
    }
  });

  test('frequency is non-increasing as rank increases (sanity check on the '
      'master ranking)', () {
    final byRank = {for (final w in words) w['rank'] as int: w['frequency']};
    int? previous;
    for (var rank = 1; rank <= 500; rank++) {
      final freq = byRank[rank] as int?;
      if (freq != null && previous != null) {
        expect(freq, lessThanOrEqualTo(previous),
            reason: 'frequency increased at rank $rank — ranking looks reordered');
      }
      if (freq != null) previous = freq;
    }
  });
}
