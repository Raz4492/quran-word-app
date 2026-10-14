import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quran_500_words/core/utils/settings_service.dart';
import 'package:quran_500_words/features/onboarding/presentation/pages/onboarding_page.dart';

void main() {
  testWidgets('Onboarding shows the welcome screen and a Next button',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final settings = await SettingsService.create();

    await tester.pumpWidget(
      RepositoryProvider<SettingsService>.value(
        value: settings,
        child: const MaterialApp(home: OnboardingPage()),
      ),
    );

    expect(find.text('Learn Quranic Words'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('Tapping Next four times reaches "Let\'s Begin"',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final settings = await SettingsService.create();

    await tester.pumpWidget(
      RepositoryProvider<SettingsService>.value(
        value: settings,
        child: const MaterialApp(home: OnboardingPage()),
      ),
    );

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }

    expect(find.text("Let's Begin"), findsOneWidget);
  });
}
