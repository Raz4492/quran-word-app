
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../quiz/presentation/pages/quiz_page.dart';
import '../../../vocabulary/presentation/pages/browse_page.dart';
import '../../../vocabulary/presentation/cubit/vocabulary_cubit.dart';
import 'settings_page.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Quiz
          _MoreMenuCard(
            icon: Icons.quiz_outlined,
            title: 'Quiz',
            subtitle: 'Easy, Medium, Hard',
            color: Colors.orange,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const QuizSetupPage(),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // Browse all Quranic words
          _MoreMenuCard(
            icon: Icons.menu_book_outlined,
            title: 'Browse All 500 Words',
            subtitle: 'Explore Quranic vocabulary',
            color: Colors.green,
            onTap: () {
              final vocabularyCubit =
                  context.read<VocabularyCubit>();

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider<VocabularyCubit>.value(
                    value: vocabularyCubit,
                    child: const BrowsePage(),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 12),
          Divider(
            color: theme.dividerColor,
            height: 32,
          ),

          // Settings
          _MoreMenuCard(
            icon: Icons.settings_outlined,
            title: 'Settings',
            subtitle: 'Language and learning preferences',
            color: Colors.blueGrey,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MoreMenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MoreMenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.dividerColor.withOpacity(0.5),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
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
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color
                            ?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.iconTheme.color?.withOpacity(0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
