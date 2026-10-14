import '../../../core/constants/app_constants.dart';
import '../../vocabulary/domain/entities/word_progress.dart';

/// A simple, SM-2-inspired spaced repetition algorithm (spec §6).
///
/// Deliberately not a full SM-2 implementation and definitely not an ML
/// model — just enough to move words through New -> Learning -> Review ->
/// Mastered based on the four grading buttons (Again / Hard / Good / Easy),
/// and to schedule a sensible `nextReviewAt`.
class SpacedRepetitionEngine {
  const SpacedRepetitionEngine();

  WordProgress grade(WordProgress current, ReviewGrade grade) {
    final now = DateTime.now();
    final wasCorrect = grade != ReviewGrade.again;

    double ease = current.easeFactor;
    int interval = current.intervalDays;
    int streak = current.streak;
    var status = current.status;

    switch (grade) {
      case ReviewGrade.again:
        ease = (ease - 0.3).clamp(AppConstants.minEaseFactor, 3.0);
        interval = 0; // shows again very soon (same session / next session)
        streak = 0;
        status = LearningStatus.learning;
        break;
      case ReviewGrade.hard:
        ease = (ease - 0.15).clamp(AppConstants.minEaseFactor, 3.0);
        interval = interval <= 0
            ? AppConstants.firstIntervalDays
            : (interval * 1.2).round();
        streak += 1;
        status = _nextStatusOnSuccess(status, streak);
        break;
      case ReviewGrade.good:
        interval = interval <= 0
            ? AppConstants.firstIntervalDays
            : interval == AppConstants.firstIntervalDays
                ? AppConstants.secondIntervalDays
                : (interval * ease).round();
        streak += 1;
        status = _nextStatusOnSuccess(status, streak);
        break;
      case ReviewGrade.easy:
        ease = (ease + 0.15).clamp(AppConstants.minEaseFactor, 3.0);
        interval = interval <= 0
            ? AppConstants.secondIntervalDays
            : (interval * ease * 1.3).round();
        streak += 2;
        status = _nextStatusOnSuccess(status, streak);
        break;
    }

    if (interval < 1) interval = 1;

    return current.copyWith(
      status: status,
      timesSeen: current.timesSeen + 1,
      timesCorrect: current.timesCorrect + (wasCorrect ? 1 : 0),
      timesIncorrect: current.timesIncorrect + (wasCorrect ? 0 : 1),
      streak: streak,
      easeFactor: ease,
      intervalDays: interval,
      lastReviewedAt: now,
      nextReviewAt: now.add(Duration(days: interval)),
    );
  }

  LearningStatus _nextStatusOnSuccess(LearningStatus current, int streak) {
    if (streak >= 8) return LearningStatus.mastered;
    if (streak >= 3) return LearningStatus.review;
    return LearningStatus.learning;
  }

  /// Orders a set of candidate words for a study/review session, prioritizing
  /// (per spec §6): wrong answers > due reviews > difficult words > recently
  /// learned > new words.
  List<WordProgress> prioritize(List<WordProgress> candidates) {
    final now = DateTime.now();
    final sorted = [...candidates];
    sorted.sort((a, b) {
      int score(WordProgress p) {
        var s = 0;
        if (p.timesIncorrect > p.timesCorrect) s -= 100;
        if (p.nextReviewAt != null && !p.nextReviewAt!.isAfter(now)) s -= 50;
        if (p.isDifficult) s -= 30;
        if (p.lastReviewedAt != null &&
            now.difference(p.lastReviewedAt!).inHours < 48) {
          s -= 10;
        }
        if (p.status == LearningStatus.newWord) s -= 1;
        return s;
      }

      return score(a).compareTo(score(b));
    });
    return sorted;
  }
}
