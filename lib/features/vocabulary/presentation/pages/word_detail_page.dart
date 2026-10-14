import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../learning/presentation/cubit/flashcard_cubit.dart';
import '../../../learning/presentation/pages/flashcard_page.dart';
import '../../domain/entities/quran_word.dart';
import '../../domain/entities/word_progress.dart';
import '../../domain/repositories/vocabulary_repository.dart';
import '../widgets/section_card.dart';
import '../../../../core/constants/app_constants.dart';

class WordDetailPage extends StatefulWidget {
  final int rank;
  const WordDetailPage({super.key, required this.rank});

  @override
  State<WordDetailPage> createState() => _WordDetailPageState();
}

class _WordDetailPageState extends State<WordDetailPage> {
  QuranWord? word;
  WordProgress? progress;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = context.read<VocabularyRepository>();
    final w = await repo.getWordByRank(widget.rank);
    final p = await repo.getProgress(widget.rank);
    if (!mounted) return;
    setState(() {
      word = w;
      progress = p;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (word == null || progress == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final w = word!;
    final p = progress!;
    final accuracy = (p.accuracy * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: Text('Word #${w.rank}'),
        actions: [
          IconButton(
            icon: Icon(p.isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: () async {
              await context.read<VocabularyRepository>().toggleFavorite(w.rank);
              _load();
            },
          ),
          IconButton(
            icon: Icon(p.isDifficult ? Icons.star : Icons.star_border),
            onPressed: () async {
              await context.read<VocabularyRepository>().toggleDifficult(w.rank);
              _load();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                Text(w.arabic, style: AppTheme.arabicStyle(size: 56)),
                const SizedBox(height: 8),
                Text(w.transliteration,
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row(context, 'বাংলা', w.bangla),
                const Divider(height: 24),
                _row(context, 'English', w.english),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Details',
            child: Column(
              children: [
                _statRow('Rank', '#${w.rank}'),
                _statRow('Frequency', w.frequency?.toString() ?? '—'),
                _statRow('Learning status', p.status.label),
                _statRow('Times reviewed', '${p.timesSeen}'),
                _statRow('Accuracy', '$accuracy%'),
                _statRow('Last reviewed', _fmtDate(p.lastReviewedAt)),
                _statRow('Next review', _fmtDate(p.nextReviewAt)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Quran Context',
            child: Text(
              'Quran examples coming soon.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              // Audio pronunciation is not bundled in this MVP; architecture
              // leaves room to attach a sound file by `rank` later (spec §19).
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Audio coming soon.')),
              );
            },
            icon: const Icon(Icons.volume_up),
            label: const Text('Listen'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (ctx) => FlashcardCubit(ctx.read(), ctx.read())
                    ..startSession(
                      source: SessionSource.specificRanks,
                      specificRanks: [w.rank],
                    ),
                  child: const FlashcardPage(),
                ),
              ),
            ),
            child: const Text('Practice this word'),
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text(value)],
      ),
    );
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return '—';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
