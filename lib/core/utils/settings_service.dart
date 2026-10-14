import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Small wrapper around SharedPreferences for user preferences and streak
/// bookkeeping. Deliberately not `flutter_secure_storage` here — nothing
/// stored is sensitive (no accounts, no PII); secure storage is reserved for
/// any future auth/cloud-sync tokens per spec §2.
class SettingsService {
  SettingsService(this._prefs);
  final SharedPreferences _prefs;

  static Future<SettingsService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsService(prefs);
  }

  // --- Onboarding / language / goal ---------------------------------
  bool get hasOnboarded => _prefs.getBool('has_onboarded') ?? false;
  Future<void> setHasOnboarded(bool value) => _prefs.setBool('has_onboarded', value);

  AppLanguage get language =>
      (_prefs.getString('language') ?? 'bangla') == 'english'
          ? AppLanguage.english
          : AppLanguage.bangla;
  Future<void> setLanguage(AppLanguage lang) =>
      _prefs.setString('language', lang == AppLanguage.english ? 'english' : 'bangla');

  int get dailyGoal => _prefs.getInt('daily_goal') ?? AppConstants.defaultDailyGoal;
  Future<void> setDailyGoal(int goal) => _prefs.setInt('daily_goal', goal);

  bool get isDarkMode => _prefs.getBool('dark_mode') ?? false;
  Future<void> setDarkMode(bool value) => _prefs.setBool('dark_mode', value);

  double get textScale => _prefs.getDouble('text_scale') ?? 1.0;
  Future<void> setTextScale(double value) => _prefs.setDouble('text_scale', value);

  bool get soundEnabled => _prefs.getBool('sound_enabled') ?? true;
  Future<void> setSoundEnabled(bool value) => _prefs.setBool('sound_enabled', value);

  bool get hapticEnabled => _prefs.getBool('haptic_enabled') ?? true;
  Future<void> setHapticEnabled(bool value) => _prefs.setBool('haptic_enabled', value);

  bool get reduceAnimations => _prefs.getBool('reduce_animations') ?? false;
  Future<void> setReduceAnimations(bool value) =>
      _prefs.setBool('reduce_animations', value);

  // --- Notifications ----------------------------------------------------
  bool get notificationsEnabled => _prefs.getBool('notifications_enabled') ?? true;
  Future<void> setNotificationsEnabled(bool value) =>
      _prefs.setBool('notifications_enabled', value);

  String get learningReminderTime =>
      _prefs.getString('learning_reminder_time') ??
      AppConstants.defaultLearningReminderTime;
  Future<void> setLearningReminderTime(String time) =>
      _prefs.setString('learning_reminder_time', time);

  String get reviewReminderTime =>
      _prefs.getString('review_reminder_time') ??
      AppConstants.defaultReviewReminderTime;
  Future<void> setReviewReminderTime(String time) =>
      _prefs.setString('review_reminder_time', time);

  // --- Streak -------------------------------------------------------
  int get currentStreak => _prefs.getInt('current_streak') ?? 0;
  int get longestStreak => _prefs.getInt('longest_streak') ?? 0;
  String? get lastActiveDate => _prefs.getString('last_active_date');

  /// Call once per day when the user completes any learning activity.
  /// Handles gaps gracefully — a missed day resets the streak to 1 rather
  /// than punishing further, and never shows guilt-based copy (spec §10).
  Future<void> recordActivityToday() async {
    final today = _dateOnly(DateTime.now());
    final last = lastActiveDate;
    if (last == today) return; // already recorded today

    int newStreak;
    if (last != null) {
      final lastDate = DateTime.parse(last);
      final diff = DateTime.parse(today).difference(lastDate).inDays;
      newStreak = diff == 1 ? currentStreak + 1 : 1;
    } else {
      newStreak = 1;
    }

    await _prefs.setInt('current_streak', newStreak);
    if (newStreak > longestStreak) {
      await _prefs.setInt('longest_streak', newStreak);
    }
    await _prefs.setString('last_active_date', today);
  }

  String _dateOnly(DateTime d) =>
      DateTime(d.year, d.month, d.day).toIso8601String().substring(0, 10);

  Future<void> resetAll() async {
    final goal = dailyGoal;
    final lang = language;
    await _prefs.clear();
    await setDailyGoal(goal);
    await setLanguage(lang);
    await setHasOnboarded(true);
  }
}
