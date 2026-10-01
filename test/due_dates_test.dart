import 'package:flutter_test/flutter_test.dart';
import 'package:goal_tracker/logic/due_dates.dart';

void main() {
  final today = DateTime(2026, 9, 30, 23, 59);

  test('formatDueDate adds the year only outside the current year', () {
    expect(formatDueDate(DateTime(2026, 10, 5), today), 'Oct 5');
    expect(formatDueDate(DateTime(2028, 1, 5), today), 'Jan 5, 2028');
    expect(formatDueDate(DateTime(2025, 12, 31), today), 'Dec 31, 2025');
  });

  test('daysUntil ignores time of day and crosses year/leap boundaries', () {
    expect(daysUntil(DateTime(2026, 9, 30, 0, 1), today), 0);
    expect(daysUntil(DateTime(2026, 10, 1), today), 1);
    expect(daysUntil(DateTime(2026, 9, 29, 23, 59), today), -1);
    expect(daysUntil(DateTime(2027, 1, 1), DateTime(2026, 12, 31)), 1);
    expect(daysUntil(DateTime(2028, 3, 1), DateTime(2028, 2, 28)), 2);
    // A UTC and a local date with the same calendar day are the same day.
    expect(daysUntil(DateTime.utc(2026, 9, 30), today), 0);
  });

  test('isOverdue only for unfinished goals with a past due date', () {
    expect(
      isOverdue(due: DateTime(2026, 9, 29), complete: false, today: today),
      isTrue,
    );
    expect(
      isOverdue(due: DateTime(2026, 9, 30), complete: false, today: today),
      isFalse,
    );
    expect(
      isOverdue(due: DateTime(2026, 9, 1), complete: true, today: today),
      isFalse,
    );
    expect(isOverdue(due: null, complete: false, today: today), isFalse);
  });

  test('dueLabel', () {
    String label(DateTime due, {bool complete = false}) =>
        dueLabel(due: due, complete: complete, today: today);
    expect(label(DateTime(2026, 9, 1)), 'Overdue · Sep 1');
    expect(label(DateTime(2025, 9, 1)), 'Overdue · Sep 1, 2025');
    expect(label(DateTime(2026, 9, 30)), 'Due today');
    expect(label(DateTime(2026, 10, 1)), 'Due tomorrow');
    expect(label(DateTime(2026, 10, 2)), 'Oct 2');
    expect(label(DateTime(2026, 9, 1), complete: true), 'Sep 1');
  });
}
