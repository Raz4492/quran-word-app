import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../vocabulary/presentation/widgets/section_card.dart';
import '../cubit/progress_cubit.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProgressCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: BlocBuilder<ProgressCubit, ProgressState>(
        builder: (context, state) {
          if (state is ProgressLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProgressError) {
            return Center(child: Text(state.message));
          }
          final s = state as ProgressLoaded;
          return RefreshIndicator(
            onRefresh: () => context.read<ProgressCubit>().load(),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                SectionCard(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 140,
                        width: 140,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              height: 140,
                              width: 140,
                              child: CircularProgressIndicator(
                                value: s.percentComplete,
                                strokeWidth: 12,
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${s.wordsLearned} / ${s.totalWords}',
                                    style: Theme.of(context).textTheme.titleMedium),
                                Text('${(s.percentComplete * 100).round()}%'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.6,
                  children: [
                    _StatCard(label: 'Mastered', value: '${s.mastered}', color: AppColors.gold),
                    _StatCard(label: 'Learning', value: '${s.learning}', color: Colors.orange),
                    _StatCard(label: 'Review', value: '${s.review}', color: AppColors.primaryGreenLight),
                    _StatCard(label: 'New', value: '${s.newWords}', color: Theme.of(context).colorScheme.outline),
                  ],
                ),
                const SizedBox(height: 16),
                SectionCard(
                  title: 'Overview',
                  child: Column(
                    children: [
                      _overviewRow('Accuracy', '${(s.accuracy * 100).round()}%'),
                      _overviewRow('Words reviewed', '${s.wordsReviewed}'),
                      _overviewRow('Current streak', '${s.currentStreak} days'),
                      _overviewRow('Longest streak', '${s.longestStreak} days'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _overviewRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(label), Text(value, style: const TextStyle(fontWeight: FontWeight.w600))],
        ),
      );
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
