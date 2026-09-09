import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:goal_tracker/controllers/goal_controller.dart';
import 'package:goal_tracker/models/goal.dart';
import 'package:goal_tracker/services/goal_store.dart';

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
