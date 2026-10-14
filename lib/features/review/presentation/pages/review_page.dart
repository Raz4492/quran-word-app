import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../learning/presentation/cubit/flashcard_cubit.dart';
import '../../../learning/presentation/pages/flashcard_page.dart';
import '../../../vocabulary/domain/repositories/vocabulary_repository.dart';
import '../../../vocabulary/presentation/widgets/section_card.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  int dueCount = 0;
  int difficultCount = 0;
  int mistakesCount = 0;
  int masteredCount = 0;
  int recentCount = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = context.read<VocabularyRepository>();
    final due = await repo.getDueForReview();
    final difficult = await repo.getDifficultWords();
    final counts = await repo.getStatusCounts();
    final allWords = await repo.getAllWords();

    var mistakes = 0;
    var recent = 0;
    for (final w in allWords) {
      final p = await repo.getProgress(w.rank);
      if (p.timesIncorrect > 0) mistakes++;
      if (p.lastReviewedAt != null &&
          DateTime.now().difference(p.lastReviewedAt!).inHours < 48) {
        recent++;
      }
    }

    if (!mounted) return;
    setState(() {
      dueCount = due.length;
      difficultCount = difficult.length;
      masteredCount = counts[LearningStatus.mastered] ?? 0;
      mistakesCount = mistakes;
      recentCount = recent;
      loading = false;
    });
  }

  void _startSession(SessionSource source) {
    Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (ctx) => FlashcardCubit(ctx.read(), ctx.read())
              ..startSession(source: source),
            child: const FlashcardPage(),
          ),
        ))
        .then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$dueCount words due today',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: dueCount == 0
                              ? null
                              : () => _startSession(SessionSource.review),
                          child: const Text('Start Review'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.5,
                    children: [
                      _StatTile(
                          label: 'Difficult Words',
                          value: difficultCount,
                          onTap: difficultCount == 0
                              ? null
                              : () => _startSession(SessionSource.difficultOnly)),
                      _StatTile(label: 'Mistakes', value: mistakesCount),
                      _StatTile(label: 'Recently Learned', value: recentCount),
                      _StatTile(label: 'Mastered', value: masteredCount),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback? onTap;
  const _StatTile({required this.label, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$value',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
