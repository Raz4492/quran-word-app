import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/word_progress.dart';

class WordProgressModel extends WordProgress {
  const WordProgressModel({
    required super.wordRank,
    super.status,
    super.timesSeen,
    super.timesCorrect,
    super.timesIncorrect,
    super.streak,
    super.easeFactor,
    super.intervalDays,
    super.lastReviewedAt,
    super.nextReviewAt,
    super.isFavorite,
    super.isDifficult,
  });

  factory WordProgressModel.initial(int wordRank) =>
      WordProgressModel(wordRank: wordRank);

  factory WordProgressModel.fromMap(Map<String, dynamic> map) {
    return WordProgressModel(
      wordRank: map['word_rank'] as int,
      status: LearningStatusX.fromDb(map['status'] as String? ?? 'new'),
      timesSeen: map['times_seen'] as int? ?? 0,
      timesCorrect: map['times_correct'] as int? ?? 0,
      timesIncorrect: map['times_wrong'] as int? ?? 0,
      streak: map['streak'] as int? ?? 0,
      easeFactor: (map['ease_factor'] as num?)?.toDouble() ??
          AppConstants.defaultEaseFactor,
      intervalDays: map['interval_days'] as int? ?? 0,
      lastReviewedAt: map['last_reviewed_at'] != null
          ? DateTime.tryParse(map['last_reviewed_at'] as String)
          : null,
      nextReviewAt: map['next_review_at'] != null
          ? DateTime.tryParse(map['next_review_at'] as String)
          : null,
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
      isDifficult: (map['is_difficult'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() => {
        'word_rank': wordRank,
        'status': status.toDb(),
        'times_seen': timesSeen,
        'times_correct': timesCorrect,
        'times_wrong': timesIncorrect,
        'streak': streak,
        'ease_factor': easeFactor,
        'interval_days': intervalDays,
        'last_reviewed_at': lastReviewedAt?.toIso8601String(),
        'next_review_at': nextReviewAt?.toIso8601String(),
        'is_favorite': isFavorite ? 1 : 0,
        'is_difficult': isDifficult ? 1 : 0,
      };

  factory WordProgressModel.fromEntity(WordProgress p) => WordProgressModel(
        wordRank: p.wordRank,
        status: p.status,
        timesSeen: p.timesSeen,
        timesCorrect: p.timesCorrect,
        timesIncorrect: p.timesIncorrect,
        streak: p.streak,
        easeFactor: p.easeFactor,
        intervalDays: p.intervalDays,
        lastReviewedAt: p.lastReviewedAt,
        nextReviewAt: p.nextReviewAt,
        isFavorite: p.isFavorite,
        isDifficult: p.isDifficult,
      );
}
