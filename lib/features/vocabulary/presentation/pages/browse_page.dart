import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubit/vocabulary_cubit.dart';
import '../widgets/section_card.dart';
import 'word_detail_page.dart';

class BrowsePage extends StatefulWidget {
  const BrowsePage({super.key});

  @override
  State<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<VocabularyCubit>().loadAll();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _statusColor(BuildContext context, LearningStatus status) {
    return switch (status) {
      LearningStatus.newWord => Theme.of(context).colorScheme.outline,
      LearningStatus.learning => Colors.orange,
      LearningStatus.review => AppColors.primaryGreenLight,
      LearningStatus.mastered => AppColors.gold,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Top 500 Quranic Words')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search Arabic, meaning, transliteration, rank…',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (q) => context.read<VocabularyCubit>().setQuery(q),
            ),
          ),
          SizedBox(
            height: 44,
            child: BlocBuilder<VocabularyCubit, VocabularyState>(
              builder: (context, state) {
                final current =
                    state is VocabularyLoaded ? state.filter : BrowseFilter.all;
                return ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: BrowseFilter.values.map((f) {
                    final selected = f == current;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(f.label),
                        selected: selected,
                        onSelected: (_) =>
                            context.read<VocabularyCubit>().setFilter(f),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<VocabularyCubit, VocabularyState>(
              builder: (context, state) {
                if (state is VocabularyLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is VocabularyError) {
                  return Center(child: Text(state.message));
                }
                final s = state as VocabularyLoaded;
                if (s.visibleWords.isEmpty) {
                  return const Center(child: Text('No words match.'));
                }
                return ListView.separated(
                  itemCount: s.visibleWords.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final lw = s.visibleWords[index];
                    return ListTile(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => WordDetailPage(rank: lw.word.rank),
                        ),
                      ),
                      leading: SizedBox(
                        width: 32,
                        child: Text('${lw.word.rank}',
                            style: Theme.of(context).textTheme.bodySmall),
                      ),
                      title: Text(lw.word.arabic,
                          style: AppTheme.arabicStyle(size: 24)),
                      subtitle: Text(
                          '${lw.word.transliteration} • ${lw.word.bangla}'),
                      trailing: StatusChip(
                        label: lw.progress.status.label,
                        color: _statusColor(context, lw.progress.status),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
