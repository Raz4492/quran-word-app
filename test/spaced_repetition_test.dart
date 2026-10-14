import 'package:flutter_test/flutter_test.dart';
import 'package:quran_500_words/core/constants/app_constants.dart';
import 'package:quran_500_words/features/learning/domain/spaced_repetition.dart';
import 'package:quran_500_words/features/vocabulary/domain/entities/word_progress.dart';

void main() {
  const engine = SpacedRepetitionEngine();

  WordProgress freshWord() => const WordProgress(wordRank: 1);

  group('grade()', () {
    test('Again resets streak to 0 and keeps status at Learning', () {
      final start = freshWord().copyWith(streak: 5, status: LearningStatus.review);
      final result = engine.grade(start, ReviewGrade.again);
      expect(result.streak, 0);
      expect(result.status, LearningStatus.learning);
      expect(result.timesIncorrect, 1);
    });

    test('Good increases streak and schedules a future review', () {
      final result = engine.grade(freshWord(), ReviewGrade.good);
      expect(result.streak, 1);
      expect(result.timesCorrect, 1);
      expect(result.nextReviewAt, isNotNull);
      expect(result.nextReviewAt!.isAfter(DateTime.now()), isTrue);
    });

    test('repeated Easy grades eventually reach Mastered', () {
      var progress = freshWord();
      for (var i = 0; i < 5; i++) {
        progress = engine.grade(progress, ReviewGrade.easy);
      }
      expect(progress.status, LearningStatus.mastered);
    });

    test('interval never drops below 1 day', () {
      final result = engine.grade(freshWord(), ReviewGrade.again);
      expect(result.intervalDays, greaterThanOrEqualTo(1));
    });

    test('easeFactor never drops below the configured minimum', () {
      var progress = freshWord();
      for (var i = 0; i < 20; i++) {
        progress = engine.grade(progress, ReviewGrade.again);
      }
      expect(progress.easeFactor, greaterThanOrEqualTo(AppConstants.minEaseFactor));
    });
  });

  group('prioritize()', () {
    test('words with more wrong answers than right come first', () {
      final good = const WordProgress(wordRank: 1, timesSeen: 5, timesCorrect: 5);
      final struggling =
          const WordProgress(wordRank: 2, timesSeen: 5, timesIncorrect: 4, timesCorrect: 1);
      final result = engine.prioritize([good, struggling]);
      expect(result.first.wordRank, 2);
    });

    test('difficult-flagged words are prioritized over plain new words', () {
      final plain = const WordProgress(wordRank: 1);
      final difficult = const WordProgress(wordRank: 2, isDifficult: true);
      final result = engine.prioritize([plain, difficult]);
      expect(result.first.wordRank, 2);
    });
  });
}
