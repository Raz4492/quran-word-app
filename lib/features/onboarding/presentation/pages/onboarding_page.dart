
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/settings_service.dart';
import '../../../../app.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _controller;

  int _page = 0;
  int _selectedGoal = AppConstants.defaultDailyGoal;
  AppLanguage _selectedLanguage = AppLanguage.bangla;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < 3) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final settings = context.read<SettingsService>();

    await settings.setDailyGoal(_selectedGoal);
    await settings.setLanguage(_selectedLanguage);
    await settings.setHasOnboarded(true);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const AppShell(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Main onboarding pages
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (index) {
                  setState(() {
                    _page = index;
                  });
                },
                children: [
                  const _IntroScreen(
                    arabic: 'القرآن',
                    title: 'Learn Quranic Words',
                    body:
                        'Master the 500 most frequent words in the Quran.',
                  ),
                  const _IntroScreen(
                    arabic: '📖',
                    title: 'Learn a Few Every Day',
                    body:
                        'Flashcards, revision and quizzes — a few minutes a day.',
                  ),
                  _GoalScreen(
                    selected: _selectedGoal,
                    onSelect: (goal) {
                      setState(() {
                        _selectedGoal = goal;
                      });
                    },
                  ),
                  _LanguageScreen(
                    selected: _selectedLanguage,
                    onSelect: (language) {
                      setState(() {
                        _selectedLanguage = language;
                      });
                    },
                  ),
                ],
              ),
            ),

            // Footer: page indicators and navigation button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Row(
                children: [
                  // Page indicators
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      4,
                      (index) {
                        final isActive = index == _page;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.only(right: 6),
                          width: isActive ? 22 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: isActive
                                ? AppColors.primaryGreen
                                : AppColors.primaryGreen.withOpacity(0.2),
                          ),
                        );
                      },
                    ),
                  ),

                  const Spacer(),

                  // Navigation button
                  ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 52),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _page == 3 ? "Let's Begin" : 'Next',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _page == 3
                              ? Icons.check_rounded
                              : Icons.arrow_forward_rounded,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Introductory onboarding screen
// -----------------------------------------------------------------------------

class _IntroScreen extends StatelessWidget {
  final String arabic;
  final String title;
  final String body;

  const _IntroScreen({
    required this.arabic,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  arabic,
                  textAlign: TextAlign.center,
                  style: arabic == 'القرآن'
                      ? AppTheme.arabicStyle(size: 52)
                      : const TextStyle(fontSize: 64),
                ),
              ),
              const SizedBox(height: 36),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                body,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.7,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Daily learning goal selection
// -----------------------------------------------------------------------------

class _GoalScreen extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;

  const _GoalScreen({
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.flag_rounded,
                size: 54,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(height: 24),
              Text(
                'Choose Your Goal',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'How many Quranic words would you like to learn each day?',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),

              ...AppConstants.dailyGoalOptions.map((goal) {
                final isSelected = selected == goal;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: OutlinedButton(
                    onPressed: () => onSelect(goal),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 58),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      backgroundColor: isSelected
                          ? AppColors.primaryGreen.withOpacity(0.10)
                          : Colors.transparent,
                      foregroundColor: AppColors.primaryGreen,
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primaryGreen
                            : AppColors.primaryGreen.withOpacity(0.25),
                        width: isSelected ? 1.8 : 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$goal words/day',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 22,
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Language selection
// -----------------------------------------------------------------------------

class _LanguageScreen extends StatelessWidget {
  final AppLanguage selected;
  final ValueChanged<AppLanguage> onSelect;

  const _LanguageScreen({
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.translate_rounded,
                size: 54,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(height: 24),
              Text(
                'Choose Language',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Select your preferred language for learning.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),

              _LanguageOption(
                title: 'বাংলা',
                subtitle: 'Bangla',
                icon: Icons.language_rounded,
                selected: selected == AppLanguage.bangla,
                onTap: () => onSelect(AppLanguage.bangla),
              ),

              const SizedBox(height: 12),

              _LanguageOption(
                title: 'English',
                subtitle: 'English language',
                icon: Icons.translate_rounded,
                selected: selected == AppLanguage.english,
                onTap: () => onSelect(AppLanguage.english),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: selected
          ? AppColors.primaryGreen.withOpacity(0.10)
          : theme.cardColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AppColors.primaryGreen
                  : AppColors.primaryGreen.withOpacity(0.20),
              width: selected ? 1.8 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primaryGreen,
                  size: 24,
                )
              else
                Icon(
                  Icons.circle_outlined,
                  color: AppColors.primaryGreen.withOpacity(0.4),
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
