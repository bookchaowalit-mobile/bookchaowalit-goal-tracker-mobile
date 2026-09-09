import 'package:flutter/foundation.dart';

import '../models/goal.dart';
import '../services/goal_store.dart';

class GoalController extends ChangeNotifier {
  GoalController(this._store);

  final GoalStore _store;
  List<Goal> _goals = const [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  List<Goal> get goals => List.unmodifiable(_goals);
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  List<Goal> get activeGoals =>
      _goals.where((goal) => !goal.isComplete).toList();
  List<Goal> get completedGoals =>
      _goals.where((goal) => goal.isComplete).toList();

  int get averageProgress {
    if (_goals.isEmpty) return 0;
    final total = _goals.fold<int>(0, (sum, goal) => sum + goal.progress);
    return (total / _goals.length).round();
  }

  Future<void> load() async {
    if (_isSaving) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _goals = await _store.load();
      _sortGoals();
    } on Object {
      _errorMessage = 'Your goals could not be loaded. Try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> upsert(Goal goal) async {
    if (!_beginWrite()) return false;
    final previous = List<Goal>.of(_goals);
    final index = _goals.indexWhere((item) => item.id == goal.id);
    _goals = List<Goal>.of(_goals);
    if (index == -1) {
      _goals.add(goal);
    } else {
      _goals[index] = goal;
    }
    _sortGoals();
    return _persistOrRollback(previous);
  }

  Future<bool> markComplete(Goal goal) => upsert(goal.copyWith(progress: 100));

  Future<bool> delete(String id) async {
    if (!_beginWrite()) return false;
    final previous = List<Goal>.of(_goals);
    _goals = _goals.where((goal) => goal.id != id).toList();
    return _persistOrRollback(previous);
  }

  Future<bool> clearAll() async {
    if (!_beginWrite()) return false;
    final previous = List<Goal>.of(_goals);
    _goals = [];
    return _persistOrRollback(previous);
  }

  Future<bool> _persistOrRollback(List<Goal> previous) async {
    try {
      await _store.save(_goals);
      return true;
    } on Object {
      _goals = previous;
      _errorMessage = 'That change was not saved. Please try again.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  bool _beginWrite() {
    if (_isSaving) {
      _errorMessage = 'Another change is still being saved.';
      notifyListeners();
      return false;
    }
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _sortGoals() {
    _goals.sort((a, b) {
      if (a.isComplete != b.isComplete) return a.isComplete ? 1 : -1;
      if (a.dueDate == null && b.dueDate != null) return 1;
      if (a.dueDate != null && b.dueDate == null) return -1;
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }
      return b.createdAt.compareTo(a.createdAt);
    });
  }
}
