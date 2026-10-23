import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'controllers/goal_controller.dart';
import 'models/goal.dart';
import 'observability/crash_reporting.dart';
import 'screens/explore_screen.dart';
import 'screens/goal_editor_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'services/goal_store.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!crashReportingEnabled(sentryDsn)) {
    runApp(GoalTrackerApp(store: SharedPreferencesGoalStore()));
    return;
  }
  await SentryFlutter.init(
    (options) => configureCrashReporting(options, dsn: sentryDsn),
    appRunner: () => runApp(
      GoalTrackerApp(store: SharedPreferencesGoalStore(), crashReporting: true),
    ),
  );
}

class GoalTrackerApp extends StatelessWidget {
  const GoalTrackerApp({
    super.key,
    required this.store,
    this.crashReporting = false,
  });

  final GoalStore store;
  final bool crashReporting;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Goal Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: MainShell(store: store, crashReporting: crashReporting),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.store,
    this.crashReporting = false,
  });

  final GoalStore store;
  final bool crashReporting;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late final GoalController _controller;
  int _index = 0;

  static const _destinations = <NavigationDestination>[
    NavigationDestination(
      icon: Icon(Icons.route_outlined),
      selectedIcon: Icon(Icons.route),
      label: 'Goals',
    ),
    NavigationDestination(
      icon: Icon(Icons.insights_outlined),
      selectedIcon: Icon(Icons.insights),
      label: 'Progress',
    ),
    NavigationDestination(
      icon: Icon(Icons.tune_outlined),
      selectedIcon: Icon(Icons.tune),
      label: 'Settings',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = GoalController(widget.store)..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openEditor([Goal? goal]) async {
    if (_controller.isSaving) return;
    final result = await Navigator.of(context).push<GoalEditorResult>(
      MaterialPageRoute(
        builder: (_) => GoalEditorScreen(goal: goal),
        fullscreenDialog: goal == null,
      ),
    );
    if (!mounted || result == null) return;

    final success = result.deletedId != null
        ? await _controller.delete(result.deletedId!)
        : await _controller.upsert(result.goal!);
    if (!mounted) return;
    final message = success
        ? result.deletedId != null
            ? 'Goal deleted'
            : goal == null
                ? 'Goal added to your trail'
                : 'Goal updated'
        : _controller.errorMessage ?? 'That change was not saved.';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final pages = <Widget>[
          HomeScreen(controller: _controller, onEdit: _openEditor),
          ExploreScreen(controller: _controller, onEdit: _openEditor),
          ProfileScreen(
            controller: _controller,
            crashReporting: widget.crashReporting,
          ),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            final expanded = constraints.maxWidth >= 720;
            final body = IndexedStack(index: _index, children: pages);
            if (expanded) {
              return Scaffold(
                body: SafeArea(
                  child: Row(
                    children: [
                      NavigationRail(
                        selectedIndex: _index,
                        onDestinationSelected: (index) =>
                            setState(() => _index = index),
                        labelType: NavigationRailLabelType.all,
                        leading: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Icon(Icons.landscape,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        destinations: _destinations
                            .map(
                              (destination) => NavigationRailDestination(
                                icon: destination.icon,
                                selectedIcon: destination.selectedIcon,
                                label: Text(destination.label),
                              ),
                            )
                            .toList(),
                      ),
                      VerticalDivider(
                          width: 1,
                          color: Theme.of(context).colorScheme.outlineVariant),
                      Expanded(child: body),
                    ],
                  ),
                ),
                floatingActionButton: _index == 0
                    ? FloatingActionButton.extended(
                        onPressed:
                            _controller.isSaving ? null : () => _openEditor(),
                        icon: const Icon(Icons.add),
                        label: const Text('Add goal'),
                      )
                    : null,
              );
            }

            return Scaffold(
              body: body,
              bottomNavigationBar: NavigationBar(
                selectedIndex: _index,
                onDestinationSelected: (index) =>
                    setState(() => _index = index),
                destinations: _destinations,
              ),
              floatingActionButton: _index == 0
                  ? FloatingActionButton(
                      onPressed:
                          _controller.isSaving ? null : () => _openEditor(),
                      tooltip: 'Add goal',
                      child: const Icon(Icons.add),
                    )
                  : null,
            );
          },
        );
      },
    );
  }
}
