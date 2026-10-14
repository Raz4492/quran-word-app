import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/settings_service.dart';
import '../../../vocabulary/domain/entities/quran_word.dart';
import '../../../vocabulary/domain/entities/word_progress.dart';
import '../../../vocabulary/domain/repositories/vocabulary_repository.dart';

part 'quiz_state.dart';

class QuizCubit extends Cubit<QuizState> {
  QuizCubit(this._repository, this._settings) : super(const QuizLoading());

  final VocabularyRepository _repository;
  final SettingsService _settings;
  final _random = Random();

  Future<void> startQuiz({
    required QuizDifficulty difficulty,
    int questionCount = 10,
    List<int>? restrictToRanks,
  }) async {
    emit(const QuizLoading());
    final allWords = await _repository.getAllWords();
    if (allWords.length < 4) {
      emit(const QuizNotEnoughWords());
      return;
    }

    // Prefer words the learner has already been exposed to (new + review),
    // falling back to the whole list if they haven't studied much yet.
    List<QuranWord> pool = allWords;
    if (restrictToRanks != null && restrictToRanks.isNotEmpty) {
      pool = allWords.where((w) => restrictToRanks.contains(w.rank)).toList();
    } else {
      final studied = <QuranWord>[];
      for (final w in allWords) {
        final p = await _repository.getProgress(w.rank);
        if (p.status != LearningStatus.newWord) studied.add(w);
      }
      pool = studied.length >= questionCount ? studied : allWords;
    }

    pool = [...pool]..shuffle(_random);
    final selected = pool.take(min(questionCount, pool.length)).toList();

    final questions = selected
        .map((w) => _buildQuestion(w, allWords, difficulty))
        .toList();

    emit(QuizInProgress(questions: questions, index: 0));
  }

  QuizQuestion _buildQuestion(
      QuranWord word, List<QuranWord> allWords, QuizDifficulty difficulty) {
    String promptLabel;
    String Function(QuranWord) answerOf;

    switch (difficulty) {
      case QuizDifficulty.easy:
        // Arabic -> English
        promptLabel = word.arabic;
        answerOf = (w) => w.english;
        break;
      case QuizDifficulty.medium:
        // Arabic -> Bangla
        promptLabel = word.arabic;
        answerOf = (w) => w.bangla;
        break;
      case QuizDifficulty.hard:
        // Meaning -> Arabic (advanced: similar-looking distractors)
        promptLabel = word.english;
        answerOf = (w) => w.arabic;
        break;
    }

    final correct = answerOf(word);
    final others = allWords.where((w) => w.rank != word.rank).toList()
      ..shuffle(_random);
    final distractors =
        others.take(6).map(answerOf).where((a) => a != correct).take(3).toSet();

    final choices = [correct, ...distractors].toSet().toList()..shuffle(_random);

    return QuizQuestion(
      word: word,
      promptLabel: promptLabel,
      choices: choices,
      correctChoice: correct,
    );
  }

  void selectAnswer(String choice) {
    final s = state;
    if (s is! QuizInProgress || s.answered) return;
    final isCorrect = choice == s.current.correctChoice;
    emit(s.copyWith(
      selectedChoice: choice,
      answered: true,
      correctCount: s.correctCount + (isCorrect ? 1 : 0),
      missedWordRanks: isCorrect
          ? s.missedWordRanks
          : [...s.missedWordRanks, s.current.word.rank],
    ));
  }

  Future<void> next() async {
    final s = state;
    if (s is! QuizInProgress) return;
    if (s.isLast) {
      await _settings.recordActivityToday();
      emit(QuizComplete(
        total: s.questions.length,
        correct: s.correctCount,
        missedWordRanks: s.missedWordRanks,
      ));
      return;
    }
    emit(s.copyWith(
      index: s.index + 1,
      clearSelected: true,
      answered: false,
    ));
  }
}
