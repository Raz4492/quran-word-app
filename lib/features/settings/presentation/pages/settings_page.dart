import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../cubit/settings_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocBuilder<SettingsCubit, SettingsSnapshot>(
        builder: (context, s) {
          final cubit = context.read<SettingsCubit>();
          return ListView(
            children: [
              const _SectionHeader('Language'),
              RadioListTile<AppLanguage>(
                title: const Text('বাংলা'),
                value: AppLanguage.bangla,
                groupValue: s.language,
                onChanged: (v) => cubit.setLanguage(v!),
              ),
              RadioListTile<AppLanguage>(
                title: const Text('English'),
                value: AppLanguage.english,
                groupValue: s.language,
                onChanged: (v) => cubit.setLanguage(v!),
              ),
              const Divider(),
              const _SectionHeader('Daily Goal'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  children: AppConstants.dailyGoalOptions.map((g) {
                    return ChoiceChip(
                      label: Text('$g words'),
                      selected: s.dailyGoal == g,
                      onSelected: (_) => cubit.setDailyGoal(g),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const _SectionHeader('Notifications'),
              SwitchListTile(
                title: const Text('Notifications'),
                value: s.notificationsEnabled,
                onChanged: cubit.setNotificationsEnabled,
              ),
              ListTile(
                title: const Text('Learning reminder'),
                subtitle: Text(s.learningReminderTime),
                enabled: s.notificationsEnabled,
                onTap: () => _pickTime(context, s.learningReminderTime,
                    cubit.setLearningReminderTime),
              ),
              ListTile(
                title: const Text('Review reminder'),
                subtitle: Text(s.reviewReminderTime),
                enabled: s.notificationsEnabled,
                onTap: () => _pickTime(context, s.reviewReminderTime,
                    cubit.setReviewReminderTime),
              ),
              const Divider(),
              const _SectionHeader('Appearance'),
              SwitchListTile(
                title: const Text('Dark Mode'),
                value: s.darkMode,
                onChanged: cubit.setDarkMode,
              ),
              ListTile(
                title: const Text('Text Size'),
                subtitle: Slider(
                  value: s.textScale,
                  min: 0.85,
                  max: 1.4,
                  divisions: 11,
                  label: s.textScale.toStringAsFixed(2),
                  onChanged: cubit.setTextScale,
                ),
              ),
              const Divider(),
              const _SectionHeader('Feedback'),
              SwitchListTile(
                title: const Text('Sound'),
                value: s.soundEnabled,
                onChanged: cubit.setSoundEnabled,
              ),
              SwitchListTile(
                title: const Text('Haptic Feedback'),
                value: s.hapticEnabled,
                onChanged: cubit.setHapticEnabled,
              ),
              SwitchListTile(
                title: const Text('Reduce Animations'),
                value: s.reduceAnimations,
                onChanged: cubit.setReduceAnimations,
              ),
              const Divider(),
              const _SectionHeader('Data'),
              ListTile(
                leading: const Icon(Icons.restart_alt, color: Colors.red),
                title: const Text('Reset Learning Progress'),
                textColor: Colors.red,
                iconColor: Colors.red,
                onTap: () => _confirmReset(context, cubit),
              ),
              const Divider(),
              const _SectionHeader('About'),
              const ListTile(title: Text('About Quran 500')),
              const ListTile(title: Text('Privacy Policy')),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickTime(
      BuildContext context, String current, Future<void> Function(String) onSet) async {
    final parts = current.split(':');
    final initial = TimeOfDay(
        hour: int.tryParse(parts.first) ?? 20,
        minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      final hhmm =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      await onSet(hhmm);
    }
  }

  Future<void> _confirmReset(BuildContext context, SettingsCubit cubit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Learning Progress?'),
        content: const Text(
            'This clears all flashcard progress, streaks and favorites. The 500-word list itself is never changed. This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await cubit.resetProgress();
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Progress reset.')));
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}
