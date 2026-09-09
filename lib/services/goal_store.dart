import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/goal.dart';

abstract interface class GoalStore {
  Future<List<Goal>> load();
  Future<void> save(List<Goal> goals);
}

class SharedPreferencesGoalStore implements GoalStore {
  static const _storageKey = 'goal_tracker_goals_v1';

  @override
  Future<List<Goal>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final payload = preferences.getString(_storageKey);
    if (payload == null || payload.isEmpty) return [];

    final decoded = jsonDecode(payload);
    if (decoded is! List) {
      throw const FormatException('Saved goals are not a list.');
    }

    return decoded
        .whereType<Map>()
        .map((item) => Goal.fromJson(Map<String, Object?>.from(item)))
        .where((goal) => goal.id.isNotEmpty && goal.title.isNotEmpty)
        .toList();
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
