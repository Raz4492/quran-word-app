
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/home/presentation/cubit/home_cubit.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/progress/presentation/cubit/progress_cubit.dart';
import 'features/progress/presentation/pages/progress_page.dart';
import 'features/review/presentation/pages/review_page.dart';
import 'features/settings/presentation/pages/more_page.dart';
import 'features/vocabulary/presentation/cubit/vocabulary_cubit.dart';
import 'features/vocabulary/presentation/pages/browse_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VocabularyCubit>(
      create: (ctx) => VocabularyCubit(
        ctx.read(),
      ),
      child: Builder(
        builder: (context) {
          return _buildShell(context);
        },
      ),
    );
  }

  Widget _buildShell(BuildContext context) {
    final pages = <Widget>[
      BlocProvider(
        create: (ctx) => HomeCubit(ctx.read(), ctx.read()),
        child: const HomePage(),
      ),

      // Uses the VocabularyCubit provided above AppShell's tab content.
      const BrowsePage(),

      const ReviewPage(),

      BlocProvider(
        create: (ctx) => ProgressCubit(ctx.read(), ctx.read()),
        child: const ProgressPage(),
      ),

      const MorePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          setState(() => _index = i);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.style_outlined),
            selectedIcon: Icon(Icons.style),
            label: 'Learn',
          ),
          NavigationDestination(
            icon: Icon(Icons.refresh),
            selectedIcon: Icon(Icons.refresh),
            label: 'Review',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            selectedIcon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
