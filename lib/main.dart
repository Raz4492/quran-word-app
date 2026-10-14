import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app.dart';
import 'core/notifications/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/settings_service.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';
import 'features/vocabulary/data/repositories/vocabulary_repository_impl.dart';
import 'features/vocabulary/domain/repositories/vocabulary_repository.dart';

/// Firebase is intentionally NOT initialized here. Per the product spec
/// (§2, §32), the app must work fully offline and Firebase (Analytics /
/// Crashlytics / FCM / Remote Config) is an optional Phase-4 add-on. To wire
/// it up later: add `Firebase.initializeApp()` behind a try/catch here so a
/// missing `google-services.json` / `GoogleService-Info.plist` never blocks
/// the learning experience from starting. See README.md for the exact steps.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsService = await SettingsService.create();
  final vocabularyRepository = VocabularyRepositoryImpl();
  await vocabularyRepository.initialize();

  await NotificationService.instance.initialize();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SettingsService>.value(value: settingsService),
        RepositoryProvider<VocabularyRepository>.value(value: vocabularyRepository),
      ],
      child: BlocProvider(
        create: (ctx) => SettingsCubit(
          ctx.read<SettingsService>(),
          ctx.read<VocabularyRepository>(),
        ),
        child: const _RootApp(),
      ),
    ),
  );
}

/// Single MaterialApp for the whole tree. Picks Onboarding vs. the main
/// bottom-nav shell based on persisted state, and re-themes live when the
/// user flips Dark Mode / Text Size in Settings.
class _RootApp extends StatelessWidget {
  const _RootApp();

  @override
  Widget build(BuildContext context) {
    final hasOnboarded = context.read<SettingsService>().hasOnboarded;

    return BlocBuilder<SettingsCubit, SettingsSnapshot>(
      builder: (context, settings) {
        return MaterialApp(
          title: 'Quran 500',
          debugShowCheckedModeBanner: false,
          themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          builder: (context, child) {
            final mq = MediaQuery.of(context);
            return MediaQuery(
              data: mq.copyWith(textScaler: TextScaler.linear(settings.textScale)),
              child: child!,
            );
          },
          home: hasOnboarded ? const AppShell() : const OnboardingPage(),
        );
      },
    );
  }
}
