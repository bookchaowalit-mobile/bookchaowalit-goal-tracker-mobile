import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:goal_tracker/controllers/goal_controller.dart';
import 'package:goal_tracker/models/goal.dart';
import 'package:goal_tracker/services/goal_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('serializes, sorts, and completes goals', () async {
    final later = Goal(
      id: 'later',
      title: 'Later goal',
      category: GoalCategory.learning,
      progress: 20,
      createdAt: DateTime(2026, 8, 2),
      dueDate: DateTime(2026, 10, 1),
    );
    final sooner = Goal(
      id: 'sooner',
      title: 'Sooner goal',
      category: GoalCategory.work,
      progress: 40,
      createdAt: DateTime(2026, 8, 1),
      dueDate: DateTime(2026, 9, 1),
    );
    final controller = GoalController(MemoryGoalStore([later, sooner]));

    await controller.load();
    expect(controller.goals.map((goal) => goal.id), ['sooner', 'later']);
    expect(controller.averageProgress, 30);

    final saved = await controller.markComplete(sooner);
    expect(saved, isTrue);
    expect(controller.completedGoals.single.id, 'sooner');
    expect(controller.goals.last.id, 'sooner');

    final roundTrip = Goal.fromJson(later.toJson());
    expect(roundTrip.title, later.title);
    expect(roundTrip.category, GoalCategory.learning);
    expect(roundTrip.dueDate, later.dueDate);
  });

  test('rolls back when storage rejects a change', () async {
    final controller = GoalController(_FailingGoalStore());
    await controller.load();

    final saved = await controller.upsert(
      Goal(
        id: 'blocked',
        title: 'Blocked write',
        category: GoalCategory.personal,
        progress: 0,
        createdAt: DateTime(2026, 8, 30),
      ),
    );

    expect(saved, isFalse);
    expect(controller.goals, isEmpty);
    expect(controller.errorMessage, contains('not saved'));
  });

  test('rejects an overlapping write before it can replace newer state',
      () async {
    final store = _BlockingGoalStore();
    final controller = GoalController(store);
    await controller.load();

    final firstWrite = controller.upsert(
      Goal(
        id: 'first',
        title: 'First write',
        category: GoalCategory.work,
        progress: 0,
        createdAt: DateTime(2026, 8, 30),
      ),
    );
    expect(controller.isSaving, isTrue);

    await controller.load();
    expect(store.loadCalls, 1);
    expect(controller.goals.map((goal) => goal.id), ['first']);

    final overlappingWrite = await controller.upsert(
      Goal(
        id: 'second',
        title: 'Overlapping write',
        category: GoalCategory.personal,
        progress: 0,
        createdAt: DateTime(2026, 8, 30),
      ),
    );

    expect(overlappingWrite, isFalse);
    expect(store.saveCalls, 1);
    expect(controller.goals.map((goal) => goal.id), ['first']);

    store.completeSave();
    expect(await firstWrite, isTrue);
    expect(controller.isSaving, isFalse);
  });

  test('skips malformed saved entries instead of failing the whole load',
      () async {
    SharedPreferences.setMockInitialValues({
      'goal_tracker_goals_v1': '[{"id":"ok","title":"Kept","progress":50},'
          '{"id":7,"title":"Wrong id type"},'
          '"not a map",'
          '{"id":"blank","title":""}]',
    });
    final goals = await SharedPreferencesGoalStore().load();
    expect(goals.map((goal) => goal.id), ['ok']);
    expect(goals.single.progress, 50);
  });

  test('reports a non-list payload as a load error', () async {
    SharedPreferences.setMockInitialValues({
      'goal_tracker_goals_v1': '{"id":"x"}',
    });
    final controller = GoalController(SharedPreferencesGoalStore());
    await controller.load();
    expect(controller.errorMessage, contains('could not be loaded'));
    expect(controller.goals, isEmpty);
  });

  test('controller reports how many saved goals were skipped', () async {
    SharedPreferences.setMockInitialValues({
      'goal_tracker_goals_v1': '[{"id":"ok","title":"Kept","progress":50},'
          '{"id":7,"title":"Wrong id type"},'
          '"not a map",'
          '{"id":"blank","title":""}]',
    });
    final store = SharedPreferencesGoalStore();
    final controller = GoalController(store);
    await controller.load();
    expect(controller.goals.map((goal) => goal.id), ['ok']);
    expect(controller.skippedCount, 3);
    controller.dismissSkipped();
    expect(controller.skippedCount, 0);

    SharedPreferences.setMockInitialValues({
      'goal_tracker_goals_v1': '[{"id":"ok","title":"Kept"}]',
    });
    await controller.load();
    expect(controller.skippedCount, 0);
  });

  test('stores that cannot report skips count as zero', () async {
    final controller = GoalController(MemoryGoalStore());
    await controller.load();
    expect(controller.skippedCount, 0);
  });

  test('fromJson edge cases: fractional, out-of-range and missing values', () {
    Goal parse(Map<String, Object?> extra) =>
        Goal.fromJson({'id': 'x', 'title': 't', ...extra});
    expect(parse({'progress': 99.9}).progress, 99);
    expect(parse({'progress': 250}).progress, 100);
    expect(parse({'progress': -5}).progress, 0);
    expect(parse({'progress': '50'}).progress, 0);
    expect(parse({'category': 'unknown'}).category, GoalCategory.personal);
    expect(parse({'dueDate': 'not a date'}).dueDate, isNull);
    expect(parse({}).isComplete, isFalse);
    expect(parse({'title': 'เป้าหมาย 🎯'}).title, 'เป้าหมาย 🎯');
  });

  test('copyWith clamps progress and can clear the due date', () {
    final goal = Goal(
      id: 'g',
      title: 't',
      category: GoalCategory.work,
      progress: 10,
      createdAt: DateTime(2026),
      dueDate: DateTime(2026, 12, 1),
    );
    expect(goal.copyWith(progress: 150).progress, 100);
    expect(goal.copyWith(progress: -1).progress, 0);
    expect(goal.copyWith(clearDueDate: true).dueDate, isNull);
    expect(goal.copyWith(title: 'u').dueDate, DateTime(2026, 12, 1));
  });

  test('average progress rounds half up and handles empty lists', () async {
    Goal g(String id, int p) => Goal(
          id: id,
          title: id,
          category: GoalCategory.work,
          progress: p,
          createdAt: DateTime(2026),
        );
    final empty = GoalController(MemoryGoalStore());
    await empty.load();
    expect(empty.averageProgress, 0);
    final c = GoalController(MemoryGoalStore([g('a', 0), g('b', 1)]));
    await c.load();
    expect(c.averageProgress, 1); // 0.5 rounds to 1
  });
}

class _FailingGoalStore implements GoalStore {
  @override
  Future<List<Goal>> load() async => [];

  @override
  Future<void> save(List<Goal> goals) => Future.error(StateError('disk full'));
}

class _BlockingGoalStore implements GoalStore {
  final _saveCompleter = Completer<void>();
  int loadCalls = 0;
  int saveCalls = 0;

  @override
  Future<List<Goal>> load() async {
    loadCalls += 1;
    return [];
  }

  @override
  Future<void> save(List<Goal> goals) {
    saveCalls += 1;
    return _saveCompleter.future;
  }

  void completeSave() => _saveCompleter.complete();
}
