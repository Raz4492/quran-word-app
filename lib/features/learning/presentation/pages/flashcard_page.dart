import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubit/flashcard_cubit.dart';

/// Shows one word at a time: tap to reveal, swipe (or tap buttons) to grade.
/// Modes 2/4/5 (meaning->Arabic, transliteration, Bangla) and mode 3 (Arabic
/// recognition) render multiple-choice options instead of the plain
/// flip card; mode 1 (Arabic->meaning) also uses options. The flip-reveal
/// card (front Arabic/translit, back + Bangla/English) matches spec §5/§38.
class FlashcardPage extends StatelessWidget {
  const FlashcardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: BlocBuilder<FlashcardCubit, FlashcardState>(
          builder: (context, state) {
            if (state is FlashcardInProgress) {
              return Text('${state.index + 1} / ${state.totalInSession}');
            }
            return const Text('Learning');
          },
        ),
      ),
      body: BlocConsumer<FlashcardCubit, FlashcardState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is FlashcardLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is FlashcardEmpty) {
            return _EmptyView(message: state.message);
          }
          if (state is FlashcardSessionComplete) {
            return _SessionCompleteView(state: state);
          }
          final s = state as FlashcardInProgress;
          return _FlashcardBody(state: s);
        },
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String message;
  const _EmptyView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌿', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlashcardBody extends StatelessWidget {
  final FlashcardInProgress state;
  const _FlashcardBody({required this.state});

  @override
  Widget build(BuildContext context) {
    final word = state.current.word;
    final usesOptions = state.options != null;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: (state.index + 1) / state.totalInSession,
            minHeight: 6,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GestureDetector(
              onTap: usesOptions ? null : () => context.read<FlashcardCubit>().reveal(),
              onHorizontalDragEnd: (details) {
                final v = details.primaryVelocity ?? 0;
                if (v < -200) {
                  context.read<FlashcardCubit>().grade(ReviewGrade.again);
                } else if (v > 200) {
                  context.read<FlashcardCubit>().grade(ReviewGrade.good);
                }
              },
              onVerticalDragEnd: (details) {
                final v = details.primaryVelocity ?? 0;
                if (v < -200) {
                  context.read<FlashcardCubit>().grade(ReviewGrade.easy);
                }
              },
              child: AnimatedSwitcher(
                duration: AppConstants.cardFlipDuration,
                child: usesOptions
                    ? _OptionsCard(
                        key: ValueKey('${word.rank}-options'),
                        state: state,
                      )
                    : _FlipCard(
                        key: ValueKey('${word.rank}-flip'),
                        state: state,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (!usesOptions) _GradingRow(revealed: state.revealed),
          if (usesOptions && state.revealed) _NextButtonRow(),
        ],
      ),
    );
  }
}

class _FlipCard extends StatelessWidget {
  final FlashcardInProgress state;
  const _FlipCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final word = state.current.word;
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(word.arabic,
                style: AppTheme.arabicStyle(), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(word.transliteration,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.outline)),
            if (!state.revealed) ...[
              const SizedBox(height: 32),
              Text('Tap to reveal',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
            if (state.revealed) ...[
              const SizedBox(height: 28),
              const Divider(),
              const SizedBox(height: 16),
              Text('বাংলা', style: Theme.of(context).textTheme.labelMedium),
              Text(word.bangla, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Text('English', style: Theme.of(context).textTheme.labelMedium),
              Text(word.english, style: Theme.of(context).textTheme.titleLarge),
            ],
          ],
        ),
      ),
    );
  }
}

class _OptionsCard extends StatelessWidget {
  final FlashcardInProgress state;
  const _OptionsCard({super.key, required this.state});

  String get _questionText => switch (state.mode) {
        FlashcardMode.arabicToMeaning => state.current.word.arabic,
        FlashcardMode.meaningToArabic => state.current.word.english,
        FlashcardMode.transliteration => state.current.word.transliteration,
        FlashcardMode.bangla => state.current.word.bangla,
        FlashcardMode.arabicRecognition => state.current.word.arabic,
      };

  String get _questionPrompt => switch (state.mode) {
        FlashcardMode.arabicToMeaning => 'What does this mean?',
        FlashcardMode.meaningToArabic => 'Which Arabic word means this?',
        FlashcardMode.transliteration => 'Which Arabic word?',
        FlashcardMode.bangla => 'এই অর্থের আরবি শব্দটি কোনটি?',
        FlashcardMode.arabicRecognition => 'Which meaning is correct?',
      };

  bool get _choicesAreArabic =>
      state.mode == FlashcardMode.meaningToArabic ||
      state.mode == FlashcardMode.transliteration ||
      state.mode == FlashcardMode.bangla;

  @override
  Widget build(BuildContext context) {
    final options = state.options!;
    return SingleChildScrollView(
      child: Column(
        children: [
          Card(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  Text(_questionText,
                      style: _choicesAreArabic == false &&
                              state.mode != FlashcardMode.transliteration
                          ? AppTheme.arabicStyle(size: 44)
                          : Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  Text(_questionPrompt,
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...options.choices.map((choice) {
            final isSelected = state.revealed;
            final isCorrectChoice = choice == options.correctChoice;
            Color? bg;
            if (isSelected) {
              if (isCorrectChoice) {
                bg = Colors.green.withOpacity(0.15);
              }
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: OutlinedButton(
                onPressed: state.revealed
                    ? null
                    : () => _onChoose(context, choice),
                style: OutlinedButton.styleFrom(
                  backgroundColor: bg,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                child: Text(
                  choice,
                  style: _choicesAreArabic
                      ? AppTheme.arabicStyle(size: 26)
                      : null,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _onChoose(BuildContext context, String choice) {
    final cubit = context.read<FlashcardCubit>();
    cubit.reveal();
    final correct = choice == state.options!.correctChoice;
    // Auto-grade based on correctness; user can still see Again/Good context.
    Future.delayed(const Duration(milliseconds: 650), () {
      if (context.mounted) {
        cubit.grade(correct ? ReviewGrade.good : ReviewGrade.again);
      }
    });
  }
}

class _NextButtonRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 4),
      child: Text('Moving on…', textAlign: TextAlign.center),
    );
  }
}

class _GradingRow extends StatelessWidget {
  final bool revealed;
  const _GradingRow({required this.revealed});

  @override
  Widget build(BuildContext context) {
    if (!revealed) {
      return Column(
        children: [
          Text('Swipe or tap the card to reveal',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () => context.read<FlashcardCubit>().reveal(),
            child: const Text('Reveal'),
          ),
        ],
      );
    }

    Widget gradeButton(String label, ReviewGrade grade, Color color) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: color,
              side: BorderSide(color: color.withOpacity(0.6)),
            ),
            onPressed: () => context.read<FlashcardCubit>().grade(grade),
            child: Text(label),
          ),
        ),
      );
    }

    return Column(
      children: [
        Text('How well did you know this?',
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 10),
        Row(
          children: [
            gradeButton('Again', ReviewGrade.again, Colors.red),
            gradeButton('Hard', ReviewGrade.hard, Colors.orange),
            gradeButton('Good', ReviewGrade.good, Colors.green),
            gradeButton('Easy', ReviewGrade.easy, Colors.teal),
          ],
        ),
      ],
    );
  }
}

class _SessionCompleteView extends StatelessWidget {
  final FlashcardSessionComplete state;
  const _SessionCompleteView({required this.state});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text('Great!', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              "You've practiced ${state.total} Quranic words.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text('${state.correct} / ${state.total} remembered well',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
