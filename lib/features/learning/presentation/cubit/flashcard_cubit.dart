import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/settings_service.dart';
import '../../../vocabulary/domain/entities/quran_word.dart';
import '../../../vocabulary/domain/entities/word_progress.dart';
import '../../../vocabulary/domain/repositories/vocabulary_repository.dart';
import '../../domain/spaced_repetition.dart';

part 'flashcard_state.dart';

/// Where the words for this session should come from.
enum SessionSource { newDailyLesson, review, difficultOnly, favoritesOnly, specificRanks }

class FlashcardCubit extends Cubit<FlashcardState> {
  FlashcardCubit(this._repository, this._settings)
      : super(const FlashcardLoading());

  final VocabularyRepository _repository;
  final SettingsService _settings;
  final SpacedRepetitionEngine _engine = const SpacedRepetitionEngine();
  final _random = Random();

  Future<void> startSession({
    required SessionSource source,
    List<int>? specificRanks,
    int? wordCount,
  }) async {
    emit(const FlashcardLoading());
    try {
      List<LearningWord> queue;
      switch (source) {
        case SessionSource.newDailyLesson:
          final ranks = await _repository
              .getNextNewWordRanks(wordCount ?? _settings.dailyGoal);
          queue = [];
          for (final r in ranks) {
            final w = await _repository.getWordByRank(r);
            if (w == null) continue;
            final p = await _repository.getProgress(r);
            queue.add(LearningWord(w, p));
          }
          break;
        case SessionSource.review:
          queue = await _repository.getDueForReview(limit: wordCount);
          break;
        case SessionSource.difficultOnly:
          queue = await _repository.getDifficultWords();
          break;
        case SessionSource.favoritesOnly:
          queue = await _repository.getFavorites();
          break;
        case SessionSource.specificRanks:
          queue = [];
          for (final r in specificRanks ?? const <int>[]) {
            final w = await _repository.getWordByRank(r);
            if (w == null) continue;
            final p = await _repository.getProgress(r);
            queue.add(LearningWord(w, p));
          }
          break;
      }

      if (queue.isEmpty) {
        emit(const FlashcardEmpty(
            'Nothing to study right now. Great job staying on top of things!'));
        return;
      }

      // Prioritize per spec §6 (wrong answers, due reviews, difficult, recent, new).
      final prioritized = _engine.prioritize(queue.map((e) => e.progress).toList());
      final byRank = {for (final lw in queue) lw.word.rank: lw};
      queue = prioritized.map((p) => byRank[p.wordRank]!).toList();

      emit(FlashcardInProgress(
        queue: queue,
        index: 0,
        mode: _pickMode(0),
        totalInSession: queue.length,
      ));
      _prepareOptionsIfNeeded();
    } catch (e) {
      emit(const FlashcardEmpty('Something went wrong. Please try again.'));
    }
  }

  /// Cycle through modes so consecutive cards don't feel identical (spec §7).
  FlashcardMode _pickMode(int index) {
    const modes = FlashcardMode.values;
    return modes[index % modes.length];
  }

  void reveal() {
    final s = state;
    if (s is! FlashcardInProgress) return;
    emit(s.copyWith(revealed: true));
  }

  void _prepareOptionsIfNeeded() {
    final s = state;
    if (s is! FlashcardInProgress) return;
    if (s.mode == FlashcardMode.arabicRecognition) return; // free reveal only

    final correctWord = s.current.word;
    final pool = s.queue.map((e) => e.word).toList();

    String labelFor(QuranWord w, FlashcardMode mode) {
      return switch (mode) {
        FlashcardMode.arabicToMeaning => w.english,
        FlashcardMode.meaningToArabic => w.arabic,
        FlashcardMode.transliteration => w.arabic,
        FlashcardMode.bangla => w.arabic,
        FlashcardMode.arabicRecognition => w.english,
      };
    }

    final correctLabel = labelFor(correctWord, s.mode);
    final others = pool.where((w) => w.rank != correctWord.rank).toList()
      ..shuffle(_random);
    final distractors =
        others.take(3).map((w) => labelFor(w, s.mode)).toSet().toList();

    final choices = [correctLabel, ...distractors];
    choices.shuffle(_random);

    emit(s.copyWith(options: FlashcardOptions(choices, correctLabel)));
  }

  Future<void> grade(ReviewGrade grade) async {
    final s = state;
    if (s is! FlashcardInProgress) return;

    final updated = _engine.grade(s.current.progress, grade);
    await _repository.saveProgress(updated);
    await _settings.recordActivityToday();

    final wasCorrect = grade != ReviewGrade.again;
    final nextCorrect = s.correctInSession + (wasCorrect ? 1 : 0);

    if (s.isLast) {
      final masteredCount = updated.status == LearningStatus.mastered ? 1 : 0;
      emit(FlashcardSessionComplete(
        total: s.totalInSession,
        correct: nextCorrect,
        wordsLearnedToMastery: masteredCount,
      ));
      return;
    }

    final nextIndex = s.index + 1;
    emit(s.copyWith(
      index: nextIndex,
      revealed: false,
      mode: _pickMode(nextIndex),
      correctInSession: nextCorrect,
      clearOptions: true,
    ));
    _prepareOptionsIfNeeded();
  }

  /// Used by multiple-choice modes: taps an answer, which reveals the card;
  /// the cubit then auto-grades shortly after (see FlashcardPage).
  void answerMultipleChoice(String choice) {
    final s = state;
    if (s is! FlashcardInProgress || s.options == null) return;
    emit(s.copyWith(revealed: true));
  }
}
