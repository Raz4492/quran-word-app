import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/settings_service.dart';
import '../../../learning/presentation/cubit/flashcard_cubit.dart' show SessionSource;
import '../../../vocabulary/domain/repositories/vocabulary_repository.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repository, this._settings) : super(const HomeLoading());

  final VocabularyRepository _repository;
  final SettingsService _settings;
  final _random = Random();

  static const _missions = [
    'Learn 5 Quranic words',
    'Review 10 words',
    'Complete one quiz',
    "Review today's difficult words",
    'Practice Arabic recognition for 5 minutes',
  ];

  Future<void> load() async {
    emit(const HomeLoading());
    try {
      final counts = await _repository.getStatusCounts();
      final due = await _repository.getDueForReview();
      final newRanks = await _repository.getNextNewWordRanks(_settings.dailyGoal);

      final mastered = counts[LearningStatus.mastered] ?? 0;
      final total = counts.values.fold<int>(0, (a, b) => a + b);
      final learnedTotal = total - (counts[LearningStatus.newWord] ?? 0);

      // "Words learned today" is approximated from how many of today's
      // target new-word slots are already filled (i.e. no longer "new").
      final goal = _settings.dailyGoal;
      final learnedToday = (goal - newRanks.length).clamp(0, goal);

      final missionText = _missions[_random.nextInt(_missions.length)];

      emit(HomeLoaded(
        dailyGoal: goal,
        wordsLearnedToday: learnedToday,
        reviewDueCount: due.length,
        currentStreak: _settings.currentStreak,
        totalWordsMastered: mastered,
        totalWordsLearned: learnedTotal,
        mission: DailyMission(
          missionText,
          'Start Mission',
          SessionSource.newDailyLesson,
        ),
        nextLessonStart: newRanks.isNotEmpty ? newRanks.first : 1,
        nextLessonCount: newRanks.length,
      ));
    } catch (e) {
      emit(const HomeError('Something went wrong. Please try again.'));
    }
  }
}
