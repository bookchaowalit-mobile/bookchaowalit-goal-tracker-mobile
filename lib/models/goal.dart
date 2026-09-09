enum GoalCategory {
  personal,
  health,
  learning,
  work;

  String get label => switch (this) {
        GoalCategory.personal => 'Personal',
        GoalCategory.health => 'Health',
        GoalCategory.learning => 'Learning',
        GoalCategory.work => 'Work',
      };
}

class Goal {
  const Goal({
    required this.id,
    required this.title,
    required this.category,
    required this.progress,
    required this.createdAt,
    this.note = '',
    this.dueDate,
  });

  final String id;
  final String title;
  final String note;
  final GoalCategory category;
  final int progress;
  final DateTime createdAt;
  final DateTime? dueDate;

  bool get isComplete => progress >= 100;

  Goal copyWith({
    String? title,
    String? note,
    GoalCategory? category,
    int? progress,
    DateTime? dueDate,
    bool clearDueDate = false,
  }) {
    return Goal(
      id: id,
      title: title ?? this.title,
      note: note ?? this.note,
      category: category ?? this.category,
      progress: (progress ?? this.progress).clamp(0, 100),
      createdAt: createdAt,
      dueDate: clearDueDate ? null : dueDate ?? this.dueDate,
    );
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'note': note,
        'category': category.name,
        'progress': progress,
        'createdAt': createdAt.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
      };

  factory Goal.fromJson(Map<String, Object?> json) {
    final rawCategory = json['category'] as String?;
    final category = GoalCategory.values
            .where((value) => value.name == rawCategory)
            .firstOrNull ??
        GoalCategory.personal;
    final rawProgress = json['progress'];

    return Goal(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      note: json['note'] as String? ?? '',
      category: category,
      progress: (rawProgress is num ? rawProgress.toInt() : 0).clamp(0, 100),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      dueDate: DateTime.tryParse(json['dueDate'] as String? ?? ''),
    );
  }
}
