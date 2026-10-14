import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/word_progress.dart';
import '../../domain/repositories/vocabulary_repository.dart';

part 'vocabulary_state.dart';

class VocabularyCubit extends Cubit<VocabularyState> {
  VocabularyCubit(this._repository) : super(const VocabularyLoading());

  final VocabularyRepository _repository;

  Future<void> loadAll() async {
    emit(const VocabularyLoading());
    try {
      final words = await _repository.getAllWords();
      final learningWords = <LearningWord>[];
      for (final w in words) {
        final progress = await _repository.getProgress(w.rank);
        learningWords.add(LearningWord(w, progress));
      }
      emit(VocabularyLoaded(allWords: learningWords, visibleWords: learningWords));
    } catch (e) {
      emit(const VocabularyError('Something went wrong. Please try again.'));
    }
  }

  void setFilter(BrowseFilter filter) {
    final current = state;
    if (current is! VocabularyLoaded) return;
    emit(_applyFilters(current.copyWith(filter: filter)));
  }

  void setQuery(String query) {
    final current = state;
    if (current is! VocabularyLoaded) return;
    emit(_applyFilters(current.copyWith(query: query)));
  }

  VocabularyLoaded _applyFilters(VocabularyLoaded s) {
    Iterable<LearningWord> words = s.allWords;

    words = switch (s.filter) {
      BrowseFilter.all => words,
      BrowseFilter.newWord =>
        words.where((w) => w.progress.status == LearningStatus.newWord),
      BrowseFilter.learning =>
        words.where((w) => w.progress.status == LearningStatus.learning),
      BrowseFilter.review =>
        words.where((w) => w.progress.status == LearningStatus.review),
      BrowseFilter.mastered =>
        words.where((w) => w.progress.status == LearningStatus.mastered),
      BrowseFilter.favorites => words.where((w) => w.progress.isFavorite),
      BrowseFilter.difficult => words.where((w) => w.progress.isDifficult),
    };

    if (s.query.trim().isNotEmpty) {
      final q = s.query.trim().toLowerCase();
      final rankQuery = int.tryParse(q);
      words = words.where((w) {
        if (rankQuery != null && w.word.rank == rankQuery) return true;
        return w.word.arabic.contains(q) ||
            w.word.transliteration.toLowerCase().contains(q) ||
            w.word.bangla.toLowerCase().contains(q) ||
            w.word.english.toLowerCase().contains(q);
      });
    }

    return s.copyWith(visibleWords: words.toList());
  }

  Future<void> toggleFavorite(int rank) async {
    await _repository.toggleFavorite(rank);
    await loadAll();
  }

  Future<void> toggleDifficult(int rank) async {
    await _repository.toggleDifficult(rank);
    await loadAll();
  }
}
