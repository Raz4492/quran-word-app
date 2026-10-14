import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../learning/presentation/cubit/flashcard_cubit.dart';
import '../../../learning/presentation/pages/flashcard_page.dart';
import '../../../review/presentation/pages/review_page.dart';
import '../../../vocabulary/presentation/widgets/section_card.dart';
import '../cubit/home_cubit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().load();
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<HomeCubit>().load(),
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is HomeError) {
                return ListView(children: [
                  const SizedBox(height: 120),
                  Center(child: Text(state.message)),
                ]);
              }
              final s = state as HomeLoaded;
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: [
                  Text('السلام عليكم',
                      style: AppTheme.arabicStyle(size: 28)),
                  const SizedBox(height: 4),
                  Text('$_greeting 👋',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 20),

                  SectionCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Your Learning Progress',
                                  style: Theme.of(context).textTheme.bodyMedium),
                              const SizedBox(height: 6),
                              Text('${s.totalWordsLearned} / 500',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Text('🔥 ${s.currentStreak}',
                                style: const TextStyle(fontSize: 20)),
                            const Text('day streak',
                                style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  SectionCard(
                    title: "Today's Goal",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${s.wordsLearnedToday} / ${s.dailyGoal} words'),
                        const SizedBox(height: 10),
                        LinearGoalBar(s.todayProgress),
                        const SizedBox(height: 4),
                        Text(
                          s.todayProgress >= 1
                              ? "You've hit today's goal. Well done!"
                              : 'Keep going!',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  SectionCard(
                    title: 'Continue Learning',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.nextLessonCount > 0
                            ? 'Words ${s.nextLessonStart}–${s.nextLessonStart + s.nextLessonCount - 1}'
                            : "You're all caught up on new words!"),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: s.nextLessonCount == 0
                              ? null
                              : () => _startLesson(context),
                          child: const Text('Continue'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  SectionCard(
                    title: 'Review',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${s.reviewDueCount} words are ready for revision'),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: s.reviewDueCount == 0
                              ? null
                              : () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => const ReviewPage())),
                          child: const Text('Review Now'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  SectionCard(
                    title: "Today's Mission",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.mission.title),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => _startLesson(context),
                          child: Text(s.mission.actionLabel),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _startLesson(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (ctx) => FlashcardCubit(
              ctx.read(),
              ctx.read(),
            )..startSession(source: SessionSource.newDailyLesson),
            child: const FlashcardPage(),
          ),
        ))
        .then((_) => context.read<HomeCubit>().load());
  }
}
