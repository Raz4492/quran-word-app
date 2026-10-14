part of 'quiz_cubit.dart';

class QuizQuestion extends Equatable {
  final QuranWord word;
  final String promptLabel; // what's shown as the question stem
  final List<String> choices;
  final String correctChoice;

  const QuizQuestion({
    required this.word,
    required this.promptLabel,
    required this.choices,
    required this.correctChoice,
  });

  @override
  List<Object?> get props => [word, promptLabel, choices, correctChoice];
}

sealed class QuizState extends Equatable {
  const QuizState();
  @override
  List<Object?> get props => [];
}

class QuizLoading extends QuizState {
  const QuizLoading();
}

class QuizNotEnoughWords extends QuizState {
  const QuizNotEnoughWords();
}

class QuizInProgress extends QuizState {
  final List<QuizQuestion> questions;
  final int index;
  final int correctCount;
  final String? selectedChoice;
  final bool answered;
  final List<int> missedWordRanks;

  const QuizInProgress({
    required this.questions,
    required this.index,
    this.correctCount = 0,
    this.selectedChoice,
    this.answered = false,
    this.missedWordRanks = const [],
  });

  QuizQuestion get current => questions[index];
  bool get isLast => index >= questions.length - 1;

  QuizInProgress copyWith({
    int? index,
    int? correctCount,
    String? selectedChoice,
    bool clearSelected = false,
    bool? answered,
    List<int>? missedWordRanks,
  }) {
    return QuizInProgress(
      questions: questions,
      index: index ?? this.index,
      correctCount: correctCount ?? this.correctCount,
      selectedChoice: clearSelected ? null : (selectedChoice ?? this.selectedChoice),
      answered: answered ?? this.answered,
      missedWordRanks: missedWordRanks ?? this.missedWordRanks,
    );
  }

  @override
  List<Object?> get props =>
      [questions, index, correctCount, selectedChoice, answered, missedWordRanks];
}

class QuizComplete extends QuizState {
  final int total;
  final int correct;
  final List<int> missedWordRanks;

  const QuizComplete({
    required this.total,
    required this.correct,
    required this.missedWordRanks,
  });

  double get percent => total == 0 ? 0 : correct / total;

  @override
  List<Object?> get props => [total, correct, missedWordRanks];
}
