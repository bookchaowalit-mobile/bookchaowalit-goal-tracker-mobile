import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/goal.dart';

abstract interface class GoalStore {
  Future<List<Goal>> load();
  Future<void> save(List<Goal> goals);
}

/// Implemented by stores that drop unreadable records while loading, so the
/// UI can tell the user instead of losing them silently.
abstract interface class ReportsSkippedRecords {
  /// Records skipped by the most recent [GoalStore.load].
  int get skippedOnLastLoad;
}

class SharedPreferencesGoalStore implements GoalStore, ReportsSkippedRecords {
  static const _storageKey = 'goal_tracker_goals_v1';

  int _skipped = 0;

  @override
  int get skippedOnLastLoad => _skipped;

  @override
  Future<List<Goal>> load() async {
    _skipped = 0;
    final preferences = await SharedPreferences.getInstance();
    final payload = preferences.getString(_storageKey);
    if (payload == null || payload.isEmpty) return [];

    final decoded = jsonDecode(payload);
    if (decoded is! List) {
      throw const FormatException('Saved goals are not a list.');
    }

    // Skip individual malformed entries instead of locking the user out of
    // every goal because one saved record has an unexpected shape.
    final goals = <Goal>[];
    for (final item in decoded.whereType<Map>()) {
      try {
        final goal = Goal.fromJson(Map<String, Object?>.from(item));
        if (goal.id.isNotEmpty && goal.title.isNotEmpty) goals.add(goal);
      } on TypeError {
        continue;
      }
    }
    _skipped = decoded.length - goals.length;
    return goals;
  }

  @override
  Future<void> save(List<Goal> goals) async {
    final preferences = await SharedPreferences.getInstance();
    final payload = jsonEncode(goals.map((goal) => goal.toJson()).toList());
    final saved = await preferences.setString(_storageKey, payload);
    if (!saved) throw StateError('The device did not save the goal list.');
  }
}

class MemoryGoalStore implements GoalStore {
  MemoryGoalStore([List<Goal> initialGoals = const []])
      : _goals = List.of(initialGoals);

  List<Goal> _goals;

  @override
  Future<List<Goal>> load() async => List.of(_goals);

  @override
  Future<void> save(List<Goal> goals) async {
    _goals = List.of(goals);
  }
}
