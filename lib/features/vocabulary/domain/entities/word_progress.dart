import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_constants.dart';
import 'quran_word.dart';

/// Mutable learning state for a single word, stored in SQLite
/// (`word_progress` table). The 500-word master list itself never changes;
/// only this record changes as the user studies.
class WordProgress extends Equatable {
  final int wordRank;
  final LearningStatus status;
  final int timesSeen;
  final int timesCorrect;
  final int timesIncorrect;
  final int streak;
  final double easeFactor;
  final int intervalDays;
  final DateTime? lastReviewedAt;
  final DateTime? nextReviewAt;
  final bool isFavorite;
  final bool isDifficult;

  const WordProgress({
    required this.wordRank,
    this.status = LearningStatus.newWord,
    this.timesSeen = 0,
    this.timesCorrect = 0,
    this.timesIncorrect = 0,
    this.streak = 0,
    this.easeFactor = AppConstants.defaultEaseFactor,
    this.intervalDays = 0,
    this.lastReviewedAt,
    this.nextReviewAt,
    this.isFavorite = false,
    this.isDifficult = false,
  });

  double get accuracy =>
      timesSeen == 0 ? 0 : (timesCorrect / timesSeen).clamp(0, 1).toDouble();

  bool get isDueForReview {
    if (nextReviewAt == null) return status != LearningStatus.newWord;
    return !nextReviewAt!.isAfter(DateTime.now());
  }

  WordProgress copyWith({
    LearningStatus? status,
    int? timesSeen,
    int? timesCorrect,
    int? timesIncorrect,
    int? streak,
    double? easeFactor,
    int? intervalDays,
    DateTime? lastReviewedAt,
    DateTime? nextReviewAt,
    bool? isFavorite,
    bool? isDifficult,
  }) {
    return WordProgress(
      wordRank: wordRank,
      status: status ?? this.status,
      timesSeen: timesSeen ?? this.timesSeen,
      timesCorrect: timesCorrect ?? this.timesCorrect,
      timesIncorrect: timesIncorrect ?? this.timesIncorrect,
      streak: streak ?? this.streak,
      easeFactor: easeFactor ?? this.easeFactor,
      intervalDays: intervalDays ?? this.intervalDays,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      isFavorite: isFavorite ?? this.isFavorite,
      isDifficult: isDifficult ?? this.isDifficult,
    );
  }

  @override
  List<Object?> get props => [
        wordRank,
        status,
        timesSeen,
        timesCorrect,
        timesIncorrect,
        streak,
        easeFactor,
        intervalDays,
        lastReviewedAt,
        nextReviewAt,
        isFavorite,
        isDifficult,
      ];
}

/// A word joined with its progress — the shape most UI widgets consume.
class LearningWord extends Equatable {
  final QuranWord word;
  final WordProgress progress;

  const LearningWord(this.word, this.progress);

  @override
  List<Object?> get props => [word, progress];
}
