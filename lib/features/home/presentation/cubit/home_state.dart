part of 'home_cubit.dart';

class DailyMission extends Equatable {
  final String title;
  final String actionLabel;
  final SessionSource source;
  const DailyMission(this.title, this.actionLabel, this.source);
  @override
  List<Object?> get props => [title, actionLabel, source];
}

sealed class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
  @override
  List<Object?> get props => [message];
}

class HomeLoaded extends HomeState {
  final int dailyGoal;
  final int wordsLearnedToday;
  final int reviewDueCount;
  final int currentStreak;
  final int totalWordsMastered;
  final int totalWordsLearned;
  final DailyMission mission;
  final int nextLessonStart; // rank of next unlearned word, 1-based
  final int nextLessonCount;

  const HomeLoaded({
    required this.dailyGoal,
    required this.wordsLearnedToday,
    required this.reviewDueCount,
    required this.currentStreak,
    required this.totalWordsMastered,
    required this.totalWordsLearned,
    required this.mission,
    required this.nextLessonStart,
    required this.nextLessonCount,
  });

  double get todayProgress =>
      dailyGoal == 0 ? 0 : (wordsLearnedToday / dailyGoal).clamp(0, 1).toDouble();

  @override
  List<Object?> get props => [
        dailyGoal,
        wordsLearnedToday,
        reviewDueCount,
        currentStreak,
        totalWordsMastered,
        totalWordsLearned,
        mission,
        nextLessonStart,
        nextLessonCount,
      ];
}
