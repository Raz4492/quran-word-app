part of 'progress_cubit.dart';

sealed class ProgressState extends Equatable {
  const ProgressState();
  @override
  List<Object?> get props => [];
}

class ProgressLoading extends ProgressState {
  const ProgressLoading();
}

class ProgressError extends ProgressState {
  final String message;
  const ProgressError(this.message);
  @override
  List<Object?> get props => [message];
}

class ProgressLoaded extends ProgressState {
  final int totalWords;
  final int mastered;
  final int review;
  final int learning;
  final int newWords;
  final double accuracy; // 0..1
  final int wordsReviewed;
  final int currentStreak;
  final int longestStreak;

  const ProgressLoaded({
    required this.totalWords,
    required this.mastered,
    required this.review,
    required this.learning,
    required this.newWords,
    required this.accuracy,
    required this.wordsReviewed,
    required this.currentStreak,
    required this.longestStreak,
  });

  int get wordsLearned => totalWords - newWords;
  double get percentComplete => totalWords == 0 ? 0 : wordsLearned / totalWords;

  @override
  List<Object?> get props => [
        totalWords,
        mastered,
        review,
        learning,
        newWords,
        accuracy,
        wordsReviewed,
        currentStreak,
        longestStreak,
      ];
}
