import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubit/quiz_cubit.dart';

class QuizSetupPage extends StatelessWidget {
  const QuizSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose difficulty', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            _DifficultyTile(
              title: 'Easy',
              subtitle: 'Arabic → English',
              onTap: () => _start(context, QuizDifficulty.easy),
            ),
            _DifficultyTile(
              title: 'Medium',
              subtitle: 'Arabic → বাংলা',
              onTap: () => _start(context, QuizDifficulty.medium),
            ),
            _DifficultyTile(
              title: 'Hard',
              subtitle: 'Meaning → Arabic (advanced distractors)',
              onTap: () => _start(context, QuizDifficulty.hard),
            ),
          ],
        ),
      ),
    );
  }

  void _start(BuildContext context, QuizDifficulty difficulty) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (ctx) => QuizCubit(ctx.read(), ctx.read())
          ..startQuiz(difficulty: difficulty),
        child: const QuizPlayPage(),
      ),
    ));
  }
}

class _DifficultyTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _DifficultyTile(
      {required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class QuizPlayPage extends StatelessWidget {
  const QuizPlayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<QuizCubit, QuizState>(builder: (context, state) {
          if (state is QuizInProgress) {
            return Text('Question ${state.index + 1} / ${state.questions.length}');
          }
          return const Text('Quiz');
        }),
      ),
      body: BlocBuilder<QuizCubit, QuizState>(
        builder: (context, state) {
          if (state is QuizLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is QuizNotEnoughWords) {
            return const Center(child: Text('Learn a few more words first!'));
          }
          if (state is QuizComplete) {
            return _QuizResultView(state: state);
          }
          final s = state as QuizInProgress;
          return _QuizQuestionView(state: s);
        },
      ),
    );
  }
}

class _QuizQuestionView extends StatelessWidget {
  final QuizInProgress state;
  const _QuizQuestionView({required this.state});

  bool get _promptIsArabic =>
      state.current.promptLabel == state.current.word.arabic;

  @override
  Widget build(BuildContext context) {
    final q = state.current;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: (state.index + 1) / state.questions.length,
            minHeight: 6,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 28),
          Text(q.promptLabel,
              style: _promptIsArabic
                  ? AppTheme.arabicStyle(size: 48)
                  : Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center),
          const SizedBox(height: 32),
          ...q.choices.map((choice) {
            Color? color;
            if (state.answered) {
              if (choice == q.correctChoice) {
                color = Colors.green;
              } else if (choice == state.selectedChoice) {
                color = Colors.red;
              }
            }
            final isArabicChoice = choice == q.word.arabic ||
                (q.choices.any((c) => c == q.word.arabic) && !_promptIsArabic);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: OutlinedButton(
                onPressed: state.answered
                    ? null
                    : () => context.read<QuizCubit>().selectAnswer(choice),
                style: OutlinedButton.styleFrom(
                  side: color != null
                      ? BorderSide(color: color, width: 2)
                      : null,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(choice,
                    style: isArabicChoice ? AppTheme.arabicStyle(size: 22) : null),
              ),
            );
          }),
          const Spacer(),
          if (state.answered)
            Column(
              children: [
                Text(
                  state.selectedChoice == q.correctChoice
                      ? 'Correct!'
                      : '${q.word.arabic} = ${q.correctChoice}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.read<QuizCubit>().next(),
                  child: Text(state.isLast ? 'Finish' : 'Next'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _QuizResultView extends StatelessWidget {
  final QuizComplete state;
  const _QuizResultView({required this.state});

  @override
  Widget build(BuildContext context) {
    final percent = (state.percent * 100).round();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Quiz Complete', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Text('${state.correct} / ${state.total}',
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            Text('$percent%'),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(children: [
                  Text('${state.correct}',
                      style: Theme.of(context).textTheme.titleLarge),
                  const Text('Words learned'),
                ]),
                Column(children: [
                  Text('${state.missedWordRanks.length}',
                      style: Theme.of(context).textTheme.titleLarge),
                  const Text('Words to review'),
                ]),
              ],
            ),
            const SizedBox(height: 24),
            if (state.missedWordRanks.isNotEmpty)
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Review Mistakes'),
              ),
            const SizedBox(height: 8),
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
