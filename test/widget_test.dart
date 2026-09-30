import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_tracker/main.dart';
import 'package:goal_tracker/models/goal.dart';
import 'package:goal_tracker/screens/goal_editor_screen.dart';
import 'package:goal_tracker/services/goal_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('creates a goal and keeps progress visible', (tester) async {
    await tester.pumpWidget(GoalTrackerApp(store: MemoryGoalStore()));
    await tester.pumpAndSettle();

    expect(find.text('No goals yet'), findsOneWidget);

    await tester.tap(find.text('Add goal'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Goal title'), 'Ship my first app');
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.widgetWithText(FilledButton, 'Create goal'),
      240,
      scrollable: find.byType(Scrollable).last,
    );
    await tester
        .ensureVisible(find.widgetWithText(FilledButton, 'Create goal'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Create goal'));
    await tester.pumpAndSettle();

    expect(find.text('Ship my first app'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byTooltip('Mark complete'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Mark complete'));
    await tester.pumpAndSettle();

    expect(find.text('Summit reached'), findsOneWidget);
    expect(find.text('100%'), findsAtLeastNWidgets(1));
  });

  testWidgets('uses a navigation rail on expanded Android layouts',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(GoalTrackerApp(store: MemoryGoalStore()));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('keeps core phone screens usable at 130 percent text scale',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    final now = DateTime(2026, 8, 30);
    await tester.pumpWidget(
      GoalTrackerApp(
        store: MemoryGoalStore([
          Goal(
            id: 'active',
            title: 'Plan a focused week with one clear next step',
            category: GoalCategory.personal,
            progress: 35,
            createdAt: now,
          ),
          Goal(
            id: 'complete',
            title: 'Publish Goal Tracker',
            category: GoalCategory.work,
            progress: 100,
            createdAt: now.subtract(const Duration(days: 1)),
          ),
        ]),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Private by default'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens the date picker when a saved target date is in the past',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: GoalEditorScreen(
          goal: Goal(
            id: 'past-date',
            title: 'Review a previous target',
            category: GoalCategory.learning,
            progress: 40,
            createdAt: DateTime(2024, 1, 1),
            dueDate: DateTime(2024, 6, 1),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Target date'));
    await tester.pumpAndSettle();

    expect(find.text('Choose a target date'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('overdue and far-future due dates are labelled clearly', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final now = DateTime.now();
    await tester.pumpWidget(
      GoalTrackerApp(
        store: MemoryGoalStore([
          Goal(
            id: 'late',
            title: 'Late goal',
            category: GoalCategory.work,
            progress: 10,
            createdAt: DateTime(2020),
            dueDate: DateTime(2020, 3, 4),
          ),
          Goal(
            id: 'far',
            title: 'Far goal',
            category: GoalCategory.work,
            progress: 10,
            createdAt: DateTime(2020),
            dueDate: DateTime(now.year + 3, 1, 5),
          ),
        ]),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const Key('due-late'))).data,
      'Overdue · Mar 4, 2020',
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('due-far'))).data,
      'Jan 5, ${now.year + 3}',
    );
  });

  testWidgets('skipped saved goals are reported and can be dismissed', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({
      'goal_tracker_goals_v1': '[{"id":"ok","title":"Kept"},"bad",{"id":1}]',
    });
    await tester
        .pumpWidget(GoalTrackerApp(store: SharedPreferencesGoalStore()));
    await tester.pumpAndSettle();
    expect(
      find.text('2 saved goals could not be read and were skipped.'),
      findsOneWidget,
    );
    expect(find.text('Kept'), findsOneWidget);
    await tester.tap(find.text('Dismiss'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('skipped-notice')), findsNothing);
  });

  testWidgets('home meets tap-target, label and contrast guidelines', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      GoalTrackerApp(
        store: MemoryGoalStore([
          Goal(
            id: 'a',
            title: 'Read a book',
            category: GoalCategory.learning,
            progress: 40,
            createdAt: DateTime(2026),
          ),
        ]),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });
}
