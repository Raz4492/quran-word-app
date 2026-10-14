part of 'flashcard_cubit.dart';

/// A single multiple-choice quiz-style prompt generated for a flashcard mode
/// that needs options (Mode 2/3/4/5). Modes 1 stays as free reveal + grade.
class FlashcardOptions extends Equatable {
  final List<String> choices;
  final String correctChoice;
  const FlashcardOptions(this.choices, this.correctChoice);
  @override
  List<Object?> get props => [choices, correctChoice];
}

sealed class FlashcardState extends Equatable {
  const FlashcardState();
  @override
  List<Object?> get props => [];
}

class FlashcardLoading extends FlashcardState {
  const FlashcardLoading();
}

class FlashcardEmpty extends FlashcardState {
  final String message;
  const FlashcardEmpty(this.message);
  @override
  List<Object?> get props => [message];
}

class FlashcardInProgress extends FlashcardState {
  final List<LearningWord> queue;
  final int index;
  final bool revealed;
  final FlashcardMode mode;
  final FlashcardOptions? options;
  final int correctInSession;
  final int totalInSession;

  const FlashcardInProgress({
    required this.queue,
    required this.index,
    required this.mode,
    this.revealed = false,
    this.options,
    this.correctInSession = 0,
    required this.totalInSession,
  });

  LearningWord get current => queue[index];
  bool get isLast => index >= queue.length - 1;

  FlashcardInProgress copyWith({
    List<LearningWord>? queue,
    int? index,
    bool? revealed,
    FlashcardMode? mode,
    FlashcardOptions? options,
    bool clearOptions = false,
    int? correctInSession,
  }) {
    return FlashcardInProgress(
      queue: queue ?? this.queue,
      index: index ?? this.index,
      revealed: revealed ?? this.revealed,
      mode: mode ?? this.mode,
      options: clearOptions ? null : (options ?? this.options),
      correctInSession: correctInSession ?? this.correctInSession,
      totalInSession: totalInSession,
    );
  }

  @override
  List<Object?> get props =>
      [queue, index, revealed, mode, options, correctInSession, totalInSession];
}

class FlashcardSessionComplete extends FlashcardState {
  final int total;
  final int correct;
  final int wordsLearnedToMastery;
  const FlashcardSessionComplete({
    required this.total,
    required this.correct,
    required this.wordsLearnedToMastery,
  });
  @override
  List<Object?> get props => [total, correct, wordsLearnedToMastery];
}
