/// Central place for app-wide constant values.
///
/// Keeping these in one file makes it easy to tune the learning experience
/// (daily goal choices, level size, SM-2 parameters) without hunting through
/// the codebase.
class AppConstants {
  AppConstants._();

  static const String appName = 'Quran 500';
  static const int totalWordCount = 500;

  /// Words per "level" in the Browse/Level screens (Level 1 = words 1-25 ...).
  static const int wordsPerLevel = 25;
  static const int totalLevels = totalWordCount ~/ wordsPerLevel;

  /// Daily goal choices offered during onboarding & settings.
  static const List<int> dailyGoalOptions = [5, 10, 15, 20];
  static const int defaultDailyGoal = 10;

  /// SM-2 inspired spaced repetition tuning.
  static const double minEaseFactor = 1.3;
  static const double defaultEaseFactor = 2.5;
  static const int firstIntervalDays = 1;
  static const int secondIntervalDays = 3;

  /// Notification defaults.
  static const String defaultLearningReminderTime = '20:00'; // 8:00 PM
  static const String defaultReviewReminderTime = '21:00'; // 9:00 PM

  static const Duration cardFlipDuration = Duration(milliseconds: 350);
  static const Duration swipeAnimationDuration = Duration(milliseconds: 250);
}

/// Learning status for a single word, mirrors the `word_progress.status`
/// column in SQLite. Order matters for the New -> Learning -> Review ->
/// Mastered progression used across the UI.
enum LearningStatus { newWord, learning, review, mastered }

extension LearningStatusX on LearningStatus {
  String get label => switch (this) {
        LearningStatus.newWord => 'New',
        LearningStatus.learning => 'Learning',
        LearningStatus.review => 'Review',
        LearningStatus.mastered => 'Mastered',
      };

  static LearningStatus fromDb(String value) => switch (value) {
        'learning' => LearningStatus.learning,
        'review' => LearningStatus.review,
        'mastered' => LearningStatus.mastered,
        _ => LearningStatus.newWord,
      };

  String toDb() => switch (this) {
        LearningStatus.newWord => 'new',
        LearningStatus.learning => 'learning',
        LearningStatus.review => 'review',
        LearningStatus.mastered => 'mastered',
      };
}

/// The four flashcard grading buttons that drive spaced repetition.
enum ReviewGrade { again, hard, good, easy }

/// The five flashcard practice modes described in the product spec.
enum FlashcardMode {
  arabicToMeaning,
  meaningToArabic,
  arabicRecognition,
  transliteration,
  bangla,
}

/// Quiz difficulty tiers.
enum QuizDifficulty { easy, medium, hard }

/// Supported interface languages. Arabic content is never translated.
enum AppLanguage { bangla, english }
