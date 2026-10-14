import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/settings_service.dart';
import '../../../vocabulary/domain/repositories/vocabulary_repository.dart';

part 'progress_state.dart';

class ProgressCubit extends Cubit<ProgressState> {
  ProgressCubit(this._repository, this._settings) : super(const ProgressLoading());

  final VocabularyRepository _repository;
  final SettingsService _settings;

  Future<void> load() async {
    emit(const ProgressLoading());
    try {
      final counts = await _repository.getStatusCounts();
      final total = counts.values.fold<int>(0, (a, b) => a + b);

      // Aggregate accuracy & total reviews across every word with activity.
      final words = await _repository.getAllWords();
      var totalReviewed = 0;
      var totalCorrect = 0;
      for (final w in words) {
        final p = await _repository.getProgress(w.rank);
        totalReviewed += p.timesSeen;
        totalCorrect += p.timesCorrect;
      }
      final accuracy = totalReviewed == 0 ? 0.0 : totalCorrect / totalReviewed;

      emit(ProgressLoaded(
        totalWords: total,
        mastered: counts[LearningStatus.mastered] ?? 0,
        review: counts[LearningStatus.review] ?? 0,
        learning: counts[LearningStatus.learning] ?? 0,
        newWords: counts[LearningStatus.newWord] ?? 0,
        accuracy: accuracy,
        wordsReviewed: totalReviewed,
        currentStreak: _settings.currentStreak,
        longestStreak: _settings.longestStreak,
      ));
    } catch (e) {
      emit(const ProgressError('Something went wrong. Please try again.'));
    }
  }
}
