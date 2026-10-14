import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/utils/settings_service.dart';
import '../../../vocabulary/domain/repositories/vocabulary_repository.dart';

class SettingsSnapshot extends Equatable {
  final AppLanguage language;
  final int dailyGoal;
  final bool darkMode;
  final double textScale;
  final bool soundEnabled;
  final bool hapticEnabled;
  final bool reduceAnimations;
  final bool notificationsEnabled;
  final String learningReminderTime;
  final String reviewReminderTime;

  const SettingsSnapshot({
    required this.language,
    required this.dailyGoal,
    required this.darkMode,
    required this.textScale,
    required this.soundEnabled,
    required this.hapticEnabled,
    required this.reduceAnimations,
    required this.notificationsEnabled,
    required this.learningReminderTime,
    required this.reviewReminderTime,
  });

  @override
  List<Object?> get props => [
        language,
        dailyGoal,
        darkMode,
        textScale,
        soundEnabled,
        hapticEnabled,
        reduceAnimations,
        notificationsEnabled,
        learningReminderTime,
        reviewReminderTime,
      ];
}

/// Thin reactive wrapper around [SettingsService] so widgets rebuild on
/// change (dark mode toggling the whole MaterialApp, etc.) without each
/// screen reaching into SharedPreferences directly.
class SettingsCubit extends Cubit<SettingsSnapshot> {
  SettingsCubit(this._settings, this._repository)
      : super(SettingsSnapshot(
          language: _settings.language,
          dailyGoal: _settings.dailyGoal,
          darkMode: _settings.isDarkMode,
          textScale: _settings.textScale,
          soundEnabled: _settings.soundEnabled,
          hapticEnabled: _settings.hapticEnabled,
          reduceAnimations: _settings.reduceAnimations,
          notificationsEnabled: _settings.notificationsEnabled,
          learningReminderTime: _settings.learningReminderTime,
          reviewReminderTime: _settings.reviewReminderTime,
        ));

  final SettingsService _settings;
  final VocabularyRepository _repository;

  void _refresh() => emit(SettingsSnapshot(
        language: _settings.language,
        dailyGoal: _settings.dailyGoal,
        darkMode: _settings.isDarkMode,
        textScale: _settings.textScale,
        soundEnabled: _settings.soundEnabled,
        hapticEnabled: _settings.hapticEnabled,
        reduceAnimations: _settings.reduceAnimations,
        notificationsEnabled: _settings.notificationsEnabled,
        learningReminderTime: _settings.learningReminderTime,
        reviewReminderTime: _settings.reviewReminderTime,
      ));

  Future<void> setLanguage(AppLanguage lang) async {
    await _settings.setLanguage(lang);
    _refresh();
  }

  Future<void> setDailyGoal(int goal) async {
    await _settings.setDailyGoal(goal);
    _refresh();
  }

  Future<void> setDarkMode(bool value) async {
    await _settings.setDarkMode(value);
    _refresh();
  }

  Future<void> setTextScale(double value) async {
    await _settings.setTextScale(value);
    _refresh();
  }

  Future<void> setSoundEnabled(bool value) async {
    await _settings.setSoundEnabled(value);
    _refresh();
  }

  Future<void> setHapticEnabled(bool value) async {
    await _settings.setHapticEnabled(value);
    _refresh();
  }

  Future<void> setReduceAnimations(bool value) async {
    await _settings.setReduceAnimations(value);
    _refresh();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    await _settings.setNotificationsEnabled(value);
    if (value) {
      await NotificationService.instance.requestPermissions();
      await NotificationService.instance.scheduleLearningReminder(
        hhmm: _settings.learningReminderTime,
        wordsWaiting: _settings.dailyGoal,
      );
    } else {
      await NotificationService.instance.cancelAll();
    }
    _refresh();
  }

  Future<void> setLearningReminderTime(String hhmm) async {
    await _settings.setLearningReminderTime(hhmm);
    if (_settings.notificationsEnabled) {
      await NotificationService.instance.scheduleLearningReminder(
        hhmm: hhmm,
        wordsWaiting: _settings.dailyGoal,
      );
    }
    _refresh();
  }

  Future<void> setReviewReminderTime(String hhmm) async {
    await _settings.setReviewReminderTime(hhmm);
    if (_settings.notificationsEnabled) {
      await NotificationService.instance
          .scheduleReviewReminder(hhmm: hhmm, wordsDue: 0);
    }
    _refresh();
  }

  /// Wipes learning progress after an explicit confirmation dialog in the UI.
  /// Never called implicitly (spec §27).
  Future<void> resetProgress() async {
    await AppDatabase.instance.resetProgress();
    await _repository.resetAllProgress();
    _refresh();
  }
}
